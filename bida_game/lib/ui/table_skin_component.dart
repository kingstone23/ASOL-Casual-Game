import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import '../main.dart';
import '../services/progression_service.dart';

/// Component đồ họa hiển thị Skin Bàn Bida tùy chỉnh (20 mẫu bàn đa dạng)
class TableSkinComponent extends Component with HasGameReference<BilliardGame> {
  TableSkinComponent() {
    priority = -1; // Nằm trên pool_table.png (-2) và nằm dưới bi / VFX (1 và 2)
  }

  @override
  void render(Canvas canvas) {
    final table = ProgressionService.instance.equippedTable;
    final size = game.size;
    if (size.x <= 0 || size.y <= 0) return;

    final pTopLeft = game.playAreaTopLeft;
    final pBottomRight = game.playAreaBottomRight;
    if (pTopLeft.x >= pBottomRight.x || pTopLeft.y >= pBottomRight.y) return;

    final playRect = Rect.fromLTRB(pTopLeft.x, pTopLeft.y, pBottomRight.x, pBottomRight.y);

    // Khi người chơi trang bị skin bàn khác (khác classic_green gốc):
    if (table.id != 'classic_green') {
      final fullRect = Rect.fromLTWH(0, 0, size.x, size.y);

      // 1. Phủ màu Thành Băng & Viền Bàn (Outer Rails)
      final railPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            table.railColor,
            Color.lerp(table.railColor, Colors.black, 0.25) ?? table.railColor,
          ],
        ).createShader(fullRect);

      final outerPath = Path()..addRect(fullRect);
      final innerPath = Path()..addRRect(RRect.fromRectAndRadius(playRect, const Radius.circular(8)));
      final railPath = Path.combine(PathOperation.difference, outerPath, innerPath);
      canvas.drawPath(railPath, railPaint);

      // 2. Viền nẹp kim loại / hoa văn sang trọng quanh mép thành băng
      final trimPaint = Paint()
        ..color = table.railAccentColor.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6;
      canvas.drawRRect(RRect.fromRectAndRadius(playRect, const Radius.circular(8)), trimPaint);
      canvas.drawRect(Rect.fromLTWH(2.5, 2.5, size.x - 5, size.y - 5), trimPaint..strokeWidth = 1.0);

      // 3. Các Điểm Ngắm Kim Cương (Diamond Sights) trên 4 thành băng
      _renderDiamondSights(canvas, size, playRect, table.railAccentColor);

      // 4. Phủ Lòng Bàn Vải Nỉ (Cloth Felt Gradient)
      final feltPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [table.clothPrimary, table.clothSecondary],
        ).createShader(playRect);
      canvas.drawRRect(RRect.fromRectAndRadius(playRect, const Radius.circular(6)), feltPaint);

      // 5. Bóng Đổ Chiều Sâu 3D Thành Băng (Ambient Cushion Drop Shadow)
      final shadowDepth = (size.y * 0.038).clamp(8.0, 18.0);
      final shadowTop = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [table.cushionShadowColor, Colors.transparent],
        ).createShader(Rect.fromLTWH(playRect.left, playRect.top, playRect.width, shadowDepth));
      canvas.drawRect(Rect.fromLTWH(playRect.left, playRect.top, playRect.width, shadowDepth), shadowTop);

      final shadowBottom = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [table.cushionShadowColor, Colors.transparent],
        ).createShader(Rect.fromLTWH(playRect.left, playRect.bottom - shadowDepth, playRect.width, shadowDepth));
      canvas.drawRect(Rect.fromLTWH(playRect.left, playRect.bottom - shadowDepth, playRect.width, shadowDepth), shadowBottom);

      // 6. Vạch Phát Bóng (Head String) & Điểm Đặt Bi (Head Spot / Foot Spot)
      final linePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.20)
        ..strokeWidth = 1.0;
      final headX = playRect.left + playRect.width * 0.25;
      final footX = playRect.left + playRect.width * 0.75;
      final midY = playRect.top + playRect.height * 0.5;

      canvas.drawLine(Offset(headX, playRect.top), Offset(headX, playRect.bottom), linePaint);

      final spotPaint = Paint()..color = Colors.white.withValues(alpha: 0.40);
      canvas.drawCircle(Offset(headX, midY), 2.8, spotPaint);
      canvas.drawCircle(Offset(footX, midY), 2.8, spotPaint);

      // 7. Lòng 6 Lỗ Bida với màu pocketColor
      for (final p in game.pockets) {
        final pocketPaint = Paint()..color = table.pocketColor;
        canvas.drawCircle(Offset(p.position.x, p.position.y), p.radius * 0.88, pocketPaint);
      }
    }
  }

  /// Vẽ 18 điểm ngắm chuẩn (Diamond Sights) trên các thành băng
  void _renderDiamondSights(Canvas canvas, Vector2 size, Rect playRect, Color accentColor) {
    final sightPaint = Paint()..color = accentColor.withValues(alpha: 0.85);
    const sightRadius = 2.2;

    // Băng dài trên và dưới (mỗi bên 6 điểm ngắm chia đều)
    final wStep = playRect.width / 8;
    for (int i = 1; i <= 7; i++) {
      if (i == 4) continue; // Bỏ qua vị trí lỗ giữa
      final x = playRect.left + wStep * i;
      final topY = playRect.top * 0.45;
      final botY = size.y - (size.y - playRect.bottom) * 0.45;
      canvas.drawCircle(Offset(x, topY), sightRadius, sightPaint);
      canvas.drawCircle(Offset(x, botY), sightRadius, sightPaint);
    }

    // Băng ngắn trái và phải (mỗi bên 3 điểm ngắm chia đều)
    final hStep = playRect.height / 4;
    for (int i = 1; i <= 3; i++) {
      final y = playRect.top + hStep * i;
      final leftX = playRect.left * 0.45;
      final rightX = size.x - (size.x - playRect.right) * 0.45;
      canvas.drawCircle(Offset(leftX, y), sightRadius, sightPaint);
      canvas.drawCircle(Offset(rightX, y), sightRadius, sightPaint);
    }
  }
}
