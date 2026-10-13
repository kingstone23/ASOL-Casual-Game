import 'package:flutter/material.dart';

enum AchievementDifficulty {
  easy,
  medium,
  hard,
  expert,
  legendary,
}

extension AchievementDifficultyExt on AchievementDifficulty {
  String get label {
    switch (this) {
      case AchievementDifficulty.easy:
        return 'Dễ';
      case AchievementDifficulty.medium:
        return 'Trung Bình';
      case AchievementDifficulty.hard:
        return 'Khó';
      case AchievementDifficulty.expert:
        return 'Siêu Khó';
      case AchievementDifficulty.legendary:
        return 'Huyền Thoại';
    }
  }

  int get defaultRewardXP {
    switch (this) {
      case AchievementDifficulty.easy:
        return 60;
      case AchievementDifficulty.medium:
        return 150;
      case AchievementDifficulty.hard:
        return 350;
      case AchievementDifficulty.expert:
        return 700;
      case AchievementDifficulty.legendary:
        return 1800;
    }
  }

  Color get color {
    switch (this) {
      case AchievementDifficulty.easy:
        return const Color(0xFF66BB6A);
      case AchievementDifficulty.medium:
        return const Color(0xFF42A5F5);
      case AchievementDifficulty.hard:
        return const Color(0xFFFFA726);
      case AchievementDifficulty.expert:
        return const Color(0xFFAB47BC);
      case AchievementDifficulty.legendary:
        return const Color(0xFFFFD700);
    }
  }
}

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final AchievementDifficulty difficulty;
  final int rewardXP;
  final int targetValue;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.difficulty,
    required this.rewardXP,
    this.targetValue = 1,
  });
}

class AchievementCatalog {
  static const List<AchievementModel> allAchievements = [
    // 1. Dễ
    AchievementModel(
      id: 'first_win',
      title: 'Phát Cơ Đầu Tiên',
      description: 'Giành chiến thắng trận đấu bida đầu tiên của bạn.',
      icon: Icons.emoji_events,
      difficulty: AchievementDifficulty.easy,
      rewardXP: 60,
    ),
    AchievementModel(
      id: 'cue_enthusiast',
      title: 'Tín Đồ Bida',
      description: 'Sở hữu ít nhất 2 cây gậy cơ trong Cửa Hàng.',
      icon: Icons.sports_baseball,
      difficulty: AchievementDifficulty.easy,
      rewardXP: 60,
      targetValue: 2,
    ),
    AchievementModel(
      id: 'spin_trick',
      title: 'Biến Hóa Điểm Chạm',
      description: 'Tùy chỉnh kỹ thuật Áp-phê (Cu-lê hoặc Trô bóng) trong trận đấu.',
      icon: Icons.rotate_right,
      difficulty: AchievementDifficulty.easy,
      rewardXP: 60,
    ),

    // 2. Trung bình
    AchievementModel(
      id: 'combo_hunter',
      title: 'Thợ Săn Combo',
      description: 'Thực hiện chuỗi ăn Combo từ 2 bi cùng nhóm trở lên trong 1 cơ.',
      icon: Icons.flash_on,
      difficulty: AchievementDifficulty.medium,
      rewardXP: 150,
    ),
    AchievementModel(
      id: 'daily_puzzle_clear',
      title: 'Bậc Thầy Giải Thế',
      description: 'Hoàn thành thử thách Thế Bi Hàng Ngày (Daily Trickshot).',
      icon: Icons.event_available,
      difficulty: AchievementDifficulty.medium,
      rewardXP: 150,
    ),
    AchievementModel(
      id: 'win_streak_3',
      title: 'Tam Liên Thắng',
      description: 'Giành tổng cộng từ 3 trận thắng trở lên.',
      icon: Icons.military_tech,
      difficulty: AchievementDifficulty.medium,
      rewardXP: 150,
      targetValue: 3,
    ),

    // 3. Khó
    AchievementModel(
      id: 'cue_collector',
      title: 'Nhà Sưu Tập Cơ Thủ',
      description: 'Mở khóa và sở hữu từ 4 cây gậy cơ trở lên trong bộ sưu tập.',
      icon: Icons.shopping_bag,
      difficulty: AchievementDifficulty.hard,
      rewardXP: 350,
      targetValue: 4,
    ),
    AchievementModel(
      id: 'rich_player',
      title: 'Đại Gia Phố Bida',
      description: 'Tích lũy tài sản đạt từ 25.000 Vàng trở lên.',
      icon: Icons.monetization_on,
      difficulty: AchievementDifficulty.hard,
      rewardXP: 350,
      targetValue: 25000,
    ),
    AchievementModel(
      id: 'multiplayer_veteran',
      title: 'Sát Thủ Đối Kháng',
      description: 'Chiến thắng trận đấu mạng nhiều người chơi (Local/Online).',
      icon: Icons.wifi_tethering,
      difficulty: AchievementDifficulty.hard,
      rewardXP: 350,
    ),

    // 4. Siêu khó
    AchievementModel(
      id: 'bot_campaign_clear',
      title: 'Khuất Phục Cao Thủ Bot',
      description: 'Vượt qua trọn vẹn 7 Ải Thử Thách Bot Campaign.',
      icon: Icons.smart_toy,
      difficulty: AchievementDifficulty.expert,
      rewardXP: 700,
      targetValue: 7,
    ),
    AchievementModel(
      id: 'cue_level_max',
      title: 'Tuyệt Đỉnh Thần Binh',
      description: 'Nâng cấp bất kỳ cây gậy cơ nào đạt cấp độ tối đa (Level 10).',
      icon: Icons.upgrade,
      difficulty: AchievementDifficulty.expert,
      rewardXP: 700,
    ),
    AchievementModel(
      id: 'reach_level_10',
      title: 'Cơ Thủ Kỳ Cựu',
      description: 'Nâng cấp trình độ nhân vật đạt từ Cấp 10 (Lv.10) trở lên.',
      icon: Icons.stars,
      difficulty: AchievementDifficulty.expert,
      rewardXP: 700,
      targetValue: 10,
    ),

    // 5. Huyền thoại
    AchievementModel(
      id: 'tournament_champion_legend',
      title: 'Vua Giải Đấu 6 Brackets',
      description: 'Vượt qua toàn bộ 6 vòng đấu Brackets khốc liệt và nâng cao cúp Vô Địch!',
      icon: Icons.workspace_premium,
      difficulty: AchievementDifficulty.legendary,
      rewardXP: 1800,
    ),
    AchievementModel(
      id: 'billiard_god',
      title: 'Huyền Thoại Bida Toàn Năng',
      description: 'Sở hữu trên 100.000 Vàng và đạt 50 trận thắng vẻ vang.',
      icon: Icons.auto_awesome,
      difficulty: AchievementDifficulty.legendary,
      rewardXP: 1800,
      targetValue: 50,
    ),
  ];

  static AchievementModel? getById(String id) {
    try {
      return allAchievements.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
