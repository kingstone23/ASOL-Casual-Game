import 'package:flutter/material.dart';
import '../models/daily_puzzle_model.dart';
import '../services/progression_service.dart';

class DailyPuzzleDialog extends StatelessWidget {
  final void Function(DailyPuzzleModel puzzle) onStartPuzzle;

  const DailyPuzzleDialog({super.key, required this.onStartPuzzle});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final puzzle = DailyPuzzleModel.generateForDate(now);
    final isCompleted = ProgressionService.instance.isDailyPuzzleCompletedToday();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A122E), Color(0xFF2E1C4D), Color(0xFF140D24)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFAB47BC).withValues(alpha: 0.6),
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black87, blurRadius: 25, offset: Offset(0, 8)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- HEADER ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF100921),
                  border: Border(
                    bottom: BorderSide(color: Colors.white12, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_note, color: Color(0xFFFFD54F), size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'NHIỆM VỤ THẾ BI HÀNG NGÀY',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${now.day}/${now.month}/${now.year}',
                        style: const TextStyle(
                          color: Color(0xFFE1BEE7),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white70),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // --- BODY CONTENT ---
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề thế bi
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFAB47BC).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFAB47BC)),
                          ),
                          child: const Text(
                            'RANDOM PUZZLE',
                            style: TextStyle(
                              color: Color(0xFFE1BEE7),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            puzzle.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Mô tả nhiệm vụ
                    Text(
                      puzzle.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Giới hạn lượt đánh
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.touch_app, color: Color(0xFFFFD54F), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Giới hạn: Tối đa ${puzzle.maxShotsAllowed} lượt đánh',
                            style: const TextStyle(
                              color: Color(0xFFFFD54F),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Gợi ý mẹo
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF381E57).withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFAB47BC).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb, color: Colors.amber, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              puzzle.hint,
                              style: const TextStyle(
                                color: Color(0xFFE1BEE7),
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Phần thưởng
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF120B22),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.monetization_on, color: Color(0xFFFFD54F), size: 20),
                              const SizedBox(width: 6),
                              Text(
                                '+${puzzle.rewardCoins} Vàng',
                                style: const TextStyle(
                                  color: Color(0xFFFFD54F),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.bolt, color: Color(0xFF69F0AE), size: 20),
                              const SizedBox(width: 6),
                              Text(
                                '+${puzzle.rewardXP} XP',
                                style: const TextStyle(
                                  color: Color(0xFF69F0AE),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.diamond, color: Color(0xFF81D4FA), size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '+${puzzle.rewardDiamonds} 💎',
                                style: const TextStyle(
                                  color: Color(0xFF81D4FA),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Nút Hành Động
                    SizedBox(
                      width: double.infinity,
                      child: isCompleted
                          ? Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle, color: Color(0xFF00E676), size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'ĐÃ HOÀN THÀNH HÔM NAY • HẸN GẶP LẠI NGÀY MAI!',
                                    style: TextStyle(
                                      color: Color(0xFF00E676),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : FilledButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                onStartPuzzle(puzzle);
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF00E676),
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.play_arrow, size: 22),
                              label: const Text(
                                'BẮT ĐẦU THỬ THÁCH THẾ BI',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
