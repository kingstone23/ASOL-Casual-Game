import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../models/cue_model.dart';
import '../services/progression_service.dart';

/// Widget Thanh Chỉnh Cơ Kéo Xuống Dạng Con Nhộng (Capsule Cue Slider)
/// Thiết kế chuẩn phong cách 8 Ball Pool kinh điển:
/// - Chữ số % màu vàng kim đậm nét phía trên đỉnh
/// - Rãnh trượt con nhộng kim loại bo tròn 2 đầu (Capsule Pill)
/// - Cây cơ gỗ 3D chân thực với đầu cơ xanh phấn (Chalk-blue tip) và phíp trắng
/// - Kéo cơ xuống để chỉnh lực, thả tay bắn ngay tức thì (chuẩn 8 Ball Pool)
/// - Nút tròn trắng viền kim loại với biểu tượng đỏ ở góc dưới
class CuePowerSliderControl extends StatefulWidget {
  final BilliardGame game;
  final bool compact;
  final bool ultraCompact;

  const CuePowerSliderControl({
    super.key,
    required this.game,
    this.compact = false,
    this.ultraCompact = false,
  });

  @override
  State<CuePowerSliderControl> createState() => _CuePowerSliderControlState();
}

class _CuePowerSliderControlState extends State<CuePowerSliderControl> {
  bool _isDragging = false;
  bool _powerLocked = false; // Khi khóa lực thì thả tay không bắn, cần bấm nút để xuất chiêu
  int _lastHapticMilestone = 0;

  void _triggerHapticForPower(double power) {
    final milestone = (power * 4).floor();
    if (milestone != _lastHapticMilestone) {
      _lastHapticMilestone = milestone;
      HapticFeedback.selectionClick();
    }
  }

  void _handleTouch(Offset localPos, double trackHeight) {
    if (!widget.game.canUserControl) return;
    if (!_isDragging) {
      setState(() => _isDragging = true);
    }

    final clampedY = localPos.dy.clamp(0.0, trackHeight);
    final ratio = (clampedY / trackHeight).clamp(0.0, 1.0);

    // Vùng đỉnh 0% - 4% là vùng nghỉ / hủy cú đánh
    if (ratio <= 0.04) {
      widget.game.setShotPower(0.05);
    } else {
      final power = (0.05 + ratio * 0.95).clamp(0.05, 1.0);
      widget.game.setShotPower(power);
      _triggerHapticForPower(power);
    }
  }

  void _handleRelease() {
    setState(() => _isDragging = false);
    if (!widget.game.canUserControl) return;

    // Nếu không khóa lực: Thả tay bắn ngay lập tức (khi lực > 0.05)
    if (!_powerLocked) {
      final currentPower = widget.game.shotPower.value;
      if (currentPower > 0.05) {
        HapticFeedback.heavyImpact();
        widget.game.shootWithPower();
      }
    }
  }

