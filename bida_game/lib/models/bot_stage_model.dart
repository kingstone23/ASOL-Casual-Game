import 'cue_model.dart';

class BotStageModel {
  final int stageNumber;
  final String title;
  final String botName;
  final String cueId;
  final double aimErrorRad;      // Sai số góc ngắm ngẫu nhiên (radians)
  final double powerAccuracy;     // Độ chính xác khi căn lực (0.0 - 1.0)
  final bool useSpin;             // Có biết dùng áp-phê Cu-lê/Trô không
  final bool useScratchPrevention;// Có biết né bi cái rơi lỗ không
  final bool useSafetyShot;       // Có biết giấu bi cái khi không có thế ăn không
  final int firstClearCoins;
  final int firstClearXP;
  final int firstClearDiamonds;
  final String description;

  const BotStageModel({
    required this.stageNumber,
    required this.title,
    required this.botName,
    required this.cueId,
    required this.aimErrorRad,
    required this.powerAccuracy,
    required this.useSpin,
    required this.useScratchPrevention,
    required this.useSafetyShot,
    required this.firstClearCoins,
    required this.firstClearXP,
    required this.firstClearDiamonds,
    required this.description,
  });

  CueModel get cue => CueCatalog.getById(cueId);
}

class BotStageCatalog {
  static const List<BotStageModel> stages = [
    BotStageModel(
      stageNumber: 1,
      title: 'Ải 1: Tân Thủ Học Việc',
      botName: 'Tân Thủ Tom',
      cueId: 'standard_cue',
      aimErrorRad: 0.075, // ~4.3 độ
      powerAccuracy: 0.65,
      useSpin: false,
      useScratchPrevention: false,
      useSafetyShot: false,
      firstClearCoins: 1000,
      firstClearXP: 120,
      firstClearDiamonds: 0,
      description: 'Đối thủ mới vào nghề, thường ngắm lệch ở khoảng cách xa và chưa biết dùng xoáy áp-phê.',
    ),
    BotStageModel(
      stageNumber: 2,
      title: 'Ải 2: Đấu Sĩ Titan',
      botName: 'Titan Jack',
      cueId: 'titan_striker',
      aimErrorRad: 0.048, // ~2.7 độ
      powerAccuracy: 0.75,
      useSpin: false,
      useScratchPrevention: true,
      useSafetyShot: false,
      firstClearCoins: 3000,
      firstClearXP: 250,
      firstClearDiamonds: 0,
      description: 'Lực phá bi cực mạnh nhờ gậy Titan, biết tính toán sơ lược để tránh bi cái rơi lỗ.',
    ),
    BotStageModel(
      stageNumber: 3,
      title: 'Ải 3: Băng Phong Hiệp Sĩ',
      botName: 'Arthur Frost',
      cueId: 'frostbite',
      aimErrorRad: 0.025, // ~1.4 độ
      powerAccuracy: 0.85,
      useSpin: true,
      useScratchPrevention: true,
      useSafetyShot: false,
      firstClearCoins: 8000,
      firstClearXP: 500,
      firstClearDiamonds: 5,
      description: 'Đường cơ ổn định và chính xác cao, hiếm khi phạm lỗi cơ bản.',
    ),
    BotStageModel(
      stageNumber: 4,
      title: 'Ải 4: Kim Ngưu Trưởng Lão',
      botName: 'Đại sư Taurus',
      cueId: 'golden_bull',
      aimErrorRad: 0.014, // ~0.8 độ
      powerAccuracy: 0.90,
      useSpin: true,
      useScratchPrevention: true,
      useSafetyShot: true,
      firstClearCoins: 18000,
      firstClearXP: 800,
      firstClearDiamonds: 10,
      description: 'Bậc thầy chiến thuật, biết đánh thế phòng thủ (Safety Shot) giấu bi cái khi không có cơ hội ăn bi.',
    ),
    BotStageModel(
      stageNumber: 5,
      title: 'Ải 5: Chiến Binh Cyber Neo',
      botName: 'Cyborg 2077',
      cueId: 'cyber_neo',
      aimErrorRad: 0.007, // ~0.4 độ
      powerAccuracy: 0.94,
      useSpin: true,
      useScratchPrevention: true,
      useSafetyShot: true,
      firstClearCoins: 40000,
      firstClearXP: 1200,
      firstClearDiamonds: 25,
      description: 'Phân tích hình học vi mạch chuẩn xác, đánh được các góc cắt siêu hẹp và dội băng.',
    ),
    BotStageModel(
      stageNumber: 6,
      title: 'Ải 6: Phượng Hoàng Lửa',
      botName: 'Hỏa Nữ Phoenix',
      cueId: 'phoenix_flame',
      aimErrorRad: 0.0035, // ~0.2 độ
      powerAccuracy: 0.98,
      useSpin: true,
      useScratchPrevention: true,
      useSafetyShot: true,
      firstClearCoins: 80000,
      firstClearXP: 2000,
      firstClearDiamonds: 50,
      description: 'Lối đánh áp-phê trô giật ngược và cu-lê đẩy bóng đỉnh cao, dọn bàn trong tích tắc.',
    ),
    BotStageModel(
      stageNumber: 7,
      title: 'Ải 7: Thần Long Tối Thượng',
      botName: 'Long Đế Master',
      cueId: 'dragon_god',
      aimErrorRad: 0.0, // Hoàn hảo không lệch
      powerAccuracy: 1.0,
      useSpin: true,
      useScratchPrevention: true,
      useSafetyShot: true,
      firstClearCoins: 150000,
      firstClearXP: 5000,
      firstClearDiamonds: 100,
      description: 'Đẳng cấp Kiện Tướng Thế Giới: Đánh chuẩn tuyệt đối từng milimet, không phạm bất kỳ sai sót nào!',
    ),
  ];

  static BotStageModel getStage(int stageNumber) {
    return stages.firstWhere(
      (s) => s.stageNumber == stageNumber,
      orElse: () => stages.first,
    );
  }
}
