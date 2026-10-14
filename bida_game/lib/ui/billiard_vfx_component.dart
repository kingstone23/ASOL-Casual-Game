import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Hiệu ứng va chạm sóng kích (Shockwave Ring) giữa 2 quả bi
class _BallCollisionShockwave {
  final Vector2 position;
  final double maxRadius;
  final double maxLife;
  final double intensity;
  final List<_SparkSpeck> sparks;
  double age = 0.0;

  _BallCollisionShockwave({
    required this.position,
    required this.maxRadius,
    required this.maxLife,
    required this.intensity,
    required this.sparks,
  });

  bool update(double dt) {
    age += dt;
    for (final s in sparks) {
      s.update(dt);
    }
    return age < maxLife;
  }

  void render(Canvas canvas) {
    final t = (age / maxLife).clamp(0.0, 1.0);
    // Ease out quartic cho sóng kích nảy bung tức thì
    final ease = 1.0 - math.pow(1.0 - t, 3.5).toDouble();
    final r = maxRadius * (0.2 + 0.8 * ease);
    final alpha = (1.0 - t) * intensity;

    if (alpha <= 0.001) return;

    // Vòng sóng kích va chạm phát quang trắng xanh tinh tế
    final ringPaint = Paint()
      ..color = Color.fromRGBO(240, 250, 255, 0.85 * alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (1.8 * (1.0 - t * 0.65)).clamp(0.4, 2.0);

    canvas.drawCircle(position.toOffset(), r, ringPaint);

    // Điểm chớp sáng tâm va chạm (Core Flash) siêu ngắn (chỉ trong 30% đầu thời gian)
    if (t < 0.35) {
      final coreFlashT = 1.0 - (t / 0.35);
      final corePaint = Paint()
        ..color = Color.fromRGBO(255, 255, 255, 0.95 * coreFlashT * intensity);
      canvas.drawCircle(position.toOffset(), maxRadius * 0.28 * coreFlashT, corePaint);
    }

    // Các tia hạt vi lượng văng ra dọc theo tiếp tuyến va chạm
    for (final s in sparks) {
      s.render(canvas, alpha);
    }
  }
}

/// Tia hạt vi lượng tiếp xúc (Micro Spark)
class _SparkSpeck {
  Vector2 pos;
  Vector2 vel;
  final double length;
  final Color color;

  _SparkSpeck({
    required this.pos,
    required this.vel,
    required this.length,
    required this.color,
  });

  void update(double dt) {
    pos += vel * dt;
    vel *= math.pow(0.2, dt).toDouble(); // Giảm tốc nhanh do ma sát nỉ
  }

  void render(Canvas canvas, double parentAlpha) {
    if (parentAlpha <= 0.01) return;
    final sparkPaint = Paint()
      ..color = color.withValues(alpha: (parentAlpha * 0.85).clamp(0.0, 1.0))
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final tail = pos - vel.normalized() * (length * 0.5);
    canvas.drawLine(pos.toOffset(), tail.toOffset(), sparkPaint);
  }
}

/// Bụi lơ gậy (Chalk Dust Puff) khi đầu cơ tiếp xúc bi cái
class _ChalkDustParticle {
  Vector2 pos;
  Vector2 vel;
  final double radius;
  final double maxLife;
  final Color color;
  double age = 0.0;

  _ChalkDustParticle({
    required this.pos,
    required this.vel,
    required this.radius,
    required this.maxLife,
    required this.color,
  });

  bool update(double dt) {
    age += dt;
    pos += vel * dt;
    // Lực cản không khí làm giảm tốc bụi lơ
    vel *= math.pow(0.15, dt).toDouble();
    return age < maxLife;
  }

  void render(Canvas canvas) {
    final t = (age / maxLife).clamp(0.0, 1.0);
    final alpha = (1.0 - t * t).clamp(0.0, 1.0);
    if (alpha <= 0.005) return;

    final curRadius = radius * (1.0 + 0.8 * t);
    final paint = Paint()
      ..color = color.withValues(alpha: alpha * 0.75)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);

    canvas.drawCircle(pos.toOffset(), curRadius, paint);
  }
}

/// Gợn ép đàn hồi băng cao su (Cushion Impact Ripple) khi bi đập vào băng
class _RailImpactRipple {
  final Vector2 position;
  final Vector2 tangent;
  final double maxHalfLength;
  final double maxLife;
  final double intensity;
  double age = 0.0;

