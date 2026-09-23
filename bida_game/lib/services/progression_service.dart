import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cue_model.dart';
import '../models/bot_stage_model.dart';
import '../models/daily_puzzle_model.dart';

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
  String _equippedCueId = 'standard_cue';
  final Map<String, int> _ownedCueLevels = {'standard_cue': 1};

  // Quản lý Ải Bot Campaign
  int _unlockedBotStage = 1;
  final Set<int> _completedBotStages = {};

  // Quản lý Nhiệm Vụ Thế Bi Hàng Ngày
  String? _lastDailyPuzzleDateCompleted;

  bool _isInitialized = false;

  int get playerLevel => _playerLevel;
  int get currentXP => _currentXP;
  int get coins => _coins;
  int get diamonds => _diamonds;
  String get equippedCueId => _equippedCueId;
  Map<String, int> get ownedCueLevels => Map.unmodifiable(_ownedCueLevels);
  int get unlockedBotStage => _unlockedBotStage;
  Set<int> get completedBotStages => Set.unmodifiable(_completedBotStages);
  String? get lastDailyPuzzleDateCompleted => _lastDailyPuzzleDateCompleted;
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
      _equippedCueId = prefs.getString('progression_equipped_cue') ?? 'standard_cue';
      _unlockedBotStage = prefs.getInt('progression_unlocked_bot_stage') ?? 1;
      _lastDailyPuzzleDateCompleted = prefs.getString('progression_last_daily_puzzle');

      final completedStagesList = prefs.getStringList('progression_completed_bot_stages');
      if (completedStagesList != null) {
        _completedBotStages.clear();
        for (final item in completedStagesList) {
          final val = int.tryParse(item);
          if (val != null) _completedBotStages.add(val);
        }
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
      await prefs.setString('progression_equipped_cue', _equippedCueId);
      await prefs.setInt('progression_unlocked_bot_stage', _unlockedBotStage);
      await prefs.setStringList(
        'progression_completed_bot_stages',
        _completedBotStages.map((e) => e.toString()).toList(),
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
}
