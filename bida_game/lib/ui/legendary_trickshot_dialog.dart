import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/legendary_trickshot_model.dart';
import '../services/progression_service.dart';

class LegendaryTrickshotDialog extends StatelessWidget {
  final void Function(LegendaryTrickshotModel shot) onSelectTrickshot;

  const LegendaryTrickshotDialog({super.key, required this.onSelectTrickshot});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ListenableBuilder(
        listenable: ProgressionService.instance,
        builder: (context, _) {
          final service = ProgressionService.instance;
          final trickshots = LegendaryTrickshotCatalog.trickshots;
          final screenHeight = MediaQuery.of(context).size.height;

          return Container(
            constraints: BoxConstraints(
              maxWidth: 840,
              maxHeight: math.min(screenHeight * 0.94, 520.0),
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D281E), Color(0xFF163E30), Color(0xFF091F17)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFD54F).withValues(alpha: 0.6),
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black87, blurRadius: 24),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Column(
                children: [
                  // --- HEADER ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF081812),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
                            ),
                          ),
                          child: const Icon(Icons.auto_awesome, color: Colors.black87, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LUYỆN TẬP THẾ ĐÁNH HUYỀN THOẠI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              Text(
                                'Đường cơ kinh điển: Efren Reyes, Ronnie O\'Sullivan, Shane Van Boening...',
                                style: TextStyle(
                                  color: Color(0xFFFFD54F),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            'Chinh phục: ${service.completedTrickshots.length} / ${trickshots.length}',
                            style: const TextStyle(
                              color: Color(0xFF00E676),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: Colors.white70, size: 22),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Đóng',
                        ),
                      ],
                    ),
                  ),

                  // --- LIST OF LEGENDARY TRICKSHOTS ---
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: trickshots.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final shot = trickshots[index];
                        final isCompleted = service.isTrickshotCompleted(shot.id);

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? const Color(0xFF133629)
                                : const Color(0xFF0E271D),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isCompleted
                                  ? const Color(0xFF00E676)
                                  : const Color(0xFFFFD54F).withValues(alpha: 0.35),
                              width: isCompleted ? 1.8 : 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Avatar Bi / Số thứ tự
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: isCompleted
                                            ? [const Color(0xFF00E676), const Color(0xFF00897B)]
                                            : [const Color(0xFFFFD54F), const Color(0xFFE65100)],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isCompleted
                                              ? const Color(0xFF00E676).withValues(alpha: 0.35)
                                              : const Color(0xFFFFD54F).withValues(alpha: 0.25),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: isCompleted
                                          ? const Icon(Icons.emoji_events, color: Colors.black87, size: 22)
                                          : Text(
                                              '#${index + 1}',
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 15,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Nội dung thế đánh
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                shot.title,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            // Độ khó sao
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: List.generate(5, (starIdx) {
                                                return Icon(
                                                  starIdx < shot.difficultyStars
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  size: 13,
                                                  color: const Color(0xFFFFD54F),
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              'Cơ thủ: ${shot.masterName}',
                                              style: const TextStyle(
                                                color: Color(0xFFFFD54F),
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '• ${shot.masterNickname}',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 10.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          shot.yearAndTournament,
                                          style: const TextStyle(
                                            color: Color(0xFF80CBC4),
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          shot.description,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11,
                                            height: 1.25,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Bottom bar: Gợi ý kỹ thuật & Nút Tập
                              Row(
                                children: [
                                  // Badge Gợi ý kỹ thuật (áp-phê, trô, cu-lê)
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black38,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.amber.withValues(alpha: 0.25),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.lightbulb, color: Color(0xFFFFD54F), size: 13),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              shot.techniqueHint,
                                              style: const TextStyle(
                                                color: Color(0xFFFFECB3),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Phần thưởng
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.monetization_on, color: Color(0xFFFFD54F), size: 14),
                                      const SizedBox(width: 2),
                                      Text(
                                        '+${shot.rewardCoins}',
                                        style: const TextStyle(
                                          color: Color(0xFFFFD54F),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 10),

                                  // Nút Vào Luyện Tập
                                  FilledButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      onSelectTrickshot(shot);
                                    },
                                    style: FilledButton.styleFrom(
                                      backgroundColor: isCompleted
                                          ? const Color(0xFF00E676)
                                          : const Color(0xFFFFB300),
                                      foregroundColor: Colors.black87,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: Icon(
                                      isCompleted ? Icons.replay : Icons.play_arrow_rounded,
                                      size: 15,
                                    ),
                                    label: Text(
                                      isCompleted ? 'LUYỆN LẠI' : 'TẬP THẾ NÀY',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
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
          );
        },
      ),
    );
  }
}