  void _togglePowerLock() {
    setState(() => _powerLocked = !_powerLocked);
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _powerLocked
              ? '🎯 Đã khóa lực: Thả tay không bắn (Chạm lại nút tròn để bắn hoặc mở khóa)'
              : '⚡ Đã mở chế độ: Kéo cơ & Thả tay bắn ngay',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ultraCompact = widget.ultraCompact;
    final compact = widget.compact;
    final controlWidth = ultraCompact ? 34.0 : (compact ? 40.0 : 46.0);
    final capsuleWidth = ultraCompact ? 22.0 : (compact ? 26.0 : 30.0);
    final bottomButtonSize = ultraCompact ? 28.0 : (compact ? 34.0 : 38.0);

    return SizedBox(
      width: controlWidth,
      child: ValueListenableBuilder<double>(
        valueListenable: widget.game.shotPower,
        builder: (context, power, _) {
          final ratio = ((power - 0.05) / 0.95).clamp(0.0, 1.0);
          final displayPercent = ratio <= 0.04 ? 0 : (ratio * 100).round();

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. Chữ số % màu vàng kim rực rỡ phía trên rãnh cơ
              _buildYellowPercentageHeader(displayPercent, ultraCompact, compact),
              SizedBox(height: ultraCompact ? 3.0 : 5.0),

              // 2. Rãnh con nhộng kim loại (Capsule Slider) chứa cây cơ gỗ 3D
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final trackHeight = constraints.maxHeight;
                    final maxTravel = trackHeight * 0.72;
                    final pullOffset = ratio * maxTravel;

                    return GestureDetector(
                      key: const ValueKey('cue_power_track_gesture'),
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (d) => _handleTouch(d.localPosition, trackHeight),
                      onPanUpdate: (d) => _handleTouch(d.localPosition, trackHeight),
                      onPanEnd: (_) => _handleRelease(),
                      onPanCancel: () => _handleRelease(),
                      onTapDown: (d) => _handleTouch(d.localPosition, trackHeight),
                      onTapUp: (_) => _handleRelease(),
                      child: Center(
                        child: Container(
                          width: capsuleWidth,
                          height: trackHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(capsuleWidth / 2),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFF1E2228),
                                Color(0xFF323842),
                                Color(0xFF15181D),
                              ],
                            ),
                            border: Border.all(
                              color: _isDragging
                                  ? const Color(0xFFFFD700)
                                  : const Color(0xFF4A5260),
                              width: _isDragging ? 2.0 : 1.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.7),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                              if (_isDragging)
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(capsuleWidth / 2 - 1.5),
                            child: Stack(
                              children: [
                                // A. Lòng rãnh tối màu với vạch chia độ rãnh
                                Positioned.fill(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Color(0xFF080A0D),
                                          Color(0xFF101419),
                                          Color(0xFF080A0D),
                                        ],
                                      ),
                                    ),
                                    child: _buildTrackTickMarks(trackHeight),
                                  ),
                                ),

                                // B. Vệt sáng năng lượng rọi theo độ kéo cơ
                                if (ratio > 0.02)
                                  Positioned(
                                    top: 0,
                                    left: 2,
                                    right: 2,
                                    height: (pullOffset + capsuleWidth * 0.4).clamp(0.0, trackHeight),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(capsuleWidth / 2),
                                          bottom: const Radius.circular(3),
                                        ),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            const Color(0xFF00E676).withValues(alpha: 0.15),
                                            (ratio > 0.75
                                                    ? const Color(0xFFFF2A4B)
                                                    : ratio > 0.4
                                                        ? const Color(0xFFFFB300)
                                                        : const Color(0xFF00E676))
                                                .withValues(alpha: 0.45),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                // C. Cây gậy cơ gỗ 3D trượt xuống từ đỉnh con nhộng
                                Positioned(
                                  top: pullOffset,
                                  left: 0,
                                  right: 0,
                                  bottom: -pullOffset,
                                  child: _buildCapsuleCueStick(capsuleWidth, trackHeight),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: ultraCompact ? 4.0 : 8.0),

              // 3. Nút tròn màu trắng có biểu tượng đỏ ở góc dưới bên trái
              _buildBottomCircularButton(bottomButtonSize, ultraCompact),
            ],
          );
        },
      ),
    );
  }

  /// Tiêu đề % màu vàng kim rực rỡ có viền đổ bóng nổi bật như ảnh mẫu
  Widget _buildYellowPercentageHeader(int percent, bool ultraCompact, bool compact) {
    return Text(
      '$percent%',
      style: TextStyle(
        color: const Color(0xFFFFDE00), // Vàng kim rực rỡ như ảnh mẫu
        fontSize: ultraCompact ? 13.0 : (compact ? 15.0 : 17.5),
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
        shadows: const [
          Shadow(
            color: Colors.black,
            offset: Offset(0, 1.8),
            blurRadius: 3.5,
          ),
          Shadow(
            color: Colors.black,
            offset: Offset(1.2, 0),
            blurRadius: 2.0,
          ),
          Shadow(
            color: Colors.black,
            offset: Offset(-1.2, 0),
            blurRadius: 2.0,
          ),
        ],
      ),
    );
  }

  /// Vẽ các vạch khắc chia độ mờ bên trong rãnh con nhộng
  Widget _buildTrackTickMarks(double height) {
    return Stack(
      children: [
        for (final pct in [0.25, 0.50, 0.75])
          Positioned(
            top: height * pct,
            left: 2,
            right: 2,
            child: Container(
              height: 1.0,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
      ],
    );
  }

  /// Widget vẽ Cây Gậy Cơ 3D chân thực: Đầu lơ xanh vòm cong, phíp trắng, thân gỗ phong vàng óng
  Widget _buildCapsuleCueStick(double capsuleWidth, double trackHeight) {
    final cue = ProgressionService.instance.equippedCue;
    final level = ProgressionService.instance.equippedCueLevel;

    return CustomPaint(
      size: Size(capsuleWidth, trackHeight),
      painter: _RealisticCapsuleCuePainter(
        capsuleWidth: capsuleWidth,
        cue: cue,
        level: level,
      ),
    );
  }

  /// Nút bấm tròn màu trắng bạc với biểu tượng đỏ góc dưới bên trái
  Widget _buildBottomCircularButton(double size, bool ultraCompact) {
    return GestureDetector(
      key: const ValueKey('cue_slider_bottom_button'),
      onTap: () {
        if (!widget.game.canUserControl) return;
        if (_powerLocked && widget.game.shotPower.value > 0.05) {
          // Nếu đang khóa lực và có lực kéo: chạm nút tròn sẽ bắn ngay
          HapticFeedback.heavyImpact();
          widget.game.shootWithPower();
        } else {
          // Chuyển đổi trạng thái khóa lực / mở lực
          _togglePowerLock();
        }
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment(-0.2, -0.3),
            radius: 0.85,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFEDEDED),
              Color(0xFFCCCCCC),
              Color(0xFF9E9E9E),
            ],
            stops: [0.0, 0.45, 0.82, 1.0],
          ),
          border: Border.all(
            color: const Color(0xFF2C3238),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: CustomPaint(
            size: Size(size * 0.50, size * 0.50),
            painter: _RedAngleSymbolPainter(),
          ),
        ),
      ),
    );
  }
}

