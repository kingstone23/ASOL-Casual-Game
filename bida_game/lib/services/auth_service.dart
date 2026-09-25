import 'dart:async';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'progression_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._internal();

  AuthService._internal();

  bool get _isFirebaseReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  FirebaseAuth? get _auth {
    if (!_isFirebaseReady) return null;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }
  
  static const String databaseUrl =
      'https://asol-game-default-rtdb.asia-southeast1.firebasedatabase.app';

  FirebaseDatabase? get _database {
    if (!_isFirebaseReady) return null;
    try {
      return FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: databaseUrl,
      );
    } catch (_) {
      try {
        return FirebaseDatabase.instance;
      } catch (_) {
        return null;
      }
    }
  }

  static const Set<String> adminEmails = {
    'baobro104@gmail.com',
    'admin@bida.com',
  };

  static bool checkIsAdmin({String? email, String? role, String? username}) {
    if (role == 'admin') return true;
    final em = email?.toLowerCase().trim() ?? '';
    final un = username?.toLowerCase().trim() ?? '';
    return adminEmails.contains(em) || un == 'admin';
  }

  User? _currentUser;
  String? _displayName;
  String _role = 'player'; // 'player' | 'admin'
  bool _isLoading = false;
  bool _isGuest = false;

  User? get currentUser => _currentUser ?? _auth?.currentUser;
  bool get isLoggedIn => currentUser != null || _isGuest;
  bool get isGuest => _isGuest;
  bool get isAdmin =>
      _role == 'admin' ||
      adminEmails.contains(currentUser?.email?.toLowerCase().trim());
  String get displayName =>
      _displayName ??
      currentUser?.displayName ??
      (currentUser?.email?.split('@').first ?? (_isGuest ? 'Cơ Thủ Khách' : 'Khách'));
  String get role => _role;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    // Tự động lắng nghe thay đổi chỉ số từ ProgressionService để đồng bộ tức thì lên Firebase
    ProgressionService.instance.addListener(() {
      if (isLoggedIn) {
        syncCurrentPlayerStats();
      }
    });

    if (!_isFirebaseReady || _auth == null) return;
    _currentUser = _auth!.currentUser;
    if (_currentUser != null) {
      _isGuest = _currentUser!.isAnonymous;
      await _fetchUserData(_currentUser!.uid);
    }
    _auth!.authStateChanges().listen((user) async {
      _currentUser = user;
      if (user != null) {
        _isGuest = user.isAnonymous;
        await _fetchUserData(user.uid);
      } else {
        if (!_isGuest) {
          _role = 'player';
          _displayName = null;
          ProgressionService.instance.resetToDefault();
        }
      }
      notifyListeners();
    });
  }

  Future<void> _fetchUserData(String uid) async {
    final email = _currentUser?.email?.toLowerCase().trim() ?? '';
    final isUserAdmin = checkIsAdmin(email: email, role: _role);

    if (isUserAdmin) {
      _role = 'admin';
      _displayName = _displayName ?? _currentUser?.displayName ?? 'Quản Trị Viên (Admin)';
      ProgressionService.instance.applyAdminPrivileges();
    }

    if (_database == null) return;
    try {
      // 1. Thử lấy dữ liệu tài khoản
      final snapshot = await _database!.ref('accounts/$uid').get();
      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
        _role = (data['role'] as String?) ?? (isUserAdmin ? 'admin' : 'player');
        _displayName = (data['displayName'] as String?) ?? (isUserAdmin ? 'Quản Trị Viên (Admin)' : _currentUser?.displayName);
      } else if (isUserAdmin) {
        // Khởi tạo node account cho admin nếu chưa có
        await _database!.ref('accounts/$uid').update({
          'uid': uid,
          'email': email.isNotEmpty ? email : 'baobro104@gmail.com',
          'username': email.isNotEmpty ? email.split('@').first : 'admin',
          'displayName': _displayName,
          'role': 'admin',
          'createdAt': ServerValue.timestamp,
        });
      }

      // 2. Thử lấy thông tin xếp hạng & chỉ số (level, coins, wins)
      DataSnapshot rankingSnapshot = await _database!.ref('ranking/$uid').get();
      if (!rankingSnapshot.exists && isUserAdmin) {
        rankingSnapshot = await _database!.ref('ranking/admin').get();
      }

      if (rankingSnapshot.exists && rankingSnapshot.value is Map) {
        final rankData = Map<dynamic, dynamic>.from(rankingSnapshot.value as Map);
        final level = (rankData['level'] as num?)?.toInt();
        final coins = (rankData['coins'] as num?)?.toInt();
        final wins = (rankData['wins'] as num?)?.toInt();
        final diamonds = (rankData['diamonds'] as num?)?.toInt();

        if (isUserAdmin) {
          ProgressionService.instance.applyAdminPrivileges();
        } else {
          ProgressionService.instance.applyCloudStats(
            level: level,
            coins: coins,
            wins: wins,
            diamonds: diamonds,
          );
        }
      } else if (isUserAdmin) {
        ProgressionService.instance.applyAdminPrivileges();
      }

      await syncCurrentPlayerStats();
    } catch (e) {
      debugPrint('Error fetching user data from Realtime Database: $e');
      if (isUserAdmin) {
        _role = 'admin';
        ProgressionService.instance.applyAdminPrivileges();
      }
    }
  }

  /// Đăng ký tài khoản mới
  /// Người dùng được thêm trực tiếp vào Firebase Authentication và Realtime Database
  Future<String?> register({
    required String emailOrUsername,
    required String password,
    required String displayName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _isGuest = false;
      final cleanInput = emailOrUsername.trim();
      final email = cleanInput.contains('@') ? cleanInput : '$cleanInput@bida.com';

      if (password.length < 6) {
        _isLoading = false;
        notifyListeners();
        return 'Mật khẩu phải có ít nhất 6 ký tự.';
      }

      if (displayName.trim().isEmpty) {
        _isLoading = false;
        notifyListeners();
        return 'Vui lòng nhập tên hiển thị.';
      }

      if (!_isFirebaseReady || _auth == null) {
        _isLoading = false;
        notifyListeners();
        return 'Firebase chưa được khởi tạo.';
      }

      // 1. Tạo trên Firebase Authentication
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(displayName.trim());
        _displayName = displayName.trim();
        _role = checkIsAdmin(email: email, username: cleanInput) ? 'admin' : 'player';

        if (_role == 'admin') {
          ProgressionService.instance.applyAdminPrivileges();
        }

        // 2. Lưu vào Realtime Database nhánh accounts & ranking
        final userMap = {
          'uid': user.uid,
          'email': email,
          'username': cleanInput,
          'displayName': _displayName,
          'role': _role,
          'createdAt': ServerValue.timestamp,
        };

        final rankingMap = {
          'uid': user.uid,
          'displayName': _displayName,
          'role': _role,
          'level': _role == 'admin' ? 99 : ProgressionService.instance.playerLevel,
          'coins': _role == 'admin' ? 9999999 : ProgressionService.instance.coins,
          'wins': _role == 'admin' ? 999 : ProgressionService.instance.totalWins,
          'updatedAt': ServerValue.timestamp,
        };

        if (_database != null) {
          try {
            await _database!.ref('accounts/${user.uid}').set(userMap);
            await _database!.ref('ranking/${user.uid}').set(rankingMap);
            if (_role == 'admin') {
              await _database!.ref('accounts/admin').set(userMap);
              await _database!.ref('ranking/admin').set(rankingMap);
            }
          } catch (dbErr) {
            debugPrint('Database write error during registration: $dbErr');
          }
        }
      }

      _isLoading = false;
      notifyListeners();
      return null; // Thành công
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      switch (e.code) {
        case 'email-already-in-use':
          return 'Tài khoản hoặc Email này đã tồn tại trên hệ thống.';
        case 'invalid-email':
          return 'Địa chỉ Email không hợp lệ.';
        case 'weak-password':
          return 'Mật khẩu quá yếu, vui lòng chọn mật khẩu phức tạp hơn.';
        default:
          return e.message ?? 'Đăng ký thất bại. Vui lòng thử lại.';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Đã xảy ra lỗi: $e';
    }
  }

  /// Đăng nhập tài khoản
  Future<String?> login({
    required String emailOrUsername,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _isGuest = false;
      if (!_isFirebaseReady || _auth == null) {
        _isLoading = false;
        notifyListeners();
        return 'Firebase chưa được khởi tạo.';
      }

      final cleanInput = emailOrUsername.trim();
      final email = cleanInput.contains('@') ? cleanInput : '$cleanInput@bida.com';
      final isLoggingAdmin = checkIsAdmin(email: email, username: cleanInput);

      UserCredential credential;
      try {
        credential = await _auth!.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (authErr) {
        // Tự động kích hoạt tài khoản admin nếu đăng nhập admin lần đầu và chưa tồn tại trong Auth
        if (isLoggingAdmin && (authErr.code == 'user-not-found' || authErr.code == 'invalid-credential')) {
          return await register(
            emailOrUsername: email,
            password: password,
            displayName: 'Quản Trị Viên (Admin)',
          );
        }
        rethrow;
      }

      final user = credential.user;
      if (user != null) {
        if (isLoggingAdmin) {
          _role = 'admin';
          _displayName = _displayName ?? user.displayName ?? 'Quản Trị Viên (Admin)';
          ProgressionService.instance.applyAdminPrivileges();
        }
        await _fetchUserData(user.uid);
      }

      _isLoading = false;
      notifyListeners();
      return null; // Thành công
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      switch (e.code) {
        case 'user-not-found':
          return 'Không tìm thấy tài khoản này trên hệ thống.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Sai mật khẩu hoặc thông tin đăng nhập.';
        case 'invalid-email':
          return 'Tên tài khoản hoặc Email không hợp lệ.';
        case 'user-disabled':
          return 'Tài khoản này đã bị tạm khóa.';
        default:
          return e.message ?? 'Đăng nhập thất bại. Vui lòng thử lại.';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Đã xảy ra lỗi: $e';
    }
  }

  /// Đăng nhập chế độ Chơi Ngay (Khách)
  Future<String?> loginAsGuest() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_isFirebaseReady && _auth != null) {
        try {
          final credential = await _auth!.signInAnonymously();
          final user = credential.user;
          if (user != null) {
            _currentUser = user;
            _isGuest = true;
            _displayName = 'Cơ Thủ #${math.Random().nextInt(9000) + 1000}';
            _role = 'player';
            try {
              await user.updateDisplayName(_displayName);
            } catch (_) {}
            _isLoading = false;
            notifyListeners();
            return null;
          }
        } catch (anonErr) {
          debugPrint('Firebase anonymous login note: $anonErr (using local guest mode)');
        }
      }

      // Guest mode offline / fallback
      _isGuest = true;
      _currentUser = null;
      _displayName = 'Cơ Thủ #${math.Random().nextInt(9000) + 1000}';
      _role = 'player';
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Không thể vào chế độ khách: $e';
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    if (_auth != null) {
      await _auth!.signOut();
    }
    _currentUser = null;
    _displayName = null;
    _role = 'player';
    _isGuest = false;
    ProgressionService.instance.resetToDefault();
    notifyListeners();
  }

  /// Đồng bộ level, coins, số trận thắng lên Realtime Database (nhánh ranking)
  Future<void> syncCurrentPlayerStats() async {
    if (!isLoggedIn || _currentUser == null || _database == null) return;
    try {
      final uid = _currentUser!.uid;
      final rankingRef = _database!.ref('ranking/$uid');
      final isUserAdmin = isAdmin;

      // Lấy chỉ số THỰC TẾ mới nhất từ ProgressionService
      final actualLevel = ProgressionService.instance.playerLevel;
      final actualCoins = ProgressionService.instance.coins;
      final actualWins = ProgressionService.instance.totalWins;

      // Nếu là Admin, lấy số thực tế (nếu chơi thắng thêm, kiếm thêm tiền thì lấy số lớn hơn)
      final level = isUserAdmin ? math.max(99, actualLevel) : actualLevel;
      final coins = isUserAdmin ? math.max(9999999, actualCoins) : actualCoins;
      final wins = isUserAdmin ? math.max(999, actualWins) : actualWins;

      final updateMap = {
        'uid': uid,
        'displayName': displayName,
        'role': _role,
        'level': level,
        'coins': coins,
        'wins': wins,
        'updatedAt': ServerValue.timestamp,
      };

      await rankingRef.update(updateMap);

      if (isUserAdmin) {
        try {
          await _database!.ref('ranking/admin').update(updateMap);
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Error syncing stats to ranking: $e');
    }
  }

  /// Lấy danh sách bảng xếp hạng theo phân loại ('level', 'coins', hoặc 'wins')
  Future<List<Map<String, dynamic>>> getRanking({
    required String category, // 'level' | 'coins' | 'wins'
    int limit = 25,
  }) async {
    final List<Map<String, dynamic>> results = [];
    final Map<String, Map<String, dynamic>> uniquePlayers = {};

    if (_database != null) {
      try {
        final snapshot = await _database!.ref('ranking').get();

        if (snapshot.exists && snapshot.value is Map) {
          final dataMap = Map<dynamic, dynamic>.from(snapshot.value as Map);
          dataMap.forEach((key, val) {
            if (val is Map) {
              final item = Map<String, dynamic>.from(val);
              item['id'] = key.toString();

              final isItemAdmin = item['role'] == 'admin' ||
                  checkIsAdmin(email: item['email'], username: item['username']);
              // Gộp các bản ghi của admin để không bị trùng lặp nhiều dòng trên BXH
              final dedupKey = isItemAdmin ? 'role_admin_leaderboard' : key.toString();

              if (!uniquePlayers.containsKey(dedupKey)) {
                uniquePlayers[dedupKey] = item;
              } else {
                final existing = uniquePlayers[dedupKey]!;
                final existingVal = (existing[category] as num?)?.toDouble() ?? 0.0;
                final currentVal = (item[category] as num?)?.toDouble() ?? 0.0;
                if (currentVal >= existingVal) {
                  uniquePlayers[dedupKey] = item;
                }
              }
            }
          });
        }
      } catch (e) {
        debugPrint('Error fetching ranking for $category: $e');
      }
    }

    results.addAll(uniquePlayers.values);

    // Luôn đảm bảo tài khoản đang đăng nhập phản ánh đúng chỉ số thực tế mới nhất
    if (isLoggedIn && _currentUser != null) {
      final myUid = _currentUser!.uid;
      final actualLevel = ProgressionService.instance.playerLevel;
      final actualCoins = ProgressionService.instance.coins;
      final actualWins = ProgressionService.instance.totalWins;

      final myLevel = isAdmin ? math.max(99, actualLevel) : actualLevel;
      final myCoins = isAdmin ? math.max(9999999, actualCoins) : actualCoins;
      final myWins = isAdmin ? math.max(999, actualWins) : actualWins;

      final myMap = {
        'id': myUid,
        'uid': myUid,
        'displayName': displayName,
        'role': _role,
        'level': myLevel,
        'coins': myCoins,
        'wins': myWins,
      };

      final existingIndex = results.indexWhere((r) =>
          r['uid'] == myUid ||
          r['id'] == myUid ||
          (isAdmin && (r['id'] == 'admin' || r['role'] == 'admin')));

      if (existingIndex >= 0) {
        final existingVal = (results[existingIndex][category] as num?)?.toDouble() ?? 0.0;
        final myVal = (myMap[category] as num?)?.toDouble() ?? 0.0;
        if (myVal >= existingVal) {
          results[existingIndex] = myMap;
        }
      } else {
        results.add(myMap);
      }
    }

    // Sắp xếp giảm dần (cao nhất đứng đầu)
    results.sort((a, b) {
      final valA = (a[category] as num?)?.toDouble() ?? 0.0;
      final valB = (b[category] as num?)?.toDouble() ?? 0.0;
      return valB.compareTo(valA);
    });

    if (results.length > limit) {
      return results.sublist(0, limit);
    }
    return results;
  }
}
