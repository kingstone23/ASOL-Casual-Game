import 'dart:async';
import 'package:flutter/material.dart';

class ComboEvent {
  final int count;
  final String title;
  final String subtitle;
  final int timestamp;

  const ComboEvent({
    required this.count,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });
}

/// Hiển thị chữ COMBO chuẩn phong cách Arcade 8-Ball Pool / ZingPlay:
/// Chữ số màu Vàng 3D + Chữ "COMBO" màu Xanh Dương 3D viền trắng nổi bật ngay trên mặt bàn.
class ComboBannerOverlay extends StatefulWidget {
  final ValueNotifier<ComboEvent?> comboNotifier;

  const ComboBannerOverlay({
    super.key,
    required this.comboNotifier,
  });

  @override
  State<ComboBannerOverlay> createState() => _ComboBannerOverlayState();
}

class _ComboBannerOverlayState extends State<ComboBannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotateAnimation;
  late final Animation<double> _opacityAnimation;
  late final Animation<Offset> _slideAnimation;

  Timer? _dismissTimer;
  ComboEvent? _currentCombo;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Hiệu ứng phóng to bật nảy mạnh mẽ (Punch Pop-in)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.15, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
    ]).animate(_controller);

    // Góc nghiêng nhẹ -4 độ phong cách hành động
    _rotateAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.12, end: -0.06)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.06, end: -0.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.40, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    widget.comboNotifier.addListener(_onComboTriggered);
  }

  void _onComboTriggered() {
    final event = widget.comboNotifier.value;
    if (event == null || event.count < 2) return;

    _dismissTimer?.cancel();
    setState(() {
      _currentCombo = event;
    });

    _controller.forward(from: 0.0);

    // Giữ chữ combo trong 1.8 giây rồi thu nhỏ mờ dần
    _dismissTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) {
            setState(() {
              _currentCombo = null;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    widget.comboNotifier.removeListener(_onComboTriggered);
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentCombo == null) return const SizedBox.shrink();

    final count = _currentCombo!.count;
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 750 || size.height < 450;
    final isUltraCompact = size.width < 550 || size.height < 360;

    final numSize = isUltraCompact ? 42.0 : (isCompact ? 54.0 : 68.0);
    final wordSize = isUltraCompact ? 32.0 : (isCompact ? 42.0 : 52.0);

    return IgnorePointer(
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: SlideTransition(
                position: _slideAnimation,
                child: Transform.rotate(
                  angle: _rotateAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        _build3DNumber(count, numSize),
                        SizedBox(width: isUltraCompact ? 4 : 8),
                        _build3DComboWord(wordSize),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Số Combo (Màu Vàng - Cam 3D viền đậm, đổ bóng khối)
  Widget _build3DNumber(int count, double fontSize) {
    final text = '$count';
    const skew = -0.18; // Nghiêng phong cách arcade thể thao

    return Transform(
      transform: Matrix4.skewX(skew),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lớp 1: Đổ bóng 3D sâu phía dưới
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF331400),
              shadows: const [
                Shadow(
                  color: Colors.black87,
                  offset: Offset(0, 6),
                  blurRadius: 10,
                ),
                Shadow(
                  color: Color(0xFF552000),
                  offset: Offset(-2, 4),
                  blurRadius: 0,
                ),
              ],
            ),
          ),
          // Lớp 2: Viền đen socola dày dặn (Thick outer stroke)
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = fontSize * 0.16
                ..strokeCap = StrokeCap.round
                ..strokeJoin = StrokeJoin.round
                ..color = const Color(0xFF4A1A00),
            ),
          ),
          // Lớp 3: Màu Gradient Vàng Chanh -> Vàng Cam -> Cam Đỏ rực lửa
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF9C4), // Vàng sáng trên đỉnh
                Color(0xFFFFEA00), // Vàng rực
                Color(0xFFFFB300), // Vàng cam
                Color(0xFFFF6D00), // Cam đậm ở đáy
              ],
              stops: [0.0, 0.25, 0.65, 1.0],
            ).createShader(bounds),
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Chữ "COMBO" (Màu Xanh Dương Điện Tử 3D viền trắng nổi)
  Widget _build3DComboWord(double fontSize) {
    const text = 'COMBO';
    const skew = -0.18; // Đồng bộ góc nghiêng với số

    return Transform(
      transform: Matrix4.skewX(skew),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lớp 1: Đổ bóng 3D khối phía dưới
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: 1.5,
              color: const Color(0xFF001F3F),
              shadows: const [
                Shadow(
                  color: Colors.black87,
                  offset: Offset(0, 6),
                  blurRadius: 10,
                ),
                Shadow(
                  color: Color(0xFF002244),
                  offset: Offset(-2, 4),
                  blurRadius: 0,
                ),
              ],
            ),
          ),
          // Lớp 2: Viền Trắng Tinh Khôi Dày (Thick crisp white border)
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: 1.5,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = fontSize * 0.18
                ..strokeCap = StrokeCap.round
                ..strokeJoin = StrokeJoin.round
                ..color = Colors.white,
            ),
          ),
          // Lớp 3: Viền Xanh Đậm Nhẹ bên trong viền trắng để tạo độ nét viền
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: 1.5,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = fontSize * 0.08
                ..strokeCap = StrokeCap.round
                ..strokeJoin = StrokeJoin.round
                ..color = const Color(0xFF01579B),
            ),
          ),
          // Lớp 4: Màu Gradient Xanh Cyan -> Xanh Dương Điện Tử -> Xanh Navy
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE0F7FA), // Xanh ngọc rất sáng ở mép trên
                Color(0xFF00E5FF), // Xanh Cyan rực rỡ
                Color(0xFF0091EA), // Xanh da trời sâu
                Color(0xFF0D47A1), // Xanh hoàng gia ở đáy
              ],
              stops: [0.0, 0.28, 0.68, 1.0],
            ).createShader(bounds),
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
