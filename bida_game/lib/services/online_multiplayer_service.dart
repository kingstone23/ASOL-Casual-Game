import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'progression_service.dart';

enum OnlineConnectionState {
  disconnected,
  connecting,
  connected,
  findingMatch,
  waitingInRoom,
  inMatch,
}

class OnlineMultiplayerService extends ChangeNotifier {
  static final OnlineMultiplayerService instance = OnlineMultiplayerService._internal();

  OnlineMultiplayerService._internal() {
    _loadSavedClientInfo();
  }

  String defaultServerUrl = 'ws://127.0.0.1:8080';
  WebSocket? _socket;
  StreamSubscription? _socketSubscription;

  OnlineConnectionState connectionState = OnlineConnectionState.disconnected;
  bool isHost = false;
  String? currentRoomId;
  String? myClientId;
  String? _lastConnectedUrl;

  String opponentName = 'Đối thủ Online';
  int opponentLevel = 1;
  int opponentCoins = 1000;

  void Function(Map<String, dynamic> data)? onMessageReceived;
  void Function(String roomId, bool isHost)? onMatchStart;
  void Function(String roomId, bool isHost, Map<String, dynamic> state)? onReconnected;

  bool get isConnected =>
      connectionState == OnlineConnectionState.connected ||
      connectionState == OnlineConnectionState.waitingInRoom ||
      connectionState == OnlineConnectionState.inMatch;

  bool get isInMatch => connectionState == OnlineConnectionState.inMatch;

