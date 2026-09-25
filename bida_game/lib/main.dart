import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Transform;
import 'package:forge2d/forge2d.dart' as forge2d;

import 'models/cue_model.dart';
import 'models/bot_stage_model.dart';
import 'models/daily_puzzle_model.dart';
import 'services/progression_service.dart';
import 'services/local_multiplayer_service.dart';
import 'ui/player_profile_bar.dart';
import 'ui/bot_stages_dialog.dart';
import 'ui/daily_puzzle_dialog.dart';
import 'ui/local_multiplayer_dialog.dart';
import 'ui/aim_ruler_slider.dart';

enum BallGroup { solids, stripes }

// Khởi tạo instance của game ở ngoài cùng để UI có thể lắng nghe trạng thái (Turn-base)
final BilliardGame gameInstance = BilliardGame();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProgressionService.instance.init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF071B16),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          secondary: Color(0xFF00B0FF),
          surface: Color(0xFF142E25),
          onSurface: Colors.white,
        ),
      ),
      home: const BilliardHome(),
    ),
  );
}

class BilliardHome extends StatefulWidget {
  const BilliardHome({super.key});

  @override
  State<BilliardHome> createState() => _BilliardHomeState();
}

class _BilliardHomeState extends State<BilliardHome> {
  bool showGame = false;

  void _startPlayerMatch() {
    gameInstance.startPlayerMatch();
    setState(() => showGame = true);
  }

  void _startBotStage(BotStageModel stage) {
    gameInstance.startBotStage(stage);
    setState(() => showGame = true);
  }

  void _startDailyPuzzle(DailyPuzzleModel puzzle) {
    gameInstance.startDailyPuzzle(puzzle);
    setState(() => showGame = true);
  }

  void _startLocalMultiplayerMatch() {
    gameInstance.startLocalMultiplayer();
    setState(() => showGame = true);
  }

  @override
  Widget build(BuildContext context) {
    if (showGame) {
      return _buildGameScreen(
        context,
        onHome: () => setState(() => showGame = false),
      );
    }
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF071B16), Color(0xFF0E5B3A), Color(0xFF06251C)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth >= 540;
              final compact = constraints.maxHeight < 420 || constraints.maxWidth < 700;

              return Column(
                children: [
                  // --- THANH TRẠNG THÁI TRÊN CÙNG (KHÔNG ĐÈ NỘI DUNG THẺ) ---
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 12 : 20,
                      vertical: compact ? 4 : 8,
                    ),
                    child: Row(
                      children: [
                        if (isLandscape) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFB77A35).withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                  ),
                                  child: Image.asset('assets/images/ball_8.png'),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  '8 POOL CASUAL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                        ],
                        // Thanh thông tin người chơi (Cấp, Vàng, Kim Cương, Nút Shop)
                        Expanded(
                          child: Align(
                            alignment: isLandscape ? Alignment.centerRight : Alignment.center,
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: PlayerProfileBar(compact: true),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- THẺ BIDA NỈ XANH VIỀN GỖ VÀNG CỔ ĐIỂN (CHUẨN MOBILE, KHÔNG TRÀN MÀN HÌNH) ---
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 10 : 20,
                          vertical: compact ? 4 : 10,
                        ),
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: isLandscape ? 720 : 440,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: compact ? 14 : 24,
                            vertical: compact ? 12 : 22,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF11633F),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFB77A35),
                              width: compact ? 4.0 : 6.0,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: isLandscape
                              ? _buildLandscapeMenuContent(compact)
                              : _buildPortraitMenuContent(compact),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// NỘI DUNG GIAO DIỆN NGANG (LANDSCAPE - CHUẨN ĐIỆN THOẠI KHÔNG CUỘN)
  Widget _buildLandscapeMenuContent(bool compact) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Cột Trái: Logo Bi 8 + Tên Game + Subtitle
        SizedBox(
          width: compact ? 190 : 225,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: compact ? 52 : 68,
                height: compact ? 52 : 68,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  border: Border.all(color: Colors.white70, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 10),
                  ],
                ),
                child: Image.asset('assets/images/ball_8.png'),
              ),
              SizedBox(height: compact ? 6 : 10),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '8 POOL BILLIARDS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 18 : 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'CHOOSE YOUR MATCH',
                style: TextStyle(
                  color: Color(0xFFFFD166),
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: compact ? 12 : 20),

        // Cột Phải: 4 Nút chế độ xếp dạng 2x2 Grid vừa vặn tuyệt đối
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildMenuButton(
                      icon: Icons.people,
                      label: 'P1 vs P2 (CÙNG MÁY)',
                      detail: '2 người trên 1 thiết bị',
                      background: const Color(0xFF1D4ED8),
                      onPressed: _startPlayerMatch,
                      compact: compact,
                    ),
                  ),
                  SizedBox(width: compact ? 8 : 12),
                  Expanded(
                    child: _buildMenuButton(
                      icon: Icons.wifi_tethering,
                      label: 'ĐẤU MẠNG LOCAL',
                      detail: 'Chung mạng WiFi / Hotspot',
                      background: const Color(0xFF00897B),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => LocalMultiplayerDialog(
                            onConnected: _startLocalMultiplayerMatch,
                          ),
                        );
                      },
                      compact: compact,
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 8 : 10),
              Row(
                children: [
                  Expanded(
                    child: _buildMenuButton(
                      icon: Icons.military_tech,
                      label: '7 ẢI THỬ THÁCH BOT',
                      detail: 'Độ khó tăng theo cấp gậy Shop',
                      background: const Color(0xFFE65100),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => BotStagesDialog(
                            onSelectStage: _startBotStage,
                          ),
                        );
                      },
                      compact: compact,
                    ),
                  ),
                  SizedBox(width: compact ? 8 : 12),
                  Expanded(
                    child: _buildMenuButton(
                      icon: Icons.event_note,
                      label: 'THẾ BI HÀNG NGÀY',
                      detail: '1 thế bi / ngày • Quà lớn',
                      background: const Color(0xFF7B1FA2),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => DailyPuzzleDialog(
                            onStartPuzzle: _startDailyPuzzle,
                          ),
                        );
                      },
                      compact: compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// NỘI DUNG GIAO DIỆN DỌC (PORTRAIT)
  Widget _buildPortraitMenuContent(bool compact) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
            border: Border.all(color: Colors.white70, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 10),
            ],
          ),
          child: Image.asset('assets/images/ball_8.png'),
        ),
        const SizedBox(height: 8),
        const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '8 POOL BILLIARDS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'CHOOSE YOUR MATCH',
          style: TextStyle(
            color: Color(0xFFFFD166),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 14),
        _buildMenuButton(
          icon: Icons.people,
          label: 'P1 vs P2 (CÙNG MÁY)',
          detail: '2 người chơi trên 1 thiết bị',
          background: const Color(0xFF1D4ED8),
          onPressed: _startPlayerMatch,
          compact: compact,
        ),
        const SizedBox(height: 8),
        _buildMenuButton(
          icon: Icons.wifi_tethering,
          label: 'ĐẤU MẠNG LOCAL (WIFI)',
          detail: 'Chơi 2 máy chung WiFi / Hotspot',
          background: const Color(0xFF00897B),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => LocalMultiplayerDialog(
                onConnected: _startLocalMultiplayerMatch,
              ),
            );
          },
          compact: compact,
        ),
        const SizedBox(height: 8),
        _buildMenuButton(
          icon: Icons.military_tech,
          label: '7 ẢI THỬ THÁCH BOT',
          detail: 'Độ khó tăng dần theo cấp gậy Shop',
          background: const Color(0xFFE65100),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => BotStagesDialog(
                onSelectStage: _startBotStage,
              ),
            );
          },
          compact: compact,
        ),
        const SizedBox(height: 8),
        _buildMenuButton(
          icon: Icons.event_note,
          label: 'THẾ BI HÀNG NGÀY',
          detail: 'Nhiệm vụ 1 thế bi ngẫu nhiên/ngày',
          background: const Color(0xFF7B1FA2),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => DailyPuzzleDialog(
                onStartPuzzle: _startDailyPuzzle,
              ),
            );
          },
          compact: compact,
        ),
      ],
    );
  }
}

/// Nút menu 4 màu phong cách cổ điển, co giãn tối ưu cho Mobile
Widget _buildMenuButton({
  required IconData icon,
  required String label,
  required String detail,
  required Color background,
  required VoidCallback onPressed,
  bool compact = false,
}) {
  return SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 14,
          vertical: compact ? 8 : 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
      ),
      child: Row(
        children: [
          Icon(icon, size: compact ? 22 : 26),
          SizedBox(width: compact ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: compact ? 13 : 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  detail,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: compact ? 9.5 : 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: compact ? 18 : 22),
        ],
      ),
    ),
  );
}

