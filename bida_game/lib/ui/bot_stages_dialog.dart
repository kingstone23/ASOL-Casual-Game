import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/bot_stage_model.dart';
import '../models/cue_model.dart';
import '../services/progression_service.dart';

class BotStagesDialog extends StatelessWidget {
  final void Function(BotStageModel stage) onSelectStage;

  const BotStagesDialog({super.key, required this.onSelectStage});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ListenableBuilder(
        listenable: ProgressionService.instance,
        builder: (context, _) {
          final service = ProgressionService.instance;
          final stages = BotStageCatalog.stages;
          final screenHeight = MediaQuery.of(context).size.height;

          return Container(
            constraints: BoxConstraints(
              maxWidth: 820,
              maxHeight: math.min(screenHeight * 0.94, 480.0),
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D1B2A), Color(0xFF1B263B), Color(0xFF0D1821)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF08121E),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.military_tech, color: Color(0xFFFFD54F), size: 26),
                        const SizedBox(width: 8),
                        const Text(
                          '7 ẢI THỬ THÁCH BOT (THEO CẤP GẬY CƠ)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Tiến độ: ${service.completedBotStages.length} / 7 ải',
                            style: const TextStyle(
                              color: Color(0xFF69F0AE),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: Colors.white70),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  // --- LIST OF 7 STAGES ---
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: stages.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final stage = stages[index];
                        final isUnlocked = service.isBotStageUnlocked(stage.stageNumber);
                        final isCompleted = service.isBotStageCompleted(stage.stageNumber);
                        final cue = stage.cue;

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUnlocked
                                ? const Color(0xFF1E2E42)
                                : const Color(0xFF141D28),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isCompleted
                                  ? const Color(0xFF00E676)
                                  : (isUnlocked
                                      ? cue.rarity.color
                                      : Colors.white12),
                              width: isCompleted ? 2 : 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Avatar / Số thứ tự ải
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: isUnlocked
                                        ? [cue.shaftColors.first, cue.handleColors.first]
                                        : [Colors.grey.shade800, Colors.grey.shade900],
                                  ),
                                  border: Border.all(
                                    color: isUnlocked ? cue.rarity.color : Colors.white24,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: isCompleted
                                      ? const Icon(Icons.check, color: Color(0xFF00E676), size: 24)
                                      : (!isUnlocked
                                          ? const Icon(Icons.lock, color: Colors.white54, size: 20)
                                          : Text(
                                              '${stage.stageNumber}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 16,
                                              ),
                                            )),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Thông tin ải
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          stage.title,
                                          style: TextStyle(
                                            color: isUnlocked ? Colors.white : Colors.white54,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: cue.rarity.color.withValues(alpha: 0.25),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Gậy: ${cue.name}',
                                            style: TextStyle(
                                              color: cue.rarity.color,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (isCompleted) ...[
                                          const SizedBox(width: 6),
                                          const Text(
                                            '★ ĐÃ VƯỢT',
                                            style: TextStyle(
                                              color: Color(0xFF00E676),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      stage.description,
                                      style: TextStyle(
                                        color: isUnlocked ? Colors.white70 : Colors.white38,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Phần thưởng lần đầu
                                    Row(
                                      children: [
                                        const Text(
                                          'Quà lần đầu: ',
                                          style: TextStyle(color: Colors.white54, fontSize: 10),
                                        ),
                                        Text(
                                          '+${stage.firstClearCoins} Vàng',
                                          style: const TextStyle(
                                            color: Color(0xFFFFD54F),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '+${stage.firstClearXP} XP',
                                          style: const TextStyle(
                                            color: Color(0xFF69F0AE),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                        if (stage.firstClearDiamonds > 0) ...[
                                          const SizedBox(width: 6),
                                          Text(
                                            '+${stage.firstClearDiamonds} 💎',
                                            style: const TextStyle(
                                              color: Color(0xFF81D4FA),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Nút Khiêu Chiến
                              FilledButton.icon(
                                onPressed: isUnlocked
                                    ? () {
                                        Navigator.of(context).pop();
                                        onSelectStage(stage);
                                      }
                                    : null,
                                style: FilledButton.styleFrom(
                                  backgroundColor: isCompleted
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFF00E5FF),
                                  foregroundColor: isCompleted ? Colors.white : Colors.black87,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: Icon(
                                  isCompleted ? Icons.replay : Icons.play_arrow,
                                  size: 18,
                                ),
                                label: Text(
                                  isCompleted ? 'ĐẤU LẠI' : 'KHIÊU CHIẾN',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                    letterSpacing: 0.8,
                                  ),
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
          );
        },
      ),
    );
  }
}
