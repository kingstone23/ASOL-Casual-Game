import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Transform;
import 'package:forge2d/forge2d.dart' as forge2d;

enum BallGroup { solids, stripes }

// Khởi tạo instance của game ở ngoài cùng để UI có thể lắng nghe trạng thái (Turn-base)
final BilliardGame gameInstance = BilliardGame();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: const BilliardHome()),
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
    gameInstance.setBotMode(false);
    setState(() => showGame = true);
  }

  void _chooseCpuDifficulty() {
    showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Chọn độ khó CPU'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 1),
            child: const ListTile(
              leading: Icon(Icons.sentiment_satisfied_alt),
              title: Text('Dễ'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 2),
            child: const ListTile(
              leading: Icon(Icons.psychology),
              title: Text('Khó'),
            ),
          ),
        ],
      ),
    ).then((difficulty) {
      if (!mounted || difficulty == null) {
        return;
      }
      gameInstance.setBotDifficulty(difficulty);
      gameInstance.setBotMode(true);
      setState(() => showGame = true);
    });
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
              final compact = constraints.maxHeight < 620;
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 560),
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 20 : 38,
                      vertical: compact ? 22 : 34,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF11633F),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFB77A35),
                        width: 8,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 24,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: compact ? 78 : 96,
                          height: compact ? 78 : 96,
                          padding: const EdgeInsets.all(8),
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
                        const SizedBox(height: 14),
                        const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '8 POOL BILLIARDS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'CHOOSE YOUR MATCH',
                          style: TextStyle(
                            color: Color(0xFFFFD166),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 26),
                        _buildMenuButton(
                          icon: Icons.people,
                          label: 'P1 vs P2',
                          detail: 'Đấu cùng bạn bè',
                          background: const Color(0xFF1D4ED8),
                          onPressed: _startPlayerMatch,
                        ),
                        const SizedBox(height: 12),
                        _buildMenuButton(
                          icon: Icons.smart_toy,
                          label: 'P1 vs CPU',
                          detail: 'Thử sức với máy',
                          background: const Color(0xFF171717),
                          onPressed: _chooseCpuDifficulty,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

Widget _buildMenuButton({
  required IconData icon,
  required String label,
  required String detail,
  required Color background,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  detail,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
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
          final topBarHeight = ultraCompact
              ? 44.0
              : (compactLayout ? 52.0 : 66.0);
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
                                      _buildRackOverlay(),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Nút bấm bắn xoáy góc phải nằm ngay dưới bảng player (Player 2)
                  Positioned(
                    top: topBarHeight +
                        topBarSpacing +
                        (ultraCompact ? 3.0 : (compactLayout ? 5.0 : 8.0)),
                    right: ultraCompact ? 3.0 : (compactLayout ? 6.0 : 12.0),
                    child: _buildTopRightSpinButton(
                      context,
                      compact: compactLayout,
                      ultraCompact: ultraCompact,
                    ),
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

// Widget Nút bấm bi cái góc phải nằm dưới bảng player
Widget _buildTopRightSpinButton(
  BuildContext context, {
  bool compact = false,
  bool ultraCompact = false,
}) {
  final buttonSize = ultraCompact ? 36.0 : (compact ? 44.0 : 54.0);
  return GestureDetector(
    onTap: () {
      if (gameInstance.isBotMode.value &&
          gameInstance.currentTurn.value == 2) {
        return;
      }
      _showCueSpinDialog(context);
    },
    onPanUpdate: (details) {
      if (gameInstance.isBotMode.value &&
          gameInstance.currentTurn.value == 2) {
        return;
      }
      _updateSpinFromTouch(details.localPosition, buttonSize);
    },
    onPanEnd: (_) => gameInstance.commitCueSpin(),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xDD1B2129),
            border: Border.all(color: Colors.white70, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Image.asset('assets/images/cue_bal.png'),
              ),
              // Chấm đỏ hiển thị điểm chạm cơ, luôn nằm chuẩn xác bên trong quả bi cái
              ValueListenableBuilder<Offset>(
                valueListenable: gameInstance.cueSpin,
                builder: (context, spin, child) {
                  final visualRadius = (buttonSize / 2 - 5.0) * 0.78;
                  final dotSize = compact ? 8.0 : 9.5;
                  return Transform.translate(
                    offset: Offset(
                      spin.dx * visualRadius,
                      spin.dy * visualRadius,
                    ),
                    child: Container(
                      width: dotSize,
                      height: dotSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.redAccent,
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: const [
                          BoxShadow(color: Colors.red, blurRadius: 4),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
          decoration: BoxDecoration(
            color: const Color(0xCC15191E),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.white24, width: 0.7),
          ),
          child: const Text(
            'XOÁY',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    ),
  );
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
                                color: Colors.cyanAccent.withOpacity(0.25),
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
                                  color: Colors.redAccent.withOpacity(0.9),
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

Widget _buildRackOverlay() {
  return ValueListenableBuilder<int>(
    valueListenable: gameInstance.matchVersion,
    builder: (context, _, child) {
      if (!gameInstance.rackOver) {
        return const SizedBox.shrink();
      }
      return Positioned.fill(
        child: Container(
          color: Colors.black.withOpacity(0.72),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 360),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF173A32),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 54),
                  const SizedBox(height: 8),
                  Text(
                    gameInstance.winningPlayer == null
                        ? 'Rack kết thúc'
                        : 'Player ${gameInstance.winningPlayer} thắng!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tỷ số  ${gameInstance.playerScores[1] ?? 0} - ${gameInstance.playerScores[2] ?? 0}',
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: gameInstance.restartMatch,
                    icon: const Icon(Icons.replay),
                    label: const Text('Chơi lại'),
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
    child: ValueListenableBuilder<int>(
      valueListenable: gameInstance.groupVersion,
      builder: (context, _, child) {
        return ValueListenableBuilder<int>(
          valueListenable: gameInstance.currentTurn,
          builder: (context, turn, child) {
            return Row(
              children: [
                Expanded(
                  child: _buildPlayerCard(
                    'Player 1',
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
                SizedBox(width: ultraCompact ? 2 : 4),
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
                SizedBox(width: ultraCompact ? 2 : 4),
                Expanded(
                  child: _buildPlayerCard(
                    'Player 2',
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
            );
          },
        );
      },
    ),
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
        if (gameInstance.isBotMode.value &&
            gameInstance.currentTurn.value == 2) {
          return;
        }
        gameInstance.beginPowerDrag(details.localPosition.dy);
      },
      onPanUpdate: (details) {
        if (gameInstance.isBotMode.value &&
            gameInstance.currentTurn.value == 2) {
          return;
        }
        gameInstance.updatePowerDrag(details.localPosition.dy);
      },
      onPanEnd: (_) {
        if (gameInstance.isBotMode.value &&
            gameInstance.currentTurn.value == 2) {
          return;
        }
        gameInstance.endPowerDrag();
        gameInstance.shootWithPower();
      },
      onPanCancel: () {
        if (gameInstance.isBotMode.value &&
            gameInstance.currentTurn.value == 2) {
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
                                  child: _CueStickWidget(
                                    height: trackHeight,
                                    width: stickWidth,
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
  const _CueStickWidget({required this.height, this.width = 16.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _VerticalCueStickPainter(),
    );
  }
}

class _VerticalCueStickPainter extends CustomPainter {
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
    canvas.drawPath(
      tipPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF26A69A), Color(0xFF00897B), Color(0xFF004D40)],
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
      colors: const [
        Color(0xFFFDE8C4),
        Color(0xFFDDB075),
        Color(0xFFB58045),
        Color(0xFF8D5B28),
      ],
      stops: const [0.0, 0.35, 0.75, 1.0],
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
      colors: const [
        Color(0xFF2979FF),
        Color(0xFF1565C0),
        Color(0xFF0D47A1),
        Color(0xFF062B66),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void _showSettings(BuildContext context, {required VoidCallback onHome}) {
  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Cài đặt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Đấu với Bot'),
              subtitle: const Text('Bot sẽ điều khiển Player 2'),
              value: gameInstance.isBotMode.value,
              onChanged: (enabled) {
                gameInstance.setBotMode(enabled);
                setState(() {});
              },
            ),
            if (gameInstance.isBotMode.value)
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Độ khó Bot',
                  border: OutlineInputBorder(),
                ),
                value: gameInstance.botDifficulty.value,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Dễ')),
                  DropdownMenuItem(value: 2, child: Text('Khó')),
                ],
                onChanged: (difficulty) {
                  if (difficulty != null) {
                    gameInstance.setBotDifficulty(difficulty);
                    setState(() {});
                  }
                },
              ),
            const SizedBox(height: 12),
            const Text('Chọn thao tác cho trận đấu hiện tại.'),
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

  late CueBall cueBall;
  final List<PoolBall> poolBalls = [];
  List<Pocket> pockets = [];
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
  double aimAngle = 0.0;

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

  @override
  Color backgroundColor() => const Color(0xFF0F7A3E);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    forge2d.maxTranslation = 42.0;
    forge2d.maxTranslationSquared = 1764.0;
    BilliardContactListener.activeGame = this;

    final tableSprite = await Sprite.load('pool_table.png');
    add(SpriteComponent(sprite: tableSprite, size: size));

    final double paddingX = size.x * 0.0574;
    final double paddingY = size.y * 0.1034;
    playAreaTopLeft = Vector2(paddingX, paddingY);
    playAreaBottomRight = Vector2(size.x - paddingX, size.y - paddingY);

    ballRadius = size.y * 0.0235;

    addAll(createBoundaries());
    pockets = createPockets();
    addAll(pockets);
    spawnTriangleBalls();

    cueBall = CueBall(Vector2(size.x * 0.25, size.y / 2), ballRadius);
    add(cueBall);
    _updateAimVector(ballRadius * 2);
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
    final colWidth = ballRadius * 1.732;
    final gap = 0.1;

    int ballNumber = 1;
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col <= row; col++) {
        final x = startX + row * colWidth;
        final y = centerY + (col - row / 2) * (ballRadius * 2 + gap);
        final ball = PoolBall(
          Vector2(x, y),
          'ball_$ballNumber.png',
          ballRadius,
          ballNumber,
        );
        poolBalls.add(ball);
        add(ball);
        ballNumber++;
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
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
    cueBall.spinInfluence = Offset.zero;
    cueBall.activeSpin = Offset.zero;
  }

  void switchTurn() {
    resetCueSpin();
    currentTurn.value = currentTurn.value == 1 ? 2 : 1;
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
    if (!physicsReady) {
      return;
    }
    resetCueSpin();
    for (final ball in poolBalls) {
      ball.removeFromParent();
    }
    poolBalls.clear();
    cueBall.removeFromParent();

    currentTurn.value = 1;
    ruleMessage.value = 'Player 1: break shot';
    shotPower.value = 0.05;
    playerGroups.clear();
    groupVersion.value++;
    shotInProgress = false;
    breakShot = true;
    rackOver = false;
    winningPlayer = null;
    ballInHand = false;
    movingCueBall = false;
    settledTime = 0;
    botWaitTime = 0;
    botState = 0;
    aimAngle = 0;
    physicsReady = false;

    spawnTriangleBalls();
    cueBall = CueBall(Vector2(size.x * 0.25, size.y / 2), ballRadius);
    add(cueBall);
    cueBall.isAiming = true;
    _updateAimVector(ballRadius * 2);
    matchVersion.value++;
  }

  void setShotPower(double value) {
    shotPower.value = value;
  }

  void setCueSpin(Offset value) {
    if (shotInProgress ||
        rackOver ||
        ballInHand ||
        (isBotMode.value && currentTurn.value == 2)) {
      return;
    }
    final dist = value.distance;
    final clamped = dist > 1.0 ? value / dist : value;
    cueSpin.value = clamped;
    cueBall.spinInfluence = clamped;
    if (cueBall.isAiming && cueBall.aimVector != null) {
      _updateAimVector(cueBall.aimVector!.length);
    }
  }

  void commitCueSpin() {
    cueBall.spinInfluence = cueSpin.value;
    if (cueBall.isAiming && cueBall.aimVector != null) {
      _updateAimVector(cueBall.aimVector!.length);
    }
  }

  void adjustShotPower(double delta) {
    if (shotInProgress ||
        rackOver ||
        ballInHand ||
        (isBotMode.value && currentTurn.value == 2)) {
      return;
    }
    shotPower.value = (shotPower.value + delta).clamp(0.05, 1.0);
    cueBall.isAiming = true;
    cueBall.strokeDistance = maxDragDistance * shotPower.value;
  }

  void beginPowerDrag(double startY) {
    if (shotInProgress ||
        rackOver ||
        ballInHand ||
        (isBotMode.value && currentTurn.value == 2)) {
      powerDragStartY = null;
      return;
    }
    powerDragStartY = startY;
  }

  void updatePowerDrag(double currentY) {
    final startY = powerDragStartY;
    if (startY == null) {
      return;
    }
    final pullDistance = math.max(0.0, currentY - startY);
    final power = (0.05 + pullDistance / maxDragDistance * 0.95).clamp(
      0.05,
      1.0,
    );
    setShotPower(power);
    cueBall.isAiming = true;
    cueBall.strokeDistance = maxDragDistance * power;
  }

  void endPowerDrag() {
    powerDragStartY = null;
  }

  void shootWithPower({bool fromBot = false}) {
    if (!physicsReady ||
        shotInProgress ||
        ballInHand ||
        rackOver ||
        (!fromBot && isBotMode.value && currentTurn.value == 2) ||
        shotPower.value <= 0.05) {
      return;
    }
    final direction = Vector2(math.cos(aimAngle), math.sin(aimAngle));
    final normalizedPower = ((shotPower.value - 0.05) / 0.95).clamp(0.0, 1.0);
    final curvedPower = math
        .pow(normalizedPower, powerCurveExponent)
        .toDouble();
    final targetSpeed =
        (minimumShotSpeed +
            (maximumShotSpeed - minimumShotSpeed) * curvedPower) *
        rollingVelocityMultiplier;

    cueBall.body.setAwake(true);
    // Vận tốc góc xoáy áp-phê quanh trục Z (áp-phê phải dx > 0 thì quay thuận chiều kim đồng hồ)
    cueBall.body.angularVelocity = -cueSpin.value.dx * 18.0;
    cueBall.body.linearVelocity.setFrom(direction * targetSpeed);

    // Khởi tạo các trạng thái động lực học xoáy
    cueBall.activeSpin = cueSpin.value;
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
          aimAngle = math.atan2(shot.direction.y, shot.direction.x);

          // Cập nhật ngắm, UI Cơ, Lực và Xoáy chính xác do Bot tính toán
          shotPower.value = shot.power;
          cueSpin.value = shot.spin;
          cueBall.spinInfluence = shot.spin;
          cueBall.isAiming = true;
          cueBall.strokeDistance = maxDragDistance * shot.power;
          _updateAimVector(ballRadius * 2);

          botState = 1; // Chuyển sang giai đoạn chờ đánh
          botWaitTime = 0;
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
    final group = playerGroups[player] ?? (player == 2 ? _inferBotGroup() : null);
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
    // 1. Pha phá bóng (Break Shot): Đánh chuẩn xác vào đỉnh tam giác với lực mạnh và trô nhẹ
    if (breakShot) {
      final apexPos = Vector2(size.x * 0.70, size.y / 2);
      final aimDir = apexPos - cueBall.body.position;
      return BotShot(
        direction: aimDir,
        totalDistance: aimDir.length,
        spin: const Offset(0.0, 0.22), // Trô nhẹ giữ bi cái ở trung tâm bàn, tránh rơi lỗ
        power: botDifficulty.value == 2 ? 0.90 : 0.75,
      );
    }

    // 2. Lọc danh sách các bi hợp lệ (tuyệt đối không nhắm bi đối thủ hay bi 8 khi chưa đến lượt)
    final legalBalls = poolBalls.where((b) => _isBallLegalTarget(b, 2)).toList();
    if (legalBalls.isEmpty) {
      return null;
    }

    final pockets = _botPocketPositions();
    BotShot? bestShot;
    var bestScore = double.infinity;

    for (final ball in legalBalls) {
      final candidatePockets = botDifficulty.value == 1
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
        final minCutCosine = botDifficulty.value == 2 ? 0.28 : 0.20;
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
        if (botDifficulty.value == 2) {
          // Nếu đánh gần thẳng mặt (cutCosine >= 0.85): bi cái rất dễ theo đà lăn tọt vào cùng lỗ đó!
          // Áp dụng trô mạnh (Backspin) để bi cái khựng lại và giật lùi an toàn
          if (cutCosine >= 0.82) {
            chosenSpin = const Offset(0.0, 0.65);
          } else {
            // Áp-phê ngang và Cu-lê/Trô tùy khoảng cách
            final cutAngle =
                cueDirection.x * objectDirection.y -
                cueDirection.y * objectDirection.x;
            double spinDx = cutAngle.clamp(-1.0, 1.0) * 0.45;
            double spinDy = (cueDistance > size.x * 0.38) ? -0.35 : 0.35;
            chosenSpin = Offset(spinDx, spinDy);
          }

          // Kiểm tra xem hướng văng của bi cái có đâm vào lỗ nào không
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
            // Thử đổi sang xoáy khác để né lỗ
            final alternateSpin = chosenSpin.dy > 0 ? const Offset(0.0, -0.6) : const Offset(0.0, 0.7);
            Vector2 altDeflection = alternateSpin.dy > 0
                ? (tangent * 0.6 - normal * 0.6).normalized()
                : (tangent * 0.6 + cueDirection * 0.6).normalized();
            if (_checkCueBallScratchRisk(aimPoint, altDeflection, pockets, maxCueTravel)) {
              // Bỏ qua lỗ này nếu không thể tránh được rơi bi cái
              continue;
            } else {
              chosenSpin = alternateSpin;
            }
          }
        }

        // Tính lực đánh chuẩn xác tối ưu theo cự ly và góc cắt
        final tableLength = size.x * 0.70;
        final effectiveDistance = cueDistance + objectDistance / math.max(0.25, cutCosine);
        final calculatedPower = (0.24 + 0.46 * (effectiveDistance / tableLength)).clamp(0.28, 0.75);

        // Tính điểm ưu tiên (Score càng nhỏ càng tốt)
        final cutPenalty = (1.0 - cutCosine) * (botDifficulty.value == 2 ? cueDistance * 0.8 : cueDistance * 0.3);
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

    // 3. Nếu không có cơ hội ăn bi trực tiếp: Thực hiện cú đánh an toàn (Safety / Kick Shot)
    // Tuyệt đối không bắn bừa vào bi đối thủ hay bi 8 để tránh bị xử phạt lỗi!
    return _findSafeLegalContactShot(legalBalls, pockets);
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

  Vector2 _nearestPocket(Vector2 ballPosition, List<Vector2> pockets) {
    pockets.sort(
      (a, b) =>
          (a - ballPosition).length2.compareTo((b - ballPosition).length2),
    );
    return pockets.first;
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
    if (shotInProgress ||
        rackOver ||
        ballInHand ||
        (isBotMode.value && currentTurn.value == 2)) {
      return;
    }
    final offset = touchPosition - cueBall.body.position;
    if (offset.length2 > 4) {
      aimAngle = math.atan2(offset.y, offset.x);
      cueBall.isAiming = true;
      _updateAimVector(ballRadius * 2);
    }
  }

  void rotateAim(double delta) {
    if (shotInProgress ||
        rackOver ||
        (isBotMode.value && currentTurn.value == 2)) {
      return;
    }
    aimAngle += delta;
    if (dragStart != null) {
      _updateAimVector(
        dragCurrent == null ? 0 : (dragStart! - dragCurrent!).length,
      );
    }
  }

  void _updateAimVector(double length) {
    cueBall.aimVector =
        Vector2(math.cos(aimAngle), math.sin(aimAngle)) * length;
  }

  @override
  void onPanStart(DragStartInfo info) {
    if (shotInProgress ||
        rackOver ||
        (isBotMode.value && currentTurn.value == 2)) {
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
    if (isBotMode.value && currentTurn.value == 2) return;
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
    if (isBotMode.value && currentTurn.value == 2) return;
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
    final position = initialCueBallPosition;
    cueBall.isSunk = false;
    cueBall.body.setTransform(position, 0);
    cueBall.body.linearVelocity.setZero();
    cueBall.body.angularVelocity = 0;
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
          !ball.isRemoved &&
          (ball.body.position - position).length < ballRadius * 2.05,
    );
    if (!overlapsBall) {
      cueBall.isSunk = false;
      cueBall.body.setTransform(position, 0);
      cueBall.body.linearVelocity.setZero();
      cueBall.body.angularVelocity = 0;
    }
  }

  void finishShot() {
    resetCueSpin();
    shotInProgress = false;
    cueBall.isAiming = true;
    _updateAimVector(ballRadius * 2);
    final currentPlayer = currentTurn.value;
    final pocketedThisShot = poolBalls
        .where((ball) => ball.pocketedThisShot)
        .toList();
    final eightPocketed = pocketedThisShot.any((ball) => ball.number == 8);
    final group = playerGroups[currentPlayer];
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
        playerScores[winningPlayer!] = playerScores[winningPlayer!]! + 1;
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
        playerScores[currentPlayer] = playerScores[currentPlayer]! + 1;
      } else {
        ruleMessage.value = 'Player $currentPlayer loses: 8-ball early';
        winningPlayer = currentPlayer == 1 ? 2 : 1;
        playerScores[winningPlayer!] = playerScores[winningPlayer!]! + 1;
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
    groupVersion.value++;
    matchVersion.value++;
  }

  BallGroup ballGroup(int number) =>
      number < 8 ? BallGroup.solids : BallGroup.stripes;

  void assignGroupAfterBreak(List<PoolBall> pocketed) {
    final candidates = pocketed.where((ball) => ball.number != 8).toList();
    final firstObject = candidates.isEmpty ? null : candidates.first;
    if (firstObject != null) {
      playerGroups[currentTurn.value] = ballGroup(firstObject.number);
      playerGroups[currentTurn.value == 1
          ? 2
          : 1] = ballGroup(firstObject.number) == BallGroup.solids
          ? BallGroup.stripes
          : BallGroup.solids;
      groupVersion.value++;
    }
  }

  String groupLabel(int player) {
    final group = playerGroups[player];
    if (group == BallGroup.solids) {
      return 'Bi trơn 1-7';
    }
    if (group == BallGroup.stripes) {
      return 'Bi sọc 9-15';
    }
    return '';
  }

  List<int> groupBalls(int player) {
    final group = playerGroups[player];
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
      .where((ball) => ballGroup(ball.number) == group)
      .every((ball) => ball.isRemoved || ball.isSunk);

  void registerRailHit(Object bodyOwner) {
    if (bodyOwner is PoolBall && !bodyOwner.isSunk) {
      objectBallHitRailThisShot = true;
      objectBallsHitRails++;
    }
  }

  PoolBall? targetForAim(Vector2 direction) {
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
  final double radius;
  final double hitboxRadius;

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
        aimVector!.length > 0.0 &&
        cueStickSprite != null) {
      final direction = aimVector!.normalized();
      final stickLength = radius * 18.0;
      final stickHeight = stickLength * 433 / 575;
      // The sprite artwork is diagonal inside its image bounds, so cancel
      // that built-in angle before aligning it with the aiming line.
      final spriteAngle = math.atan2(433, 575);
      final cueAngle = math.atan2(direction.y, direction.x) + spriteAngle;

      canvas.save();
      canvas.translate(
        -direction.x * (radius + strokeDistance),
        -direction.y * (radius + strokeDistance),
      );
      canvas.rotate(cueAngle);
      cueStickSprite!.render(
        canvas,
        position: Vector2(-stickLength, 0),
        size: Vector2(stickLength, stickHeight),
      );
      canvas.restore();
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
        ..color = Colors.white.withOpacity(0.5)
        ..strokeWidth = 0.4;
      final direction = aimVector!.normalized();
      final guide = (game as BilliardGame).guideForAim(direction);
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

        // 1. Đường ngắm bi cái tới điểm tiếp xúc (Ghost Ball)
        canvas.drawLine(
          Offset.zero,
          ghostOffset.toOffset(),
          Paint()
            ..color = Colors.cyanAccent.withOpacity(0.9)
            ..strokeWidth = 1.1,
        );

        // 2. Đường lăn dự kiến của bi mục tiêu
        canvas.drawLine(
          targetOffset.toOffset(),
          targetLineEnd.toOffset(),
          Paint()
            ..color = Colors.white.withOpacity(0.75)
            ..strokeWidth = 0.7,
        );

        // 3. Vòng tròn bi mục tiêu và điểm tiếp xúc
        canvas.drawCircle(
          targetCenterOffset.toOffset(),
          radius,
          Paint()
            ..color = Colors.white.withOpacity(0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8,
        );
        canvas.drawCircle(
          ghostOffset.toOffset(),
          radius,
          Paint()
            ..color = Colors.cyanAccent.withOpacity(0.85)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8,
        );
        canvas.drawLine(
          ghostOffset.toOffset(),
          targetOffset.toOffset(),
          Paint()
            ..color = Colors.orangeAccent.withOpacity(0.9)
            ..strokeWidth = 0.9,
        );
        canvas.drawCircle(
          targetOffset.toOffset(),
          radius * 0.22,
          Paint()..color = Colors.orangeAccent.withOpacity(0.95),
        );

        // 4. Đường rẽ của bi cái sau va chạm (hiển thị tác động xoáy Cu-lê, Trô bóng, Áp-phê)
        final deflectionLength = (50.0 + gameInstance.shotPower.value * 120.0).clamp(40.0, 160.0);
        final cueDeflectionEnd = ghostOffset + guide.cueDeflection * deflectionLength;
        canvas.drawLine(
          ghostOffset.toOffset(),
          cueDeflectionEnd.toOffset(),
          Paint()
            ..color = Colors.amberAccent.withOpacity(0.88)
            ..strokeWidth = 0.9,
        );
        canvas.drawCircle(
          cueDeflectionEnd.toOffset(),
          radius * 0.22,
          Paint()..color = Colors.amberAccent.withOpacity(0.95),
        );
      } else if (rayHitPoint != null && reflectionVector != null) {
        // Ngắm A-băng (đập băng trực tiếp): phản ánh góc nảy có xoáy áp-phê
        final localHitPoint = rayHitPoint! - body.position;
        canvas.drawLine(Offset.zero, localHitPoint.toOffset(), aimPaint);
        canvas.drawCircle(
          localHitPoint.toOffset(),
          0.6,
          Paint()..color = Colors.red.withOpacity(0.8),
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
          (localHitPoint + (adjustedReflection * 45.0)).toOffset(),
          Paint()
            ..color = Colors.yellow.withOpacity(0.7)
            ..strokeWidth = 0.6,
        );
      } else {
        canvas.drawLine(Offset.zero, (aimVector! * 2.5).toOffset(), aimPaint);
      }
      canvas.restore();
    }

    canvas.restore();
  }
}

class PoolBall extends BodyComponent {
  final Vector2 initialPosition;
  final double radius;
  final double hitboxRadius;
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
    if (isSunk && !isRemoved) {
      removeFromParent(); // Xóa bi khỏi bàn khi lọt lỗ
    }
  }

  @override
  void render(Canvas canvas) {
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