Widget _buildGameScreen(BuildContext context, {required VoidCallback onHome}) {
  return Scaffold(
    backgroundColor: const Color(0xFF121212),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          final compactLayout = screenWidth < 900 || screenHeight < 520;
          final ultraCompact = screenWidth < 720 || screenHeight < 390;

          final screenPadding = (screenWidth * 0.012).clamp(
            ultraCompact ? 3.0 : 5.0,
            12.0,
          );
          final topBarSpacing = ultraCompact ? 3.0 : (compactLayout ? 5.0 : 8.0);

          return Center(
            child: Padding(
              padding: EdgeInsets.all(screenPadding),
              child: Stack(
                children: [
                  Column(
                    children: [
                      _buildControlBar(
                        context,
                        compact: compactLayout,
                        ultraCompact: ultraCompact,
                        onHome: onHome,
                      ),
                      SizedBox(height: topBarSpacing),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildPowerControl(
                              compact: compactLayout,
                              ultraCompact: ultraCompact,
                            ),
                            SizedBox(width: ultraCompact ? 4 : (compactLayout ? 6 : 10)),
                            Expanded(
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio: 2 / 1,
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          ultraCompact ? 12 : 20,
                                        ),
                                        child: GameWidget(game: gameInstance),
                                      ),
                                      _buildRackOverlay(onHome: onHome),
                                      Positioned(
                                        bottom: ultraCompact ? 5 : 10,
                                        left: 0,
                                        right: 0,
                                        child: ValueListenableBuilder<String>(
                                          valueListenable:
                                              gameInstance.ruleMessage,
                                          builder: (context, message, child) =>
                                              Center(
                                                child: DecoratedBox(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.72),
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: ultraCompact ? 8 : 12,
                                                          vertical: ultraCompact ? 3 : 6,
                                                        ),
                                                    child: Text(
                                                      message,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: ultraCompact ? 10.5 : 12.5,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: ultraCompact ? 4 : (compactLayout ? 6 : 10)),
                            _buildRightSideControls(
                              context,
                              compact: compactLayout,
                              ultraCompact: ultraCompact,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

// Widget tổ hợp cột điều khiển bên phải: Thanh Trượt Thước Đo Vi Chỉnh Góc Bắn + Nút Áp-phê Xoáy Chuẩn 8 Ball Pool
Widget _buildRightSideControls(
  BuildContext context, {
  bool compact = false,
  bool ultraCompact = false,
}) {
  return AimRulerSliderControl(
    game: gameInstance,
    compact: compact,
    ultraCompact: ultraCompact,
    onOpenSpinDialog: () {
      if (!gameInstance.canUserControl) return;
      _showCueSpinDialog(context);
    },
  );
}

Widget _buildPowerControl({bool compact = false, bool ultraCompact = false}) {
  final controlWidth = ultraCompact ? 36.0 : (compact ? 44.0 : 52.0);
  return Container(
    width: controlWidth,
    padding: EdgeInsets.symmetric(
      horizontal: ultraCompact ? 2.5 : (compact ? 4 : 5),
      vertical: ultraCompact ? 4 : (compact ? 6 : 8),
    ),
    decoration: BoxDecoration(
      color: const Color(0xFF1B2026),
      borderRadius: BorderRadius.circular(ultraCompact ? 10 : 14),
      border: Border.all(color: Colors.white24, width: 1.0),
      boxShadow: const [
        BoxShadow(
          color: Colors.black45,
          blurRadius: 8,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (details) {
        if (!gameInstance.canUserControl) {
          return;
        }
        gameInstance.beginPowerDrag(details.localPosition.dy);
      },
      onPanUpdate: (details) {
        if (!gameInstance.canUserControl) {
          return;
        }
        gameInstance.updatePowerDrag(details.localPosition.dy);
      },
      onPanEnd: (_) {
        if (!gameInstance.canUserControl) {
          return;
        }
        gameInstance.endPowerDrag();
        gameInstance.shootWithPower();
      },
      onPanCancel: () {
        if (!gameInstance.canUserControl) {
          return;
        }
        gameInstance.endPowerDrag();
      },
      child: ValueListenableBuilder<double>(
        valueListenable: gameInstance.shotPower,
        builder: (context, power, child) {
          final powerColor = power > 0.80
              ? Colors.redAccent
              : power > 0.45
                  ? Colors.amber
                  : const Color(0xFF00E676);

          return Column(
            children: [
              Icon(
                Icons.flash_on,
                color: powerColor,
                size: ultraCompact ? 13 : (compact ? 15 : 18),
              ),
              const SizedBox(height: 1),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ultraCompact ? 2 : 4,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: powerColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: powerColor.withValues(alpha: 0.6),
                    width: 0.7,
                  ),
                ),
                child: Text(
                  '${(power * 100).round()}%',
                  style: TextStyle(
                    color: powerColor,
                    fontSize: ultraCompact ? 8.0 : (compact ? 9.0 : 10.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: ultraCompact ? 3 : 5),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Thanh đo lực neon
                    Container(
                      width: ultraCompact ? 5.5 : (compact ? 7.0 : 8.5),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: Colors.white24, width: 0.6),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2.5),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(color: Colors.white10),
                            FractionallySizedBox(
                              heightFactor: power,
                              widthFactor: 1.0,
                              alignment: Alignment.bottomCenter,
                              child: DecoratedBox(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Color(0xFF00E676),
                                      Colors.amber,
                                      Colors.redAccent,
                                    ],
                                    stops: [0.0, 0.6, 1.0],
                                  ),
                                ),
                              ),
                            ),
                            for (var mark = 1; mark < 10; mark++)
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment(0, 1.0 - mark / 5.0),
                                  child: Container(
                                    height: 1,
                                    color: Colors.black45,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: ultraCompact ? 3 : (compact ? 4 : 6)),
                    // Cây cơ bida tương tác - lún sâu theo lực
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final trackHeight = constraints.maxHeight;
                          // Khi tăng lực từ 5% -> 100%, cây cơ lún sâu xuống dọc theo thanh lực
                          final maxTravel = trackHeight * 0.72;
                          final normalizedPower =
                              ((power - 0.05) / 0.95).clamp(0.0, 1.0);
                          final pullOffset = normalizedPower * maxTravel;

                          final stickWidth = ultraCompact ? 10.0 : (compact ? 12.0 : 15.0);

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                // Rãnh cơ bóng mờ tinh tế
                                Container(
                                  width: stickWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.black38,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.white10,
                                      width: 0.6,
                                    ),
                                  ),
                                ),
                                // Vệt sáng năng lượng chạy phía trên đầu cơ khi lún xuống
                                if (pullOffset > 2)
                                  Positioned(
                                    top: 0,
                                    height: pullOffset,
                                    width: stickWidth * 0.65,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            powerColor.withValues(alpha: 0.12),
                                            powerColor.withValues(alpha: 0.70),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                // Cây cơ di chuyển lún sâu xuống theo lực kéo
                                Transform.translate(
                                  offset: Offset(0, pullOffset),
                                  child: ListenableBuilder(
                                    listenable: ProgressionService.instance,
                                    builder: (context, _) {
                                      final equippedCue =
                                          ProgressionService.instance.equippedCue;
                                      return _CueStickWidget(
                                        height: trackHeight,
                                        width: stickWidth,
                                        cue: equippedCue,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: ultraCompact ? 3 : 5),
              // Chữ LỰC xoay xuôi chuẩn ngang
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ultraCompact ? 3 : 5,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xDD15191E),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: Colors.white24, width: 0.7),
                ),
                child: Text(
                  'LỰC',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ultraCompact ? 8.0 : (compact ? 9.0 : 10.0),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class _CueStickWidget extends StatelessWidget {
  final double height;
  final double width;
  final CueModel? cue;
  const _CueStickWidget({required this.height, this.width = 16.0, this.cue});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _VerticalCueStickPainter(cue: cue),
    );
  }
}

class _VerticalCueStickPainter extends CustomPainter {
  final CueModel? cue;
  _VerticalCueStickPainter({this.cue});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centerX = w / 2;

    final topR = (w * 0.22).clamp(2.5, 3.8);
    final botR = (w * 0.42).clamp(5.0, 7.5);

    double radiusAt(double y) => topR + (botR - topR) * (y / h);

    void drawSection({
      required double yTop,
      required double yBot,
      required List<Color> colors,
      List<double>? stops,
    }) {
      final rTop = radiusAt(yTop);
      final rBot = radiusAt(yBot);
      final path = Path()
        ..moveTo(centerX - rTop, yTop)
        ..lineTo(centerX + rTop, yTop)
        ..lineTo(centerX + rBot, yBot)
        ..lineTo(centerX - rBot, yBot)
        ..close();

      final maxR = math.max(rTop, rBot);
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: colors,
          stops: stops,
        ).createShader(
          Rect.fromLTWH(centerX - maxR, yTop, maxR * 2, yBot - yTop),
        );

      canvas.drawPath(path, paint);
    }

    // A. Đầu lơ (Chalk tip) ở trên cùng: y = 0 -> y = 7
    final tipH = 7.0;
    final tipR = radiusAt(tipH);
    final tipPath = Path()
      ..moveTo(centerX - radiusAt(0), 0)
      ..lineTo(centerX + radiusAt(0), 0)
      ..lineTo(centerX + tipR, tipH)
      ..lineTo(centerX - tipR, tipH)
      ..close();
    final tipColor = cue?.tipColor ?? const Color(0xFF26A69A);
    canvas.drawPath(
      tipPath,
      Paint()
        ..shader = LinearGradient(
          colors: [
            tipColor,
            tipColor.withValues(alpha: 0.8),
            const Color(0xFF004D40),
          ],
        ).createShader(Rect.fromLTWH(centerX - tipR, 0, tipR * 2, tipH)),
    );

    // B. Phíp cơ (Ferrule): y = 7 -> y = 17
    drawSection(
      yTop: 7,
      yBot: 17,
      colors: const [Color(0xFFFFFFFF), Color(0xFFE8E8E8), Color(0xFFBDBDBD)],
    );

    // C. Ngọn cơ gỗ phong (Shaft): y = 17 -> y = h * 0.58
    final shaftBot = h * 0.58;
    drawSection(
      yTop: 17,
      yBot: shaftBot,
      colors: cue?.shaftColors ?? const [
        Color(0xFFFDE8C4),
        Color(0xFFDDB075),
        Color(0xFFB58045),
        Color(0xFF8D5B28),
      ],
      stops: cue != null ? null : const [0.0, 0.35, 0.75, 1.0],
    );

    // D. Ren nối kim loại (Joint collar): y = shaftBot -> y = shaftBot + 12
    drawSection(
      yTop: shaftBot,
      yBot: shaftBot + 3,
      colors: const [Color(0xFFEEEEEE), Color(0xFF9E9E9E), Color(0xFF616161)],
    );
    drawSection(
      yTop: shaftBot + 3,
      yBot: shaftBot + 9,
      colors: const [Color(0xFF303030), Color(0xFF151515), Color(0xFF000000)],
    );
    drawSection(
      yTop: shaftBot + 9,
      yBot: shaftBot + 12,
      colors: const [Color(0xFFEEEEEE), Color(0xFF9E9E9E), Color(0xFF616161)],
    );

    // E. Chuôi cơ (Butt Sleeve): y = shaftBot + 12 -> y = h - 14
    final buttTop = shaftBot + 12;
    final buttBot = h - 14;
    drawSection(
      yTop: buttTop,
      yBot: buttBot,
      colors: cue?.handleColors ?? const [
        Color(0xFF2979FF),
        Color(0xFF1565C0),
        Color(0xFF0D47A1),
        Color(0xFF062B66),
      ],
      stops: cue != null ? null : const [0.0, 0.3, 0.7, 1.0],
    );

    // Họa tiết hoa văn chuôi cơ
    final wrapTop = buttTop + (buttBot - buttTop) * 0.22;
    final wrapBot = buttTop + (buttBot - buttTop) * 0.78;
    drawSection(
      yTop: wrapTop,
      yBot: wrapBot,
      colors: const [
        Color(0xFFEEEEEE),
        Color(0xFFCFD8DC),
        Color(0xFF90A4AE),
        Color(0xFF455A64),
      ],
    );

    // F. Bịt đáy chuôi (Butt Cap): y = buttBot -> y = h - 6
    drawSection(
      yTop: buttBot,
      yBot: h - 6,
      colors: const [Color(0xFFFFFFFF), Color(0xFFE0E0E0), Color(0xFF9E9E9E)],
    );

    // G. Đệm chân cao su (Bumper): y = h - 6 -> y = h
    final bumpR = radiusAt(h);
    final bumperPath = Path()
      ..moveTo(centerX - radiusAt(h - 6), h - 6)
      ..lineTo(centerX + radiusAt(h - 6), h - 6)
      ..lineTo(centerX + bumpR, h - 2)
      ..quadraticBezierTo(centerX, h + 2, centerX - bumpR, h - 2)
      ..close();
    canvas.drawPath(
      bumperPath,
      Paint()..color = const Color(0xFF1E1E1E),
    );

    // H. Đường bóng sáng (Glossy highlight)
    final shinePath = Path()
      ..moveTo(centerX - topR * 0.3, 2)
      ..lineTo(centerX - topR * 0.1, 2)
      ..lineTo(centerX - botR * 0.1, h - 8)
      ..lineTo(centerX - botR * 0.3, h - 8)
      ..close();
    canvas.drawPath(
      shinePath,
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );
  }

  @override
  bool shouldRepaint(covariant _VerticalCueStickPainter oldDelegate) =>
      oldDelegate.cue != cue;
}



void _showCueSpinDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: const Color(0xFF1B2026),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Điểm tác động bi cái (Xoáy)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Kéo chấm đỏ để chỉnh Cu-lê (tiến), Trô bóng (lùi) hoặc Áp-phê (ngang)',
                style: TextStyle(color: Colors.white60, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              // Khung hiển thị quả bi cái tương tác
              SizedBox(
                width: 230,
                height: 230,
                child: ValueListenableBuilder<Offset>(
                  valueListenable: gameInstance.cueSpin,
                  builder: (context, spin, child) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) =>
                        _updateSpinFromTouch(details.localPosition, 230),
                    onPanUpdate: (details) =>
                        _updateSpinFromTouch(details.localPosition, 230),
                    onPanEnd: (_) => gameInstance.commitCueSpin(),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Vỏ nền bi cái với viền phát sáng nhẹ
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withValues(alpha: 0.25),
                                blurRadius: 18,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/cue_bal.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Trục tọa độ và vòng tròn ranh giới an toàn
                        IgnorePointer(
                          child: CustomPaint(
                            size: const Size(200, 200),
                            painter: _CueBallGuidePainter(),
                          ),
                        ),
                        // Chấm đỏ đánh dấu điểm chạm cơ
                        Builder(
                          builder: (context) {
                            const maxRadius = 100.0 * 0.80; // 80px
                            return Transform.translate(
                              offset: Offset(
                                spin.dx * maxRadius,
                                spin.dy * maxRadius,
                              ),
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.redAccent.withValues(alpha: 0.9),
                                  border: Border.all(color: Colors.white, width: 2.5),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Nhãn trạng thái xoáy thời gian thực
              ValueListenableBuilder<Offset>(
                valueListenable: gameInstance.cueSpin,
                builder: (context, spin, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      _describeSpin(spin),
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              // Các nút chọn nhanh preset xoáy
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  _spinPresetChip('Tâm bi (Chuẩn)', Offset.zero),
                  _spinPresetChip('Cu-lê (Tiến)', const Offset(0.0, -0.75)),
                  _spinPresetChip('Trô bóng (Lùi)', const Offset(0.0, 0.75)),
                  _spinPresetChip('Áp-phê Trái', const Offset(-0.75, 0.0)),
                  _spinPresetChip('Áp-phê Phải', const Offset(0.75, 0.0)),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Xong'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0E5B3A),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

String _describeSpin(Offset spin) {
  if (spin.distance < 0.08) {
    return 'Tâm bi (Đánh thường, không xoáy)';
  }
  final parts = <String>[];
  if (spin.dy < -0.15) {
    parts.add('Cu-lê ${(-spin.dy * 100).round()}%');
  } else if (spin.dy > 0.15) {
    parts.add('Trô bóng ${(spin.dy * 100).round()}%');
  }
  if (spin.dx < -0.15) {
    parts.add('Áp-phê Trái ${(-spin.dx * 100).round()}%');
  } else if (spin.dx > 0.15) {
    parts.add('Áp-phê Phải ${(spin.dx * 100).round()}%');
  }
  return parts.isEmpty ? 'Gần tâm bi' : parts.join(' • ');
}

Widget _spinPresetChip(String label, Offset presetSpin) {
  return ActionChip(
    label: Text(label, style: const TextStyle(fontSize: 11.5, color: Colors.white)),
    backgroundColor: const Color(0xFF2B323B),
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    onPressed: () {
      gameInstance.setCueSpin(presetSpin);
      gameInstance.commitCueSpin();
    },
  );
}

class _CueBallGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final linePaint = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1.0;

    // Trục chữ thập tâm bi
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.85),
      Offset(center.dx, center.dy + radius * 0.85),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx - radius * 0.85, center.dy),
      Offset(center.dx + radius * 0.85, center.dy),
      linePaint,
    );

    // Vòng tròn an toàn tiếp xúc cơ (tránh tẹt cơ ngoài rìa)
    final circlePaint = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius * 0.80, circlePaint);
    canvas.drawCircle(center, radius * 0.40, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void _updateSpinFromTouch(Offset localPosition, double controlSize) {
  final center = Offset(controlSize / 2, controlSize / 2);
  final ballRadius = (controlSize / 2) * 0.82;
  final offset = localPosition - center;
  final distance = offset.distance;
  final maxRadius = ballRadius * 0.80; // Giữ đầu cơ an toàn trên mặt bi cái
  final limited = distance > maxRadius
      ? offset * (maxRadius / distance)
      : offset;
  gameInstance.setCueSpin(Offset(limited.dx / maxRadius, limited.dy / maxRadius));
}

MatchRewardResult? _lastMatchReward;

Widget _buildRackOverlay({VoidCallback? onHome}) {
  return ValueListenableBuilder<int>(
    valueListenable: gameInstance.matchVersion,
    builder: (context, matchVersion, child) {
      if (!gameInstance.rackOver) {
        return const SizedBox.shrink();
      }

      final reward = _lastMatchReward;

      String titleText;
      if (gameInstance.activeDailyPuzzle != null) {
        titleText = gameInstance.winningPlayer == 1
            ? '🎉 PHÁ GIẢI THẾ BI THÀNH CÔNG!'
            : '😢 THẾ BI CHƯA HOÀN THÀNH';
      } else if (gameInstance.activeBotStage != null) {
        titleText = gameInstance.winningPlayer == 1
            ? '🎉 VƯỢT ẢI ${gameInstance.activeBotStage!.stageNumber} THÀNH CÔNG!'
            : '😢 ${gameInstance.activeBotStage!.botName.toUpperCase()} ĐÃ CHIẾN THẮNG!';
      } else {
        titleText = gameInstance.winningPlayer == null
            ? 'Ván đấu kết thúc'
            : (gameInstance.winningPlayer == 1
                ? '🎉 BẠN ĐÃ CHIẾN THẮNG!'
                : (gameInstance.isBotMode.value
                    ? '🤖 BOT ĐÃ CHIẾN THẮNG!'
                    : 'ĐỐI THỦ CHIẾN THẮNG'));
      }

      final subtitleText = gameInstance.activeDailyPuzzle != null
          ? 'Đã dùng: ${gameInstance.dailyPuzzleShotsTaken} / ${gameInstance.activeDailyPuzzle!.maxShotsAllowed} cơ'
          : 'Tỷ số  ${gameInstance.playerScores[1] ?? 0} - ${gameInstance.playerScores[2] ?? 0}';

      return Positioned.fill(
        child: Container(
          color: Colors.black.withValues(alpha: 0.75),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF133E32), Color(0xFF0D251E)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black87, blurRadius: 20),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    gameInstance.winningPlayer == 1
                        ? Icons.emoji_events
                        : Icons.sentiment_dissatisfied,
                    color: Colors.amber,
                    size: 52,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    titleText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitleText,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),

                  // Phần thưởng
                  if (reward != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        children: [
                          if (reward.customMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              margin: const EdgeInsets.only(bottom: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD54F).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                reward.customMessage!,
                                style: const TextStyle(
                                  color: Color(0xFFFFD54F),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ] else ...[
                            const Text(
                              'PHẦN THƯỞNG',
                              style: TextStyle(
                                color: Color(0xFFFFD54F),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.teal.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '+${reward.earnedXP} XP',
                                  style: const TextStyle(
                                    color: Color(0xFF69F0AE),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.monetization_on, color: Color(0xFFFFD54F), size: 14),
                                    const SizedBox(width: 3),
                                    Text(
                                      '+${reward.earnedCoins}',
                                      style: const TextStyle(
                                        color: Color(0xFFFFD54F),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (reward.bonusDiamonds > 0) ...[
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlue.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.diamond, color: Color(0xFF29B6F6), size: 14),
                                      const SizedBox(width: 3),
                                      Text(
                                        '+${reward.bonusDiamonds}',
                                        style: const TextStyle(
                                          color: Color(0xFF81D4FA),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (reward.didLevelUp) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '🎉 LÊN CẤP ${reward.newLevel}! (+${reward.bonusDiamonds} Kim Cương)',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (onHome != null) ...[
                        OutlinedButton.icon(
                          onPressed: () {
                            if (gameInstance.isLocalMultiplayer.value) {
                              LocalMultiplayerService.instance.disconnect();
                            }
                            onHome();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Colors.white30),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.home, size: 18),
                          label: const Text('Menu Chính', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                      ],
                      FilledButton.icon(
                        onPressed: () {
                          if (gameInstance.isLocalMultiplayer.value) {
                            LocalMultiplayerService.instance.sendRestart();
                          }
                          gameInstance.restartMatch();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF00E676),
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.replay, size: 18),
                        label: const Text('Chơi lại', style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildControlBar(
  BuildContext context, {
  bool compact = false,
  bool ultraCompact = false,
  required VoidCallback onHome,
}) {
  return ValueListenableBuilder<int>(
    valueListenable: gameInstance.groupVersion,
    builder: (context, _, child) {
      return ValueListenableBuilder<int>(
        valueListenable: gameInstance.currentTurn,
        builder: (context, turn, child) {
          // Giao diện thanh trạng thái riêng cho Thế Bi Hàng Ngày (Daily Trickshot)
          if (gameInstance.activeDailyPuzzle != null) {
            final puzzle = gameInstance.activeDailyPuzzle!;
            return Container(
              height: ultraCompact ? 44.0 : (compact ? 52.0 : 66.0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xE620252A),
                borderRadius: BorderRadius.circular(ultraCompact ? 8 : 12),
                border: Border.all(color: const Color(0xFFAB47BC), width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 3)),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Thoát về menu',
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    iconSize: ultraCompact ? 18 : 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: onHome,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7B1FA2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'DAILY PUZZLE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                puzzle.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: ultraCompact ? 11 : 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          puzzle.description,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: ultraCompact ? 9 : 10.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFD54F)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sports_baseball, color: Color(0xFFFFD54F), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Cơ: ${gameInstance.dailyPuzzleShotsTaken} / ${puzzle.maxShotsAllowed}',
                          style: const TextStyle(
                            color: Color(0xFFFFD54F),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Gợi ý: ${puzzle.hint}',
                    icon: const Icon(Icons.lightbulb, color: Color(0xFFFFEB3B)),
                    iconSize: ultraCompact ? 18 : 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('💡 Gợi ý: ${puzzle.hint}'),
                          backgroundColor: const Color(0xFF4A148C),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Cài đặt',
                    icon: const Icon(Icons.settings),
                    color: Colors.white,
                    iconSize: ultraCompact ? 16 : (compact ? 19 : 22),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tightFor(
                      width: ultraCompact ? 28 : (compact ? 32 : 38),
                      height: ultraCompact ? 28 : (compact ? 32 : 38),
                    ),
                    style: IconButton.styleFrom(backgroundColor: Colors.black54),
                    onPressed: () => _showSettings(context, onHome: onHome),
                  ),
                ],
              ),
            );
          }

          // Tên hiển thị người chơi P1 và P2 theo chế độ
          String p1Name = 'Player 1';
          if (gameInstance.isLocalMultiplayer.value) {
            p1Name = LocalMultiplayerService.instance.isHost
                ? 'Bạn (Host P1)'
                : 'Đối thủ (Host P1)';
          }

          String p2Name = 'Player 2';
          if (gameInstance.activeBotStage != null) {
            p2Name = '${gameInstance.activeBotStage!.botName} (Ải ${gameInstance.activeBotStage!.stageNumber})';
          } else if (gameInstance.isBotMode.value) {
            p2Name = 'CPU (${gameInstance.botDifficulty.value == 1 ? 'Dễ' : 'Khó'})';
          } else if (gameInstance.isLocalMultiplayer.value) {
            p2Name = LocalMultiplayerService.instance.isHost
                ? 'Đối thủ (P2)'
                : 'Bạn (Client P2)';
          }

          return Container(
            height: ultraCompact ? 44.0 : (compact ? 52.0 : 66.0),
            padding: EdgeInsets.symmetric(
              horizontal: ultraCompact ? 4 : 8,
              vertical: ultraCompact ? 3 : 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xE620252A),
              borderRadius: BorderRadius.circular(ultraCompact ? 8 : 12),
              border: Border.all(color: Colors.white24),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 3)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildPlayerCard(
                    p1Name,
                    Colors.blue,
                    turn == 1,
                    gameInstance.playerScores[1] ?? 0,
                    gameInstance.groupLabel(1),
                    gameInstance.groupBalls(1),
                    false,
                    compact: compact,
                    ultraCompact: ultraCompact,
                  ),
                ),
                SizedBox(width: ultraCompact ? 2 : 6),
                // Nút Cài đặt ở giữa (Shop đã đưa về góc phải màn hình chính theo yêu cầu)
                IconButton(
                  tooltip: 'Cài đặt',
                  icon: const Icon(Icons.settings),
                  color: Colors.white,
                  iconSize: ultraCompact ? 16 : (compact ? 19 : 22),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(
                    width: ultraCompact ? 28 : (compact ? 32 : 38),
                    height: ultraCompact ? 28 : (compact ? 32 : 38),
                  ),
                  style: IconButton.styleFrom(backgroundColor: Colors.black54),
                  onPressed: () => _showSettings(context, onHome: onHome),
                ),
                SizedBox(width: ultraCompact ? 2 : 6),
                Expanded(
                  child: _buildPlayerCard(
                    p2Name,
                    Colors.red,
                    turn == 2,
                    gameInstance.playerScores[2] ?? 0,
                    gameInstance.groupLabel(2),
                    gameInstance.groupBalls(2),
                    true,
                    compact: compact,
                    ultraCompact: ultraCompact,
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}



void _showSettings(BuildContext context, {required VoidCallback onHome}) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cài đặt'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chọn thao tác cho trận đấu hiện tại.'),
        ],
      ),
      actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showDeclareLoss(context);
            },
            icon: const Icon(Icons.flag),
            label: const Text('Xử thua'),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onHome();
            },
            icon: const Icon(Icons.home),
            label: const Text('Menu chính'),
          ),
          FilledButton.icon(
            onPressed: () {
              gameInstance.restartMatch();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.restart_alt),
            label: const Text('Bắt đầu lại'),
          ),
        ],
      ),
  );
}

void _showDeclareLoss(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Chọn người thua'),
      content: const Text('Player nào bị xử thua trận này?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            gameInstance.declareLoss(1);
            Navigator.pop(context);
          },
          child: const Text('Player 1 thua'),
        ),
        TextButton(
          onPressed: () {
            gameInstance.declareLoss(2);
            Navigator.pop(context);
          },
          child: const Text('Player 2 thua'),
        ),
      ],
    ),
  );
}

Widget _buildPlayerCard(
  String name,
  Color color,
  bool isTurn,
  int score,
  String groupLabel,
  List<int> groupBalls,
  bool alignRight, {
  bool compact = false,
  bool ultraCompact = false,
}) {
  final ballBoxSize = ultraCompact ? 16.0 : (compact ? 19.0 : 24.0);
  final ballImgSize = ultraCompact ? 14.0 : (compact ? 17.0 : 22.0);
  final nameFontSize = ultraCompact ? 10.0 : (compact ? 11.5 : 12.5);
  final detailFontSize = ultraCompact ? 7.5 : (compact ? 8.5 : 9.5);

  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: ultraCompact ? 3 : 5,
      vertical: ultraCompact ? 1 : 2,
    ),
    decoration: BoxDecoration(
      color: color.withValues(alpha: isTurn ? 0.16 : 0.04),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: color.withValues(alpha: isTurn ? 0.8 : 0.18),
        width: isTurn ? 1.2 : 0.7,
      ),
    ),
    child: Row(
      textDirection: alignRight ? TextDirection.rtl : TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: alignRight
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isTurn && !alignRight)
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: ultraCompact ? 9 : 12,
                    ),
                  if (isTurn && !alignRight) SizedBox(width: ultraCompact ? 2 : 4),
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: nameFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isTurn && alignRight) SizedBox(width: ultraCompact ? 2 : 4),
                  if (isTurn && alignRight)
                    Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: ultraCompact ? 9 : 12,
                    ),
                ],
              ),
              Text(
                'Tỷ số: $score',
                style: TextStyle(color: Colors.white70, fontSize: detailFontSize),
              ),
              if (groupLabel.isNotEmpty)
                Text(
                  groupLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white70, fontSize: detailFontSize),
                ),
            ],
          ),
        ),
        Expanded(
          flex: 6,
          child: Align(
            alignment: alignRight
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              runAlignment: WrapAlignment.center,
              spacing: ultraCompact ? 1.5 : 3.0,
              runSpacing: 1.0,
              textDirection: alignRight
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              children: [
                for (final number in groupBalls)
                  Opacity(
                    opacity: gameInstance.isBallPocketed(number) ? 0.25 : 1,
                    child: Container(
                      width: ballBoxSize,
                      height: ballBoxSize,
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(ballBoxSize / 2),
                        border: Border.all(color: Colors.white24, width: 0.6),
                      ),
                      child: Image.asset(
                        'assets/images/ball_$number.png',
                        width: ballImgSize,
                        height: ballImgSize,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class BilliardGame extends Forge2DGame with PanDetector {
  BilliardGame()
    : super(
        gravity: Vector2.zero(),
        contactListener: BilliardContactListener(),
      );

  // Biến quản lý lượt chơi (Turn base)
  ValueNotifier<int> currentTurn = ValueNotifier<int>(1);
  ValueNotifier<bool> isBotMode = ValueNotifier<bool>(false);
  ValueNotifier<int> botDifficulty = ValueNotifier<int>(1);
  ValueNotifier<String> ruleMessage = ValueNotifier<String>(
    'Player 1: break shot',
  );
  ValueNotifier<double> shotPower = ValueNotifier<double>(0.05);
  ValueNotifier<Offset> cueSpin = ValueNotifier<Offset>(Offset.zero);
  ValueNotifier<int> groupVersion = ValueNotifier<int>(0);
  ValueNotifier<int> matchVersion = ValueNotifier<int>(0);
  final Map<int, int> playerScores = {1: 0, 2: 0};
  int? winningPlayer;

  // Chế độ Ải Bot Campaign, Thế Bi Hàng Ngày, Mạng Local WiFi
  BotStageModel? activeBotStage;
  DailyPuzzleModel? activeDailyPuzzle;
  int dailyPuzzleShotsTaken = 0;
  final ValueNotifier<bool> isLocalMultiplayer = ValueNotifier<bool>(false);

  bool get isMyTurn {
    if (isLocalMultiplayer.value) {
      final isHost = LocalMultiplayerService.instance.isHost;
      return (isHost && currentTurn.value == 1) || (!isHost && currentTurn.value == 2);
    }
    return true;
  }

  bool get canUserControl =>
      !shotInProgress &&
      !rackOver &&
      !(isBotMode.value && currentTurn.value == 2) &&
      isMyTurn;

  void initMultiplayer() {
    LocalMultiplayerService.instance.onMessageReceived = (data) {
      if (!_hasGameLoaded) return;
      final type = data['type'] as String?;
      if (type == 'aim') {
        aimAngle = (data['angle'] as num).toDouble();
        shotPower.value = (data['power'] as num).toDouble();
        cueBall.isAiming = true;
        cueBall.strokeDistance = maxDragDistance * shotPower.value;
        _updateAimVector(ballRadius * 2);
      } else if (type == 'spin') {
        final spin = Offset(
          (data['dx'] as num).toDouble(),
          (data['dy'] as num).toDouble(),
        );
        cueSpin.value = spin;
        cueBall.spinInfluence = spin;
      } else if (type == 'ball_in_hand') {
        final x = (data['x'] as num).toDouble();
        final y = (data['y'] as num).toDouble();
        cueBall.body.setTransform(Vector2(x, y), 0);
        cueBall.body.linearVelocity.setZero();
        _updateAimVector(ballRadius * 2);
      } else if (type == 'shoot') {
        shotPower.value = (data['power'] as num).toDouble();
        shootWithPower(fromNetwork: true);
      } else if (type == 'restart') {
        restartMatch();
      }
    };
  }

  late CueBall cueBall;
  final List<PoolBall> poolBalls = [];
  List<Pocket> pockets = [];
  List<Wall> walls = [];
  SpriteComponent? tableSpriteComponent;
  Vector2? _lastConfiguredSize;
  Vector2? dragStart;
  Vector2? dragCurrent;
  bool shotInProgress = false;
  double settledTime = 0;
  bool breakShot = true;
  bool rackOver = false;
  bool ballInHand = false;
  bool movingCueBall = false;
  final Map<int, BallGroup> playerGroups = {};
  bool objectBallHitRailThisShot = false;
  int objectBallsHitRails = 0;

  double maxDragDistance = 180.0;
  final ValueNotifier<double> aimAngleNotifier = ValueNotifier<double>(0.0);
  double get aimAngle => aimAngleNotifier.value;
  set aimAngle(double val) => aimAngleNotifier.value = val;

  // Tinh chỉnh lực, độ dốc mượt và tốc độ bóng theo yêu cầu
  static const double rollingVelocityMultiplier = 1.0;
  static const double rollingDeceleration =
      135.0; // Tăng ma sát để bóng dừng nhanh hơn (Cũ: 115.0)
  static const double minimumShotSpeed = 60.0;
  static const double maximumShotSpeed =
      1600.0; // Giảm tốc độ bắn tối đa tránh loạn (Cũ: 2500.0)
  static const double stopAngularVelocity = 0.08;
  static const double powerCurveExponent = 1.4; // Trợ lực cong nhẹ hơn
  static const double maximumBallSpeed = maximumShotSpeed;
  double? powerDragStartY;

  // Quản lý trạng thái Bot
  double botWaitTime = 0;
  int botState = 0; // 0: Đang phân tích, 1: Đang ngắm và lên cơ

  // Khai báo kích thước động
  late double ballRadius;
  late Vector2 playAreaTopLeft;
  late Vector2 playAreaBottomRight;
  bool physicsReady = false;
  bool _hasGameLoaded = false;
  bool get hasGameLoaded => _hasGameLoaded;

  @override
  Color backgroundColor() => const Color(0xFF0F7A3E);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    forge2d.maxTranslation = 42.0;
    forge2d.maxTranslationSquared = 1764.0;
    BilliardContactListener.activeGame = this;

    final tableSprite = await Sprite.load('pool_table.png');
    tableSpriteComponent = SpriteComponent(sprite: tableSprite, size: size);
    add(tableSpriteComponent!);

    _reconfigureTableForSize(size, initialLoad: true);

    if (activeDailyPuzzle != null) {
      ruleMessage.value = 'Thế bi: ${activeDailyPuzzle!.title}';
      dailyPuzzleShotsTaken = 0;
      breakShot = false;
      _setupDailyPuzzle(activeDailyPuzzle!);
    } else {
      spawnTriangleBalls();
      _resetCueBall();
    }

    _hasGameLoaded = true;
    _updateAimVector(ballRadius * 2);
    initMultiplayer();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (size.x <= 0 || size.y <= 0) return;
    if (_lastConfiguredSize == null ||
        (_lastConfiguredSize!.x - size.x).abs() > 1.0 ||
        (_lastConfiguredSize!.y - size.y).abs() > 1.0) {
      _reconfigureTableForSize(size);
    }
  }

  void _reconfigureTableForSize(Vector2 newSize, {bool initialLoad = false}) {
    _lastConfiguredSize = newSize.clone();
    tableSpriteComponent?.size = newSize;

    final double paddingX = newSize.x * 0.0574;
    final double paddingY = newSize.y * 0.1034;
    playAreaTopLeft = Vector2(paddingX, paddingY);
    playAreaBottomRight = Vector2(newSize.x - paddingX, newSize.y - paddingY);

    ballRadius = newSize.y * 0.0235;

    // Tái cấu hình băng và lỗ theo kích thước mới
    for (final w in walls) {
      if (w.isMounted && !w.isRemoved && !w.isRemoving) {
        w.removeFromParent();
      }
    }
    walls.clear();
    walls = createBoundaries();
    addAll(walls);

    for (final p in pockets) {
      if (p.isMounted && !p.isRemoved && !p.isRemoving) {
        p.removeFromParent();
      }
    }
    pockets.clear();
    pockets = createPockets();
    addAll(pockets);

    // Cập nhật lại bán kính vật lý cho các bi
    for (final ball in poolBalls) {
      ball.updateRadius(ballRadius);
    }
    try {
      if (cueBall.isMounted) {
        cueBall.updateRadius(ballRadius);
      }
    } catch (_) {}

    if (!initialLoad && !shotInProgress && _hasGameLoaded) {
      if (activeDailyPuzzle != null) {
        _setupDailyPuzzle(activeDailyPuzzle!);
      } else if (breakShot) {
        spawnTriangleBalls();
        _resetCueBall();
      }
    }
  }

  List<Wall> createBoundaries() {
    final sx = size.x;
    final sy = size.y;

    // Tọa độ chuẩn xác của 6 băng bida và má lỗ đo từ pool_table.png (662x377)
    final cushionTop = sy * 0.1034;
    final cushionBot = sy * 0.8912;
    final cushionLeft = sx * 0.0574;
    final cushionRight = sx * 0.9411;

    // Tỉ lệ vát mũi băng 4 lỗ góc rộng rãi, thông thoáng (~34.3px miệng lỗ)
    const xCut = 0.0950;
    const yCut = 0.1660;

    // 1. Băng Trên - Trái (Top-Left Cushion):
    final pTLFacing = Vector2(sx * 0.0650, sy * 0.0620);
    final pTLNose = Vector2(sx * xCut, cushionTop);
    final pTMLeftNose = Vector2(sx * 0.4600, cushionTop);
    final pTMLeftFacing = Vector2(sx * 0.4740, sy * 0.0680);

    // 2. Băng Trên - Phải (Top-Right Cushion):
    final pTMRightFacing = Vector2(sx * 0.5260, sy * 0.0680);
    final pTMRightNose = Vector2(sx * 0.5400, cushionTop);
    final pTRNose = Vector2(sx * (1.0 - xCut), cushionTop);
    final pTRFacing = Vector2(sx * (1.0 - 0.0650), sy * 0.0620);

    // 3. Băng Ngắn - Phải (Right Cushion):
    final pTRSideFacing = Vector2(sx * (1.0 - 0.0350), sy * 0.1140);
    final pRTopNose = Vector2(cushionRight, sy * yCut);
    final pRBotNose = Vector2(cushionRight, sy * (1.0 - yCut));
    final pBRSideFacing = Vector2(sx * (1.0 - 0.0350), sy * (1.0 - 0.1140));

    // 4. Băng Dưới - Phải (Bottom-Right Cushion):
    final pBRFacing = Vector2(sx * (1.0 - 0.0650), sy * (1.0 - 0.0620));
    final pBRNose = Vector2(sx * (1.0 - xCut), cushionBot);
    final pBMRightNose = Vector2(sx * 0.5400, cushionBot);
    final pBMRightFacing = Vector2(sx * 0.5260, sy * (1.0 - 0.0680));

    // 5. Băng Dưới - Trái (Bottom-Left Cushion):
    final pBMLeftFacing = Vector2(sx * 0.4740, sy * (1.0 - 0.0680));
    final pBMLeftNose = Vector2(sx * 0.4600, cushionBot);
    final pBLNose = Vector2(sx * xCut, cushionBot);
    final pBLFacing = Vector2(sx * 0.0650, sy * (1.0 - 0.0620));

    // 6. Băng Ngắn - Trái (Left Cushion):
    final pBLSideFacing = Vector2(sx * 0.0350, sy * (1.0 - 0.1140));
    final pLBotNose = Vector2(cushionLeft, sy * (1.0 - yCut));
    final pLTopNose = Vector2(cushionLeft, sy * yCut);
    final pTLSideFacing = Vector2(sx * 0.0350, sy * 0.1140);

    return [
      // Băng Trên - Trái
      Wall(pTLFacing, pTLNose, restitution: 0.25, friction: 0.25, isFacing: true),
      Wall(pTLNose, pTMLeftNose),
      Wall(pTMLeftNose, pTMLeftFacing, restitution: 0.25, friction: 0.25, isFacing: true),

      // Băng Trên - Phải
      Wall(pTMRightFacing, pTMRightNose, restitution: 0.25, friction: 0.25, isFacing: true),
      Wall(pTMRightNose, pTRNose),
      Wall(pTRNose, pTRFacing, restitution: 0.25, friction: 0.25, isFacing: true),

      // Băng Ngắn - Phải
      Wall(pTRSideFacing, pRTopNose, restitution: 0.25, friction: 0.25, isFacing: true),
      Wall(pRTopNose, pRBotNose),
      Wall(pRBotNose, pBRSideFacing, restitution: 0.25, friction: 0.25, isFacing: true),

      // Băng Dưới - Phải
      Wall(pBRFacing, pBRNose, restitution: 0.25, friction: 0.25, isFacing: true),
      Wall(pBRNose, pBMRightNose),
      Wall(pBMRightNose, pBMRightFacing, restitution: 0.25, friction: 0.25, isFacing: true),

      // Băng Dưới - Trái
      Wall(pBMLeftFacing, pBMLeftNose, restitution: 0.25, friction: 0.25, isFacing: true),
      Wall(pBMLeftNose, pBLNose),
      Wall(pBLNose, pBLFacing, restitution: 0.25, friction: 0.25, isFacing: true),

      // Băng Ngắn - Trái
      Wall(pBLSideFacing, pLBotNose, restitution: 0.25, friction: 0.25, isFacing: true),
      Wall(pLBotNose, pLTopNose),
      Wall(pLTopNose, pTLSideFacing, restitution: 0.25, friction: 0.25, isFacing: true),

      // Vách chặn an toàn lòng 6 lỗ (Pocket Cups / Backstops)
      Wall(pTLFacing, Vector2(sx * 0.015, sy * 0.030), restitution: 0.10, friction: 0.40),
      Wall(Vector2(sx * 0.015, sy * 0.030), pTLSideFacing, restitution: 0.10, friction: 0.40),

      Wall(pTRFacing, Vector2(sx * 0.985, sy * 0.030), restitution: 0.10, friction: 0.40),
      Wall(Vector2(sx * 0.985, sy * 0.030), pTRSideFacing, restitution: 0.10, friction: 0.40),

      Wall(pBLFacing, Vector2(sx * 0.015, sy * 0.970), restitution: 0.10, friction: 0.40),
      Wall(Vector2(sx * 0.015, sy * 0.970), pBLSideFacing, restitution: 0.10, friction: 0.40),

      Wall(pBRFacing, Vector2(sx * 0.985, sy * 0.970), restitution: 0.10, friction: 0.40),
      Wall(Vector2(sx * 0.985, sy * 0.970), pBRSideFacing, restitution: 0.10, friction: 0.40),

      Wall(pTMLeftFacing, Vector2(sx * 0.4740, sy * 0.025), restitution: 0.10, friction: 0.40),
      Wall(Vector2(sx * 0.4740, sy * 0.025), Vector2(sx * 0.5260, sy * 0.025), restitution: 0.10, friction: 0.40),
      Wall(Vector2(sx * 0.5260, sy * 0.025), pTMRightFacing, restitution: 0.10, friction: 0.40),

      Wall(pBMLeftFacing, Vector2(sx * 0.4740, sy * 0.975), restitution: 0.10, friction: 0.40),
      Wall(Vector2(sx * 0.4740, sy * 0.975), Vector2(sx * 0.5260, sy * 0.975), restitution: 0.10, friction: 0.40),
      Wall(Vector2(sx * 0.5260, sy * 0.975), pBMRightFacing, restitution: 0.10, friction: 0.40),
    ];
  }

  List<Pocket> createPockets() {
    final double cornerPocketRadius = ballRadius * 3.00;
    final double middlePocketRadius = ballRadius * 2.00;
    final double cornerDropDist = ballRadius * 3.00;
    final double middleDropDist = ballRadius * 2.00;

    final p0 = Vector2(size.x * 0.0520, size.y * 0.0915);
    final p1 = Vector2(size.x * 0.4985, size.y * 0.0756);
    final p2 = Vector2(size.x * 0.9480, size.y * 0.0915);
    final p3 = Vector2(size.x * 0.0520, size.y * 0.9085);
    final p4 = Vector2(size.x * 0.4988, size.y * 0.9159);
    final p5 = Vector2(size.x * 0.9480, size.y * 0.9085);

    return [
      Pocket(
        p0,
        cornerPocketRadius,
        dropDistance: cornerDropDist,
      ),
      Pocket(
        p1,
        middlePocketRadius,
        isMiddle: true,
        dropDistance: middleDropDist,
      ),
      Pocket(
        p2,
        cornerPocketRadius,
        dropDistance: cornerDropDist,
      ),
      Pocket(
        p3,
        cornerPocketRadius,
        dropDistance: cornerDropDist,
      ),
      Pocket(
        p4,
        middlePocketRadius,
        isMiddle: true,
        dropDistance: middleDropDist,
      ),
      Pocket(
        p5,
        cornerPocketRadius,
        dropDistance: cornerDropDist,
      ),
    ];
  }

  void spawnTriangleBalls() {
    final startX = size.x * 0.70;
    final centerY = size.y / 2;
    final hitboxR = ballRadius * 0.88;
    // Khoảng cách tâm giữa 2 bi chạm nhau: 2 * hitboxR + 0.12 (triệt tiêu va chạm trùng lặp Box2D)
    final spacing = hitboxR * 2.0 + 0.12;
    final dx = spacing * 0.8660254; // cos(30 deg) = sqrt(3)/2

    // Thứ tự xếp bi chuẩn quốc tế 8-ball: Bi 8 nằm chính giữa hàng thứ 3 (row 2, col 1)
    const rackOrder = [1, 9, 2, 3, 8, 10, 4, 11, 5, 12, 13, 6, 14, 7, 15];

    final Map<int, Vector2> rackPositions = {};
    int idx = 0;
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col <= row; col++) {
        final x = startX + row * dx;
        final y = centerY + (col - row / 2.0) * spacing;
        rackPositions[rackOrder[idx]] = Vector2(x, y);
        idx++;
      }
    }

    if (poolBalls.length == 15) {
      // TÁI SỬ DỤNG 15 BI CÓ SẴN - KHÔNG XÓA ASYNC, KHÔNG TẠO CHỒNG CHÉO TRÁNH NỔ BI
      for (final ball in poolBalls) {
        final pos = rackPositions[ball.number] ?? Vector2(startX, centerY);
        ball.updateRadius(ballRadius);
        ball.isSunk = false;
        ball.pocketedThisShot = false;
        ball.body.setTransform(pos, 0);
        ball.body.linearVelocity.setZero();
        ball.body.angularVelocity = 0;
        ball.body.clearForces();
        ball.body.setAwake(true);
      }
    } else {
      // Lần đầu tiên khi chưa có đủ 15 bi
      for (final b in poolBalls) {
        if (b.isMounted && !b.isRemoved && !b.isRemoving) {
          b.removeFromParent();
        }
      }
      poolBalls.clear();

      for (int number = 1; number <= 15; number++) {
        final pos = rackPositions[number] ?? Vector2(startX, centerY);
        final ball = PoolBall(
          pos,
          'ball_$number.png',
          ballRadius,
          number,
        );
        poolBalls.add(ball);
        add(ball);
      }
    }
  }

  void _resetCueBall({Vector2? customPos}) {
    final pos = customPos ?? Vector2(size.x * 0.25, size.y / 2);
    try {
      if (cueBall.isMounted) {
        cueBall.updateRadius(ballRadius);
        cueBall.isSunk = false;
        cueBall.pocketedThisShot = false;
        cueBall.hitObjectThisShot = false;
        cueBall.firstObjectBallHit = null;
        cueBall.hasCollidedBall = false;
        cueBall.drawFollowTimer = 0;
        cueBall.drawFollowForce = Vector2.zero();
        cueBall.activeSpin = Offset.zero;
        cueBall.spinInfluence = Offset.zero;
        cueBall.body.setTransform(pos, 0);
        cueBall.body.linearVelocity.setZero();
        cueBall.body.angularVelocity = 0;
        cueBall.body.clearForces();
        cueBall.body.setAwake(true);
        cueBall.isAiming = true;
        _updateAimVector(ballRadius * 2);
        return;
      }
    } catch (_) {}

    cueBall = CueBall(pos, ballRadius);
    add(cueBall);
    cueBall.isAiming = true;
    _updateAimVector(ballRadius * 2);
  }

  void _setupDailyPuzzle(DailyPuzzleModel puzzle) {
    if (poolBalls.length != 15) {
      spawnTriangleBalls();
    }
    final puzzleBallNumbers = puzzle.balls.map((b) => b.ballNumber).toSet();
    final Map<int, Vector2> puzzlePositions = {};
    for (final cfg in puzzle.balls) {
      puzzlePositions[cfg.ballNumber] = Vector2(size.x * cfg.normX, size.y * cfg.normY);
    }

    for (final ball in poolBalls) {
      ball.updateRadius(ballRadius);
      if (puzzleBallNumbers.contains(ball.number)) {
        final pos = puzzlePositions[ball.number]!;
        ball.isSunk = false;
        ball.pocketedThisShot = false;
        ball.body.setTransform(pos, 0);
        ball.body.linearVelocity.setZero();
        ball.body.angularVelocity = 0;
        ball.body.clearForces();
        ball.body.setAwake(true);
      } else {
        ball.isSunk = true;
        ball.pocketedThisShot = false;
        ball.body.setTransform(Vector2(-1000, -1000), 0);
        ball.body.linearVelocity.setZero();
        ball.body.angularVelocity = 0;
        ball.body.clearForces();
      }
    }

    _resetCueBall(
      customPos: Vector2(
        size.x * puzzle.cueBallNormX,
        size.y * puzzle.cueBallNormY,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_hasGameLoaded) {
      return;
    }
    if (!physicsReady) {
      physicsReady =
          cueBall.isMounted && poolBalls.every((ball) => ball.isMounted);
      if (!physicsReady) {
        return;
      }
    }
    _checkContinuousPocketDrops();
    _keepBallsInsideTable();
    _applyClothPhysics(dt);

    if (!shotInProgress) {
      _maybeTakeBotTurn(dt);
      return;
    }

    final cueStopped = _bodyStopped(cueBall.body);
    final ballsStopped = poolBalls.every(
      (ball) => ball.isRemoved || _bodyStopped(ball.body),
    );
    if (cueStopped && ballsStopped) {
      settledTime += dt;
      if (settledTime > 0.25) {
        finishShot();
      }
    } else {
      settledTime = 0;
    }
  }

  bool _bodyStopped(Body body) {
    return body.linearVelocity.length < 0.35 &&
        body.angularVelocity.abs() < stopAngularVelocity;
  }

  void _applyClothPhysics(double dt) {
    if (!_hasGameLoaded) return;
    _applyClothPhysicsToBody(cueBall.body, dt);
    for (final ball in poolBalls) {
      if (ball.isRemoved) {
        continue;
      }
      _applyClothPhysicsToBody(ball.body, dt);
    }
  }

  void _applyClothPhysicsToBody(Body body, double dt) {
    final velocity = body.linearVelocity;
    final speed = velocity.length;
    if (speed <= 0) {
      return;
    }

    if (body == cueBall.body) {
      // 1. Áp dụng lực giật lùi (Trô) hoặc đẩy tới (Cu-lê) sau khi chạm bi mục tiêu
      if (cueBall.drawFollowTimer > 0) {
        cueBall.drawFollowTimer -= dt;
        final factor = (cueBall.drawFollowTimer / 0.35).clamp(0.0, 1.0);
        velocity.add(cueBall.drawFollowForce * (factor * dt));
      }

      // 2. Độ xoáy hao mòn dần do ma sát với mặt vải nỉ
      final decayY = math.exp(-2.2 * dt);
      final decayX = math.exp(-0.7 * dt);
      cueBall.activeSpin = Offset(
        cueBall.activeSpin.dx * decayX,
        cueBall.activeSpin.dy * decayY,
      );

      // 3. Trước va chạm: nếu có xoáy giật lùi (trô) thì ma sát trượt làm bóng hãm tốc nhanh hơn
      if (!cueBall.hasCollidedBall && cueBall.activeSpin.dy > 0.1) {
        final brake = cueBall.activeSpin.dy * 45.0 * dt;
        final reducedSpeed = math.max(0.0, speed - brake);
        if (speed > 0) {
          velocity.scale(reducedSpeed / speed);
        }
      }
    }

    final nextSpeed = math.max(
      0.0,
      velocity.length - rollingDeceleration * dt,
    );
    if (nextSpeed == 0) {
      velocity.setZero();
    } else {
      velocity.scale(nextSpeed / velocity.length);
    }
    if (velocity.length > maximumBallSpeed) {
      velocity.scale(maximumBallSpeed / velocity.length);
    }
    if (velocity.length < 1.0) {
      velocity.setZero();
    }
  }

  void _keepBallsInsideTable() {
    if (!_hasGameLoaded) return;
    if (!cueBall.isSunk) {
      _keepBodyInsideTable(cueBall);
    }
    for (final ball in poolBalls) {
      if (!ball.isRemoved && !ball.isSunk) {
        _keepBodyInsideTable(ball);
      }
    }
  }

  void _keepBodyInsideTable(BodyComponent ball) {
    final body = ball.body;
    final position = body.position;
    // Vùng bao an toàn ngoài cùng (mép gỗ ngoài của bàn)
    final minX = size.x * 0.015;
    final maxX = size.x * 0.985;
    final minY = size.y * 0.025;
    final maxY = size.y * 0.975;
    var corrected = false;

    if (position.x < minX) {
      position.x = minX;
      corrected = true;
    } else if (position.x > maxX) {
      position.x = maxX;
      corrected = true;
    }
    if (position.y < minY) {
      position.y = minY;
      corrected = true;
    } else if (position.y > maxY) {
      position.y = maxY;
      corrected = true;
    }

    if (corrected) {
      body.setTransform(position, 0);
      body.setAwake(true);
    }
  }

  void _checkContinuousPocketDrops() {
    for (final pocket in pockets) {
      if (!cueBall.isSunk && canBallEnterPocket(cueBall.body, pocket)) {
        cueBall.isSunk = true;
        cueBall.pocketedThisShot = true;
      }
      for (final ball in poolBalls) {
        if (!ball.isRemoved &&
            !ball.isSunk &&
            canBallEnterPocket(ball.body, pocket)) {
          ball.isSunk = true;
          ball.pocketedThisShot = true;
        }
      }
    }
  }

  bool canBallEnterPocket(Body ballBody, Pocket pocket) {
    final ballPos = ballBody.position;
    final pocketPos = pocket.position;
    final dist = (ballPos - pocketPos).length;
    return dist <= pocket.dropDistance;
  }

  void resetCueSpin() {
    cueSpin.value = Offset.zero;
    if (_hasGameLoaded) {
      cueBall.spinInfluence = Offset.zero;
      cueBall.activeSpin = Offset.zero;
    }
  }

  void switchTurn() {
    resetCueSpin();
    currentTurn.value = currentTurn.value == 1 ? 2 : 1;
  }

  void startPlayerMatch() {
    activeBotStage = null;
    activeDailyPuzzle = null;
    isLocalMultiplayer.value = false;
    isBotMode.value = false;
    restartMatch();
  }

  void startBotStage(BotStageModel stage) {
    activeBotStage = stage;
    activeDailyPuzzle = null;
    isLocalMultiplayer.value = false;
    isBotMode.value = true;
    botDifficulty.value = stage.stageNumber <= 3 ? 1 : 2;
    restartMatch();
  }

  void startDailyPuzzle(DailyPuzzleModel puzzle) {
    activeDailyPuzzle = puzzle;
    dailyPuzzleShotsTaken = 0;
    activeBotStage = null;
    isLocalMultiplayer.value = false;
    isBotMode.value = false;
    restartMatch();
  }

  void startLocalMultiplayer() {
    activeBotStage = null;
    activeDailyPuzzle = null;
    isLocalMultiplayer.value = true;
    isBotMode.value = false;
    restartMatch();
  }

  void setBotMode(bool enabled) {
    if (isBotMode.value == enabled) {
      return;
    }
    isBotMode.value = enabled;
    restartMatch();
  }

  void setBotDifficulty(int difficulty) {
    if (difficulty != 1 && difficulty != 2) {
      return;
    }
    botDifficulty.value = difficulty;
    if (isBotMode.value) {
      restartMatch();
    }
  }

  void declareLoss(int loser) {
    if (rackOver || shotInProgress || (loser != 1 && loser != 2)) {
      return;
    }
    winningPlayer = loser == 1 ? 2 : 1;
    playerScores[winningPlayer!] = playerScores[winningPlayer!]! + 1;
    ruleMessage.value = 'Player $loser bị xử thua';
    rackOver = true;
    ballInHand = false;
    matchVersion.value++;
  }

  void restartMatch() {
    currentTurn.value = 1;
    shotPower.value = 0.05;
    playerGroups.clear();
    groupVersion.value++;
    shotInProgress = false;
    breakShot = activeDailyPuzzle == null;
    rackOver = false;
    winningPlayer = null;
    ballInHand = false;
    movingCueBall = false;
    settledTime = 0;
    botWaitTime = 0;
    botState = 0;
    aimAngle = 0;
    physicsReady = false;
    _lastMatchReward = null;

    if (activeDailyPuzzle != null) {
      ruleMessage.value = 'Thế bi: ${activeDailyPuzzle!.title}';
      dailyPuzzleShotsTaken = 0;
    } else if (activeBotStage != null) {
      ruleMessage.value = '${activeBotStage!.title} - Bắt đầu!';
    } else if (isLocalMultiplayer.value) {
      ruleMessage.value = LocalMultiplayerService.instance.isHost
          ? 'Đấu mạng: Lượt của bạn (P1 break shot)'
          : 'Đấu mạng: Lượt đối thủ (P1 break shot)';
    } else {
      ruleMessage.value = 'Player 1: break shot';
    }

    resetCueSpin();

    if (!_hasGameLoaded) {
      matchVersion.value++;
      return;
    }

    if (activeDailyPuzzle != null) {
      _setupDailyPuzzle(activeDailyPuzzle!);
    } else {
      spawnTriangleBalls();
      _resetCueBall();
    }

    matchVersion.value++;
  }

  void setShotPower(double value) {
    shotPower.value = value.clamp(0.05, 1.0);
    if (_hasGameLoaded) {
      cueBall.isAiming = true;
      cueBall.strokeDistance = maxDragDistance * shotPower.value;
    }
    if (isLocalMultiplayer.value && isMyTurn) {
      LocalMultiplayerService.instance.sendAim(
        angle: aimAngle,
        power: shotPower.value,
      );
    }
  }

  void setCueSpin(Offset value) {
    if (!canUserControl) {
      return;
    }
    final dist = value.distance;
    final clamped = dist > 1.0 ? value / dist : value;
    cueSpin.value = clamped;
    if (_hasGameLoaded) {
      cueBall.spinInfluence = clamped;
      if (cueBall.isAiming && cueBall.aimVector != null) {
        _updateAimVector(cueBall.aimVector!.length);
      }
    }
    if (isLocalMultiplayer.value && isMyTurn) {
      LocalMultiplayerService.instance.sendSpin(dx: clamped.dx, dy: clamped.dy);
    }
  }

  void commitCueSpin() {
    if (!_hasGameLoaded) return;
    cueBall.spinInfluence = cueSpin.value;
    if (cueBall.isAiming && cueBall.aimVector != null) {
      _updateAimVector(cueBall.aimVector!.length);
    }
  }

  void adjustShotPower(double delta) {
    if (!canUserControl) {
      return;
    }
    shotPower.value = (shotPower.value + delta).clamp(0.05, 1.0);
    if (_hasGameLoaded) {
      cueBall.isAiming = true;
      cueBall.strokeDistance = maxDragDistance * shotPower.value;
    }
    if (isLocalMultiplayer.value && isMyTurn) {
      LocalMultiplayerService.instance.sendAim(
        angle: aimAngle,
        power: shotPower.value,
      );
    }
  }

  void beginPowerDrag(double startY) {
    if (!canUserControl) {
      powerDragStartY = null;
      return;
    }
    powerDragStartY = startY;
  }

  void updatePowerDrag(double currentY) {
    final startY = powerDragStartY;
    if (startY == null || !canUserControl) {
      return;
    }
    final pullDistance = math.max(0.0, currentY - startY);
    final power = (0.05 + pullDistance / maxDragDistance * 0.95).clamp(
      0.05,
      1.0,
    );
    setShotPower(power);
    if (_hasGameLoaded) {
      cueBall.isAiming = true;
      cueBall.strokeDistance = maxDragDistance * power;
    }
    if (isLocalMultiplayer.value && isMyTurn) {
      LocalMultiplayerService.instance.sendAim(angle: aimAngle, power: power);
    }
  }

  void endPowerDrag() {
    powerDragStartY = null;
  }

  void shootWithPower({bool fromBot = false, bool fromNetwork = false}) {
    if (!_hasGameLoaded ||
        !physicsReady ||
        shotInProgress ||
        ballInHand ||
        rackOver ||
        (!fromBot && !fromNetwork && !canUserControl) ||
        shotPower.value <= 0.05) {
      return;
    }

    if (isLocalMultiplayer.value && !fromBot && !fromNetwork) {
      LocalMultiplayerService.instance.sendShoot(power: shotPower.value);
    }

    final direction = Vector2(math.cos(aimAngle), math.sin(aimAngle));
    final normalizedPower = ((shotPower.value - 0.05) / 0.95).clamp(0.0, 1.0);
    final curvedPower = math
        .pow(normalizedPower, powerCurveExponent)
        .toDouble();

    // Áp dụng chỉ số Lực (Force) và Xoáy (Spin) từ cây gậy cơ đang trang bị hoặc gậy của Bot
    final cue = ProgressionService.instance.equippedCue;
    final level = ProgressionService.instance.equippedCueLevel;
    
    double forceMult = 1.0;
    double spinMult = 1.0;
    if (fromBot && activeBotStage != null) {
      forceMult = activeBotStage!.cue.getForceMultiplier(activeBotStage!.stageNumber);
      spinMult = activeBotStage!.cue.getSpinMultiplier(activeBotStage!.stageNumber);
    } else if (!fromBot && currentTurn.value == 1) {
      forceMult = cue.getForceMultiplier(level);
      spinMult = cue.getSpinMultiplier(level);
    }

    final targetSpeed =
        (minimumShotSpeed +
            (maximumShotSpeed - minimumShotSpeed) * curvedPower) *
        rollingVelocityMultiplier *
        forceMult;

    cueBall.body.setAwake(true);
    // Vận tốc góc xoáy áp-phê quanh trục Z (áp-phê phải dx > 0 thì quay thuận chiều kim đồng hồ)
    cueBall.body.angularVelocity = -cueSpin.value.dx * 18.0 * spinMult;
    cueBall.body.linearVelocity.setFrom(direction * targetSpeed);

    // Khởi tạo các trạng thái động lực học xoáy
    cueBall.activeSpin = cueSpin.value * spinMult;
    cueBall.shotDirection = direction.clone();
    cueBall.hasCollidedBall = false;
    cueBall.drawFollowTimer = 0.0;
    cueBall.drawFollowForce.setZero();

    shotInProgress = true;
    objectBallHitRailThisShot = false;
    objectBallsHitRails = 0;

    for (final ball in poolBalls) {
      ball.pocketedThisShot = false;
    }
    cueBall.pocketedThisShot = false;
    cueBall.hitObjectThisShot = false;
    cueBall.firstObjectBallHit = null;
    settledTime = 0;
    shotPower.value = 0.05;
    cueBall.spinInfluence = cueSpin.value;
    cueBall.strokeDistance = 0;
    cueBall.isAiming = false;
  }

  void _maybeTakeBotTurn(double dt) {
    if (!isBotMode.value || currentTurn.value != 2 || rackOver) {
      botWaitTime = 0;
      botState = 0;
      return;
    }

    botWaitTime += dt;

    // Giai đoạn 1: Bot phân tích bi và lên đường ngắm (chưa đánh)
    if (botState == 0) {
      if (botWaitTime > 0.8 && physicsReady) {
        if (ballInHand) {
          _placeBotCueBall();
          ballInHand = false;
        }

        final shot = _chooseBotShot();
        if (shot != null && shot.direction.length2 > 1) {
          double angle = math.atan2(shot.direction.y, shot.direction.x);
          double pwr = shot.power;
          Offset spin = shot.spin;

          if (activeBotStage != null) {
            final stage = activeBotStage!;
            final angleErr = (math.Random().nextDouble() * 2 - 1) * stage.aimErrorRad;
            angle += angleErr;
            final pwrErr = (math.Random().nextDouble() * 2 - 1) * (1.0 - stage.powerAccuracy) * 0.20;
            pwr = (pwr + pwrErr).clamp(0.15, 0.95);
            if (!stage.useSpin) {
              spin = Offset.zero;
            }
          }

          aimAngle = angle;
          shotPower.value = pwr;
          cueSpin.value = spin;
          cueBall.spinInfluence = spin;
          cueBall.isAiming = true;
          cueBall.strokeDistance = maxDragDistance * pwr;
          _updateAimVector(ballRadius * 2);

          botState = 1; // Chuyển sang giai đoạn chờ đánh
          botWaitTime = 0;
        } else {
          // Phòng ngừa trường hợp bot không tìm thấy đường bi lý tưởng: tự động nhắm bi 8 hoặc bi gần nhất
          final aliveBalls = poolBalls.where((b) => !b.isSunk && !b.isRemoved).toList();
          if (aliveBalls.isNotEmpty) {
            final targetBall = aliveBalls.firstWhere(
              (b) => b.number == 8,
              orElse: () => aliveBalls.first,
            );
            final aimDir = targetBall.body.position - cueBall.body.position;
            aimAngle = math.atan2(aimDir.y, aimDir.x);
            shotPower.value = 0.42;
            cueSpin.value = Offset.zero;
            cueBall.spinInfluence = Offset.zero;
            cueBall.isAiming = true;
            cueBall.strokeDistance = maxDragDistance * 0.42;
            _updateAimVector(ballRadius * 2);
            botState = 1;
            botWaitTime = 0;
          }
        }
      }
    }
    // Giai đoạn 2: Bot đứng ngắm trong 1.5s rồi mới dứt khoát bắn
    else if (botState == 1) {
      if (botWaitTime > 1.5) {
        shootWithPower(fromBot: true);
        botState = 0;
        botWaitTime = 0;
      }
    }
  }

  bool _isBallLegalTarget(PoolBall ball, int player) {
    if (ball.isRemoved || ball.isSunk) return false;
    final group = getPlayerGroup(player);
    if (ball.number == 8) {
      if (group == null) return false;
      return allGroupBallsPocketed(group);
    }
    if (group == null) {
      return true; // Bàn mở (Open table): mọi bi trừ bi 8
    }
    return ballGroup(ball.number) == group;
  }

  bool _isPocketEntryFeasible(Vector2 ballPos, Vector2 pocket, int pocketIndex) {
    final fromPocket = (ballPos - pocket).normalized();
    Vector2 pocketInward;
    switch (pocketIndex) {
      case 0:
        pocketInward = Vector2(0.707, 0.707);
        break;
      case 1:
        pocketInward = Vector2(0.0, 1.0);
        break;
      case 2:
        pocketInward = Vector2(-0.707, 0.707);
        break;
      case 3:
        pocketInward = Vector2(0.707, -0.707);
        break;
      case 4:
        pocketInward = Vector2(0.0, -1.0);
        break;
      case 5:
      default:
        pocketInward = Vector2(-0.707, -0.707);
        break;
    }
    final entryCosine = fromPocket.dot(pocketInward);
    // Lỗ giữa yêu cầu góc vào thoáng hơn
    if (pocketIndex == 1 || pocketIndex == 4) {
      return entryCosine >= 0.40;
    } else {
      return entryCosine >= 0.25;
    }
  }

  bool _checkCueBallScratchRisk(
    Vector2 ghostPos,
    Vector2 cueDeflection,
    List<Vector2> pockets,
    double maxTravel,
  ) {
    for (final pocket in pockets) {
      final toPocket = pocket - ghostPos;
      final proj = toPocket.dot(cueDeflection);
      if (proj > 0 && proj < maxTravel) {
        final dist = (toPocket - cueDeflection * proj).length;
        if (dist < ballRadius * 2.2) {
          return true; // Nguy cơ bi cái rơi thẳng vào lỗ
        }
      }
    }
    return false;
  }

  void _placeBotCueBall() {
    _prepareCueBallForPlacement();
    final minX = playAreaTopLeft.x + ballRadius * 1.5;
    final maxX = playAreaBottomRight.x - ballRadius * 1.5;
    final minY = playAreaTopLeft.y + ballRadius * 1.5;
    final maxY = playAreaBottomRight.y - ballRadius * 1.5;

    final legalBalls = poolBalls.where((b) => _isBallLegalTarget(b, 2)).toList();
    final pockets = _botPocketPositions();

    Vector2? bestPosition;
    double bestScore = double.infinity;

    // Ưu tiên cực cao của Bot Khó: Đặt bi cái thẳng tắp sau lưng bi mục tiêu dễ vào lỗ nhất
    if (botDifficulty.value == 2) {
      for (final ball in legalBalls) {
        for (int i = 0; i < pockets.length; i++) {
          final pocket = pockets[i];
          if (!_isPocketEntryFeasible(ball.body.position, pocket, i) ||
              !_isBotPathClear(ball.body.position, pocket, excluded: ball)) {
            continue;
          }
          final toPocket = (pocket - ball.body.position).normalized();
          // Đặt bi cái cách bi mục tiêu 3.8 lần bán kính
          final candidate = ball.body.position - toPocket * (ballRadius * 3.8);

          if (candidate.x >= minX &&
              candidate.x <= maxX &&
              candidate.y >= minY &&
              candidate.y <= maxY) {
            final overlaps = poolBalls.any((b) =>
                !b.isRemoved &&
                !b.isSunk &&
                (b.body.position - candidate).length < ballRadius * 2.3);
            if (!overlaps) {
              final distToPocket = (pocket - ball.body.position).length;
              if (distToPocket < bestScore) {
                bestScore = distToPocket;
                bestPosition = candidate;
              }
            }
          }
        }
      }
    }

    // Nếu không có vị trí thẳng hoàn hảo hoặc độ khó 1: quét lưới tìm vị trí có góc bắn an toàn nhất
    if (bestPosition == null) {
      for (var column = 1; column <= 8; column++) {
        for (var row = 1; row <= 5; row++) {
          final candidate = Vector2(
            minX + (maxX - minX) * column / 9,
            minY + (maxY - minY) * row / 6,
          );
          final overlaps = poolBalls.any((b) =>
              !b.isRemoved &&
              !b.isSunk &&
              (b.body.position - candidate).length < ballRadius * 2.2);
          if (overlaps) continue;

          cueBall.body.setTransform(candidate, 0);
          cueBall.body.linearVelocity.setZero();
          cueBall.body.angularVelocity = 0;
          final shot = _chooseBotShot();
          if (shot != null && shot.totalDistance < bestScore) {
            bestScore = shot.totalDistance;
            bestPosition = candidate.clone();
          }
        }
      }
    }

    final position = bestPosition ?? initialCueBallPosition;
    cueBall.body.setTransform(position, 0);
    cueBall.body.linearVelocity.setZero();
    cueBall.body.angularVelocity = 0;
    cueBall.isSunk = false;
    cueBall.isAiming = true;
    _updateAimVector(ballRadius * 2);
  }

  BotShot? _chooseBotShot() {
    // 1. Pha phá bóng (Break Shot): Đánh chuẩn xác vào đỉnh tam giác
    if (breakShot) {
      final apexPos = Vector2(size.x * 0.70, size.y / 2);
      final aimDir = apexPos - cueBall.body.position;
      final useSpin = activeBotStage != null
          ? activeBotStage!.useSpin
          : (botDifficulty.value == 2);
      final pwr = activeBotStage != null
          ? (0.70 + activeBotStage!.powerAccuracy * 0.25).clamp(0.65, 0.95)
          : (botDifficulty.value == 2 ? 0.90 : 0.75);
      return BotShot(
        direction: aimDir,
        totalDistance: aimDir.length,
        spin: useSpin ? const Offset(0.0, 0.22) : Offset.zero,
        power: pwr,
      );
    }

    // 2. Lọc danh sách các bi hợp lệ (tuyệt đối không nhắm bi đối thủ hay bi 8 khi chưa đến lượt)
    var legalBalls = poolBalls.where((b) => _isBallLegalTarget(b, 2)).toList();
    if (legalBalls.isEmpty) {
      final botGroup = getPlayerGroup(2);
      final allPotted = botGroup != null && allGroupBallsPocketed(botGroup);
      final eightBall = poolBalls.firstWhere(
        (b) => b.number == 8 && !b.isSunk && !b.isRemoved,
        orElse: () => poolBalls.firstWhere(
          (b) => !b.isSunk && !b.isRemoved,
          orElse: () => poolBalls.first,
        ),
      );
      if (allPotted && !eightBall.isSunk && !eightBall.isRemoved) {
        legalBalls = [eightBall];
      } else {
        return null;
      }
    }

    final pockets = _botPocketPositions();
    BotShot? bestShot;
    var bestScore = double.infinity;

    final isSimplePocketSearch = (activeBotStage != null && activeBotStage!.stageNumber <= 2) ||
        (activeBotStage == null && botDifficulty.value == 1);
    final isAdvanced = (activeBotStage != null && activeBotStage!.stageNumber >= 4) ||
        (activeBotStage == null && botDifficulty.value == 2);
    final enableSpin = activeBotStage != null ? activeBotStage!.useSpin : (botDifficulty.value == 2);
    final enableScratchPrevention = activeBotStage != null
        ? activeBotStage!.useScratchPrevention
        : (botDifficulty.value == 2);

    for (final ball in legalBalls) {
      final candidatePockets = isSimplePocketSearch
          ? [_nearestPocket(ball.body.position, pockets)]
          : pockets;

      for (int pIdx = 0; pIdx < candidatePockets.length; pIdx++) {
        final pocket = candidatePockets[pIdx];

        // Kiểm tra góc vào lỗ có khả thi không
        if (!_isPocketEntryFeasible(ball.body.position, pocket, pIdx)) {
          continue;
        }

        final objectDirection = (pocket - ball.body.position).normalized();
        final aimPoint = ball.body.position - objectDirection * (cueBall.hitboxRadius + ball.hitboxRadius);
        final cueDistance = (aimPoint - cueBall.body.position).length;
        final objectDistance = (pocket - ball.body.position).length;

        // Kiểm tra đường đi của bi cái tới Ghost Ball và bi mục tiêu tới lỗ có bị chắn không
        if (!_isInsidePlayableArea(aimPoint) ||
            !_isBotPathClear(cueBall.body.position, aimPoint, excluded: ball) ||
            !_isBotPathClear(ball.body.position, pocket, excluded: ball)) {
          continue;
        }

        final cueDirection = (aimPoint - cueBall.body.position).normalized();
        final cutCosine = cueDirection.dot(objectDirection);

        // Góc cắt quá lớn (> 74 độ) không thể ăn bi trực tiếp
        final minCutCosine = isAdvanced ? 0.28 : 0.20;
        if (cutCosine < minCutCosine) {
          continue;
        }

        // Tính toán hướng rẽ bi cái và xoáy an toàn chống rơi lỗ (Scratch Prevention)
        final normal = objectDirection;
        final dot = cueDirection.dot(normal);
        Vector2 tangent = cueDirection - normal * dot;
        if (tangent.length2 > 0.0001) {
          tangent.normalize();
        } else {
          tangent = Vector2(-normal.y, normal.x);
        }

        Offset chosenSpin = Offset.zero;
        if (enableSpin) {
          if (cutCosine >= 0.82) {
            chosenSpin = const Offset(0.0, 0.65);
          } else {
            final cutAngle =
                cueDirection.x * objectDirection.y -
                cueDirection.y * objectDirection.x;
            double spinDx = cutAngle.clamp(-1.0, 1.0) * 0.45;
            double spinDy = (cueDistance > size.x * 0.38) ? -0.35 : 0.35;
            chosenSpin = Offset(spinDx, spinDy);
          }

          if (enableScratchPrevention) {
            Vector2 cueDeflection = tangent;
            if (chosenSpin.dy > 0.05) {
              cueDeflection = (tangent * (1.0 - chosenSpin.dy * 0.45) - normal * (chosenSpin.dy * 0.75)).normalized();
            } else if (chosenSpin.dy < -0.05) {
              final f = -chosenSpin.dy;
              cueDeflection = (tangent * (1.0 - f * 0.45) + cueDirection * (f * 0.75)).normalized();
            }

            final maxCueTravel = cueDistance * 0.8 + 120.0;
            final hasScratchRisk = _checkCueBallScratchRisk(aimPoint, cueDeflection, pockets, maxCueTravel);
            if (hasScratchRisk) {
              final alternateSpin = chosenSpin.dy > 0 ? const Offset(0.0, -0.6) : const Offset(0.0, 0.7);
              Vector2 altDeflection = alternateSpin.dy > 0
                  ? (tangent * 0.6 - normal * 0.6).normalized()
                  : (tangent * 0.6 + cueDirection * 0.6).normalized();
              if (_checkCueBallScratchRisk(aimPoint, altDeflection, pockets, maxCueTravel)) {
                continue;
              } else {
                chosenSpin = alternateSpin;
              }
            }
          }
        }

        // Tính lực đánh chuẩn xác tối ưu theo cự ly và góc cắt
        final tableLength = size.x * 0.70;
        final effectiveDistance = cueDistance + objectDistance / math.max(0.25, cutCosine);
        final calculatedPower = (0.24 + 0.46 * (effectiveDistance / tableLength)).clamp(0.28, 0.75);

        // Tính điểm ưu tiên (Score càng nhỏ càng tốt)
        final cutPenalty = (1.0 - cutCosine) * (isAdvanced ? cueDistance * 0.8 : cueDistance * 0.3);
        final score = cueDistance + objectDistance * 1.15 + cutPenalty;

        if (score < bestScore) {
          bestScore = score;
          bestShot = BotShot(
            direction: aimPoint - cueBall.body.position,
            totalDistance: cueDistance + objectDistance,
            spin: chosenSpin,
            power: calculatedPower,
          );
        }
      }
    }

    if (bestShot != null) {
      return bestShot;
    }

    // 3. Nếu không có cơ hội ăn bi trực tiếp:
    final enableSafety = activeBotStage != null
        ? activeBotStage!.useSafetyShot
        : (botDifficulty.value == 2);
    if (enableSafety) {
      return _findSafeLegalContactShot(legalBalls, pockets);
    }

    // Bot chưa biết đánh safety: đánh bi mục tiêu đầu tiên
    final firstBall = legalBalls.first;
    final aimDir = firstBall.body.position - cueBall.body.position;
    return BotShot(
      direction: aimDir,
      totalDistance: aimDir.length,
      spin: Offset.zero,
      power: 0.32,
    );
  }

  BotShot _findSafeLegalContactShot(List<PoolBall> legalBalls, List<Vector2> pockets) {
    // 1. Tìm bi hợp lệ có đường ngắm trực tiếp thông thoáng nhất
    PoolBall? bestDirectBall;
    double bestDirectDist = double.infinity;
    Vector2? bestDirectAim;

    for (final ball in legalBalls) {
      if (_isBotPathClear(cueBall.body.position, ball.body.position, excluded: ball)) {
        final dist = (ball.body.position - cueBall.body.position).length;
        if (dist < bestDirectDist) {
          bestDirectDist = dist;
          bestDirectBall = ball;
          bestDirectAim = ball.body.position - cueBall.body.position;
        }
      }
    }

    if (bestDirectBall != null && bestDirectAim != null) {
      return BotShot(
        direction: bestDirectAim,
        totalDistance: bestDirectDist,
        spin: Offset.zero,
        power: 0.34, // Đánh lực vừa phải chạm bi hợp lệ và đưa bi chạm băng
      );
    }

    // 2. Nếu tất cả bi hợp lệ bị che khuất (Snookered): Thử cú A-băng dội thành chạm bi hợp lệ
    final walls = [
      playAreaTopLeft.y + ballRadius,
      playAreaBottomRight.x - ballRadius,
      playAreaBottomRight.y - ballRadius,
      playAreaTopLeft.x + ballRadius,
    ];

    for (final ball in legalBalls) {
      // Dội băng trên
      final mirrorTop = Vector2(ball.body.position.x, 2 * walls[0] - ball.body.position.y);
      final rayTop = mirrorTop - cueBall.body.position;
      if (rayTop.y < 0) {
        final t = (walls[0] - cueBall.body.position.y) / rayTop.y;
        final railPoint = cueBall.body.position + rayTop * t;
        if (railPoint.x >= playAreaTopLeft.x + ballRadius &&
            railPoint.x <= playAreaBottomRight.x - ballRadius) {
          if (_isBotPathClear(cueBall.body.position, railPoint) &&
              _isBotPathClear(railPoint, ball.body.position, excluded: ball)) {
            final aimDir = railPoint - cueBall.body.position;
            return BotShot(
              direction: aimDir,
              totalDistance: aimDir.length + (ball.body.position - railPoint).length,
              spin: Offset.zero,
              power: 0.48,
            );
          }
        }
      }

      // Dội băng dưới
      final mirrorBottom = Vector2(ball.body.position.x, 2 * walls[2] - ball.body.position.y);
      final rayBottom = mirrorBottom - cueBall.body.position;
      if (rayBottom.y > 0) {
        final t = (walls[2] - cueBall.body.position.y) / rayBottom.y;
        final railPoint = cueBall.body.position + rayBottom * t;
        if (railPoint.x >= playAreaTopLeft.x + ballRadius &&
            railPoint.x <= playAreaBottomRight.x - ballRadius) {
          if (_isBotPathClear(cueBall.body.position, railPoint) &&
              _isBotPathClear(railPoint, ball.body.position, excluded: ball)) {
            final aimDir = railPoint - cueBall.body.position;
            return BotShot(
              direction: aimDir,
              totalDistance: aimDir.length + (ball.body.position - railPoint).length,
              spin: Offset.zero,
              power: 0.48,
            );
          }
        }
      }
    }

    // 3. Phương án cuối cùng: Nhắm thẳng vào bi hợp lệ gần nhất
    legalBalls.sort((a, b) =>
      (a.body.position - cueBall.body.position).length2.compareTo(
        (b.body.position - cueBall.body.position).length2,
      ),
    );
    final fallbackTarget = legalBalls.first;
    final fallbackDir = fallbackTarget.body.position - cueBall.body.position;
    return BotShot(
      direction: fallbackDir,
      totalDistance: fallbackDir.length,
      spin: Offset.zero,
      power: 0.35,
    );
  }

  BallGroup? _inferBotGroup() {
    final opponentGroup = playerGroups[1];
    if (opponentGroup == null) {
      return null;
    }
    return opponentGroup == BallGroup.solids
        ? BallGroup.stripes
        : BallGroup.solids;
  }

  BallGroup? getPlayerGroup(int player) {
    if (playerGroups.containsKey(player)) {
      return playerGroups[player];
    }
    if (player == 2 && playerGroups.containsKey(1)) {
      return _inferBotGroup();
    }
    if (player == 1 && playerGroups.containsKey(2)) {
      return playerGroups[2] == BallGroup.solids
          ? BallGroup.stripes
          : BallGroup.solids;
    }
    return null;
  }

  Vector2 _nearestPocket(Vector2 ballPosition, List<Vector2> pockets) {
    return pockets.reduce(
      (a, b) => (a - ballPosition).length2 < (b - ballPosition).length2 ? a : b,
    );
  }

  bool _isBotPathClear(Vector2 start, Vector2 end, {PoolBall? excluded}) {
    final path = end - start;
    final pathLength2 = path.length2;
    if (pathLength2 <= 1) {
      return false;
    }
    for (final ball in poolBalls) {
      if (ball == excluded || ball.isRemoved || ball.isSunk) {
        continue;
      }
      final toBall = ball.body.position - start;
      final projection = (toBall.dot(path) / pathLength2).clamp(0.0, 1.0);
      final closestPoint = start + path * projection;
      if ((ball.body.position - closestPoint).length < ballRadius * 2.06) {
        return false;
      }
    }
    return true;
  }

  bool _isInsidePlayableArea(Vector2 position) {
    return position.x >= playAreaTopLeft.x + ballRadius &&
        position.x <= playAreaBottomRight.x - ballRadius &&
        position.y >= playAreaTopLeft.y + ballRadius &&
        position.y <= playAreaBottomRight.y - ballRadius;
  }

  List<Vector2> _botPocketPositions() {
    return [
      Vector2(size.x * 0.0520, size.y * 0.0915), // Top-Left
      Vector2(size.x * 0.4985, size.y * 0.0756), // Top-Middle
      Vector2(size.x * 0.9480, size.y * 0.0915), // Top-Right
      Vector2(size.x * 0.0520, size.y * 0.9085), // Bottom-Left
      Vector2(size.x * 0.4988, size.y * 0.9159), // Bottom-Middle
      Vector2(size.x * 0.9480, size.y * 0.9085), // Bottom-Right
    ];
  }

  void rotateAimToPoint(Vector2 touchPosition) {
    if (!canUserControl || ballInHand || !physicsReady || !_hasGameLoaded) {
      return;
    }
    final offset = touchPosition - cueBall.body.position;
    if (offset.length2 > 4) {
      aimAngle = math.atan2(offset.y, offset.x);
      cueBall.isAiming = true;
      _updateAimVector(ballRadius * 2);
      if (isLocalMultiplayer.value && isMyTurn) {
        LocalMultiplayerService.instance.sendAim(
          angle: aimAngle,
          power: shotPower.value,
        );
      }
    }
  }

  void rotateAim(double delta) {
    if (!canUserControl) {
      return;
    }
    aimAngle += delta;
    if (_hasGameLoaded && physicsReady) {
      cueBall.isAiming = true;
      _updateAimVector(ballRadius * 2);
    }
    if (isLocalMultiplayer.value && isMyTurn) {
      LocalMultiplayerService.instance.sendAim(
        angle: aimAngle,
        power: shotPower.value,
      );
    }
  }

  void _updateAimVector(double length) {
    if (!_hasGameLoaded) return;
    cueBall.aimVector =
        Vector2(math.cos(aimAngle), math.sin(aimAngle)) * length;
  }

  @override
  void onPanStart(DragStartInfo info) {
    if (!canUserControl || !_hasGameLoaded || !physicsReady) {
      return;
    }
    dragStart = info.eventPosition.widget;
    dragCurrent = dragStart;
    if (ballInHand) {
      movingCueBall =
          (dragStart! - cueBall.body.position).length <= ballRadius * 2.5;
      if (movingCueBall) {
        cueBall.isAiming = false;
      }
      return;
    }
    rotateAimToPoint(dragStart!);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (!canUserControl || !_hasGameLoaded || !physicsReady) return;
    dragCurrent = info.eventPosition.widget;
    if (dragStart != null) {
      if (movingCueBall) {
        moveCueBallTo(dragCurrent!);
        return;
      }
      rotateAimToPoint(dragCurrent!);
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (!canUserControl || !_hasGameLoaded || !physicsReady) return;
    if (movingCueBall) {
      movingCueBall = false;
      ballInHand = false;
      cueBall.isAiming = true;
      _updateAimVector(ballRadius * 2);
    }
    dragStart = null;
    dragCurrent = null;
  }

  void _prepareCueBallForPlacement() {
    resetCueSpin();
    var position = initialCueBallPosition;
    final r = ballRadius * 2.1;
    var shift = 0.0;
    while (poolBalls.any((b) => !b.isSunk && (b.body.position - position).length < r) && shift < size.x * 0.3) {
      shift += ballRadius * 1.5;
      position = Vector2(
        (size.x * 0.25 - shift).clamp(playAreaTopLeft.x + ballRadius * 2, size.x * 0.5),
        size.y / 2,
      );
    }
    cueBall.isSunk = false;
    cueBall.body.setTransform(position, 0);
    cueBall.body.linearVelocity.setZero();
    cueBall.body.angularVelocity = 0;
    cueBall.body.clearForces();
    cueBall.body.setAwake(true);
    cueBall.isAiming = false;
    cueBall.strokeDistance = 0;
  }

  Vector2 get initialCueBallPosition => Vector2(size.x * 0.25, size.y / 2);

  void moveCueBallTo(Vector2 requestedPosition) {
    final position = Vector2(
      requestedPosition.x.clamp(
        playAreaTopLeft.x + ballRadius,
        playAreaBottomRight.x - ballRadius,
      ),
      requestedPosition.y.clamp(
        playAreaTopLeft.y + ballRadius,
        playAreaBottomRight.y - ballRadius,
      ),
    );
    final overlapsBall = poolBalls.any(
      (ball) =>
          !ball.isSunk &&
          (ball.body.position - position).length < ballRadius * 2.05,
    );
    if (!overlapsBall) {
      cueBall.isSunk = false;
      cueBall.body.setTransform(position, 0);
      cueBall.body.linearVelocity.setZero();
      cueBall.body.angularVelocity = 0;
      cueBall.body.clearForces();
      cueBall.body.setAwake(true);
      if (isLocalMultiplayer.value && isMyTurn) {
        LocalMultiplayerService.instance.sendBallInHand(
          x: position.x,
          y: position.y,
        );
      }
    }
  }

  void finishShot() {
    resetCueSpin();
    shotInProgress = false;
    cueBall.isAiming = true;
    _updateAimVector(ballRadius * 2);

    // Xử lý riêng cho chế độ Thế Bi Hàng Ngày (Daily Puzzle)
    if (activeDailyPuzzle != null) {
      dailyPuzzleShotsTaken++;
      final targetBalls = activeDailyPuzzle!.balls
          .where((b) => !b.isObstacle)
          .map((b) => b.ballNumber)
          .toSet();
      final obstacleBalls = activeDailyPuzzle!.balls
          .where((b) => b.isObstacle)
          .map((b) => b.ballNumber)
          .toSet();

      final cueScratched = cueBall.pocketedThisShot;
      final obstacleSunk = poolBalls.any(
        (b) => b.isSunk && obstacleBalls.contains(b.number),
      );
      final allTargetsSunk = poolBalls
          .where((b) => targetBalls.contains(b.number))
          .every((b) => b.isSunk);

      if (cueScratched || obstacleSunk) {
        ruleMessage.value = cueScratched
            ? 'Thất bại: Bi cái rơi lỗ!'
            : 'Thất bại: Bi chướng ngại rơi lỗ!';
        winningPlayer = 2; // Thất bại
        rackOver = true;
      } else if (allTargetsSunk) {
        ruleMessage.value = 'Chúc mừng! Phá giải thế bi thành công!';
        winningPlayer = 1; // Thắng cuộc
        rackOver = true;
      } else if (dailyPuzzleShotsTaken >= activeDailyPuzzle!.maxShotsAllowed) {
        ruleMessage.value =
            'Thất bại: Hết số cơ cho phép (${activeDailyPuzzle!.maxShotsAllowed})!';
        winningPlayer = 2;
        rackOver = true;
      } else {
        ruleMessage.value =
            'Lượt $dailyPuzzleShotsTaken/${activeDailyPuzzle!.maxShotsAllowed} - Đánh tiếp!';
      }
      groupVersion.value++;
      matchVersion.value++;
      return;
    }

    final currentPlayer = currentTurn.value;
    final pocketedThisShot = poolBalls
        .where((ball) => ball.pocketedThisShot)
        .toList();
    final eightPocketed = pocketedThisShot.any((ball) => ball.number == 8);
    final group = getPlayerGroup(currentPlayer);
    final firstHit = cueBall.firstObjectBallHit;
    final legalTargetHit =
        firstHit == null ||
        (firstHit != 8 && (group == null || ballGroup(firstHit) == group)) ||
        (firstHit == 8 && group != null && allGroupBallsPocketed(group));
    final foul =
        cueBall.pocketedThisShot ||
        !cueBall.hitObjectThisShot ||
        !legalTargetHit ||
        (breakShot && pocketedThisShot.isEmpty && objectBallsHitRails < 4);

    if (foul) {
      if (eightPocketed) {
        ruleMessage.value = 'Foul: 8-ball on an illegal shot';
        winningPlayer = currentPlayer == 1 ? 2 : 1;
        playerScores[winningPlayer!] = (playerScores[winningPlayer!] ?? 0) + 1;
        rackOver = true;
      } else {
        ruleMessage.value = 'Foul - ball in hand';
        switchTurn();
        ballInHand = true;
        _prepareCueBallForPlacement();
      }
    } else if (eightPocketed) {
      final canWin = group != null && allGroupBallsPocketed(group);
      if (canWin) {
        ruleMessage.value = 'Player $currentPlayer wins the rack!';
        winningPlayer = currentPlayer;
        playerScores[currentPlayer] = (playerScores[currentPlayer] ?? 0) + 1;
      } else {
        ruleMessage.value = 'Player $currentPlayer loses: 8-ball early';
        winningPlayer = currentPlayer == 1 ? 2 : 1;
        playerScores[winningPlayer!] = (playerScores[winningPlayer!] ?? 0) + 1;
      }
      rackOver = true;
    } else if (breakShot) {
      breakShot = false;
      ruleMessage.value = pocketedThisShot.isNotEmpty
          ? 'Player $currentPlayer continues'
          : 'Player ${currentPlayer == 1 ? 2 : 1} turn';
      if (pocketedThisShot.isEmpty) {
        switchTurn();
      }
    } else if (group == null &&
        pocketedThisShot.any((ball) => ball.number != 8)) {
      assignGroupAfterBreak(pocketedThisShot);
      ruleMessage.value = 'Player $currentPlayer continues';
    } else if (pocketedThisShot.any(
      (ball) => ballGroup(ball.number) == group,
    )) {
      ruleMessage.value = 'Player $currentPlayer continues';
    } else {
      ruleMessage.value = 'Player ${currentPlayer == 1 ? 2 : 1} turn';
      switchTurn();
    }
    if (isLocalMultiplayer.value && !rackOver) {
      ruleMessage.value = isMyTurn
          ? 'Đấu mạng: Lượt của bạn!'
          : 'Đấu mạng: Lượt của đối thủ...';
    }
    if (rackOver) {
      _processMatchRewards();
    }
    groupVersion.value++;
    matchVersion.value++;
  }

  BallGroup? ballGroup(int number) {
    if (number < 8) return BallGroup.solids;
    if (number > 8) return BallGroup.stripes;
    return null; // Bi 8 là bi đen trung lập, không thuộc nhóm bi trơn hay bi sọc
  }

  void assignGroupAfterBreak(List<PoolBall> pocketed) {
    final candidates = pocketed.where((ball) => ball.number != 8).toList();
    final firstObject = candidates.isEmpty ? null : candidates.first;
    if (firstObject != null) {
      final grp = ballGroup(firstObject.number);
      if (grp != null) {
        playerGroups[currentTurn.value] = grp;
        playerGroups[currentTurn.value == 1 ? 2 : 1] =
            grp == BallGroup.solids ? BallGroup.stripes : BallGroup.solids;
        groupVersion.value++;
      }
    }
  }

  String groupLabel(int player) {
    final group = getPlayerGroup(player);
    if (group == BallGroup.solids) {
      return 'Bi trơn 1-7';
    }
    if (group == BallGroup.stripes) {
      return 'Bi sọc 9-15';
    }
    return '';
  }

  List<int> groupBalls(int player) {
    final group = getPlayerGroup(player);
    if (group == null) {
      return const [];
    }
    return group == BallGroup.solids
        ? List<int>.generate(7, (index) => index + 1)
        : List<int>.generate(7, (index) => index + 9);
  }

  bool isBallPocketed(int number) => poolBalls.any(
    (ball) => ball.number == number && (ball.isSunk || ball.isRemoved),
  );

  bool allGroupBallsPocketed(BallGroup group) => poolBalls
      .where((ball) => ball.number != 8 && ballGroup(ball.number) == group)
      .every((ball) => ball.isRemoved || ball.isSunk);

  void _processMatchRewards() {
    final isWinner = winningPlayer == 1;
    final p1Balls = groupBalls(1);
    final pocketed = p1Balls.isEmpty
        ? 0
        : p1Balls.where((bNum) => isBallPocketed(bNum)).length;

    if (activeDailyPuzzle != null) {
      if (isWinner) {
        _lastMatchReward = ProgressionService.instance.claimDailyPuzzleReward(
          activeDailyPuzzle!,
        );
      } else {
        _lastMatchReward = null;
      }
    } else if (activeBotStage != null) {
      if (isWinner) {
        _lastMatchReward = ProgressionService.instance.completeBotStage(
          activeBotStage!,
        );
      } else {
        _lastMatchReward = ProgressionService.instance.handleMatchRewards(
          isWinner: false,
          pottedBallsCount: pocketed,
        );
      }
    } else {
      _lastMatchReward = ProgressionService.instance.handleMatchRewards(
        isWinner: isWinner,
        pottedBallsCount: pocketed,
      );
    }
  }

  void registerRailHit(Object bodyOwner) {
    if (bodyOwner is PoolBall && !bodyOwner.isSunk) {
      objectBallHitRailThisShot = true;
      objectBallsHitRails++;
    }
  }

  PoolBall? targetForAim(Vector2 direction) {
    if (!_hasGameLoaded) return null;
    PoolBall? target;
    var nearestDistance = double.infinity;
    for (final ball in poolBalls) {
      if (ball.isRemoved || ball.isSunk) {
        continue;
      }
      final offset = ball.body.position - cueBall.body.position;
      final forwardDistance = offset.dot(direction);
      if (forwardDistance <= 0) {
        continue;
      }
      final sideDistance = (offset - direction * forwardDistance).length;
      if (sideDistance <= ballRadius * 1.25 &&
          forwardDistance < nearestDistance) {
        nearestDistance = forwardDistance;
        target = ball;
      }
    }
    return target;
  }

  AimGuide? guideForAim(Vector2 direction) {
    if (!_hasGameLoaded) return null;
    final normalizedDirection = direction.normalized();
    AimGuide? guide;
    var nearestDistance = double.infinity;
    final collisionDistance = (cueBall.hitboxRadius * 2.0);

    for (final ball in poolBalls) {
      if (ball.isRemoved || ball.isSunk) {
        continue;
      }
      final offset = ball.body.position - cueBall.body.position;
      final projectedDistance = offset.dot(normalizedDirection);
      if (projectedDistance <= 0) {
        continue;
      }
      final perpendicular = offset - normalizedDirection * projectedDistance;
      final perpendicularDistance = perpendicular.length;
      if (perpendicularDistance > collisionDistance) {
        continue;
      }
      final alongCircle = math.sqrt(
        math.max(
          0,
          collisionDistance * collisionDistance -
              perpendicularDistance * perpendicularDistance,
        ),
      );
      final impactDistance = projectedDistance - alongCircle;
      if (impactDistance <= 0 || impactDistance >= nearestDistance) {
        continue;
      }
      final impactPoint =
          cueBall.body.position + normalizedDirection * impactDistance;
      final objectDirection = (ball.body.position - impactPoint).normalized();
      final ghostCenter =
          ball.body.position - objectDirection * collisionDistance;

      // Tính toán hướng rẽ của bi cái (định luật 90 độ tiếp tuyến + tác động xoáy)
      final normal = objectDirection;
      final dot = normalizedDirection.dot(normal);
      Vector2 tangent = normalizedDirection - normal * dot;
      if (tangent.length2 > 0.0001) {
        tangent.normalize();
      } else {
        tangent = Vector2(-normal.y, normal.x);
      }

      final spin = cueSpin.value;
      Vector2 predictedCueDir = tangent;
      if (spin.dy > 0.05) {
        // Trô bóng (Lùi): kéo lệch hướng lùi về phía sau (-normal)
        predictedCueDir = (tangent * (1.0 - spin.dy * 0.45) - normal * (spin.dy * 0.75)).normalized();
      } else if (spin.dy < -0.05) {
        // Cu-lê (Tiến): đẩy lệch hướng tiến theo hướng ngắm ban đầu
        final follow = -spin.dy;
        predictedCueDir = (tangent * (1.0 - follow * 0.45) + normalizedDirection * (follow * 0.75)).normalized();
      }
      if (spin.dx.abs() > 0.05) {
        predictedCueDir = (predictedCueDir + tangent * (spin.dx * 0.18)).normalized();
      }

      guide = AimGuide(ball, impactPoint, objectDirection, ghostCenter, predictedCueDir);
      nearestDistance = impactDistance;
    }
    return guide;
  }

  Vector2 lineToTableEdge(Vector2 start, Vector2 direction) {
    final ray = direction.normalized();
    var distance = double.infinity;
    if (ray.x > 0) {
      distance = math.min(
        distance,
        (playAreaBottomRight.x - ballRadius - start.x) / ray.x,
      );
    } else if (ray.x < 0) {
      distance = math.min(
        distance,
        (playAreaTopLeft.x + ballRadius - start.x) / ray.x,
      );
    }
    if (ray.y > 0) {
      distance = math.min(
        distance,
        (playAreaBottomRight.y - ballRadius - start.y) / ray.y,
      );
    } else if (ray.y < 0) {
      distance = math.min(
        distance,
        (playAreaTopLeft.y + ballRadius - start.y) / ray.y,
      );
    }
    return start + ray * math.max(0.0, distance);
  }
}

class BotShot {
  final Vector2 direction;
  final double totalDistance;
  final Offset spin;
  final double power;

  BotShot({
    required this.direction,
    required this.totalDistance,
    required this.spin,
    this.power = 0.5,
  });
}

class AimGuide {
  final PoolBall target;
  final Vector2 impactPoint;
  final Vector2 objectDirection;
  final Vector2 ghostCenter;
  final Vector2 cueDeflection;

  AimGuide(
    this.target,
    this.impactPoint,
    this.objectDirection,
    this.ghostCenter,
    this.cueDeflection,
  );
}

// ================= LỚP VẬT LÝ =================

class Wall extends BodyComponent {
  final Vector2 start;
  final Vector2 end;
  final double restitution;
  final double friction;
  final bool isFacing;

  Wall(
    this.start,
    this.end, {
    this.restitution = 0.82,
    this.friction = 0.10,
    this.isFacing = false,
  }) : super(renderBody: false);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(start, end);
    final fixtureDef = FixtureDef(
      shape,
      friction: friction,
      restitution: restitution,
    );
    final createdBody = world.createBody(BodyDef(type: BodyType.static))
      ..createFixture(fixtureDef);
    createdBody.userData = this;
    return createdBody;
  }
}

// Lớp quản lý va chạm chung cho toàn bộ bàn bida
class BilliardContactListener extends ContactListener {
  static BilliardGame? activeGame;

  @override
  void beginContact(Contact contact) {
    final fixtureA = contact.fixtureA;
    final fixtureB = contact.fixtureB;

    final bodyA = fixtureA.body;
    final bodyB = fixtureB.body;

    // Kiểm tra nếu một bên là Lỗ (Pocket) và bên còn lại là Bi (Ball)
    _checkPocketCollision(bodyA, bodyB);
    _checkPocketCollision(bodyB, bodyA);
    _checkBallCollision(bodyA, bodyB);
    _checkRailCollision(bodyA, bodyB);
    _checkRailCollision(bodyB, bodyA);
  }

  void _checkRailCollision(Body first, Body second) {
    if (first.userData is Wall && second.userData is CueBall) {
      final wall = first.userData as Wall;
      if (!wall.isFacing) {
        _applyCushionSpin(second.userData as CueBall, wall);
      } else {
        activeGame?.registerRailHit(second.userData!);
      }
    } else if (first.userData is Wall && second.userData is PoolBall) {
      activeGame?.registerRailHit(second.userData!);
    }
  }

  void _applyCushionSpin(CueBall cue, Wall wall) {
    activeGame?.registerRailHit(cue);

    final spin = cue.activeSpin;
    if (spin.dx.abs() < 0.05) {
      return;
    }

    final wallVec = (wall.end - wall.start).normalized();
    final tableCenter = activeGame != null
        ? Vector2(activeGame!.size.x / 2, activeGame!.size.y / 2)
        : Vector2(500, 250);
    final wallMid = (wall.start + wall.end) * 0.5;
    final toCenter = (tableCenter - wallMid).normalized();

    Vector2 normal = Vector2(-wallVec.y, wallVec.x);
    if (normal.dot(toCenter) < 0) {
      normal = -normal;
    }
    // Tiếp tuyến sao cho quay ngược chiều kim đồng hồ 90 độ từ pháp tuyến
    final tangent = Vector2(-normal.y, normal.x);

    final speed = cue.body.linearVelocity.length;
    // Áp-phê tác động lực dọc theo mép băng (running english nảy choãi, reverse english nảy gắt)
    final spinKick = tangent * (spin.dx * math.min(speed * 0.38, 260.0));
    cue.body.linearVelocity.add(spinKick);

    // Băng tiêu hao bớt một phần áp-phê
    cue.activeSpin = Offset(cue.activeSpin.dx * 0.55, cue.activeSpin.dy * 0.65);
  }

  void _checkBallCollision(Body first, Body second) {
    final cue = first.userData is CueBall
        ? first.userData as CueBall
        : second.userData is CueBall
        ? second.userData as CueBall
        : null;
    final target = first.userData is PoolBall
        ? first.userData as PoolBall
        : second.userData is PoolBall
        ? second.userData as PoolBall
        : null;
    if (cue != null && target != null) {
      cue.hitObjectThisShot = true;
      cue.firstObjectBallHit ??= target.number;
      if (!cue.hasCollidedBall) {
        cue.hasCollidedBall = true;
        // Áp dụng lực giật lùi (Trô) hoặc đẩy tới (Cu-lê) dựa trên activeSpin
        if (cue.shotDirection != null) {
          final dir = cue.shotDirection!;
          if (cue.activeSpin.dy > 0.08) {
            // Trô bóng (draw shot) - giật ngược lại
            cue.drawFollowForce = -dir * (cue.activeSpin.dy * 340.0);
            cue.drawFollowTimer = 0.35;
          } else if (cue.activeSpin.dy < -0.08) {
            // Cu-lê (follow shot) - đẩy tiến tới
            cue.drawFollowForce = dir * (-cue.activeSpin.dy * 320.0);
            cue.drawFollowTimer = 0.35;
          }
        }
      }
    }
  }

  void _checkPocketCollision(Body pocketBody, Body ballBody) {
    if (pocketBody.userData is Pocket) {
      final pocket = pocketBody.userData as Pocket;
      final game = activeGame;
      if (game != null && !game.canBallEnterPocket(ballBody, pocket)) {
        return;
      }
      if (ballBody.userData is PoolBall) {
        final ball = ballBody.userData as PoolBall;
        ball.isSunk = true;
        ball.pocketedThisShot = true;
      } else if (ballBody.userData is CueBall) {
        final cueBall = ballBody.userData as CueBall;
        cueBall.isSunk = true;
        cueBall.pocketedThisShot = true;
      }
    }
  }

  @override
  void endContact(Contact contact) {}

  @override
  void preSolve(Contact contact, Manifold oldManifold) {}

  @override
  void postSolve(Contact contact, ContactImpulse impulse) {}
}

// Cảm biến Lỗ Bida
class Pocket extends BodyComponent {
  @override
  final Vector2 position;
  final double radius;
  final bool isMiddle;
  final double dropDistance;

  Pocket(
    this.position,
    this.radius, {
    this.isMiddle = false,
    double? dropDistance,
  })  : dropDistance = dropDistance ?? radius,
        super(renderBody: false);

  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;
    // isSensor: true giúp bi lọt qua thay vì dội lại như đập tường
    final fixtureDef = FixtureDef(shape, isSensor: true);
    final createdBody = world.createBody(
      BodyDef(type: BodyType.static, position: position),
    )..createFixture(fixtureDef);
    createdBody.userData = this;
    return createdBody;
  }
}

// Lớp hỗ trợ tia ngắm A-Băng
class AimRayCastCallback extends RayCastCallback {
  final Body ignoreBody;
  Vector2? hitPoint, hitNormal;
  Fixture? hitFixture;

  AimRayCastCallback(this.ignoreBody);

  @override
  double reportFixture(
    Fixture fixture,
    Vector2 point,
    Vector2 normal,
    double fraction,
  ) {
    if (fixture.body == ignoreBody || fixture.isSensor) {
      return -1.0; // Xuyên qua Lỗ Bida
    }
    hitPoint = point.clone();
    hitNormal = normal.clone();
    hitFixture = fixture;
    return fraction;
  }
}

class CueBall extends BodyComponent {
  final Vector2 initialPosition;
  double radius;
  double hitboxRadius;

  Vector2? aimVector, rayHitPoint, reflectionVector;
  Sprite? cueSprite;
  Sprite? cueStickSprite;
  double strokeDistance = 0;
  Offset spinInfluence = Offset.zero;
  Offset activeSpin = Offset.zero;
  Vector2? shotDirection;
  bool hasCollidedBall = false;
  double drawFollowTimer = 0.0;
  Vector2 drawFollowForce = Vector2.zero();
  bool isAiming = true;
  bool isSunk = false;
  bool hitObjectThisShot = false;
  int? firstObjectBallHit;
  bool pocketedThisShot = false;

  CueBall(
    this.initialPosition,
    this.radius, {
    double? hitboxRadius,
  }) : hitboxRadius = hitboxRadius ?? (radius * 0.88);

  void updateRadius(double newRadius) {
    radius = newRadius;
    hitboxRadius = newRadius * 0.88;
    try {
      for (final f in body.fixtures) {
        if (f.shape is CircleShape) {
          f.shape.radius = hitboxRadius;
        }
      }
    } catch (_) {}
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    cueSprite = await Sprite.load('cue_bal.png');
    cueStickSprite = await Sprite.load('cue_stick.png');
  }

  @override
  Body createBody() {
    final shape = CircleShape()..radius = hitboxRadius;
    final fixtureDef = FixtureDef(
      shape,
      restitution: 0.86,
      density: 0.8,
      friction: 0.22,
    );
    final createdBody = world.createBody(
      BodyDef(
        type: BodyType.dynamic,
        position: initialPosition,
        bullet: true,
        fixedRotation: false,
        linearDamping: 0.0,
        angularDamping: 0.18,
      ),
    )..createFixture(fixtureDef);
    createdBody.userData = this;
    return createdBody;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isSunk) {
      body.linearVelocity.setZero();
      body.angularVelocity = 0;
      isAiming = false;
      return;
    }

    if (aimVector != null && aimVector!.length > 0.0) {
      final callback = AimRayCastCallback(body);
      final p1 = body.position;
      final direction = aimVector!.normalized();
      final p2 = p1 + (direction * 2000.0);
      world.raycast(callback, p1, p2);

      if (callback.hitPoint != null &&
          callback.hitNormal != null &&
          callback.hitFixture != null) {
        rayHitPoint = callback.hitPoint;
        final v = direction;
        final n = callback.hitNormal!;
        final dotProduct = v.dot(n);

        if (callback.hitFixture!.shape.shapeType == ShapeType.circle) {
          Vector2 tangentVector = v - (n * dotProduct);
          reflectionVector = tangentVector.length2 > 0.001
              ? tangentVector.normalized()
              : Vector2.zero();
        } else {
          reflectionVector = (v - (n * 2.0 * dotProduct))..normalize();
        }
      } else {
        rayHitPoint = null;
        reflectionVector = null;
      }
    } else {
      rayHitPoint = null;
      reflectionVector = null;
    }
  }

  @override
  void render(Canvas canvas) {
    if (isSunk) {
      return;
    }
    // The physics body can spin, but aiming is defined in world space.
    canvas.save();
    canvas.rotate(-body.angle);
    if (isAiming &&
        aimVector != null &&
        aimVector!.length > 0.0) {
      final direction = aimVector!.normalized();

      // Cây cơ hiển thị theo gậy người chơi đang trang bị (hoặc gậy của Bot khi đến lượt Bot)
      CueModel activeCue = ProgressionService.instance.equippedCue;
      int activeLevel = ProgressionService.instance.equippedCueLevel;
      if (gameInstance.isBotMode.value &&
          gameInstance.currentTurn.value == 2 &&
          gameInstance.activeBotStage != null) {
        activeCue = gameInstance.activeBotStage!.cue;
        activeLevel = gameInstance.activeBotStage!.stageNumber;
      }

      _renderEquippedCueStick(
        canvas,
        direction,
        strokeDistance,
        activeCue,
        activeLevel,
      );
    }

    if (cueSprite != null) {
      canvas.save();
      cueSprite!.render(
        canvas,
        position: Vector2(-radius, -radius),
        size: Vector2(radius * 2, radius * 2),
      );
      canvas.restore();
    }

    if (isAiming && aimVector != null) {
      canvas.save();
      final aimPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..strokeWidth = 0.4;
      final direction = aimVector!.normalized();
      final guide = (game as BilliardGame).guideForAim(direction);

      final cue = ProgressionService.instance.equippedCue;
      final level = ProgressionService.instance.equippedCueLevel;
      final aimMult = (gameInstance.currentTurn.value == 1 && !gameInstance.isBotMode.value) || (!gameInstance.isBotMode.value)
          ? cue.getAimMultiplier(level)
          : 1.0;

      if (guide != null) {
        final targetOffset = guide.impactPoint - body.position;
        final targetCenterOffset = guide.target.body.position - body.position;
        final ghostOffset = guide.ghostCenter - body.position;
        final targetLineEnd =
            (game as BilliardGame).lineToTableEdge(
              guide.target.body.position,
              guide.objectDirection,
            ) -
            body.position;

        // Vệt hào quang ma pháp nếu gậy đạt Lv >= 7 (Epic/Legendary)
        if (level >= 7) {
          canvas.drawCircle(
            ghostOffset.toOffset(),
            radius * 1.35,
            Paint()
              ..color = cue.auraColor.withValues(alpha: 0.4)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5,
          );
        }

        // 1. Đường ngắm bi cái tới điểm tiếp xúc (Ghost Ball)
        canvas.drawLine(
          Offset.zero,
          ghostOffset.toOffset(),
          Paint()
            ..color = (level >= 8 ? cue.ballTrailColor : Colors.cyanAccent).withValues(alpha: 0.9)
            ..strokeWidth = 1.1 + (level >= 8 ? 0.3 : 0.0),
        );

        // 2. Đường lăn dự kiến của bi mục tiêu (kéo dài theo aimMult)
        final extendedEnd = targetOffset + (targetLineEnd - targetOffset) * aimMult.clamp(0.8, 1.4);
        canvas.drawLine(
          targetOffset.toOffset(),
          extendedEnd.toOffset(),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.75)
            ..strokeWidth = 0.7,
        );

        // 3. Vòng tròn bi mục tiêu và điểm tiếp xúc
        canvas.drawCircle(
          targetCenterOffset.toOffset(),
          radius,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8,
        );
        canvas.drawCircle(
          ghostOffset.toOffset(),
          radius,
          Paint()
            ..color = (level >= 8 ? cue.ballTrailColor : Colors.cyanAccent).withValues(alpha: 0.85)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8,
        );
        canvas.drawLine(
          ghostOffset.toOffset(),
          targetOffset.toOffset(),
          Paint()
            ..color = Colors.orangeAccent.withValues(alpha: 0.9)
            ..strokeWidth = 0.9,
        );
        canvas.drawCircle(
          targetOffset.toOffset(),
          radius * 0.22,
          Paint()..color = Colors.orangeAccent.withValues(alpha: 0.95),
        );

        // 4. Đường rẽ của bi cái sau va chạm (hiển thị tác động xoáy Cu-lê, Trô bóng, Áp-phê có nhân aimMult)
        final deflectionLength = (50.0 + gameInstance.shotPower.value * 120.0).clamp(40.0, 160.0) * aimMult;
        final cueDeflectionEnd = ghostOffset + guide.cueDeflection * deflectionLength;
        canvas.drawLine(
          ghostOffset.toOffset(),
          cueDeflectionEnd.toOffset(),
          Paint()
            ..color = Colors.amberAccent.withValues(alpha: 0.88)
            ..strokeWidth = 0.9,
        );
        canvas.drawCircle(
          cueDeflectionEnd.toOffset(),
          radius * 0.22,
          Paint()..color = Colors.amberAccent.withValues(alpha: 0.95),
        );
      } else if (rayHitPoint != null && reflectionVector != null) {
        // Ngắm A-băng (đập băng trực tiếp): phản ánh góc nảy có xoáy áp-phê
        final localHitPoint = rayHitPoint! - body.position;
        canvas.drawLine(Offset.zero, localHitPoint.toOffset(), aimPaint);
        canvas.drawCircle(
          localHitPoint.toOffset(),
          0.6,
          Paint()..color = Colors.red.withValues(alpha: 0.8),
        );

        // Điều chỉnh góc phản xạ của tia A-băng theo áp-phê
        final spin = (game as BilliardGame).cueSpin.value;
        Vector2 adjustedReflection = reflectionVector!;
        if (spin.dx.abs() > 0.05) {
          final normal = (adjustedReflection - direction).normalized();
          final tangent = Vector2(-normal.y, normal.x);
          adjustedReflection = (adjustedReflection + tangent * (spin.dx * 0.35)).normalized();
        }

        canvas.drawLine(
          localHitPoint.toOffset(),
          (localHitPoint + (adjustedReflection * 45.0 * aimMult)).toOffset(),
          Paint()
            ..color = Colors.yellow.withValues(alpha: 0.7)
            ..strokeWidth = 0.6,
        );
      } else {
        canvas.drawLine(Offset.zero, (aimVector! * 2.5 * aimMult).toOffset(), aimPaint);
      }
      canvas.restore();
    }

    canvas.restore();
  }

  void _renderEquippedCueStick(
    Canvas canvas,
    Vector2 direction,
    double strokeDistance,
    CueModel cue,
    int level,
  ) {
    final stickLength = radius * 19.5;
    final angle = math.atan2(direction.y, direction.x);

    canvas.save();
    // Dịch chuyển đến vị trí đầu cơ cách mép bi cái một khoảng strokeDistance
    canvas.translate(
      -direction.x * (radius * 1.05 + strokeDistance),
      -direction.y * (radius * 1.05 + strokeDistance),
    );
    canvas.rotate(angle);

    // Tip nằm tại x = 0, gậy kéo dài về phía âm trục X (từ 0 đến -stickLength)
    final tipR = radius * 0.22;
    final ferruleR = radius * 0.24;
    final jointR = radius * 0.33;
    final buttR = radius * 0.44;

    // 0. Hào quang tỏa sáng (Aura Glow) cho gậy cấp cao (Lv >= 3 hoặc Epic/Legendary)
    if (level >= 3 || cue.rarity == CueRarity.epic || cue.rarity == CueRarity.legendary) {
      final auraColor = cue.auraColor;
      final auraAlpha = level >= 7 ? 0.60 : 0.38;
      final auraPaint = Paint()
        ..color = auraColor.withValues(alpha: auraAlpha)
        ..strokeWidth = radius * (level >= 7 ? 1.4 : 0.9)
        ..style = PaintingStyle.stroke
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, level >= 7 ? 4.5 : 2.5);
      canvas.drawLine(const Offset(-2, 0), Offset(-stickLength + 2, 0), auraPaint);
    }

    void drawSegment({
      required double xStart,
      required double xEnd,
      required double rStart,
      required double rEnd,
      required List<Color> colors,
    }) {
      final path = Path()
        ..moveTo(xStart, -rStart)
        ..lineTo(xEnd, -rEnd)
        ..lineTo(xEnd, rEnd)
        ..lineTo(xStart, rStart)
        ..close();

      final maxR = math.max(rStart, rEnd);
      final c0 = colors[0];
      final cMid = colors.length > 2 ? colors[1] : colors[0];
      final cLast = colors.last;

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            c0,
            cMid,
            const Color(0xFFFFFFFF).withValues(alpha: 0.65), // Vệt phản chiếu ánh sáng trụ 3D
            cMid,
            cLast.withValues(alpha: 0.85),
          ],
          stops: const [0.0, 0.25, 0.48, 0.72, 1.0],
        ).createShader(Rect.fromLTRB(xEnd, -maxR, xStart, maxR));

      canvas.drawPath(path, paint);
    }

    // 1. Đầu lơ (Chalk Tip) bo cong vòm ở đỉnh x = 0
    final tipLen = radius * 0.35;
    final tipPath = Path()
      ..moveTo(0, 0)
      ..arcToPoint(
        Offset(-tipLen, -tipR),
        radius: Radius.circular(tipR),
        clockwise: false,
      )
      ..lineTo(-tipLen, tipR)
      ..arcToPoint(
        const Offset(0, 0),
        radius: Radius.circular(tipR),
        clockwise: false,
      )
      ..close();
    canvas.drawPath(tipPath, Paint()..color = cue.tipColor);

    // 2. Phíp cơ trắng ngà (White Ferrule)
    final ferruleLen = radius * 0.70;
    drawSegment(
      xStart: -tipLen,
      xEnd: -(tipLen + ferruleLen),
      rStart: tipR,
      rEnd: ferruleR,
      colors: const [Color(0xFFDCDCDC), Color(0xFFFFFFFF), Color(0xFFB0B0B0)],
    );

    // Vòng chỉ đen giữa phíp và thân ngọn
    canvas.drawLine(
      Offset(-(tipLen + ferruleLen), -ferruleR),
      Offset(-(tipLen + ferruleLen), ferruleR),
      Paint()
        ..color = const Color(0xFF222222)
        ..strokeWidth = 0.6,
    );

    // 3. Ngọn cơ (Shaft) - thể hiện màu sắc skin đặc trưng của cây gậy
    final jointX = -stickLength * 0.52;
    drawSegment(
      xStart: -(tipLen + ferruleLen),
      xEnd: jointX,
      rStart: ferruleR,
      rEnd: jointR,
      colors: cue.shaftColors,
    );

    // 4. Khớp ren kim loại trang trí dát vàng / chrome (Joint Rings)
    final jointLen = radius * 0.55;
    drawSegment(
      xStart: jointX,
      xEnd: jointX - jointLen,
      rStart: jointR,
      rEnd: jointR + 0.05,
      colors: const [Color(0xFFB8860B), Color(0xFFFFD700), Color(0xFF5A440D)],
    );

    // 5. Chuôi gậy (Handle / Butt) - hoa văn tay cầm của skin
    final buttCapX = -stickLength + radius * 0.50;
    drawSegment(
      xStart: jointX - jointLen,
      xEnd: buttCapX,
      rStart: jointR + 0.05,
      rEnd: buttR,
      colors: cue.handleColors,
    );

    // 6. Đệm cao su chống va đập ở đuôi gậy (Bumper)
    final bumperPath = Path()
      ..moveTo(buttCapX, -buttR)
      ..arcToPoint(
        Offset(-stickLength, 0),
        radius: Radius.circular(buttR),
        clockwise: false,
      )
      ..arcToPoint(
        Offset(buttCapX, buttR),
        radius: Radius.circular(buttR),
        clockwise: false,
      )
      ..close();
    canvas.drawPath(bumperPath, Paint()..color = const Color(0xFF141414));

    canvas.restore();
  }
}

class PoolBall extends BodyComponent {
  final Vector2 initialPosition;
  double radius;
  double hitboxRadius;
  final String imageName;
  final int number;
  Sprite? ballSprite;
  bool isSunk = false;
  bool pocketedThisShot = false;

  PoolBall(
    this.initialPosition,
    this.imageName,
    this.radius,
    this.number, {
    double? hitboxRadius,
  }) : hitboxRadius = hitboxRadius ?? (radius * 0.88);

  void updateRadius(double newRadius) {
    radius = newRadius;
    hitboxRadius = newRadius * 0.88;
    try {
      for (final f in body.fixtures) {
        if (f.shape is CircleShape) {
          f.shape.radius = hitboxRadius;
        }
      }
    } catch (_) {}
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    ballSprite = await Sprite.load(imageName);
  }

  @override
  Body createBody() {
    final shape = CircleShape()..radius = hitboxRadius;
    final fixtureDef = FixtureDef(
      shape,
      restitution: 0.86,
      density: 0.8,
      friction: 0.22,
    );
    final createdBody = world.createBody(
      BodyDef(
        type: BodyType.dynamic,
        position: initialPosition,
        bullet: true,
        fixedRotation: false,
        linearDamping: 0.0,
        angularDamping: 0.18,
      ),
    )..createFixture(fixtureDef);
    createdBody.userData = this;
    return createdBody;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isSunk) {
      body.linearVelocity.setZero();
      body.angularVelocity = 0;
      if (body.position.x > -500) {
        body.setTransform(Vector2(-1000, -1000), 0);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (isSunk || isRemoved || isRemoving) {
      return;
    }
    if (ballSprite != null) {
      canvas.save();
      // ĐÃ BỎ KHÓA GÓC XOAY
      ballSprite!.render(
        canvas,
        position: Vector2(-radius, -radius),
        size: Vector2(radius * 2, radius * 2),
      );
      canvas.restore();
    }
  }
}
