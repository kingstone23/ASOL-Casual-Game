import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cue_model.dart';
import '../models/bot_stage_model.dart';
import '../models/daily_puzzle_model.dart';
import '../models/achievement_model.dart';
import '../models/tournament_model.dart';

class MatchRewardResult {
  final int earnedXP;
  final int earnedCoins;
  final bool didLevelUp;
  final int oldLevel;
  final int newLevel;
  final int bonusDiamonds;
  final String? customMessage;

  const MatchRewardResult({
    required this.earnedXP,
    required this.earnedCoins,
    required this.didLevelUp,
    required this.oldLevel,
    required this.newLevel,
    required this.bonusDiamonds,
    this.customMessage,
  });
}

class ProgressionService extends ChangeNotifier {
  static final ProgressionService instance = ProgressionService._internal();

  ProgressionService._internal();

  int _playerLevel = 1;
  int _currentXP = 0;
  int _coins = 1200;
  int _diamonds = 30;
  int _totalWins = 0;
  String _equippedCueId = 'standard_cue';
  final Map<String, int> _ownedCueLevels = {'standard_cue': 1};

  // Quản lý Ải Bot Campaign
  int _unlockedBotStage = 1;
  final Set<int> _completedBotStages = {};

  // Quản lý Nhiệm Vụ Thế Bi Hàng Ngày
  String? _lastDailyPuzzleDateCompleted;

  // Quản lý Giải Đấu Tournament 6 Brackets
  int _currentTournamentBracket = 1;
  int _tournamentWins = 0;

  // Quản lý Thành Tựu & Huy Chương
  final Set<String> _unlockedAchievements = {};
  final Set<String> _claimedAchievements = {};
  final Set<String> _unlockedMedals = {};
  final List<String> _showcasedMedals = []; // Tối đa 5 huy chương hiển thị trên Profile

  bool _isInitialized = false;

  int get playerLevel => _playerLevel;
  int get currentXP => _currentXP;
  int get coins => _coins;
  int get diamonds => _diamonds;
  int get totalWins => _totalWins;
  String get equippedCueId => _equippedCueId;
  Map<String, int> get ownedCueLevels => Map.unmodifiable(_ownedCueLevels);
  int get unlockedBotStage => _unlockedBotStage;
  Set<int> get completedBotStages => Set.unmodifiable(_completedBotStages);
  String? get lastDailyPuzzleDateCompleted => _lastDailyPuzzleDateCompleted;
  int get currentTournamentBracket => _currentTournamentBracket;
  int get tournamentWins => _tournamentWins;
  Set<String> get unlockedAchievements => Set.unmodifiable(_unlockedAchievements);
  Set<String> get claimedAchievements => Set.unmodifiable(_claimedAchievements);
  Set<String> get unlockedMedals => Set.unmodifiable(_unlockedMedals);
  List<String> get showcasedMedals => List.unmodifiable(_showcasedMedals);
  bool get isInitialized => _isInitialized;

  CueModel get equippedCue => CueCatalog.getById(_equippedCueId);
  int get equippedCueLevel => _ownedCueLevels[_equippedCueId] ?? 1;

  int get xpRequiredForNextLevel => _playerLevel * 120;
  double get xpProgress => (_currentXP / xpRequiredForNextLevel).clamp(0.0, 1.0);

  bool isBotStageUnlocked(int stageNumber) => stageNumber <= _unlockedBotStage;
  bool isBotStageCompleted(int stageNumber) => _completedBotStages.contains(stageNumber);

  bool isDailyPuzzleCompletedToday() {
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return _lastDailyPuzzleDateCompleted == todayKey;
  }

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _playerLevel = prefs.getInt('progression_level') ?? 1;
      _currentXP = prefs.getInt('progression_xp') ?? 0;
      _coins = prefs.getInt('progression_coins') ?? 1200;
      _diamonds = prefs.getInt('progression_diamonds') ?? 30;
      _totalWins = prefs.getInt('progression_total_wins') ?? 0;
      _equippedCueId = prefs.getString('progression_equipped_cue') ?? 'standard_cue';
      _unlockedBotStage = prefs.getInt('progression_unlocked_bot_stage') ?? 1;
      _lastDailyPuzzleDateCompleted = prefs.getString('progression_last_daily_puzzle');
      _currentTournamentBracket = prefs.getInt('progression_tournament_bracket') ?? 1;
      _tournamentWins = prefs.getInt('progression_tournament_wins') ?? 0;

