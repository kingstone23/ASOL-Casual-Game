import 'package:flutter/material.dart';
import '../services/language_service.dart';

enum MedalRarity {
  bronze,
  silver,
  gold,
  diamond,
  mythic,
}

extension MedalRarityExt on MedalRarity {
  String get label {
    return LanguageService.instance.localizeMedalRarity(name, switch (this) {
      MedalRarity.bronze => 'Đồng',
      MedalRarity.silver => 'Bạc',
      MedalRarity.gold => 'Vàng',
      MedalRarity.diamond => 'Kim Cương',
      MedalRarity.mythic => 'Thần Thoại',
    });
  }


  List<Color> get gradientColors {
    switch (this) {
      case MedalRarity.bronze:
        return const [Color(0xFFCD7F32), Color(0xFF8D5524)];
      case MedalRarity.silver:
        return const [Color(0xFFCFD8DC), Color(0xFF78909C)];
      case MedalRarity.gold:
        return const [Color(0xFFFFD54F), Color(0xFFFF8F00)];
      case MedalRarity.diamond:
        return const [Color(0xFF80DEEA), Color(0xFF00ACC1)];
      case MedalRarity.mythic:
        return const [Color(0xFFFF4081), Color(0xFF7C4DFF)];
    }
  }

  Color get glowColor {
    switch (this) {
      case MedalRarity.bronze:
        return const Color(0xFFCD7F32);
      case MedalRarity.silver:
        return const Color(0xFFB0BEC5);
      case MedalRarity.gold:
        return const Color(0xFFFFD54F);
      case MedalRarity.diamond:
        return const Color(0xFF00E5FF);
      case MedalRarity.mythic:
        return const Color(0xFFE040FB);
    }
  }
}

class MedalModel {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final MedalRarity rarity;
  final String unlockRequirement;

  const MedalModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.unlockRequirement,
  });

  String get localizedName => LanguageService.instance.localizeMedalName(id, name);
  String get localizedDescription => LanguageService.instance.localizeMedalDescription(id, description);
  String get localizedRequirement => LanguageService.instance.localizeMedalRequirement(id, unlockRequirement);
}


class MedalCatalog {
  static const List<MedalModel> allMedals = [
    // 1. Quán Quân Tournament
    MedalModel(
      id: 'tournament_champion',
      name: 'Cúp Quán Quân Tournament',
      description: 'Danh hiệu cao quý nhất dành cho cơ thủ thống trị cả 6 Brackets của giải đấu.',
      icon: Icons.emoji_events,
      rarity: MedalRarity.mythic,
      unlockRequirement: 'Vô địch chế độ Giải Đấu Tournament 6 Brackets',
    ),

    // 2. Á Quân Tournament
    MedalModel(
      id: 'tournament_runner_up',
      name: 'Huy Chương Á Quân',
      description: 'Khẳng định bản lĩnh kiên cường khi bước chân vào trận Đại Chung Kết Bracket 6.',
      icon: Icons.workspace_premium,
      rarity: MedalRarity.gold,
      unlockRequirement: 'Lọt vào trận Chung Kết Bracket 6 của Tournament',
    ),

    // 3. Tứ Cường Tournament
    MedalModel(
      id: 'tournament_semis',
      name: 'Huy Chương Tứ Cường',
      description: 'Vượt qua vòng Tứ Kết và ghi tên mình vào Bán Kết Bracket 4.',
      icon: Icons.military_tech,
      rarity: MedalRarity.silver,
      unlockRequirement: 'Vượt qua Bracket 3 để tiến vào Bán Kết Tournament',
    ),

    // 4. Thiện Xạ Combo
    MedalModel(
      id: 'sharpshooter',
      name: 'Huy Chương Thiện Xạ',
      description: 'Dành cho cơ thủ có nhãn quan siêu phàm, ghi combo ăn nhiều bi liên hoàn.',
      icon: Icons.gps_fixed,
      rarity: MedalRarity.gold,
      unlockRequirement: 'Thực hiện chuỗi ăn Combo bi trong trận đấu',
    ),

    // 5. Thần Cơ Diệu Toán
    MedalModel(
      id: 'trickshot_master',
      name: 'Thần Cơ Diệu Toán',
      description: 'Giải mã thành công thế bi hiểm hóc của nhiệm vụ Hàng Ngày.',
      icon: Icons.diamond,
      rarity: MedalRarity.diamond,
      unlockRequirement: 'Chiến thắng chế độ Thế Bi Hàng Ngày',
    ),

    // 6. Chinh Phục Ải Bot
    MedalModel(
      id: 'bot_slayer',
      name: 'Huy Hiệu Trùm Bot',
      description: 'Đánh bại Boss Bot cao nhất trong chuỗi 7 Ải Thử Thách Chiến Dịch.',
      icon: Icons.smart_toy,
      rarity: MedalRarity.diamond,
      unlockRequirement: 'Vượt qua ải 7 trong Chiến Dịch Bot',
    ),

    // 7. Bậc Thầy Gậy Cơ
    MedalModel(
      id: 'cue_master',
      name: 'Bậc Thầy Gậy Cơ',
      description: 'Sở hữu và rèn đúc gậy cơ đạt mốc nâng cấp Level 5 trở lên.',
      icon: Icons.hardware,
      rarity: MedalRarity.gold,
      unlockRequirement: 'Nâng cấp bất kỳ cây gậy nào lên cấp 5+',
    ),

    // 8. Đại Kiện Tướng
    MedalModel(
      id: 'grandmaster',
      name: 'Đại Kiện Tướng Bida',
      description: 'Minh chứng cho đẳng cấp cơ thủ kỳ cựu đạt Cấp độ 10+.',
      icon: Icons.stars,
      rarity: MedalRarity.gold,
      unlockRequirement: 'Đạt Cấp độ người chơi Lv.10 trở lên',
    ),

    // 9. Triệu Phú Kim Tiền
    MedalModel(
      id: 'wealthy_striker',
      name: 'Triệu Phú Phố Bida',
      description: 'Sở hữu khối tài sản từ 20.000 Vàng trong két sắt cá nhân.',
      icon: Icons.monetization_on,
      rarity: MedalRarity.silver,
      unlockRequirement: 'Tích lũy đạt trên 20.000 Vàng',
    ),

    // 10. Cơ Thủ Tinh Anh
    MedalModel(
      id: 'bronze_champion',
      name: 'Cơ Thủ Tinh Anh',
      description: 'Ghi dấu ấn những bước đầu tiên trên đấu trường bi-a chuyên nghiệp.',
      icon: Icons.verified,
      rarity: MedalRarity.bronze,
      unlockRequirement: 'Chiến thắng trận đấu đầu tiên',
    ),
  ];

  static MedalModel? getById(String id) {
    try {
      return allMedals.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