/// CustomPainter vẽ biểu tượng góc ngắm màu đỏ bên trong nút tròn trắng (chuẩn ảnh mẫu)
class _RedAngleSymbolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD32F2F) // Đỏ tươi nổi bật
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Vẽ góc nhọn nghiêng (Angle symbol ∠)
    final path = Path()
      ..moveTo(w * 0.82, h * 0.82)
      ..lineTo(w * 0.22, h * 0.82)
      ..lineTo(w * 0.72, h * 0.18);

    canvas.drawPath(path, paint);

    // Điểm chấm đỏ tâm góc
    final dotPaint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.42, h * 0.62), 1.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// CustomPainter vẽ cây gậy cơ 3D dáng con nhộng chân thực:
/// - Đỉnh vòm bo tròn màu xanh phấn (Chalk-blue tip)
/// - Vòng đệm phíp cơ trắng (White ferrule)
/// - Thân cơ gỗ phong vàng ấm áp (Maple wood cylinder với ánh sáng 3D)
/// - Tích hợp hoa văn và màu sắc từ gậy cơ đang trang bị trong Shop
class _RealisticCapsuleCuePainter extends CustomPainter {
  final double capsuleWidth;
  final CueModel cue;
  final int level;

  _RealisticCapsuleCuePainter({
    required this.capsuleWidth,
    required this.cue,
    required this.level,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centerX = w / 2;

    // Chiều rộng gậy cơ ôm khít bên trong rãnh con nhộng (cách mép 1.5px)
    final stickWidth = (w - 3.0).clamp(16.0, 26.0);
    final halfStick = stickWidth / 2;
    final stickLeft = centerX - halfStick;
    final stickRight = centerX + halfStick;

    // 1. Thân cơ gỗ phong 3D (Shaft & Handle)
    final cueBodyRect = Rect.fromLTWH(stickLeft, 0, stickWidth, h);
    final cueBodyPath = Path()
      ..moveTo(stickLeft, halfStick)
      ..lineTo(stickLeft, h - 8)
      ..arcToPoint(
        Offset(stickRight, h - 8),
        radius: Radius.circular(halfStick),
        clockwise: false,
      )
      ..lineTo(stickRight, halfStick)
      ..close();

    // Dải gradient màu gỗ tự nhiên hoặc màu skin cơ trang bị
    final baseWoodColors = cue.shaftColors.isNotEmpty
        ? cue.shaftColors
        : const [
            Color(0xFF8D5322),
            Color(0xFFDF9E52),
            Color(0xFFFBE4C2),
            Color(0xFFC78438),
            Color(0xFF754013),
          ];

    final woodGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        baseWoodColors[0],
        baseWoodColors[baseWoodColors.length > 2 ? 1 : 0],
        const Color(0xFFFDF0D8), // Ánh sáng bóng trụ ở giữa
        baseWoodColors[baseWoodColors.length > 2 ? 2 : baseWoodColors.length - 1],
        const Color(0xFF5A310C), // Đổ bóng cạnh phải
      ],
      stops: const [0.0, 0.28, 0.50, 0.76, 1.0],
    );

