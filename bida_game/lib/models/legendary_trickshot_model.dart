import 'dart:ui';

class TrickshotBallConfig {
  final int ballNumber;
  final double normX; // 0.0 - 1.0 theo chiều dài bàn
  final double normY; // 0.0 - 1.0 theo chiều rộng bàn
  final bool isObstacle; // Bi chướng ngại vật cản đường (không được ăn vào lỗ)
  final bool isTarget; // Bi mục tiêu chính phải ăn vào lỗ

  const TrickshotBallConfig({
    required this.ballNumber,
    required this.normX,
    required this.normY,
    this.isObstacle = false,
    this.isTarget = false,
  });
}

class LegendaryTrickshotModel {
  final String id;
  final String title;
  final String masterName;
  final String masterNickname;
  final String yearAndTournament;
  final int difficultyStars; // 1 - 5 sao
  final String description;
  final String techniqueHint;
  final int rewardCoins;
  final int rewardXP;
  final double cueBallNormX;
  final double cueBallNormY;
  final List<TrickshotBallConfig> balls;
  final int targetPocketIndex; // 0: TL, 1: TC, 2: TR, 3: BL, 4: BC, 5: BR (-1 nếu cho phép bất kỳ lỗ nào)
  final int targetBallNumber;
  final bool requireDrawShot; // Cần dùng kỹ thuật trô bóng (backspin)
  final bool requireFollowShot; // Cần dùng kỹ thuật cu-lê (topspin)
  final double suggestedAimAngle;
  final double suggestedPower;
  final Offset suggestedSpin;

  const LegendaryTrickshotModel({
    required this.id,
    required this.title,
    required this.masterName,
    required this.masterNickname,
    required this.yearAndTournament,
    required this.difficultyStars,
    required this.description,
    required this.techniqueHint,
    required this.rewardCoins,
    required this.rewardXP,
    required this.cueBallNormX,
    required this.cueBallNormY,
    required this.balls,
    required this.targetPocketIndex,
    required this.targetBallNumber,
    this.requireDrawShot = false,
    this.requireFollowShot = false,
    this.suggestedAimAngle = 0.0,
    this.suggestedPower = 0.65,
    this.suggestedSpin = Offset.zero,
  });

  String get playerName => masterName;
  String get techniqueNotes => techniqueHint;

  String get playerAvatar {
    if (masterName.contains('Efren')) return '🧙‍♂️';
    if (masterName.contains('Ronnie')) return '🚀';
    if (masterName.contains('Shane')) return '⚡';
    if (masterName.contains('Bustamante')) return '🛡️';
    if (masterName.contains('Hoàng')) return '⭐';
    if (masterName.contains('Florian')) return '🐍';
    if (masterName.contains('Earl')) return '👑';
    return '🦅';
  }
}