      final completedStagesList = prefs.getStringList('progression_completed_bot_stages');
      if (completedStagesList != null) {
        _completedBotStages.clear();
        for (final item in completedStagesList) {
          final val = int.tryParse(item);
          if (val != null) _completedBotStages.add(val);
        }
      }

      final achList = prefs.getStringList('progression_unlocked_achievements');
      if (achList != null) {
        _unlockedAchievements.addAll(achList);
      }
      final claimedList = prefs.getStringList('progression_claimed_achievements');
      if (claimedList != null) {
        _claimedAchievements.addAll(claimedList);
      }

      final medalList = prefs.getStringList('progression_unlocked_medals');
      if (medalList != null) {
        _unlockedMedals.addAll(medalList);
      }

      final showList = prefs.getStringList('progression_showcased_medals');
      if (showList != null) {
        _showcasedMedals.clear();
        _showcasedMedals.addAll(showList.take(5));
      }

      final ownedJson = prefs.getString('progression_owned_cues');
      if (ownedJson != null) {
        final decoded = jsonDecode(ownedJson) as Map<String, dynamic>;
        _ownedCueLevels.clear();
        decoded.forEach((key, val) {
          _ownedCueLevels[key] = (val as num).toInt();
        });
      }
      if (!_ownedCueLevels.containsKey('standard_cue')) {
        _ownedCueLevels['standard_cue'] = 1;
      }
      if (!_ownedCueLevels.containsKey(_equippedCueId)) {
        _equippedCueId = 'standard_cue';
      }