  Future<void> _loadSavedClientInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      myClientId = prefs.getString('online_client_id');
      if (myClientId == null) {
        myClientId = 'player_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (DateTime.now().microsecond % 9000))}';
        await prefs.setString('online_client_id', myClientId!);
      }
      _lastConnectedUrl = prefs.getString('online_server_url') ?? defaultServerUrl;
    } catch (_) {}
  }

  Future<void> _saveActiveMatch(String roomId, bool isHost) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_online_room_id', roomId);
      await prefs.setBool('active_online_is_host', isHost);
      if (_lastConnectedUrl != null) {
        await prefs.setString('online_server_url', _lastConnectedUrl!);
      }
    } catch (_) {}
  }

  Future<void> clearActiveMatch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('active_online_room_id');
      await prefs.remove('active_online_is_host');
    } catch (_) {}
  }

  Future<String?> getSavedActiveRoomId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('active_online_room_id');
    } catch (_) {
      return null;
    }
  }

  /// Kết nối tới máy chủ WebSocket
  Future<bool> connect({String? url}) async {
    final serverUrl = url ?? _lastConnectedUrl ?? defaultServerUrl;
    _lastConnectedUrl = serverUrl;
    await disconnect(keepRoomId: true);

    connectionState = OnlineConnectionState.connecting;
    notifyListeners();

    try {
      final uri = Uri.parse(serverUrl);
      _socket = await WebSocket.connect(uri.toString()).timeout(
        const Duration(seconds: 7),
      );

      connectionState = currentRoomId != null ? OnlineConnectionState.inMatch : OnlineConnectionState.connected;
      notifyListeners();

      _listenToSocket();
      sendProfile();

      // Nếu đang có ván đấu dở dang, thử kết nối lại ngay lập tức
      final savedRoom = await getSavedActiveRoomId();
      if (savedRoom != null && savedRoom.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final savedIsHost = prefs.getBool('active_online_is_host') ?? isHost;
        reconnectMatch(roomId: savedRoom, isHost: savedIsHost);
      }

      return true;
    } catch (e) {
      debugPrint('Lỗi kết nối WebSocket: $e');
      connectionState = OnlineConnectionState.disconnected;
      notifyListeners();
      return false;
    }
  }

  void _listenToSocket() {
    _socketSubscription = _socket?.listen(
      (dynamic data) {
        try {
          final json = jsonDecode(data.toString()) as Map<String, dynamic>;
          _handleServerMessage(json);
        } catch (e) {
          debugPrint('Lỗi decode message từ WebSocket server: $e');
        }
      },
      onDone: () {
        debugPrint('WebSocket server đã đóng kết nối hoặc socket ngắt');
        // Không xóa currentRoomId để cho phép tự động reconnect khi mở lại app!
        disconnect(keepRoomId: true);
      },
      onError: (err) {
        debugPrint('Lỗi kết nối WebSocket: $err');
        disconnect(keepRoomId: true);
      },
    );
  }

  void _handleServerMessage(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    switch (type) {
      case 'connected':
        myClientId ??= data['clientId']?.toString();
        break;

      case 'room_created':
        currentRoomId = data['roomId']?.toString();
        isHost = true;
        connectionState = OnlineConnectionState.waitingInRoom;
        notifyListeners();
        break;

      case 'room_joined':
        currentRoomId = data['roomId']?.toString();
        isHost = false;
        connectionState = OnlineConnectionState.waitingInRoom;
        notifyListeners();
        break;

      case 'opponent_joined':
        opponentName = data['opponentName']?.toString() ?? opponentName;
        opponentLevel = (data['opponentLevel'] as num?)?.toInt() ?? opponentLevel;
        opponentCoins = (data['opponentCoins'] as num?)?.toInt() ?? opponentCoins;
        notifyListeners();
        break;

      case 'match_start':
        currentRoomId = data['roomId']?.toString() ?? currentRoomId;
        connectionState = OnlineConnectionState.inMatch;
        if (currentRoomId != null) {
          _saveActiveMatch(currentRoomId!, isHost);
        }
        notifyListeners();
        onMatchStart?.call(currentRoomId ?? '', isHost);
        sendProfile();
        break;

      case 'match_found':
        currentRoomId = data['roomId']?.toString();
        isHost = data['role'] == 'host';
        opponentName = data['opponentName']?.toString() ?? opponentName;
        opponentLevel = (data['opponentLevel'] as num?)?.toInt() ?? opponentLevel;
        opponentCoins = (data['opponentCoins'] as num?)?.toInt() ?? opponentCoins;
        connectionState = OnlineConnectionState.inMatch;
        if (currentRoomId != null) {
          _saveActiveMatch(currentRoomId!, isHost);
        }
        notifyListeners();
        onMatchStart?.call(currentRoomId ?? '', isHost);
        sendProfile();
        break;

      case 'matchmaking_waiting':
        connectionState = OnlineConnectionState.findingMatch;
        notifyListeners();
        break;

      case 'matchmaking_cancelled':
        connectionState = OnlineConnectionState.connected;
        notifyListeners();
        break;

      // Reconnect thành công vào phòng cũ
      case 'reconnected_success':
        currentRoomId = data['roomId']?.toString() ?? currentRoomId;
        isHost = data['role'] == 'p1' || data['role'] == 'host';
        opponentName = data['opponentName']?.toString() ?? opponentName;
        opponentLevel = (data['opponentLevel'] as num?)?.toInt() ?? opponentLevel;
        opponentCoins = (data['opponentCoins'] as num?)?.toInt() ?? opponentCoins;
        connectionState = OnlineConnectionState.inMatch;
        if (currentRoomId != null) {
          _saveActiveMatch(currentRoomId!, isHost);
        }
        notifyListeners();
        onReconnected?.call(currentRoomId ?? '', isHost, data);
        onMessageReceived?.call(data);
        break;

      case 'reconnect_failed':
        clearActiveMatch();
        currentRoomId = null;
        if (connectionState == OnlineConnectionState.inMatch) {
          connectionState = OnlineConnectionState.connected;
        }
        notifyListeners();
        break;

      // Đối thủ ngắt kết nối tạm thời (trận đấu vẫn tiếp tục!)
      case 'opponent_disconnected':
        onMessageReceived?.call(data);
        break;

      // Đối thủ đã kết nối lại
      case 'opponent_reconnected':
        onMessageReceived?.call(data);
        break;

      // Đối thủ chủ động đầu hàng / thoát trận từ Settings (Xử thắng cho mình)
      case 'opponent_forfeited':
        clearActiveMatch();
        onMessageReceived?.call(data);
        break;

      case 'opponent_left':
        // Chỉ xử lý khi đang ở phòng chờ hoặc trận đã kết thúc
        if (connectionState != OnlineConnectionState.inMatch) {
          connectionState = OnlineConnectionState.connected;
          currentRoomId = null;
          notifyListeners();
        }
        onMessageReceived?.call(data);
        break;

      default:
        // Chuyển tiếp tới game loop xử lý (aim, spin, shoot, ball_in_hand, sync_balls, v.v.)
        onMessageReceived?.call(data);
        break;
    }
  }

  void sendJson(Map<String, dynamic> data) {
    if (_socket != null && _socket?.readyState == WebSocket.open) {
      try {
        _socket?.add(jsonEncode(data));
      } catch (e) {
        debugPrint('Lỗi gửi dữ liệu qua WebSocket: $e');
      }
    }
  }

  void sendProfile() {
    sendJson({
      'type': 'set_profile',
      'clientId': myClientId,
      'name': AuthService.instance.displayName,
      'level': ProgressionService.instance.playerLevel,
      'coins': ProgressionService.instance.coins,
      'showcasedMedals': ProgressionService.instance.showcasedMedals,
    });
  }

  void createRoom() {
    sendProfile();
    sendJson({'type': 'create_room'});
  }

  void joinRoom(String roomId) {
    sendProfile();
    sendJson({'type': 'join_room', 'roomId': roomId.trim()});
  }

  void startQuickMatch() {
    sendProfile();
    sendJson({'type': 'quick_match'});
  }

  void cancelQuickMatch() {
    sendJson({'type': 'cancel_matchmaking'});
  }

  void reconnectMatch({required String roomId, required bool isHost}) {
    sendProfile();
    sendJson({
      'type': 'reconnect_match',
      'roomId': roomId.trim(),
      'clientId': myClientId,
      'role': isHost ? 'p1' : 'p2',
    });
  }

  /// Đầu hàng / Rời trận đấu có xác nhận từ Settings (Xử thua cho mình)
  void forfeitMatch() {
    final roomId = currentRoomId;
    if (roomId != null) {
      sendJson({
        'type': 'forfeit',
        'roomId': roomId,
      });
    }
    clearActiveMatch();
    currentRoomId = null;
    if (connectionState == OnlineConnectionState.inMatch) {
      connectionState = OnlineConnectionState.connected;
    }
    notifyListeners();
  }

  void sendAim({required double angle, required double power}) {
    sendJson({'type': 'aim', 'angle': angle, 'power': power});
  }

  void sendSpin({required double dx, required double dy}) {
    sendJson({'type': 'spin', 'dx': dx, 'dy': dy});
  }

  void sendShoot({required double power}) {
    sendJson({'type': 'shoot', 'power': power});
  }

  void sendBallInHand({required double x, required double y, bool placed = false}) {
    sendJson({'type': 'ball_in_hand', 'x': x, 'y': y, 'placed': placed});
  }

  void sendSyncBalls(List<Map<String, dynamic>> balls) {
    sendJson({'type': 'sync_balls', 'balls': balls});
  }

  void sendRestart() {
    sendJson({'type': 'restart'});
  }

  Future<void> disconnect({bool keepRoomId = false}) async {
    try {
      await _socketSubscription?.cancel();
      _socketSubscription = null;
      await _socket?.close();
      _socket = null;
    } catch (_) {}

    connectionState = OnlineConnectionState.disconnected;
    if (!keepRoomId) {
      currentRoomId = null;
      isHost = false;
      opponentName = 'Đối thủ Online';
      clearActiveMatch();
    }
    notifyListeners();
  }
}