  _RailImpactRipple({
    required this.position,
    required this.tangent,
    required this.maxHalfLength,
    required this.maxLife,
    required this.intensity,
  });

  bool update(double dt) {
    age += dt;
    return age < maxLife;
  }

  void render(Canvas canvas) {
    final t = (age / maxLife).clamp(0.0, 1.0);
    final ease = 1.0 - math.pow(1.0 - t, 2.5).toDouble();
    final halfLen = maxHalfLength * (0.3 + 0.7 * ease);
    final alpha = (1.0 - t) * intensity;
    if (alpha <= 0.01) return;

    final p1 = position - tangent * halfLen;
    final p2 = position + tangent * halfLen;

    final ripplePaint = Paint()
      ..color = Color.fromRGBO(200, 255, 230, 0.70 * alpha)
      ..strokeWidth = (2.2 * (1.0 - t)).clamp(0.6, 2.5)
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    canvas.drawLine(p1.toOffset(), p2.toOffset(), ripplePaint);
  }
}

/// Lịch sử vệt chuyển động của quả bi ở tốc độ cao
class _BallMotionTrailHistory {
  final List<Vector2> positions = [];
  double lastRecordTime = 0.0;

  void addPosition(Vector2 pos) {
    positions.insert(0, pos.clone());
    if (positions.length > 4) {
      positions.removeLast();
    }
  }

  void clear() {
    positions.clear();
  }
}

/// Hiệu ứng xoáy tụ hút vào lỗ (Pocket Drop Vortex) khi bi lọt lỗ
class _PocketDropVortex {
  static const double maxLife = 0.38;
  final Vector2 position;
  final double radius;
  double age = 0.0;

  _PocketDropVortex({
    required this.position,
    required this.radius,
  });

  bool update(double dt) {
    age += dt;
    return age < maxLife;
  }