      checkAchievementsAndMedals();
    } catch (e) {
      debugPrint('Error loading progression data: $e');
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('progression_level', _playerLevel);
      await prefs.setInt('progression_xp', _currentXP);
      await prefs.setInt('progression_coins', _coins);
      await prefs.setInt('progression_diamonds', _diamonds);
      await prefs.setInt('progression_total_wins', _totalWins);
      await prefs.setString('progression_equipped_cue', _equippedCueId);
      await prefs.setInt('progression_unlocked_bot_stage', _unlockedBotStage);
      await prefs.setInt('progression_tournament_bracket', _currentTournamentBracket);
      await prefs.setInt('progression_tournament_wins', _tournamentWins);
      await prefs.setStringList(
        'progression_completed_bot_stages',
        _completedBotStages.map((e) => e.toString()).toList(),
      );
      await prefs.setStringList(
        'progression_unlocked_achievements',
        _unlockedAchievements.toList(),
      );
      await prefs.setStringList(
        'progression_claimed_achievements',
        _claimedAchievements.toList(),
      );
      await prefs.setStringList(
        'progression_unlocked_medals',
        _unlockedMedals.toList(),
      );
      await prefs.setStringList(
        'progression_showcased_medals',
        _showcasedMedals.take(5).toList(),
      );
      if (_lastDailyPuzzleDateCompleted != null) {
        await prefs.setString('progression_last_daily_puzzle', _lastDailyPuzzleDateCompleted!);
      }
      await prefs.setString('progression_owned_cues', jsonEncode(_ownedCueLevels));
    } catch (e) {
      debugPrint('Error saving progression data: $e');
    }
  }

  bool isCueOwned(String cueId) => _ownedCueLevels.containsKey(cueId);

  bool isCueEquipped(String cueId) => _equippedCueId == cueId;

  int getCueLevel(String cueId) => _ownedCueLevels[cueId] ?? 0;

  bool canUnlockCue(CueModel cue) => _playerLevel >= cue.requiredLevel;

  void addCoins(int amount) {
    if (amount <= 0) return;
    _coins += amount;
    _save();
    notifyListeners();
  }

  void addDiamonds(int amount) {
    if (amount <= 0) return;
    _diamonds += amount;
    _save();
    notifyListeners();
  }

  void recordWin() {
    _totalWins++;
    _save();
    notifyListeners();
  }

  /// Kích hoạt đặc quyền và chỉ số tài khoản Admin:
  /// Cấp độ 99, 9.999.999 Vàng, 99.999 Kim Cương, 999 Trận thắng,
  /// Mở khóa tất cả Ải Bot và sở hữu toàn bộ gậy Max Cấp (Lv.10).
  void applyAdminPrivileges() {
    _playerLevel = 99;
    _currentXP = 0;
    _coins = 9999999;
    _diamonds = 99999;
    _totalWins = 999;
    _unlockedBotStage = 7;
    for (int i = 1; i <= 7; i++) {
      _completedBotStages.add(i);
    }
    for (final cue in CueCatalog.allCues) {
      _ownedCueLevels[cue.id] = 10;
    }
    _equippedCueId = 'dragon_god';
    _save();
    notifyListeners();
  }

  /// Áp dụng dữ liệu đồng bộ từ Firebase Realtime Database cho người chơi
  void applyCloudStats({
    int? level,
    int? xp,
    int? coins,
    int? diamonds,
    int? wins,
    String? equippedCue,
  }) {
    bool hasChanged = false;
    if (level != null && level > 0 && level != _playerLevel) {
      _playerLevel = level;
      hasChanged = true;
    }
    if (xp != null && xp >= 0) {
      _currentXP = xp;
      hasChanged = true;
    }
    if (coins != null && coins >= 0 && coins != _coins) {
      _coins = coins;
      hasChanged = true;
    }
    if (diamonds != null && diamonds >= 0 && diamonds != _diamonds) {
      _diamonds = diamonds;
      hasChanged = true;
    }
    if (wins != null && wins >= 0 && wins != _totalWins) {
      _totalWins = wins;
      hasChanged = true;
    }
    if (equippedCue != null && CueCatalog.getById(equippedCue).id == equippedCue) {
      _equippedCueId = equippedCue;
      if (!_ownedCueLevels.containsKey(equippedCue)) {
        _ownedCueLevels[equippedCue] = 1;
      }
      hasChanged = true;
    }

    if (hasChanged) {
      _save();
      notifyListeners();
    }
  }

  /// Đặt lại chỉ số về mặc định khi đăng xuất
  void resetToDefault() {
    _playerLevel = 1;
    _currentXP = 0;
    _coins = 1200;
    _diamonds = 30;
    _totalWins = 0;
    _equippedCueId = 'standard_cue';
    _ownedCueLevels.clear();
    _ownedCueLevels['standard_cue'] = 1;
    _unlockedBotStage = 1;
    _completedBotStages.clear();
    _lastDailyPuzzleDateCompleted = null;
    _save();
    notifyListeners();
  }

  bool spendCoins(int amount) {
    if (amount <= 0) return true;
    if (_coins < amount) return false;
    _coins -= amount;
    _save();
    notifyListeners();
    return true;
  }

  bool spendDiamonds(int amount) {
    if (amount <= 0) return true;
    if (_diamonds < amount) return false;
    _diamonds -= amount;
    _save();
    notifyListeners();
    return true;
  }

  /// Mua gậy trong Shop
  bool buyCue(CueModel cue) {
    if (isCueOwned(cue.id)) return false;
    if (!canUnlockCue(cue)) return false;

    if (cue.priceDiamonds != null && cue.priceDiamonds! > 0) {
      if (!spendDiamonds(cue.priceDiamonds!)) return false;
    } else if (cue.priceCoins != null && cue.priceCoins! > 0) {
      if (!spendCoins(cue.priceCoins!)) return false;
    }

    _ownedCueLevels[cue.id] = 1;
    _equippedCueId = cue.id;
    _save();
    notifyListeners();
    return true;
  }

  /// Nâng cấp gậy lên cấp kế tiếp (Lv. 1 -> Lv. 10)
  bool upgradeCue(String cueId) {
    if (!isCueOwned(cueId)) return false;
    final currentLvl = _ownedCueLevels[cueId] ?? 1;
    if (currentLvl >= 10) return false;

    final cue = CueCatalog.getById(cueId);
    final cost = cue.getUpgradeCostCoins(currentLvl);

    if (!spendCoins(cost)) return false;

    _ownedCueLevels[cueId] = currentLvl + 1;
    _save();
    notifyListeners();
    return true;
  }

  /// Trang bị gậy
  void equipCue(String cueId) {
    if (!isCueOwned(cueId)) return;
    _equippedCueId = cueId;
    _save();
    notifyListeners();
  }

  /// Thêm XP và tính toán thăng cấp (Level Up)
  MatchRewardResult addXPAndCoins({
    required int xpGained,
    required int coinsGained,
  }) {
    final oldLevel = _playerLevel;
    _currentXP += xpGained;
    _coins += coinsGained;

    int bonusDiamonds = 0;
    bool didLevelUp = false;

    while (_currentXP >= xpRequiredForNextLevel) {
      _currentXP -= xpRequiredForNextLevel;
      _playerLevel++;
      didLevelUp = true;
      // Phần thưởng khi thăng cấp: Vàng + Kim Cương
      _coins += _playerLevel * 250;
      bonusDiamonds += 5;
      _diamonds += 5;
    }

    _save();
    notifyListeners();

    return MatchRewardResult(
      earnedXP: xpGained,
      earnedCoins: coinsGained,
      didLevelUp: didLevelUp,
      oldLevel: oldLevel,
      newLevel: _playerLevel,
      bonusDiamonds: bonusDiamonds,
    );
  }

  /// Thưởng trận đấu dựa trên kết quả Thắng / Thua và gậy trang bị
  MatchRewardResult handleMatchRewards({
    required bool isWinner,
    required int pottedBallsCount,
  }) {
    int baseXp = isWinner ? 140 : 40;
    int baseCoins = isWinner ? 300 : 50;

    baseXp += pottedBallsCount * 12;
    baseCoins += pottedBallsCount * 25;

    // Kỹ năng nội tại gậy:
    // Cơ Kim Ngưu: +10% Vàng thắng ván
    if (isWinner && _equippedCueId == 'golden_bull') {
      baseCoins = (baseCoins * 1.10).round();
    }
    // Cơ Đế Vương Rồng: Thua được trợ giá hoàn 50%
    if (!isWinner && _equippedCueId == 'dragon_god') {
      baseCoins = 150; // Hoàn trợ cấp an ủi lớn
    }

    return addXPAndCoins(
      xpGained: baseXp,
      coinsGained: baseCoins,
    );
  }

  /// Khấu trừ số tiền bị mất khi thua trận (không để âm dưới 0)
  int deductMatchLostCoins(int amount) {
    if (amount <= 0) return 0;
    final lost = _coins >= amount ? amount : _coins;
    _coins -= lost;
    _save();
    notifyListeners();
    return lost;
  }

  void recordLoss() {
    notifyListeners();
  }

  /// Xử lý tiền cược và phần thưởng riêng cho chế độ Đấu Mạng Local WiFi:
  /// - Người thắng: Nhận tiền cược (+ Vàng) và XP
  /// - Người thua: Bị trừ tiền cược (- Vàng) từ tài khoản
  MatchRewardResult handleMultiplayerMatchRewards({
    required bool isWinner,
    int betAmount = 500,
  }) {
    if (isWinner) {
      int gainedCoins = betAmount;
      if (_equippedCueId == 'golden_bull') {
        gainedCoins = (gainedCoins * 1.10).round();
      }
      final xpResult = addXPAndCoins(
        xpGained: 150,
        coinsGained: gainedCoins,
      );
      recordWin();
      return MatchRewardResult(
        earnedXP: 150,
        earnedCoins: gainedCoins,
        didLevelUp: xpResult.didLevelUp,
        oldLevel: xpResult.oldLevel,
        newLevel: xpResult.newLevel,
        bonusDiamonds: xpResult.bonusDiamonds,
        customMessage: 'THẮNG ĐẤU MẠNG LOCAL (+$gainedCoins VÀNG)',
      );
    } else {
      int lostCoins = betAmount;
      if (_equippedCueId == 'dragon_god') {
        lostCoins = (lostCoins * 0.5).round();
      }
      final actualLost = deductMatchLostCoins(lostCoins);
      recordLoss();
      return MatchRewardResult(
        earnedXP: 30,
        earnedCoins: -actualLost,
        didLevelUp: false,
        oldLevel: playerLevel,
        newLevel: playerLevel,
        bonusDiamonds: 0,
        customMessage: 'THUA ĐẤU MẠNG LOCAL (-$actualLost VÀNG)',
      );
    }
  }

  /// Trao thưởng khi người chơi vượt qua 1 Ải Bot Campaign
  MatchRewardResult completeBotStage(BotStageModel stage) {
    final isFirstClear = !_completedBotStages.contains(stage.stageNumber);
    if (isFirstClear) {
      _completedBotStages.add(stage.stageNumber);
      if (stage.stageNumber == _unlockedBotStage && _unlockedBotStage < 7) {
        _unlockedBotStage++;
      }
      if (stage.firstClearDiamonds > 0) {
        _diamonds += stage.firstClearDiamonds;
      }
      final result = addXPAndCoins(
        xpGained: stage.firstClearXP,
        coinsGained: stage.firstClearCoins,
      );
      _save();
      return MatchRewardResult(
        earnedXP: stage.firstClearXP,
        earnedCoins: stage.firstClearCoins,
        didLevelUp: result.didLevelUp,
        oldLevel: result.oldLevel,
        newLevel: result.newLevel,
        bonusDiamonds: stage.firstClearDiamonds + result.bonusDiamonds,
        customMessage: 'VƯỢT ẢI ${stage.stageNumber} LẦN ĐẦU THÀNH CÔNG!',
      );
    } else {
      // Vượt ải các lần sau nhận thưởng bình thường
      return addXPAndCoins(
        xpGained: (stage.firstClearXP * 0.4).round(),
        coinsGained: (stage.firstClearCoins * 0.35).round(),
      );
    }
  }

  /// Trao thưởng khi hoàn thành Nhiệm Vụ Thế Bi Hàng Ngày
  MatchRewardResult? claimDailyPuzzleReward(DailyPuzzleModel puzzle) {
    if (isDailyPuzzleCompletedToday()) {
      return null;
    }
    _lastDailyPuzzleDateCompleted = puzzle.dateKey;
    if (puzzle.rewardDiamonds > 0) {
      _diamonds += puzzle.rewardDiamonds;
    }
    final result = addXPAndCoins(
      xpGained: puzzle.rewardXP,
      coinsGained: puzzle.rewardCoins,
    );
    _save();
    return MatchRewardResult(
      earnedXP: puzzle.rewardXP,
      earnedCoins: puzzle.rewardCoins,
      didLevelUp: result.didLevelUp,
      oldLevel: result.oldLevel,
      newLevel: result.newLevel,
      bonusDiamonds: puzzle.rewardDiamonds + result.bonusDiamonds,
      customMessage: 'HOÀN THÀNH NHIỆM VỤ THẾ BI HÀNG NGÀY!',
    );
  }

  // --- QUẢN LÝ HUY CHƯƠNG & SHOWCASE (TỐI ĐA 5 HUY CHƯƠNG) ---
  bool isMedalUnlocked(String medalId) => _unlockedMedals.contains(medalId);
  bool isMedalShowcased(String medalId) => _showcasedMedals.contains(medalId);

  void unlockMedal(String medalId) {
    if (!_unlockedMedals.contains(medalId)) {
      _unlockedMedals.add(medalId);
      if (_showcasedMedals.length < 5 && !_showcasedMedals.contains(medalId)) {
        _showcasedMedals.add(medalId);
      }
      _save();
      notifyListeners();
    }
  }

  /// Bật/tắt ghim huy chương lên hồ sơ (Profile) - Tối đa 5 huy chương
  /// Trả về true nếu thành công, false nếu đã đạt giới hạn 5 huy chương
  bool toggleShowcaseMedal(String medalId) {
    if (!isMedalUnlocked(medalId)) return false;
    if (_showcasedMedals.contains(medalId)) {
      _showcasedMedals.remove(medalId);
      _save();
      notifyListeners();
      return true;
    } else {
      if (_showcasedMedals.length >= 5) {
        return false; // Đã đạt tối đa 5 huy chương
      }
      _showcasedMedals.add(medalId);
      _save();
      notifyListeners();
      return true;
    }
  }

  // --- QUẢN LÝ THÀNH TỰU (ACHIEVEMENTS) & NHẬN EXP ---
  bool isAchievementUnlocked(String id) => _unlockedAchievements.contains(id);
  bool isAchievementClaimed(String id) => _claimedAchievements.contains(id);

  void unlockAchievement(String id) {
    if (!_unlockedAchievements.contains(id)) {
      _unlockedAchievements.add(id);
      _save();
      notifyListeners();
    }
  }

  /// Nhận thưởng EXP cho thành tựu dựa trên độ khó
  MatchRewardResult? claimAchievement(String id) {
    final ach = AchievementCatalog.getById(id);
    if (ach == null) return null;
    if (!_unlockedAchievements.contains(id)) return null;
    if (_claimedAchievements.contains(id)) return null;

    _claimedAchievements.add(id);
    final result = addXPAndCoins(
      xpGained: ach.rewardXP,
      coinsGained: 0,
    );
    _save();
    return MatchRewardResult(
      earnedXP: ach.rewardXP,
      earnedCoins: 0,
      didLevelUp: result.didLevelUp,
      oldLevel: result.oldLevel,
      newLevel: result.newLevel,
      bonusDiamonds: result.bonusDiamonds,
      customMessage: 'NHẬN THƯỞNG THÀNH TỰU: ${ach.title} (+${ach.rewardXP} XP)!',
    );
  }

  /// Tự động kiểm tra và mở khóa các thành tựu và huy chương đủ điều kiện
  void checkAchievementsAndMedals() {
    bool changed = false;

    // Thành tựu thắng trận đầu
    if (_totalWins >= 1) {
      if (!_unlockedAchievements.contains('first_win')) {
        _unlockedAchievements.add('first_win');
        changed = true;
      }
      if (!_unlockedMedals.contains('bronze_champion')) {
        _unlockedMedals.add('bronze_champion');
        if (_showcasedMedals.length < 5 && !_showcasedMedals.contains('bronze_champion')) {
          _showcasedMedals.add('bronze_champion');
        }
        changed = true;
      }
    }

    // Tam liên thắng
    if (_totalWins >= 3 && !_unlockedAchievements.contains('win_streak_3')) {
      _unlockedAchievements.add('win_streak_3');
      changed = true;
    }

    // Sở hữu gậy
    if (_ownedCueLevels.length >= 2 && !_unlockedAchievements.contains('cue_enthusiast')) {
      _unlockedAchievements.add('cue_enthusiast');
      changed = true;
    }
    if (_ownedCueLevels.length >= 4 && !_unlockedAchievements.contains('cue_collector')) {
      _unlockedAchievements.add('cue_collector');
      changed = true;
    }

    // Gậy nâng cấp Lv.5+
    final hasCueLv5 = _ownedCueLevels.values.any((lvl) => lvl >= 5);
    if (hasCueLv5 && !_unlockedMedals.contains('cue_master')) {
      _unlockedMedals.add('cue_master');
      if (_showcasedMedals.length < 5 && !_showcasedMedals.contains('cue_master')) {
        _showcasedMedals.add('cue_master');
      }
      changed = true;
    }

    // Gậy nâng cấp Max Lv.10
    final hasCueLv10 = _ownedCueLevels.values.any((lvl) => lvl >= 10);
    if (hasCueLv10 && !_unlockedAchievements.contains('cue_level_max')) {
      _unlockedAchievements.add('cue_level_max');
      changed = true;
    }

    // Tài sản vàng
    if (_coins >= 20000 && !_unlockedMedals.contains('wealthy_striker')) {
      _unlockedMedals.add('wealthy_striker');
      if (_showcasedMedals.length < 5 && !_showcasedMedals.contains('wealthy_striker')) {
        _showcasedMedals.add('wealthy_striker');
      }
      changed = true;
    }
    if (_coins >= 25000 && !_unlockedAchievements.contains('rich_player')) {
      _unlockedAchievements.add('rich_player');
      changed = true;
    }
    if (_coins >= 100000 && _totalWins >= 50 && !_unlockedAchievements.contains('billiard_god')) {
      _unlockedAchievements.add('billiard_god');
      changed = true;
    }

    // Cấp độ người chơi
    if (_playerLevel >= 10) {
      if (!_unlockedAchievements.contains('reach_level_10')) {
        _unlockedAchievements.add('reach_level_10');
        changed = true;
      }
      if (!_unlockedMedals.contains('grandmaster')) {
        _unlockedMedals.add('grandmaster');
        if (_showcasedMedals.length < 5 && !_showcasedMedals.contains('grandmaster')) {
          _showcasedMedals.add('grandmaster');
        }
        changed = true;
      }
    }

    // Chiến dịch Bot Ải 7
    if (_completedBotStages.contains(7)) {
      if (!_unlockedAchievements.contains('bot_campaign_clear')) {
        _unlockedAchievements.add('bot_campaign_clear');
        changed = true;
      }
      if (!_unlockedMedals.contains('bot_slayer')) {
        _unlockedMedals.add('bot_slayer');
        if (_showcasedMedals.length < 5 && !_showcasedMedals.contains('bot_slayer')) {
          _showcasedMedals.add('bot_slayer');
        }
        changed = true;
      }
    }

    // Vô địch Tournament
    if (_tournamentWins >= 1) {
      if (!_unlockedAchievements.contains('tournament_champion_legend')) {
        _unlockedAchievements.add('tournament_champion_legend');
        changed = true;
      }
      if (!_unlockedMedals.contains('tournament_champion')) {
        _unlockedMedals.add('tournament_champion');
        if (_showcasedMedals.length < 5 && !_showcasedMedals.contains('tournament_champion')) {
          _showcasedMedals.add('tournament_champion');
        }
        changed = true;
      }
    }

    if (changed) {
      _save();
      notifyListeners();
    }
  }

  // --- QUẢN LÝ GIẢI ĐẤU TOURNAMENT 6 BRACKETS ---
  /// Trao thưởng sau khi người chơi thắng 1 Bracket Tournament
  MatchRewardResult completeTournamentBracket(TournamentBracketStage stage) {
    final isChampion = stage.bracketNumber == 6;

    final result = addXPAndCoins(
      xpGained: stage.xpReward,
      coinsGained: stage.coinReward,
    );
    recordWin();

    if (stage.bonusMedalId != null) {
      unlockMedal(stage.bonusMedalId!);
    }

    if (isChampion) {
      _tournamentWins++;
      _currentTournamentBracket = 1;
      unlockMedal('tournament_champion');
      unlockAchievement('tournament_champion_legend');
      if (!_showcasedMedals.contains('tournament_champion')) {
        if (_showcasedMedals.length < 5) {
          _showcasedMedals.add('tournament_champion');
        } else {
          _showcasedMedals[0] = 'tournament_champion';
        }
      }
      _save();
      return MatchRewardResult(
        earnedXP: stage.xpReward,
        earnedCoins: stage.coinReward,
        didLevelUp: result.didLevelUp,
        oldLevel: result.oldLevel,
        newLevel: result.newLevel,
        bonusDiamonds: 50 + result.bonusDiamonds,
        customMessage: '🏆 QUÁN QUÂN VÔ ĐỊCH TOURNAMENT 6 BRACKETS (+${stage.coinReward} VÀNG, CÚP VÀNG & THÀNH TỰU)!',
      );
    } else {
      _currentTournamentBracket = stage.bracketNumber + 1;
      _save();
      return MatchRewardResult(
        earnedXP: stage.xpReward,
        earnedCoins: stage.coinReward,
        didLevelUp: result.didLevelUp,
        oldLevel: result.oldLevel,
        newLevel: result.newLevel,
        bonusDiamonds: result.bonusDiamonds,
        customMessage: 'VƯỢT QUA ${stage.title} (TIẾN VÀO BRACKET $_currentTournamentBracket)!',
      );
    }
  }

  void resetTournament() {
    _currentTournamentBracket = 1;
    _save();
    notifyListeners();
  }
}