    canvas.drawPath(
      cueBodyPath,
      Paint()..shader = woodGradient.createShader(cueBodyRect),
    );

    // 2. Vòng đệm ren kim loại & họa tiết chuôi gậy
    final ringY = h * 0.48;
    final ringPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color(0xFF8A7320), Color(0xFFFFE082), Color(0xFF6B5510)],
      ).createShader(Rect.fromLTWH(stickLeft, ringY, stickWidth, 5.0));
    canvas.drawRect(Rect.fromLTWH(stickLeft, ringY, stickWidth, 3.5), ringPaint);

    // 3. Phíp cơ trắng (Ferrule)
    final ferruleHeight = 9.0;
    final ferruleRect = Rect.fromLTWH(stickLeft, 6.0, stickWidth, ferruleHeight);
    final ferrulePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFFCCCCCC),
          Color(0xFFFFFFFF),
          Color(0xFFF0F0F0),
          Color(0xFFB0B0B0),
        ],
        stops: [0.0, 0.35, 0.65, 1.0],
      ).createShader(ferruleRect);
    canvas.drawRect(ferruleRect, ferrulePaint);

    // Viền kim loại mỏng ngăn giữa phíp và thân gỗ
    canvas.drawLine(
      Offset(stickLeft, 6.0 + ferruleHeight),
      Offset(stickRight, 6.0 + ferruleHeight),
      Paint()
        ..color = const Color(0xFF424242)
        ..strokeWidth = 0.8,
    );

    // 4. Đầu lơ xanh phấn (Chalk-blue tip) dạng vòm cong ở đỉnh
    final tipPath = Path()
      ..moveTo(stickLeft, 6.0)
      ..lineTo(stickRight, 6.0)
      ..arcToPoint(
        Offset(stickLeft, 6.0),
        radius: Radius.circular(halfStick),
        clockwise: false,
      )
      ..close();

    final tipPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.2, -0.3),
        radius: 0.9,
        colors: [
          Color(0xFF40C4FF), // Xanh lơ sáng (Chalk blue)
          Color(0xFF0091EA),
          Color(0xFF01579B),
        ],
      ).createShader(Rect.fromLTWH(stickLeft, 0, stickWidth, halfStick * 2));
    canvas.drawPath(tipPath, tipPaint);

    // Viền đen phân tách đầu cơ và phíp
    canvas.drawLine(
      Offset(stickLeft, 6.0),
      Offset(stickRight, 6.0),
      Paint()
        ..color = const Color(0xFF1A1A1A)
        ..strokeWidth = 1.0,
    );

    // 5. Hào quang tỏa sáng nếu gậy cấp cao (Level >= 7)
    if (level >= 7) {
      final auraPaint = Paint()
        ..color = cue.auraColor.withValues(alpha: 0.35)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawLine(Offset(stickLeft - 1, 10), Offset(stickLeft - 1, h - 10), auraPaint);
      canvas.drawLine(Offset(stickRight + 1, 10), Offset(stickRight + 1, h - 10), auraPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RealisticCapsuleCuePainter oldDelegate) {
    return oldDelegate.capsuleWidth != capsuleWidth ||
        oldDelegate.cue != cue ||
        oldDelegate.level != level;
  }
}