  void render(Canvas canvas) {
    final t = (age / maxLife).clamp(0.0, 1.0);
    final alpha = (1.0 - t * t).clamp(0.0, 1.0);
    if (alpha <= 0.01) return;

    // Vòng tụ sáng xoáy vào tâm lỗ mượt mà
    final shrink = 1.0 - math.pow(t, 1.8).toDouble() * 0.52;
    final curR = radius * shrink;

    final rimPaint = Paint()
      ..color = Color.fromRGBO(255, 225, 120, 0.65 * alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (2.2 * (1.0 - t * 0.7)).clamp(0.5, 2.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    canvas.drawCircle(position.toOffset(), curR, rimPaint);

    // Vùng bóng sâu lòng lỗ tạo cảm giác bi rơi chìm vào họng lỗ
    final depthShadowPaint = Paint()
      ..color = Color.fromRGBO(5, 5, 5, 0.55 * alpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawCircle(position.toOffset(), radius * 0.65 * (1.0 - t * 0.3), depthShadowPaint);
  }
}

/// Xung chấn tiếp xúc đầu gậy cơ (Cue Tip Strike Pulse)
class _CueTipHitPulse {
  static const double maxLife = 0.14;
  final Vector2 position;
  final double maxRadius;
  final double intensity;
  double age = 0.0;

  _CueTipHitPulse({
    required this.position,
    required this.maxRadius,
    required this.intensity,
  });

  bool update(double dt) {
    age += dt;
    return age < maxLife;
  }

  void render(Canvas canvas) {
    final t = (age / maxLife).clamp(0.0, 1.0);
    final alpha = (1.0 - t) * intensity;
    if (alpha <= 0.01) return;

    final r = maxRadius * math.sqrt(t);
    final pulsePaint = Paint()
      ..color = Color.fromRGBO(255, 255, 255, 0.90 * alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (1.8 * (1.0 - t)).clamp(0.5, 2.0);

    canvas.drawCircle(position.toOffset(), r, pulsePaint);

    if (t < 0.4) {
      final coreAlpha = (1.0 - t / 0.4) * intensity;
      final flashPaint = Paint()..color = Color.fromRGBO(255, 255, 255, coreAlpha);
      canvas.drawCircle(position.toOffset(), maxRadius * 0.3 * (1.0 - t / 0.4), flashPaint);
    }
  }
}

/// Component quản lý toàn bộ hiệu ứng vật lý thị giác (VFX) đỉnh cao của bàn bida:
/// 1. Sóng kích va chạm & chớp tâm nảy bi
/// 2. Bụi lơ gậy cơ tán xạ khi phát lực
/// 3. Xung chấn tiếp xúc đầu gậy cơ
/// 4. Gợn sóng đàn hồi băng cao su
/// 5. Vệt mờ tốc độ cao chân thực
/// 6. Xoáy hút chìm bi vào lỗ
class BilliardVfxComponent extends Component {
  final List<_BallCollisionShockwave> _shockwaves = [];
  final List<_ChalkDustParticle> _chalkPuffs = [];
  final List<_RailImpactRipple> _railRipples = [];
  final List<_PocketDropVortex> _pocketVortices = [];
  final List<_CueTipHitPulse> _cueHitPulses = [];
  final Map<int, _BallMotionTrailHistory> _motionTrails = {};

  final math.Random _random = math.Random();

  BilliardVfxComponent() {
    priority = 5; // Hiển thị phía trên mặt bàn và bi
  }

  /// Kích hoạt hiệu ứng va chạm giữa 2 bi bida
  void addBallCollision(Vector2 contactPoint, double relativeSpeed, {double ballRadius = 12.0}) {
    if (relativeSpeed < 30.0) return;

    // Chuẩn hóa cường độ theo vận tốc va chạm
    final intensity = (relativeSpeed / 480.0).clamp(0.25, 1.0);
    final maxRadius = (ballRadius * 0.75 + ballRadius * 1.35 * intensity).clamp(8.0, 32.0);
    final maxLife = 0.16 + 0.08 * intensity;

    // Sinh các tia hạt tiếp xúc nếu va chạm mạnh
    final sparks = <_SparkSpeck>[];
    if (relativeSpeed > 220.0) {
      final count = (3 + (intensity * 5).round()).clamp(3, 8);
      for (int i = 0; i < count; i++) {
        final angle = _random.nextDouble() * 2 * math.pi;
        final speed = 40.0 + _random.nextDouble() * 120.0 * intensity;
        sparks.add(
          _SparkSpeck(
            pos: contactPoint.clone(),
            vel: Vector2(math.cos(angle) * speed, math.sin(angle) * speed),
            length: 4.0 + 4.0 * intensity,
            color: _random.nextBool()
                ? const Color(0xFFE0F7FA)
                : const Color(0xFFFFF9C4),
          ),
        );
      }
    }

    _shockwaves.add(
      _BallCollisionShockwave(
        position: contactPoint.clone(),
        maxRadius: maxRadius,
        maxLife: maxLife,
        intensity: intensity,
        sparks: sparks,
      ),
    );
  }

  /// Kích hoạt hiệu ứng bụi lơ gậy và xung chấn phát lực khi đầu gậy chạm bi
  void addCueChalkPuff({
    required Vector2 tipPos,
    required Vector2 shotDirection,
    required double shotSpeed,
    double ballRadius = 12.0,
  }) {
    final speedRatio = (shotSpeed / 1200.0).clamp(0.25, 1.0);
    final particleCount = (6 + (speedRatio * 8).round()).clamp(6, 14);

    // Xung chấn đầu cơ tiếp xúc bi cái
    _cueHitPulses.add(
      _CueTipHitPulse(
        position: tipPos.clone(),
        maxRadius: ballRadius * 0.95,
        intensity: speedRatio,
      ),
    );

    // Bụi lơ phun ngược về hướng sau gậy với góc xòe hình nón
    final baseDir = -shotDirection.normalized();
    final baseAngle = math.atan2(baseDir.y, baseDir.x);

    for (int i = 0; i < particleCount; i++) {
      final spread = (_random.nextDouble() - 0.5) * 1.3;
      final angle = baseAngle + spread;
      final pSpeed = (35.0 + _random.nextDouble() * 85.0) * speedRatio;
      final vel = Vector2(math.cos(angle) * pSpeed, math.sin(angle) * pSpeed);

      final chalkColors = [
        const Color(0xFF80DEEA), // Màu phấn Master Chalk xanh ngọc
        const Color(0xFFB2EBF2),
        const Color(0xFFE0F7FA),
        const Color(0xFFFFFFFF),
      ];
      final color = chalkColors[_random.nextInt(chalkColors.length)];

      _chalkPuffs.add(
        _ChalkDustParticle(
          pos: tipPos.clone() + (vel.normalized() * (1.5 + _random.nextDouble() * 2.5)),
          vel: vel,
          radius: 1.0 + _random.nextDouble() * 1.8 * speedRatio,
          maxLife: 0.22 + _random.nextDouble() * 0.16,
          color: color,
        ),
      );
    }
  }

  /// Kích hoạt hiệu ứng đàn hồi nảy băng cao su
  void addRailImpact({
    required Vector2 ballPos,
    required Vector2 wallStart,
    required Vector2 wallEnd,
    required double speed,
    double ballRadius = 12.0,
  }) {
    if (speed < 60.0) return;
    final wallVec = wallEnd - wallStart;
    final wallLen = wallVec.length;
    if (wallLen < 0.001) return;

    final tangent = wallVec.normalized();
    // Chiếu vị trí bi lên đoạn thẳng băng
    final toBall = ballPos - wallStart;
    final proj = toBall.dot(tangent).clamp(0.0, wallLen);
    final contactPos = wallStart + tangent * proj;

    final intensity = (speed / 450.0).clamp(0.2, 1.0);
    _railRipples.add(
      _RailImpactRipple(
        position: contactPos,
        tangent: tangent,
        maxHalfLength: ballRadius * (1.2 + 1.0 * intensity),
        maxLife: 0.16 + 0.06 * intensity,
        intensity: intensity,
      ),
    );
  }

  /// Kích hoạt hiệu ứng hút rơi vào miệng lỗ
  void addPocketDrop(Vector2 pocketPos, [double pocketRadius = 24.0]) {
    _pocketVortices.add(
      _PocketDropVortex(
        position: pocketPos.clone(),
        radius: pocketRadius,
      ),
    );
  }

  /// Cập nhật vệt chuyển động của quả bi
  void recordBallPosition(int ballId, Vector2 pos, double speed) {
    if (speed < 320.0) {
      _motionTrails[ballId]?.clear();
      return;
    }
    final history = _motionTrails.putIfAbsent(ballId, () => _BallMotionTrailHistory());
    history.addPosition(pos);
  }

  /// Xóa toàn bộ hiệu ứng khi reset rack hoặc đổi bàn
  void clearAll() {
    _shockwaves.clear();
    _chalkPuffs.clear();
    _railRipples.clear();
    _pocketVortices.clear();
    _cueHitPulses.clear();
    _motionTrails.clear();
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Cập nhật các danh sách hiệu ứng và lọc bỏ các hiệu ứng hết hạn
    _shockwaves.removeWhere((sw) => !sw.update(dt));
    _chalkPuffs.removeWhere((cp) => !cp.update(dt));
    _railRipples.removeWhere((rr) => !rr.update(dt));
    _pocketVortices.removeWhere((pv) => !pv.update(dt));
    _cueHitPulses.removeWhere((chp) => !chp.update(dt));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 1. Vẽ gợn xoáy tụ hút vào lỗ (dưới các hiệu ứng nảy trên mặt bàn)
    for (final pv in _pocketVortices) {
      pv.render(canvas);
    }

    // 2. Vẽ gợn đàn hồi băng cao su
    for (final rr in _railRipples) {
      rr.render(canvas);
    }

    // 3. Vẽ vệt mờ tốc độ cao của các bi
    _renderMotionTrails(canvas);

    // 4. Vẽ sóng kích va chạm nảy bi
    for (final sw in _shockwaves) {
      sw.render(canvas);
    }

    // 5. Vẽ xung chấn tiếp xúc đầu gậy cơ
    for (final chp in _cueHitPulses) {
      chp.render(canvas);
    }

    // 6. Vẽ bụi lơ gậy cơ
    for (final cp in _chalkPuffs) {
      cp.render(canvas);
    }
  }

  void _renderMotionTrails(Canvas canvas) {
    for (final entry in _motionTrails.entries) {
      final ballId = entry.key;
      final history = entry.value;
      if (history.positions.length < 2) continue;

      final isCueBall = ballId == 0;
      final trailBaseColor = isCueBall
          ? const Color(0xFF00E5FF)
          : const Color(0xFFFFD54F);

      for (int i = 0; i < history.positions.length - 1; i++) {
        final pos = history.positions[i];
        final nextPos = history.positions[i + 1];
        final alpha = (0.28 - i * 0.08).clamp(0.04, 0.35);

        final trailPaint = Paint()
          ..color = trailBaseColor.withValues(alpha: alpha)
          ..strokeWidth = (14.0 - i * 3.0).clamp(4.0, 16.0)
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

        canvas.drawLine(pos.toOffset(), nextPos.toOffset(), trailPaint);
      }
    }
  }
}
