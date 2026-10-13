import 'package:flutter/material.dart';
import '../models/tournament_model.dart';
import '../services/progression_service.dart';

class TournamentDialog extends StatelessWidget {
  final void Function(TournamentBracketStage stage) onStartBracketMatch;

  const TournamentDialog({
    super.key,
    required this.onStartBracketMatch,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 750;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 30,
        vertical: isMobile ? 10 : 20,
      ),
      child: Container(
        width: 860,
        height: screenSize.height * 0.90,
        decoration: BoxDecoration(
          color: const Color(0xFF0D1D17),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFFFD54F), width: 1.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.85),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Grand Champion Reward Banner
            _buildChampionBanner(),

            // 6 Brackets Ladder
            Expanded(
              child: ListenableBuilder(
                listenable: ProgressionService.instance,
                builder: (context, _) {
                  return _buildBracketLadder(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B3D30), Color(0xFF10261E)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(bottom: BorderSide(color: Color(0xFFFFD54F), width: 1.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
              ),
            ),
            child: const Icon(Icons.emoji_events, color: Colors.black87, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GIẢI ĐẤU VÔ ĐỊCH 6 BRACKETS (TOURNAMENT)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Vượt qua 6 vòng đấu tử thần • Giành Cúp Vàng Quán Quân, EXP & Thành Tựu!',
                  style: TextStyle(color: Color(0xFFFFD54F), fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white70),
            tooltip: 'Đóng',
          ),
        ],
      ),
    );
  }

  Widget _buildChampionBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5D4037), Color(0xFF2E1C14)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.6)),
      ),
      child: const Row(
        children: [
          Icon(Icons.workspace_premium, color: Color(0xFFFFD54F), size: 28),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🏆 PHẦN THƯỞNG QUÁN QUÂN ĐẠI CHUNG KẾT BRACKET 6:',
                  style: TextStyle(
                    color: Color(0xFFFFD54F),
                    fontWeight: FontWeight.w900,
                    fontSize: 11.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '+15.000 Vàng • +2.500 EXP • Cúp Quán Quân Tournament • Thành Tựu Vua Giải Đấu!',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBracketLadder(BuildContext context) {
    final currentBracket = ProgressionService.instance.currentTournamentBracket;
    final brackets = TournamentCatalog.brackets;

    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: brackets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final stage = brackets[index];
        final isPassed = stage.bracketNumber < currentBracket;
        final isCurrent = stage.bracketNumber == currentBracket;
        final isLocked = stage.bracketNumber > currentBracket;
        final isFinal = stage.bracketNumber == 6;

        return Container(
          decoration: BoxDecoration(
            color: isCurrent
                ? const Color(0xFF1B4332)
                : (isPassed ? const Color(0xFF132B22) : Colors.black38),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrent
                  ? const Color(0xFFFFD54F)
                  : (isPassed ? const Color(0xFF00E676) : Colors.white12),
              width: isCurrent ? 2.0 : 1.0,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Bracket Badge Number
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: isPassed
                        ? const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00B0FF)])
                        : (isCurrent
                            ? const LinearGradient(colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)])
                            : null),
                    color: isLocked ? Colors.white12 : null,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isPassed
                        ? const Icon(Icons.check, color: Colors.black, size: 26)
                        : (isLocked
                            ? const Icon(Icons.lock, color: Colors.white38, size: 22)
                            : (isFinal
                                ? const Icon(Icons.emoji_events, color: Colors.black87, size: 26)
                                : Text(
                                    '${stage.bracketNumber}',
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 20,
                                    ),
                                  ))),
                  ),
                ),
                const SizedBox(width: 14),

                // Info: Title, Round Name, Opponent, Rewards
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: isFinal
                                  ? Colors.amber.withValues(alpha: 0.25)
                                  : const Color(0xFF26A69A).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'BRACKET ${stage.bracketNumber} • ${stage.roundName}',
                              style: TextStyle(
                                color: isFinal ? const Color(0xFFFFD54F) : Colors.tealAccent,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isFinal) ...[
                            const Text(
                              '👑 TRẬN TRANH CÚP VÔ ĐỊCH',
                              style: TextStyle(
                                color: Color(0xFFFFD54F),
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        stage.title,
                        style: TextStyle(
                          color: isLocked ? Colors.white54 : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.sports_esports, color: Colors.white60, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Đối thủ: ${stage.opponentName} (Lv.${stage.opponentLevel}) • ${stage.opponentCue.name}',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Rewards Row
                      Wrap(
                        spacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.monetization_on, color: Color(0xFFFFD54F), size: 13),
                              const SizedBox(width: 3),
                              Text(
                                '+${stage.coinReward} Vàng',
                                style: const TextStyle(
                                  color: Color(0xFFFFD54F),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.tealAccent, size: 13),
                              const SizedBox(width: 3),
                              Text(
                                '+${stage.xpReward} EXP',
                                style: const TextStyle(
                                  color: Colors.tealAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                          if (stage.bonusMedalId != null) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.workspace_premium, color: Color(0xFFFF4081), size: 13),
                                const SizedBox(width: 3),
                                Text(
                                  isFinal ? '🏆 Cúp Quán Quân' : '🎖️ Huy Chương',
                                  style: const TextStyle(
                                    color: Color(0xFFFF4081),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Action Button
                if (isCurrent) ...[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onStartBracketMatch(stage);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB300),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isFinal ? Icons.emoji_events : Icons.play_arrow, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          isFinal ? 'TRANH CÚP' : 'VÀO TRẬN',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (isPassed) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF00E676)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Color(0xFF00E676), size: 15),
                        SizedBox(width: 4),
                        Text(
                          'ĐÃ THẮNG',
                          style: TextStyle(
                            color: Color(0xFF00E676),
                            fontWeight: FontWeight.bold,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Khóa',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