class LegendaryTrickshotCatalog {
  static const List<LegendaryTrickshotModel> trickshots = [
    // 1. CÚ DỘI BĂNG Z-BANK HUYỀN THOẠI - EFREN 'BATA' REYES
    LegendaryTrickshotModel(
      id: 'efren_z_bank',
      title: 'Cú Dội Băng Z-Bank Huyền Thoại',
      masterName: 'Efren "Bata" Reyes',
      masterNickname: 'Phù Thủy Bida (The Magician)',
      yearAndTournament: 'Chung kết Sands Regency Open 1995',
      difficultyStars: 4,
      description: 'Bi số 8 bị che khuất sau bi số 2 và 3. Cú đánh lịch sử của Efren Reyes đưa bi cái dội 2 băng hình chữ Z chạm chuẩn xác bi 8 vào lỗ góc đối diện!',
      techniqueHint: 'Chỉnh áp-phê nhẹ bên phải (dx ~ 0.35), lực vừa phải (~65%) để bi cái nảy 2 băng mượt mà góc Z vào bi 8.',
      rewardCoins: 5000,
      rewardXP: 600,
      cueBallNormX: 0.28,
      cueBallNormY: 0.72,
      targetPocketIndex: 0, // Top-Left Pocket
      targetBallNumber: 8,
      suggestedAimAngle: -0.65,
      suggestedPower: 0.65,
      suggestedSpin: Offset(0.35, 0.0),
      balls: [
        TrickshotBallConfig(ballNumber: 8, normX: 0.24, normY: 0.32, isTarget: true),
        TrickshotBallConfig(ballNumber: 2, normX: 0.32, normY: 0.48, isObstacle: true),
        TrickshotBallConfig(ballNumber: 3, normX: 0.36, normY: 0.54, isObstacle: true),
      ],
    ),

    // 2. SIÊU TRÔ KÉO LÙI XUYÊN BÀN - SHANE VAN BOENING
    LegendaryTrickshotModel(
      id: 'shane_super_draw',
      title: 'Siêu Trô Kéo Lùi Xuyên Bàn',
      masterName: 'Shane Van Boening',
      masterNickname: 'The South Dakota Kid',
      yearAndTournament: 'Vô Địch US Open 9-Ball',
      difficultyStars: 3,
      description: 'Cú trô bóng (Draw shot) uy lực giật lùi bi cái hơn 1.5m dọc bàn sau khi ăn bi số 1 vào lỗ giữa, giành thế điều bi hoàn hảo!',
      techniqueHint: 'Kéo điểm chạm cơ xuống đáy bi cái (dy = 0.85 - 1.0) và kéo lực cơ trên 80% để bi giật ngược ngoạn mục sau va chạm.',
      rewardCoins: 4000,
      rewardXP: 450,
      cueBallNormX: 0.45,
      cueBallNormY: 0.50,
      targetPocketIndex: 1, // Top-Center Pocket
      targetBallNumber: 1,
      requireDrawShot: true,
      suggestedAimAngle: -1.5708, // Hướng thẳng lên bi 1
      suggestedPower: 0.85,
      suggestedSpin: Offset(0.0, 0.90),
      balls: [
        TrickshotBallConfig(ballNumber: 1, normX: 0.45, normY: 0.24, isTarget: true),
        TrickshotBallConfig(ballNumber: 8, normX: 0.82, normY: 0.76),
      ],
    ),

    // 3. CU-LÊ CONG 2 BĂNG VƯỢT CHƯỚNG NGẠI - RONNIE O'SULLIVAN
    LegendaryTrickshotModel(
      id: 'ronnie_max_follow',
      title: 'Cu-Lê Đẩy Xoáy 2 Băng Tuyệt Đỉnh',
      masterName: 'Ronnie O\'Sullivan',
      masterNickname: 'The Rocket',
      yearAndTournament: 'World Snooker Championship',
      difficultyStars: 4,
      description: 'Kỹ thuật Cu-lê (Topspin follow-through) đỉnh cao đưa bi số 4 vào lỗ góc, bi cái men theo đà xoáy lướt 2 băng mở toang góc ăn bi tiếp theo!',
      techniqueHint: 'Đẩy điểm chạm cơ lên đỉnh cao nhất của bi cái (dy = -0.90) kèm lực mạnh (~78%) để bi cái phóng vụt lên sau khi bi 4 chạm lỗ.',
      rewardCoins: 6500,
      rewardXP: 750,
      cueBallNormX: 0.36,
      cueBallNormY: 0.65,
      targetPocketIndex: 2, // Top-Right Pocket
      targetBallNumber: 4,
      requireFollowShot: true,
      suggestedAimAngle: -0.75,
      suggestedPower: 0.78,
      suggestedSpin: Offset(0.0, -0.85),
      balls: [
        TrickshotBallConfig(ballNumber: 4, normX: 0.68, normY: 0.35, isTarget: true),
        TrickshotBallConfig(ballNumber: 6, normX: 0.45, normY: 0.42, isObstacle: true),
        TrickshotBallConfig(ballNumber: 8, normX: 0.22, normY: 0.28),
      ],
    ),

    // 4. ÁP-PHÊ BẺ BĂNG LỖ TÍT HIỂM HÓC - FRANCISCO BUSTAMANTE
    LegendaryTrickshotModel(
      id: 'bustamante_reverse_kick',
      title: 'Áp-Phê Ngược Bẻ Băng Lỗ Tít',
      masterName: 'Francisco Bustamante',
      masterNickname: 'Django (Cơ Thủ Thép)',
      yearAndTournament: 'World Pool Masters',
      difficultyStars: 4,
      description: 'Bi cái sát mép băng dọc, sử dụng áp-phê ngược (Reverse English) dội băng gắt đưa bi số 5 chui tọt vào lỗ tít đối diện!',
      techniqueHint: 'Dùng áp-phê trái (dx = -0.55), lực 70% để bi cái nảy băng ép góc vào bi 5 chuẩn xác.',
      rewardCoins: 7500,
      rewardXP: 850,
      cueBallNormX: 0.18,
      cueBallNormY: 0.82,
      targetPocketIndex: 5, // Bottom-Right Pocket
      targetBallNumber: 5,
      suggestedAimAngle: 0.42,
      suggestedPower: 0.72,
      suggestedSpin: Offset(-0.60, 0.0),
      balls: [
        TrickshotBallConfig(ballNumber: 5, normX: 0.84, normY: 0.82, isTarget: true),
        TrickshotBallConfig(ballNumber: 7, normX: 0.50, normY: 0.82, isObstacle: true),
      ],
    ),

    // 5. ĐƯỜNG CƠ KẾT LIỄU VƯƠN TẦM THẾ GIỚI - DƯƠNG QUỐC HOÀNG (HOÀNG SAO)
    LegendaryTrickshotModel(
      id: 'hoang_sao_clutch',
      title: 'Đường Cơ Kết Liễu Vươn Tầm Thế Giới',
      masterName: 'Dương Quốc Hoàng',
      masterNickname: 'Hoàng Sao (Vietnam Pride)',
      yearAndTournament: 'Tứ kết World 9-Ball Championship 2023',
      difficultyStars: 5,
      description: 'Thế bi cân não giúp cơ thủ Việt Nam làm nức lòng người hâm mộ thế giới: Cú cắt bi số 8 góc siêu mỏng và hãm bi cái an toàn tuyệt đối!',
      techniqueHint: 'Ngắm tiếp tuyến mép bi 8 cực mỏng, dùng trô nhẹ (dy ~ 0.4) và lực vừa (~50%) để bi 8 rơi lỗ góc dưới.',
      rewardCoins: 10000,
      rewardXP: 1200,
      cueBallNormX: 0.38,
      cueBallNormY: 0.42,
      targetPocketIndex: 3, // Bottom-Left Pocket
      targetBallNumber: 8,
      suggestedAimAngle: 2.12,
      suggestedPower: 0.52,
      suggestedSpin: Offset(0.0, 0.45),
      balls: [
        TrickshotBallConfig(ballNumber: 8, normX: 0.16, normY: 0.78, isTarget: true),
        TrickshotBallConfig(ballNumber: 9, normX: 0.28, normY: 0.62, isObstacle: true),
      ],
    ),

    // 6. MASSÉ BẺ CONG QUANH BI CHƯỚNG NGẠI - FLORIAN "VENOM" KOHLER
    LegendaryTrickshotModel(
      id: 'venom_masse_curve',
      title: 'Massé Bẻ Cong Quanh Bi Cản',
      masterName: 'Florian "Venom" Kohler',
      masterNickname: 'Vua Trickshot Thế Giới (Venom Trickshots)',
      yearAndTournament: 'Kỷ Lục Guinness Trickshot',
      difficultyStars: 5,
      description: 'Cú đánh đường cong ma thuật: 2 bi cản đứng chắn trước mặt, bi cái uốn lượn hình cánh cung vòng qua chướng ngại vật ăn bi số 8!',
      techniqueHint: 'Chỉnh áp-phê lệch phải cực đại (dx = 0.85, dy = 0.55) kết hợp trô và lực mạnh để tạo quỹ đạo cong ngoạn mục.',
      rewardCoins: 12000,
      rewardXP: 1500,
      cueBallNormX: 0.32,
      cueBallNormY: 0.50,
      targetPocketIndex: 0, // Top-Left Pocket
      targetBallNumber: 8,
      suggestedAimAngle: 2.70,
      suggestedPower: 0.85,
      suggestedSpin: Offset(0.85, 0.55),
      balls: [
        TrickshotBallConfig(ballNumber: 8, normX: 0.14, normY: 0.22, isTarget: true),
        TrickshotBallConfig(ballNumber: 10, normX: 0.22, normY: 0.36, isObstacle: true),
        TrickshotBallConfig(ballNumber: 11, normX: 0.26, normY: 0.42, isObstacle: true),
      ],
    ),

    // 7. COMBO XUYÊN KHE CỬA LỖ THẦN KỲ - EARL STRICKLAND
    LegendaryTrickshotModel(
      id: 'earl_combo_jump',
      title: 'Combo Xuyên Khe Cửa Lỗ Thần Kỳ',
      masterName: 'Earl Strickland',
      masterNickname: 'The Pearl (Huyền Thoại 9 Lần Vô Địch)',
      yearAndTournament: 'World Pool Championship',
      difficultyStars: 3,
      description: 'Hai bi đối thủ kẹp chẹt ngay miệng lỗ góc. Cú dội má bi cái tinh tế kích hoạt bi mục tiêu số 3 luồn qua khe hẹp chui thẳng vào lỗ!',
      techniqueHint: 'Ngắm chuẩn vào tâm điểm tiếp xúc giữa bi cái và bi 3, căn lực 55% không dùng xoáy để bi đi thẳng vào khe hẹp.',
      rewardCoins: 4500,
      rewardXP: 500,
      cueBallNormX: 0.52,
      cueBallNormY: 0.68,
      targetPocketIndex: 3, // Bottom-Left Pocket
      targetBallNumber: 3,
      suggestedAimAngle: 2.68,
      suggestedPower: 0.55,
      suggestedSpin: Offset.zero,
      balls: [
        TrickshotBallConfig(ballNumber: 3, normX: 0.24, normY: 0.82, isTarget: true),
        TrickshotBallConfig(ballNumber: 13, normX: 0.12, normY: 0.80, isObstacle: true),
        TrickshotBallConfig(ballNumber: 14, normX: 0.18, normY: 0.88, isObstacle: true),
      ],
    ),

    // 8. CÚ DỌN BÀN CẤP TỐC ĐỈNH CAO - JAYSON SHAW
    LegendaryTrickshotModel(
      id: 'shaw_speed_clear',
      title: 'Cú Dọn Bàn Cấp Tốc Đỉnh Cao',
      masterName: 'Jayson Shaw',
      masterNickname: 'Eagle Eye (Mắt Đại Bàng)',
      yearAndTournament: 'Mosconi Cup MVP Challenge',
      difficultyStars: 4,
      description: 'Thế bi mở hoàn hảo nhưng đòi hỏi tốc độ ra ngọn dứt khoát: Đưa bi số 8 vào lỗ giữa và trô bi cái giữ lại nguyên vị trí giữa bàn!',
      techniqueHint: 'Trô nhẹ (dy = 0.55), lực 60%, ngắm thẳng vào miệng lỗ giữa bên dưới.',
      rewardCoins: 6000,
      rewardXP: 700,
      cueBallNormX: 0.50,
      cueBallNormY: 0.32,
      targetPocketIndex: 4, // Bottom-Center Pocket
      targetBallNumber: 8,
      requireDrawShot: true,
      suggestedAimAngle: 1.5708, // Hướng thẳng xuống
      suggestedPower: 0.62,
      suggestedSpin: Offset(0.0, 0.60),
      balls: [
        TrickshotBallConfig(ballNumber: 8, normX: 0.50, normY: 0.70, isTarget: true),
      ],
    ),
  ];

  static LegendaryTrickshotModel getById(String id) {
    return trickshots.firstWhere(
      (s) => s.id == id,
      orElse: () => trickshots.first,
    );
  }
}
