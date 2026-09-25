import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/cue_model.dart';
import '../services/progression_service.dart';

class CueShopDialog extends StatefulWidget {
  const CueShopDialog({super.key});

  @override
  State<CueShopDialog> createState() => _CueShopDialogState();
}

class _CueShopDialogState extends State<CueShopDialog> {
  late String _selectedCueId;
  String? _toastMessage;
  bool _toastIsError = false;
  Timer? _toastTimer;

  @override
  void initState() {
    super.initState();
    _selectedCueId = ProgressionService.instance.equippedCueId;
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ListenableBuilder(
        listenable: ProgressionService.instance,
        builder: (context, _) {
          final service = ProgressionService.instance;
          final selectedCue = CueCatalog.getById(_selectedCueId);
          final isOwned = service.isCueOwned(selectedCue.id);
          final isEquipped = service.isCueEquipped(selectedCue.id);
          final isUnlocked = service.canUnlockCue(selectedCue);
          final currentLevel = service.getCueLevel(selectedCue.id);
          final screenHeight = MediaQuery.of(context).size.height;

          return Container(
            constraints: BoxConstraints(
              maxWidth: 880,
              maxHeight: math.min(screenHeight * 0.94, 480.0),
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F1B16), Color(0xFF162B23), Color(0xFF0B1411)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF26A69A).withValues(alpha: 0.6),
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 30,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  Column(
                    children: [
                      // --- TOP BAR ---
                      _buildHeader(service),

                      // --- MAIN BODY (SPLIT VIEW) ---
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // CỘT TRÁI: DANH SÁCH GẬY CƠ
                            Expanded(
                              flex: 5,
                              child: _buildCueList(service),
                            ),

                            // PHÂN TÁCH DỌC
                            Container(
                              width: 1.5,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),

                            // CỘT PHẢI: CHI TIẾT GẬY & NÂNG CẤP
                            Expanded(
                              flex: 6,
                              child: _buildCueDetailPanel(
                                service,
                                selectedCue,
                                isOwned: isOwned,
                                isEquipped: isEquipped,
                                isUnlocked: isUnlocked,
                                currentLevel: currentLevel,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // In-Shop Floating Notification Banner
                  if (_toastMessage != null)
                    Positioned(
                      top: 54,
                      left: 16,
                      right: 16,
                      child: Center(
                        child: _buildInShopToast(),
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

  Widget _buildHeader(ProgressionService service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF081410),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.storefront, color: Color(0xFFFFD54F), size: 24),
          const SizedBox(width: 8),
          const Text(
            'CỬA HÀNG GẬY CƠ & TIẾN TRÌNH',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),

          // Level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Cấp ${service.playerLevel}',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Vàng
          Row(
            children: [
              const Icon(Icons.monetization_on, color: Color(0xFFFFD54F), size: 18),
              const SizedBox(width: 4),
              Text(
                '${service.coins}',
                style: const TextStyle(
                  color: Color(0xFFFFD54F),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Kim Cương
          Row(
            children: [
              const Icon(Icons.diamond, color: Color(0xFF29B6F6), size: 17),
              const SizedBox(width: 4),
              Text(
                '${service.diamonds}',
                style: const TextStyle(
                  color: Color(0xFF81D4FA),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Nút Đóng
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white70),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Đóng',
          ),
        ],
      ),
    );
  }

  Widget _buildCueList(ProgressionService service) {
    final cues = CueCatalog.allCues;
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: cues.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final cue = cues[index];
        final isSelected = cue.id == _selectedCueId;
        final isOwned = service.isCueOwned(cue.id);
        final isEquipped = service.isCueEquipped(cue.id);
        final isUnlocked = service.canUnlockCue(cue);
        final cueLevel = service.getCueLevel(cue.id);

        return InkWell(
          onTap: () => setState(() => _selectedCueId = cue.id),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? cue.rarity.color.withValues(alpha: 0.22)
                  : (isOwned
                      ? const Color(0xFF142E25)
                      : const Color(0xFF0F1B17)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? cue.rarity.color
                    : (isEquipped
                        ? const Color(0xFF00E676)
                        : Colors.white.withValues(alpha: 0.1)),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: cue.rarity.glowColor,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Khối màu nhận diện phẩm cấp
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [cue.shaftColors.first, cue.handleColors.first],
                    ),
                    border: Border.all(color: cue.rarity.color, width: 1.5),
                  ),
                  child: Icon(
                    !isUnlocked
                        ? Icons.lock
                        : (isEquipped ? Icons.check : Icons.sports_volleyball),
                    color: !isUnlocked ? Colors.white70 : Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),

                // Tên và thông tin gậy
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              cue.name,
                              style: TextStyle(
                                color: isUnlocked ? Colors.white : Colors.white54,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: cue.rarity.color.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              cue.rarity.displayName,
                              style: TextStyle(
                                color: cue.rarity.color,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (!isUnlocked) ...[
                            Text(
                              'Cần Cấp ${cue.requiredLevel}',
                              style: const TextStyle(
                                color: Color(0xFFFF5252),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ] else if (isOwned) ...[
                            Text(
                              'Cấp gậy: $cueLevel/10',
                              style: const TextStyle(
                                color: Color(0xFF69F0AE),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isEquipped) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E676).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color(0xFF00E676),
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  'ĐANG DÙNG',
                                  style: TextStyle(
                                    color: Color(0xFF00E676),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ] else ...[
                            _buildPriceTag(cue),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceTag(CueModel cue) {
    if (cue.isFree) {
      return const Text(
        'Miễn phí',
        style: TextStyle(
          color: Color(0xFF69F0AE),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    if (cue.priceDiamonds != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.diamond, color: Color(0xFF29B6F6), size: 13),
          const SizedBox(width: 3),
          Text(
            '${cue.priceDiamonds}',
            style: const TextStyle(
              color: Color(0xFF81D4FA),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.monetization_on, color: Color(0xFFFFD54F), size: 13),
        const SizedBox(width: 3),
        Text(
          '${cue.priceCoins}',
          style: const TextStyle(
            color: Color(0xFFFFD54F),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCueDetailPanel(
    ProgressionService service,
    CueModel cue, {
    required bool isOwned,
    required bool isEquipped,
    required bool isUnlocked,
    required int currentLevel,
  }) {
    final effectiveLevel = isOwned ? currentLevel : 1;
    final currentStats = cue.getStatsForLevel(effectiveLevel);
    final nextStats = isOwned && effectiveLevel < 10
        ? cue.getStatsForLevel(effectiveLevel + 1)
        : null;
    final upgradeCost = isOwned ? cue.getUpgradeCostCoins(effectiveLevel) : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề & Độ hiếm
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cue.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cue.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cue.rarity.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: cue.rarity.color, width: 1.5),
                ),
                child: Text(
                  cue.rarity.displayName.toUpperCase(),
                  style: TextStyle(
                    color: cue.rarity.color,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // XEM TRƯỚC CÂY GẬY VECTOR NẰM NGANG
          Container(
            height: 52,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cue.rarity.color.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: CustomPaint(
              painter: _HorizontalCuePreviewPainter(
                cue: cue,
                level: effectiveLevel,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // CẤP ĐỘ GẬY (SEGMENTS)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOwned
                    ? 'CẤP ĐỘ GẬY: $effectiveLevel / 10'
                    : 'CẤP ĐỘ KHỞI ĐIỂM: Lv.1',
                style: TextStyle(
                  color: cue.rarity.color,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.8,
                ),
              ),
              if (isOwned && effectiveLevel == 10)
                const Text(
                  '★ MAX LEVEL',
                  style: TextStyle(
                    color: Color(0xFFFFD54F),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(10, (idx) {
              final isFilled = idx < effectiveLevel;
              return Expanded(
                child: Container(
                  height: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    color: isFilled
                        ? cue.rarity.color
                        : Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),

          // 4 THANH CHỈ SỐ STATS
          _buildStatRow(
            label: 'Lực đánh (Force)',
            current: currentStats.force,
            next: nextStats?.force,
            color: const Color(0xFFFF7043),
            icon: Icons.flash_on,
          ),
          const SizedBox(height: 6),
          _buildStatRow(
            label: 'Tia ngắm (Aim Guide)',
            current: currentStats.aim,
            next: nextStats?.aim,
            color: const Color(0xFF29B6F6),
            icon: Icons.track_changes,
          ),
          const SizedBox(height: 6),
          _buildStatRow(
            label: 'Độ xoáy (Spin)',
            current: currentStats.spin,
            next: nextStats?.spin,
            color: const Color(0xFFAB47BC),
            icon: Icons.rotate_right,
          ),
          const SizedBox(height: 6),
          _buildStatRow(
            label: 'Thời gian lượt (Time)',
            current: currentStats.time,
            next: nextStats?.time,
            color: const Color(0xFFFFCA28),
            icon: Icons.timer,
          ),
          const SizedBox(height: 12),

          // HỘP NỘI TẠI KỸ NĂNG ĐẶC BIỆT
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A2F),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF26A69A).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFFFD54F),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cue.passivePerk,
                    style: const TextStyle(
                      color: Color(0xFFE0F2F1),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // CÁC NÚT THAO TÁC (MUA, NÂNG CẤP, TRANG BỊ)
          _buildActionButtons(
            service,
            cue,
            isOwned: isOwned,
            isEquipped: isEquipped,
            isUnlocked: isUnlocked,
            currentLevel: effectiveLevel,
            upgradeCost: upgradeCost,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required double current,
    double? next,
    required Color color,
    required IconData icon,
  }) {
    const double maxStat = 16.0;
    final currentRatio = (current / maxStat).clamp(0.0, 1.0);
    final nextDiff = (next != null && next > current) ? next - current : 0.0;
    final nextRatio = ((current + nextDiff) / maxStat).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 13),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  current.toStringAsFixed(1),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                if (nextDiff > 0) ...[
                  Text(
                    ' (+${nextDiff.toStringAsFixed(1)})',
                    style: const TextStyle(
                      color: Color(0xFF69F0AE),
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 3),
        Stack(
          children: [
            // Background bar
            Container(
              height: 7,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Next stat preview
            if (nextDiff > 0)
              FractionallySizedBox(
                widthFactor: nextRatio,
                child: Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            // Current stat
            FractionallySizedBox(
              widthFactor: currentRatio,
              child: Container(
                height: 7,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    ProgressionService service,
    CueModel cue, {
    required bool isOwned,
    required bool isEquipped,
    required bool isUnlocked,
    required int currentLevel,
    required int upgradeCost,
  }) {
    // 1. Chưa đủ cấp độ để mở khóa
    if (!isUnlocked) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () {
            _showToast(
              context,
              'Cây cơ này yêu cầu đạt Cấp ${cue.requiredLevel} để mở khóa!',
              isError: true,
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white12,
            foregroundColor: Colors.white54,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.lock, size: 18),
          label: Text(
            'KHÓA • YÊU CẦU ĐẠT CẤP ${cue.requiredLevel}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ),
      );
    }

    // 2. Đã mở khóa nhưng CHƯA MUA
    if (!isOwned) {
      final isDiamond = cue.priceDiamonds != null;
      final price = isDiamond ? cue.priceDiamonds! : (cue.priceCoins ?? 0);
      final canAfford = isDiamond
          ? service.diamonds >= price
          : service.coins >= price;

      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () {
            if (!canAfford) {
              final missing = price - (isDiamond ? service.diamonds : service.coins);
              _showToast(
                context,
                isDiamond
                    ? 'Bạn không đủ Kim Cương để mua cây cơ này (còn thiếu $missing Kim Cương)!'
                    : 'Bạn không đủ Vàng để mua cây cơ này (còn thiếu $missing Vàng)!',
                isError: true,
              );
              return;
            }
            final success = service.buyCue(cue);
            if (success) {
              _showToast(context, 'Chúc mừng! Đã sở hữu và trang bị ${cue.name}!');
            } else {
              _showToast(
                context,
                'Không thể mua cây cơ này. Vui lòng kiểm tra lại số dư!',
                isError: true,
              );
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: canAfford ? const Color(0xFF00E676) : Colors.grey.shade700,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: Icon(isDiamond ? Icons.diamond : Icons.monetization_on, size: 20),
          label: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'MUA NGAY • $price ${isDiamond ? 'KIM CƯƠNG' : 'VÀNG'}',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      );
    }

    // 3. ĐÃ SỞ HỮU: CUNG CẤP NÚT TRANG BỊ & NÂNG CẤP
    return Row(
      children: [
        // Nút Trang Bị / Đang dùng
        Expanded(
          flex: 4,
          child: isEquipped
              ? Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF00E676),
                      width: 1.8,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF00E676), size: 18),
                      SizedBox(width: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'ĐANG DÙNG',
                          style: TextStyle(
                            color: Color(0xFF00E676),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : FilledButton.icon(
                  onPressed: () {
                    service.equipCue(cue.id);
                    _showToast(context, 'Đã trang bị ${cue.name} thành công!');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF00B0FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.colorize, size: 18, color: Colors.white),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'TRANG BỊ',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.8,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 10),

        // Nút Nâng Cấp Gậy
        Expanded(
          flex: 6,
          child: FilledButton.icon(
            onPressed: currentLevel >= 10
                ? null
                : () {
                    final canUpgrade = service.coins >= upgradeCost;
                    if (!canUpgrade) {
                      final missing = upgradeCost - service.coins;
                      _showToast(
                        context,
                        'Bạn cần thêm $missing Vàng để nâng cấp gậy này (tổng $upgradeCost Vàng)!',
                        isError: true,
                      );
                      return;
                    }
                    final ok = service.upgradeCue(cue.id);
                    if (ok) {
                      _showToast(
                        context,
                        'Chúc mừng! Nâng cấp ${cue.name} lên Cấp ${currentLevel + 1} thành công!',
                      );
                    }
                  },
            style: FilledButton.styleFrom(
              backgroundColor: currentLevel >= 10
                  ? Colors.white12
                  : const Color(0xFFFFB300),
              foregroundColor: currentLevel >= 10
                  ? Colors.white38
                  : Colors.black87,
              disabledBackgroundColor: Colors.white12,
              disabledForegroundColor: Colors.white38,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: Icon(
              currentLevel >= 10 ? Icons.star : Icons.arrow_upward,
              size: 18,
            ),
            label: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                currentLevel >= 10
                    ? 'TỐI ĐA (MAX)'
                    : 'NÂNG LV.${currentLevel + 1} • $upgradeCost VÀNG',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showToast(BuildContext context, String message, {bool isError = false}) {
    _toastTimer?.cancel();
    setState(() {
      _toastMessage = message;
      _toastIsError = isError;
    });
    _toastTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _toastMessage = null;
        });
      }
    });
  }

  Widget _buildInShopToast() {
    return TweenAnimationBuilder<double>(
      key: ValueKey(_toastMessage),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, anim, child) {
        return Transform.translate(
          offset: Offset(0, (1 - anim) * -16),
          child: Opacity(
            opacity: anim.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _toastIsError
                ? [const Color(0xFFD32F2F), const Color(0xFF8B0000)]
                : [const Color(0xFF2E7D32), const Color(0xFF1B5E20)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _toastIsError ? const Color(0xFFFF8A80) : const Color(0xFF69F0AE),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: (_toastIsError ? Colors.redAccent : Colors.greenAccent)
                  .withValues(alpha: 0.4),
              blurRadius: 18,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
            const BoxShadow(
              color: Colors.black54,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _toastIsError ? Icons.error_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                _toastMessage ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () {
                _toastTimer?.cancel();
                setState(() => _toastMessage = null);
              },
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.close, color: Colors.white70, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter vẽ preview gậy cơ nằm ngang theo màu sắc đặc trưng của CueModel
class _HorizontalCuePreviewPainter extends CustomPainter {
  final CueModel cue;
  final int level;

  _HorizontalCuePreviewPainter({required this.cue, required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centerY = h / 2;

    final tipRadius = 2.4;
    final handleRadius = 5.2;

    // 1. Vẽ vệt hào quang sáng đằng sau (Aura Glow)
    final auraPaint = Paint()
      ..color = cue.auraColor.withValues(alpha: (0.3 + level * 0.05).clamp(0.2, 0.8))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawLine(
      Offset(10, centerY),
      Offset(w - 10, centerY),
      auraPaint..strokeWidth = 14,
    );

    // 2. Thân gậy thon dần (Shaft - Từ trái sang phải hoặc ngược lại)
    // Đầu gậy (bên phải): nhỏ (tipRadius), Đuôi gậy (bên trái): to (handleRadius)
    final xHandleStart = 15.0;
    final xHandleEnd = w * 0.40;
    final xShaftEnd = w - 20.0;

    // Phần tay cầm (Handle)
    final handlePath = Path()
      ..moveTo(xHandleStart, centerY - handleRadius)
      ..lineTo(xHandleEnd, centerY - (handleRadius * 0.82))
      ..lineTo(xHandleEnd, centerY + (handleRadius * 0.82))
      ..lineTo(xHandleStart, centerY + handleRadius)
      ..close();

    final handlePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: cue.handleColors,
      ).createShader(Rect.fromLTWH(xHandleStart, centerY - handleRadius, xHandleEnd - xHandleStart, handleRadius * 2));
    canvas.drawPath(handlePath, handlePaint);

    // Vòng khuyên kim loại giữa tay cầm và ngọn
    final ringPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawRect(
      Rect.fromLTWH(xHandleEnd - 2, centerY - handleRadius * 0.82, 4, handleRadius * 1.64),
      ringPaint,
    );

    // Phần ngọn cơ (Shaft)
    final shaftPath = Path()
      ..moveTo(xHandleEnd, centerY - (handleRadius * 0.82))
      ..lineTo(xShaftEnd, centerY - tipRadius)
      ..lineTo(xShaftEnd, centerY + tipRadius)
      ..lineTo(xHandleEnd, centerY + (handleRadius * 0.82))
      ..close();

    final shaftPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: cue.shaftColors,
      ).createShader(Rect.fromLTWH(xHandleEnd, centerY - handleRadius, xShaftEnd - xHandleEnd, handleRadius * 2));
    canvas.drawPath(shaftPath, shaftPaint);

    // Đầu cơ (Tip)
    final tipPaint = Paint()..color = cue.tipColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(xShaftEnd, centerY - tipRadius, 4.0, tipRadius * 2),
        const Radius.circular(1.5),
      ),
      tipPaint,
    );

    // Điểm nhấn sao/lửa nếu là gậy cấp cao (Lv. 8 - 10)
    if (level >= 8) {
      final sparkPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(xShaftEnd + 2, centerY), 2.2, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HorizontalCuePreviewPainter oldDelegate) {
    return oldDelegate.cue.id != cue.id || oldDelegate.level != level;
  }
}
