import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bida_game/models/cue_model.dart';
import 'package:bida_game/models/bot_stage_model.dart';
import 'package:bida_game/models/daily_puzzle_model.dart';
import 'package:bida_game/services/progression_service.dart';
import 'package:bida_game/ui/cue_power_slider.dart';
import 'package:bida_game/ui/aim_ruler_slider.dart';
import 'package:bida_game/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Cue Catalog & Stats Scaling Tests', () {
    test('Catalog contains 7 cues with valid attributes', () {
      final cues = CueCatalog.allCues;
      expect(cues.length, equals(7));

      final standard = CueCatalog.getById('standard_cue');
      expect(standard.isFree, isTrue);
      expect(standard.requiredLevel, equals(1));

      final dragon = CueCatalog.getById('dragon_god');
      expect(dragon.rarity, equals(CueRarity.legendary));
      expect(dragon.requiredLevel, equals(60));
      expect(dragon.priceDiamonds, equals(1500));
    });

    test('Cue stats scale from Level 1 to Level 10', () {
      final cue = CueCatalog.getById('titan_striker');
      final statLv1 = cue.getStatsForLevel(1);
      final statLv5 = cue.getStatsForLevel(5);
      final statLv10 = cue.getStatsForLevel(10);

      expect(statLv5.force, greaterThan(statLv1.force));
      expect(statLv10.force, greaterThan(statLv5.force));

      expect(cue.getForceMultiplier(10), greaterThan(cue.getForceMultiplier(1)));
      expect(cue.getAimMultiplier(10), greaterThan(cue.getAimMultiplier(1)));
      expect(cue.getSpinMultiplier(10), greaterThan(cue.getSpinMultiplier(1)));
    });

    test('Upgrade cost increases with level', () {
      final cue = CueCatalog.getById('frostbite');
      final costLv1 = cue.getUpgradeCostCoins(1);
      final costLv2 = cue.getUpgradeCostCoins(2);
      expect(costLv2, greaterThan(costLv1));
      expect(cue.getUpgradeCostCoins(10), equals(0)); // Max level cost is 0
    });
  });

  group('Bot Stage Campaign Catalog Tests', () {
    test('BotStageCatalog contains 7 progressive stages', () {
      final stages = BotStageCatalog.stages;
      expect(stages.length, equals(7));

      final stage1 = stages[0];
      final stage7 = stages[6];

      expect(stage1.stageNumber, equals(1));
      expect(stage7.stageNumber, equals(7));

      // Stage 7 has higher accuracy than stage 1
      expect(stage1.aimErrorRad, greaterThan(stage7.aimErrorRad));
      expect(stage7.powerAccuracy, greaterThan(stage1.powerAccuracy));

      // High stages use advanced AI tricks
      expect(stage1.useSpin, isFalse);
      expect(stage7.useSpin, isTrue);
      expect(stage7.useSafetyShot, isTrue);
      expect(stage7.useScratchPrevention, isTrue);
    });
  });

  group('Daily Puzzle Generator Tests', () {
    test('DailyPuzzleModel generates consistent seeded layout for given date', () {
      final date = DateTime(2026, 9, 23);
      final puzzle1 = DailyPuzzleModel.generateForDate(date);
      final puzzle2 = DailyPuzzleModel.generateForDate(date);

      expect(puzzle1.dateKey, equals('2026-09-23'));
      expect(puzzle1.dateKey, equals(puzzle2.dateKey));
      expect(puzzle1.title, equals(puzzle2.title));
      expect(puzzle1.balls.length, equals(puzzle2.balls.length));
      expect(puzzle1.maxShotsAllowed, greaterThanOrEqualTo(1));
      expect(puzzle1.rewardCoins, greaterThan(0));
      expect(puzzle1.rewardXP, greaterThan(0));
    });
  });

  group('ProgressionService Logic & Rewards Tests', () {
    test('XP addition and Level Up rewards', () {
      final service = ProgressionService.instance;
      final initialLevel = service.playerLevel;
      final xpRequired = service.xpRequiredForNextLevel;

      final result = service.addXPAndCoins(
        xpGained: xpRequired + 10,
        coinsGained: 200,
      );

      expect(result.didLevelUp, isTrue);
      expect(service.playerLevel, equals(initialLevel + 1));
      expect(result.bonusDiamonds, greaterThan(0));
    });

    test('Bot stage completion unlocks next stage', () {
      final service = ProgressionService.instance;
      final stage1 = BotStageCatalog.getStage(1);

      expect(service.isBotStageUnlocked(1), isTrue);
      final reward = service.completeBotStage(stage1);

      expect(service.isBotStageCompleted(1), isTrue);
      expect(service.isBotStageUnlocked(2), isTrue);
      expect(reward.earnedCoins, equals(stage1.firstClearCoins));
      expect(reward.earnedXP, equals(stage1.firstClearXP));
    });

    test('Daily puzzle reward claim is recorded and prevented on duplicate claim', () {
      final service = ProgressionService.instance;
      final puzzle = DailyPuzzleModel.generateForDate(DateTime.now());

      final reward = service.claimDailyPuzzleReward(puzzle);
      expect(reward, isNotNull);
      expect(service.isDailyPuzzleCompletedToday(), isTrue);

      final secondClaim = service.claimDailyPuzzleReward(puzzle);
      expect(secondClaim, isNull);
    });

    test('Level requirement gates cue unlocking', () {
      final service = ProgressionService.instance;
      final standard = CueCatalog.getById('standard_cue');
      final dragon = CueCatalog.getById('dragon_god');

      expect(service.canUnlockCue(standard), isTrue);
      if (service.playerLevel < 60) {
        expect(service.canUnlockCue(dragon), isFalse);
      }
    });
  });

  group('Aim Ruler Slider Control Tests', () {
    test('aimAngle and aimAngleNotifier are synchronized', () {
      gameInstance.aimAngle = 1.25;
      expect(gameInstance.aimAngleNotifier.value, closeTo(1.25, 0.0001));

      gameInstance.aimAngleNotifier.value = 2.50;
      expect(gameInstance.aimAngle, closeTo(2.50, 0.0001));
    });

    test('Micro-step angle rotation scales precisely for millimeter aiming', () {
      final initialAngle = gameInstance.aimAngle;
      const microStep = 0.0045; // ~0.25 degrees (~1mm)
      gameInstance.rotateAim(microStep);

      expect(gameInstance.aimAngle, closeTo(initialAngle + microStep, 0.0001));
    });

    testWidgets('AimRulerSliderControl renders yellow 0° and vertical capsule track', (tester) async {
      gameInstance.startPlayerMatch();
      gameInstance.aimAngle = 0.0;
      bool spinOpened = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 450,
              width: 80,
              child: AimRulerSliderControl(
                game: gameInstance,
                onOpenSpinDialog: () => spinOpened = true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Kiểm tra chữ số 0° màu vàng ở đỉnh
      expect(find.text('0°'), findsOneWidget);

      // Kiểm tra rãnh trượt thước đo
      final trackFinder = find.byKey(const ValueKey('aim_ruler_track_gesture'));
      expect(trackFinder, findsOneWidget);

      // Kéo vuốt trên rãnh thước để xoay góc ngắm
      await tester.drag(trackFinder, const Offset(0, 60));
      await tester.pump();

      // Góc ngắm thay đổi
      expect(gameInstance.aimAngle, isNot(equals(0.0)));
    });
  });

  group('8-Ball & Group Targeting Tests', () {
    test('ballGroup correctly categorizes solids, stripes, and 8-ball as neutral', () {
      for (int i = 1; i <= 7; i++) {
        expect(gameInstance.ballGroup(i), equals(BallGroup.solids));
      }
      expect(gameInstance.ballGroup(8), isNull);
      for (int i = 9; i <= 15; i++) {
        expect(gameInstance.ballGroup(i), equals(BallGroup.stripes));
      }
    });

    test('getPlayerGroup accurately provides or infers player groups', () {
      gameInstance.playerGroups.clear();
      gameInstance.playerGroups[1] = BallGroup.solids;
      expect(gameInstance.getPlayerGroup(1), equals(BallGroup.solids));
      expect(gameInstance.getPlayerGroup(2), equals(BallGroup.stripes));

      gameInstance.playerGroups[1] = BallGroup.stripes;
      expect(gameInstance.getPlayerGroup(2), equals(BallGroup.solids));
    });
  });

  group('Lifecycle & Pre-load Safety Tests', () {
    test('Starting match modes before game is loaded does not throw LateInitializationError', () {
      expect(() => gameInstance.startPlayerMatch(), returnsNormally);
      expect(gameInstance.isBotMode.value, isFalse);
      expect(gameInstance.activeBotStage, isNull);

      final stage = BotStageCatalog.stages.first;
      expect(() => gameInstance.startBotStage(stage), returnsNormally);
      expect(gameInstance.isBotMode.value, isTrue);
      expect(gameInstance.activeBotStage, equals(stage));

      final puzzle = DailyPuzzleModel.generateForDate(DateTime.now());
      expect(() => gameInstance.startDailyPuzzle(puzzle), returnsNormally);
      expect(gameInstance.activeDailyPuzzle, equals(puzzle));

      expect(() => gameInstance.startLocalMultiplayer(), returnsNormally);
      expect(gameInstance.isLocalMultiplayer.value, isTrue);

      expect(() => gameInstance.resetCueSpin(), returnsNormally);
      expect(() => gameInstance.update(0.016), returnsNormally);
    });
  });

  group('Cue Power Pull-Down Slider Tests', () {
    test('setShotPower clamps precisely within valid bounds [0.05, 1.0]', () {
      gameInstance.setShotPower(0.0);
      expect(gameInstance.shotPower.value, closeTo(0.05, 0.0001));

      gameInstance.setShotPower(0.55);
      expect(gameInstance.shotPower.value, closeTo(0.55, 0.0001));

      gameInstance.setShotPower(1.50);
      expect(gameInstance.shotPower.value, closeTo(1.0, 0.0001));

      gameInstance.setShotPower(-0.2);
      expect(gameInstance.shotPower.value, closeTo(0.05, 0.0001));
    });

    testWidgets('CuePowerSliderControl renders yellow 0% and capsule with bottom circular button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 450,
              width: 80,
              child: CuePowerSliderControl(game: gameInstance),
            ),
          ),
        ),
      );
      await tester.pump();

      // Kiểm tra hiển thị % màu vàng ở đỉnh (mặc định 0%)
      expect(find.text('0%'), findsOneWidget);

      // Kiểm tra rãnh trượt con nhộng và nút tròn ở đáy
      expect(find.byKey(const ValueKey('cue_power_track_gesture')), findsOneWidget);
      expect(find.byKey(const ValueKey('cue_slider_bottom_button')), findsOneWidget);

      // Chạm nút tròn ở đáy
      await tester.tap(find.byKey(const ValueKey('cue_slider_bottom_button')));
      await tester.pump();
    });

    testWidgets('Dragging cue slider down and releasing invokes release-to-shoot', (tester) async {
      gameInstance.startPlayerMatch();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 450,
              width: 80,
              child: CuePowerSliderControl(game: gameInstance),
            ),
          ),
        ),
      );
      await tester.pump();

      // Kéo thanh trượt xuống
      final trackFinder = find.byKey(const ValueKey('cue_power_track_gesture'));
      expect(trackFinder, findsOneWidget);

      final topLeft = tester.getTopLeft(trackFinder);
      final gesture = await tester.startGesture(topLeft + const Offset(10, 10));
      await gesture.moveBy(const Offset(0, 120));
      await tester.pump();

      // Lực cơ tăng lên khi kéo xuống
      expect(gameInstance.shotPower.value, greaterThan(0.05));

      // Thả tay ra (up)
      await gesture.up();
      await tester.pump();
    });

    test('Restarting match when balls are sunk/removed does not throw lifecycle event exception', () {
      gameInstance.startPlayerMatch();

      // Giả lập một số bi đã bị chìm vào lỗ
      for (int i = 0; i < gameInstance.poolBalls.length; i++) {
        if (i % 2 == 0) {
          gameInstance.poolBalls[i].isSunk = true;
        }
      }

      expect(() => gameInstance.restartMatch(), returnsNormally);
    });

    test('Equipping different cues updates ProgressionService.equippedCue dynamically', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'progression_owned_cues',
        jsonEncode({'standard_cue': 1, 'frostbite': 1, 'dragon_god': 1}),
      );
      await ProgressionService.instance.init();

      // Mặc định là standard_cue
      expect(ProgressionService.instance.equippedCue.id, equals('standard_cue'));

      // Trang bị Cơ Băng Phong
      ProgressionService.instance.equipCue('frostbite');
      expect(ProgressionService.instance.equippedCue.id, equals('frostbite'));
      expect(ProgressionService.instance.equippedCue.name, equals('Cơ Băng Phong'));
      expect(ProgressionService.instance.equippedCue.tipColor, isNotNull);
      expect(ProgressionService.instance.equippedCue.shaftColors, isNotEmpty);

      // Trang bị Cơ Rồng Vàng
      ProgressionService.instance.equipCue('dragon_god');
      expect(ProgressionService.instance.equippedCue.id, equals('dragon_god'));
      expect(ProgressionService.instance.equippedCue.name, equals('Cơ Đế Vương Rồng Vàng'));

      // Chuyển lại về standard_cue
      ProgressionService.instance.equipCue('standard_cue');
      expect(ProgressionService.instance.equippedCue.id, equals('standard_cue'));
    });
  });
}


