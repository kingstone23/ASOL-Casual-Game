import 'package:flutter/material.dart';
import '../services/progression_service.dart';
import 'cue_shop_dialog.dart';

class PlayerProfileBar extends StatelessWidget {
  final bool compact;
  final bool showShopButton;

  const PlayerProfileBar({
    super.key,
    this.compact = false,
    this.showShopButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ProgressionService.instance,
      builder: (context, _) {
        final service = ProgressionService.instance;
        final level = service.playerLevel;
        final xp = service.currentXP;
        final nextXp = service.xpRequiredForNextLevel;
        final progress = service.xpProgress;
        final coins = service.coins;
        final diamonds = service.diamonds;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14,
            vertical: compact ? 4 : 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1E18).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF26A69A).withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Level Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  'Lv.$level',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w900,
                    fontSize: compact ? 11 : 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 2. XP Progress Bar
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: compact ? 70 : 100),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'XP',
                          style: TextStyle(
                            color: Colors.tealAccent,
                            fontSize: compact ? 9 : 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$xp/$nextXp',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: compact ? 8 : 9,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: compact ? 4 : 6,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF00E676),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // 3. Vàng (Coins)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Color(0xFFFFD54F),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatNumber(coins),
                      style: TextStyle(
                        color: const Color(0xFFFFD54F),
                        fontWeight: FontWeight.w800,
                        fontSize: compact ? 11 : 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // 4. Kim Cương (Diamonds)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.diamond,
                      color: Color(0xFF29B6F6),
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatNumber(diamonds),
                      style: TextStyle(
                        color: const Color(0xFF81D4FA),
                        fontWeight: FontWeight.w800,
                        fontSize: compact ? 11 : 12,
                      ),
                    ),
                  ],
                ),
              ),

              // 5. Nút mở Cửa hàng (Shop)
              if (showShopButton) ...[
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const CueShopDialog(),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 8 : 12,
                      vertical: compact ? 4 : 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pinkAccent.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_bag,
                          color: Colors.white,
                          size: compact ? 14 : 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'SHOP',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            fontSize: compact ? 11 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}
