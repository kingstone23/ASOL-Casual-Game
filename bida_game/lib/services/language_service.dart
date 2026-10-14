import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 5 ngôn ngữ hỗ trợ: Việt, Anh, Trung, Nhật, Hàn
enum AppLanguage {
  vi('vi', 'Tiếng Việt', 'Vietnamese', '🇻🇳'),
  en('en', 'English', 'English', '🇬🇧'),
  zh('zh', '中文', 'Chinese', '🇨🇳'),
  ja('ja', '日本語', 'Japanese', '🇯🇵'),
  ko('ko', '한국어', 'Korean', '🇰🇷');

  final String code;
  final String nativeName;
  final String englishName;
  final String flag;

  const AppLanguage(this.code, this.nativeName, this.englishName, this.flag);

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.vi,
    );
  }
}

/// Dịch vụ quản lý ngôn ngữ và bản địa hóa đa ngôn ngữ toàn game
class LanguageService extends ChangeNotifier {
  static final LanguageService instance = LanguageService._();
  LanguageService._();

  static const String _prefKey = 'app_selected_language';
  AppLanguage _currentLanguage = AppLanguage.vi;

  AppLanguage get currentLanguage => _currentLanguage;
  String get currentCode => _currentLanguage.code;

  /// Khởi tạo và nạp ngôn ngữ đã lưu từ SharedPreferences
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefKey);
      if (savedCode != null) {
        _currentLanguage = AppLanguage.fromCode(savedCode);
      }
    } catch (e) {
      debugPrint('LanguageService init error: $e');
    }
  }

  /// Thay đổi ngôn ngữ và lưu vĩnh viễn
  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;
    _currentLanguage = language;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, language.code);
    } catch (e) {
      debugPrint('LanguageService save error: $e');
    }
  }

  /// Lấy bản dịch theo key
  String t(String key) {
    final langMap = _translations[key];
    if (langMap == null) return key;
    return langMap[_currentLanguage.code] ?? langMap['en'] ?? langMap['vi'] ?? key;
  }

  static final Map<String, Map<String, String>> _translations = {
    // Menu & Chế độ chơi
    'app_title': {
      'vi': '8 POOL BILLIARDS',
      'en': '8 POOL BILLIARDS',
      'zh': '8球台球大师',
      'ja': '8ボール ビリヤード',
      'ko': '8볼 당구 마스터',
    },
    'choose_match': {
      'vi': 'CHỌN CHẾ ĐỘ ĐẤU',
      'en': 'CHOOSE YOUR MATCH',
      'zh': '选择对决模式',
      'ja': '試合モードを選択',
      'ko': '경기 모드 선택',
    },
    'p1_vs_p2': {
      'vi': 'P1 vs P2 (CÙNG MÁY)',
      'en': 'P1 vs P2 (LOCAL 2P)',
      'zh': '双人对决 (同机)',
      'ja': 'P1 vs P2 (ローカル対戦)',
      'ko': 'P1 vs P2 (로컬 2인)',
    },
    'p1_vs_p2_desc': {
      'vi': '2 người chơi trên 1 thiết bị',
      'en': '2 players on 1 device',
      'zh': '一台手机双人对战',
      'ja': '1台の端末で2人対戦',
      'ko': '한 기기에서 2인 대전',
    },
    'legendary_trickshot': {
      'vi': 'THẾ ĐÁNH HUYỀN THOẠI',
      'en': 'LEGENDARY TRICKSHOTS',
      'zh': '传奇花式杆法',
      'ja': '伝説のトリックショット',
      'ko': '전설의 트릭샷',
    },
    'legendary_trickshot_desc': {
      'vi': '8 thế đánh của cơ thủ thế giới',
      'en': '8 world pro trickshots',
      'zh': '世界大师8大经典名局',
      'ja': '世界プロ8大名ショット',
      'ko': '세계 프로 8대 명샷',
    },
    'tournament': {
      'vi': 'TOURNAMENT 6 BRACKETS',
      'en': 'TOURNAMENT 6 BRACKETS',
      'zh': '6轮巡回锦标赛',
      'ja': '6段階トーナメント',
      'ko': '6강 토너먼트 대회',
    },
    'tournament_desc': {
      'vi': 'Tranh cúp Quán Quân • Siêu quà',
      'en': 'Win Champion Cup • Mega Rewards',
      'zh': '角逐冠军奖杯 • 豪华大奖',
      'ja': '優勝カップ争奪 • 超豪華報酬',
      'ko': '챔피언 컵 쟁탈 • 대박 보상',
    },
    'local_wifi': {
      'vi': 'ĐẤU MẠNG LOCAL',
      'en': 'LOCAL NETWORK MATCH',
      'zh': '局域网联机对战',
      'ja': 'ローカル通信対戦',
      'ko': '로컬 네트워크 대전',
    },
    'local_wifi_desc': {
      'vi': 'Chung mạng WiFi / Hotspot',
      'en': 'Same WiFi / Hotspot network',
      'zh': '同一WiFi或手机热点',
      'ja': '同一WiFi / テザリング',
      'ko': '동일 WiFi / 핫스팟',
    },
    'bot_stages': {
      'vi': '10 ẢI THỬ THÁCH BOT',
      'en': '10 BOT CHALLENGES',
      'zh': '人机10重试炼',
      'ja': '10段階BOTチャレンジ',
      'ko': '10단계 봇 챌린지',
    },
    'bot_stages_desc': {
      'vi': '4 Hạng: Đồng, Bạc, Vàng, Kim Cương',
      'en': '4 Tiers: Bronze, Silver, Gold, Diamond',
      'zh': '4大段位: 青铜、白银、黄金、钻石',
      'ja': '4階級: ブロンズ、シルバー、ゴールド、ダイヤ',
      'ko': '4등급: 브론즈, 실버, 골드, 다이아몬드',
    },
    'daily_puzzle': {
      'vi': 'THẾ BI HÀNG NGÀY',
      'en': 'DAILY PUZZLE',
      'zh': '每日残局挑战',
      'ja': 'デイリーパズル',
      'ko': '일일 퍼즐 미션',
    },
    'daily_puzzle_desc': {
      'vi': '1 thế bi / ngày • Quà lớn',
      'en': '1 puzzle / day • Big rewards',
      'zh': '每日1局 • 丰厚奖赏',
      'ja': '1日1問 • 豪華プレゼント',
      'ko': '매일 1문제 • 특별 보상',
    },

    // Cài đặt & Ngôn ngữ
    'settings_title': {
      'vi': 'Cài đặt & Âm thanh',
      'en': 'Settings & Audio',
      'zh': '设置与音频',
      'ja': '設定とオーディオ',
      'ko': '설정 및 오디오',
    },
    'language': {
      'vi': 'Ngôn ngữ',
      'en': 'Language',
      'zh': '语言',
      'ja': '言語',
      'ko': '언어',
    },
    'select_language': {
      'vi': 'Chọn ngôn ngữ',
      'en': 'Select Language',
      'zh': '选择语言',
      'ja': '言語を選択',
      'ko': '언어 선택',
    },
    'bgm_title': {
      'vi': 'Nhạc nền Bida (BGM)',
      'en': 'Billiards BGM',
      'zh': '台球背景音乐 (BGM)',
      'ja': 'ビリヤードBGM',
      'ko': '당구 배경음악 (BGM)',
    },
    'sfx_title': {
      'vi': 'Hiệu ứng âm thanh (SFX)',
      'en': 'Sound Effects (SFX)',
      'zh': '打击音效 (SFX)',
      'ja': '効果音 (SFX)',
      'ko': '타격 효과음 (SFX)',
    },
    'match_actions': {
      'vi': 'Thao tác trận đấu:',
      'en': 'Match Actions:',
      'zh': '对局操作:',
      'ja': '試合操作:',
      'ko': '경기 메뉴:',
    },
    'surrender_lan': {
      'vi': 'Xử thua (LAN)',
      'en': 'Declare Loss (LAN)',
      'zh': '认输 (LAN)',
      'ja': '降参 (LAN)',
      'ko': '항복 (LAN)',
    },
    'main_menu': {
      'vi': 'Menu chính',
      'en': 'Main Menu',
      'zh': '主菜单',
      'ja': 'メインメニュー',
      'ko': '메인 메뉴',
    },
    'restart': {
      'vi': 'Bắt đầu lại',
      'en': 'Restart',
      'zh': '重新开局',
      'ja': '最初から',
      'ko': '다시 시작',
    },
    'close': {
      'vi': 'Đóng',
      'en': 'Close',
      'zh': '关闭',
      'ja': '閉じる',
      'ko': '닫기',
    },

    // Bàn đấu & Trạng thái HUD
    'turn': {
      'vi': 'LƯỢT',
      'en': 'TURN',
      'zh': '回合',
      'ja': 'ターン',
      'ko': '턴',
    },
    'turn_p1': {
      'vi': 'Lượt P1',
      'en': 'Player 1 Turn',
      'zh': '玩家1 回合',
      'ja': 'P1のターン',
      'ko': 'P1 턴',
    },
    'turn_p2': {
      'vi': 'Lượt P2',
      'en': 'Player 2 Turn',
      'zh': '玩家2 回合',
      'ja': 'P2のターン',
      'ko': 'P2 턴',
    },
    'turn_you': {
      'vi': 'Lượt của bạn',
      'en': 'Your Turn',
      'zh': '您的回合',
      'ja': 'あなたのターン',
      'ko': '당신의 턴',
    },
    'turn_bot': {
      'vi': 'Lượt của Bot',
      'en': 'Bot Turn',
      'zh': '电脑回合',
      'ja': 'BOTのターン',
      'ko': '봇의 턴',
    },
    'bot_hard': {
      'vi': 'MÁY (KHÓ)',
      'en': 'BOT (HARD)',
      'zh': '电脑 (困难)',
      'ja': 'BOT (上級)',
      'ko': '봇 (어려움)',
    },
    'bot_easy': {
      'vi': 'MÁY (DỄ)',
      'en': 'BOT (EASY)',
      'zh': '电脑 (简单)',
      'ja': 'BOT (初級)',
      'ko': '봇 (쉬움)',
    },
    'you': {
      'vi': 'Bạn',
      'en': 'You',
      'zh': '你',
      'ja': 'あなた',
      'ko': '당신',
    },
    'player_1': {
      'vi': 'Cơ thủ 1',
      'en': 'Player 1',
      'zh': '玩家 1',
      'ja': 'プレイヤー 1',
      'ko': '플레이어 1',
    },
    'player_2': {
      'vi': 'Cơ thủ 2',
      'en': 'Player 2',
      'zh': '玩家 2',
      'ja': 'プレイヤー 2',
      'ko': '플레이어 2',
    },
    'target_balls': {
      'vi': 'Bi mục tiêu',
      'en': 'Target Balls',
      'zh': '目标球',
      'ja': 'ターゲットボール',
      'ko': '목표구',
    },
    'solids': {
      'vi': 'Bi Trơn (1-7)',
      'en': 'Solids (1-7)',
      'zh': '全色球 (1-7)',
      'ja': 'ソリッド (1-7)',
      'ko': '솔리드 (1-7)',
    },
    'stripes': {
      'vi': 'Bi Sọc (9-15)',
      'en': 'Stripes (9-15)',
      'zh': '花色球 (9-15)',
      'ja': 'ストライプ (9-15)',
      'ko': '스트라이프 (9-15)',
    },
    'open_table': {
      'vi': 'Bàn tự do',
      'en': 'Open Table',
      'zh': '开放球局',
      'ja': 'オープン',
      'ko': '오픈 테이블',
    },
    'eight_ball_target': {
      'vi': 'Bi 8 Đen (Ăn để thắng)',
      'en': '8-Ball (Pocket to Win)',
      'zh': '8号黑球 (打进获胜)',
      'ja': '8番ボール (沈めて勝利)',
      'ko': '8번 볼 (넣으면 승리)',
    },
    'cue_stick': {
      'vi': 'Gậy cơ',
      'en': 'Cue Stick',
      'zh': '球杆',
      'ja': 'キュー',
      'ko': '큐',
    },
    'change_cue': {
      'vi': 'Đổi gậy',
      'en': 'Change Cue',
      'zh': '更换球杆',
      'ja': 'キュー変更',
      'ko': '큐 변경',
    },
    'power': {
      'vi': 'LỰC',
      'en': 'POWER',
      'zh': '力度',
      'ja': 'パワー',
      'ko': '파워',
    },
    'victory': {
      'vi': 'CHIẾN THẮNG!',
      'en': 'VICTORY!',
      'zh': '比赛胜利!',
      'ja': '勝利!',
      'ko': '승리!',
    },
    'defeat': {
      'vi': 'THẤT BẠI',
      'en': 'DEFEAT',
      'zh': '对局惜败',
      'ja': '敗北',
      'ko': '패배',
    },
    'foul': {
      'vi': 'PHẠM LỖI!',
      'en': 'FOUL!',
      'zh': '犯规!',
      'ja': 'ファウル!',
      'ko': '파울!',
    },
    'ball_in_hand': {
      'vi': 'Bi trong tay: Đặt bi cái tự do',
      'en': 'Ball in hand: Place cue ball anywhere',
      'zh': '自由球: 可在桌面任意位置放置白球',
      'ja': 'フリーボール: 好きな位置に手球を配置',
      'ko': '프리볼: 원하는 위치에 수구를 배치',
    },
    'cue_ball_scratched': {
      'vi': 'Bi cái vào lỗ!',
      'en': 'Cue ball scratched!',
      'zh': '白球落袋犯规!',
      'ja': 'スクラッチ!',
      'ko': '수구 낙하 파울!',
    },

    // Profile & Shop & Cúp
    'shop': {
      'vi': 'CỬA HÀNG',
      'en': 'SHOP',
      'zh': '商城',
      'ja': 'ショップ',
      'ko': '상점',
    },
    'leaderboard': {
      'vi': 'BXH',
      'en': 'RANK',
      'zh': '排行榜',
      'ja': 'ランキング',
      'ko': '랭킹',
    },
    'medals': {
      'vi': 'HUY CHƯƠNG',
      'en': 'MEDALS',
      'zh': '勋章',
      'ja': 'メダル',
      'ko': '훈장',
    },
    'profile': {
      'vi': 'HỒ SƠ',
      'en': 'PROFILE',
      'zh': '档案',
      'ja': 'プロフィール',
      'ko': '프로필',
    },
    'coins': {
      'vi': 'Vàng',
      'en': 'Coins',
      'zh': '金币',
      'ja': 'コイン',
      'ko': '골드',
    },
    'diamonds': {
      'vi': 'Kim Cương',
      'en': 'Diamonds',
      'zh': '钻石',
      'ja': 'ダイヤ',
      'ko': '다이아',
    },
    'level': {
      'vi': 'Cấp',
      'en': 'Level',
      'zh': '等级',
      'ja': 'レベル',
      'ko': '레벨',
    },
    'guest': {
      'vi': 'Khách',
      'en': 'Guest',
      'zh': '游客',
      'ja': 'ゲスト',
      'ko': '게스트',
    },
    'equip': {
      'vi': 'Trang bị',
      'en': 'Equip',
      'zh': '装备',
      'ja': '装備',
      'ko': '장착',
    },
    'equipped': {
      'vi': 'Đang dùng',
      'en': 'Equipped',
      'zh': '使用中',
      'ja': '使用中',
      'ko': '사용 중',
    },
    'upgrade': {
      'vi': 'Nâng cấp',
      'en': 'Upgrade',
      'zh': '升级',
      'ja': '強化',
      'ko': '업그레이드',
    },
    'cue_selector_title': {
      'vi': 'Chọn Gậy Cơ Thi Đấu',
      'en': 'Select Cue Stick',
      'zh': '选择参赛球杆',
      'ja': '試合用キューを選択',
      'ko': '경기용 큐 선택',
    },
    'turn_banner_p1': {
      'vi': 'Lượt P1',
      'en': 'Turn: P1',
      'zh': '回合: 玩家1',
      'ja': 'ターン: P1',
      'ko': '턴: P1',
    },
    'turn_banner_p2': {
      'vi': 'Lượt P2',
      'en': 'Turn: P2',
      'zh': '回合: 玩家2',
      'ja': 'ターン: P2',
      'ko': '턴: P2',
    },
    'score': {
      'vi': 'Tỷ số',
      'en': 'Score',
      'zh': '比分',
      'ja': 'スコア',
      'ko': '스코어',
    },
    'select_cue_p1': {
      'vi': 'CHỌN GẬY CƠ • PLAYER 1',
      'en': 'SELECT CUE • PLAYER 1',
      'zh': '选择球杆 • 玩家1',
      'ja': 'キュー選択 • P1',
      'ko': '큐 선택 • P1',
    },
    'select_cue_p2': {
      'vi': 'CHỌN GẬY CƠ • PLAYER 2',
      'en': 'SELECT CUE • PLAYER 2',
      'zh': '选择球杆 • 玩家2',
      'ja': 'キュー選択 • P2',
      'ko': '큐 선택 • P2',
    },
    'force': {
      'vi': 'Lực',
      'en': 'Force',
      'zh': '力量',
      'ja': 'パワー',
      'ko': '파워',
    },
    'aim': {
      'vi': 'Ngắm',
      'en': 'Aim',
      'zh': '瞄准',
      'ja': '照準',
      'ko': '조준',
    },
    'spin': {
      'vi': 'Xoáy',
      'en': 'Spin',
      'zh': '加塞',
      'ja': 'スピン',
      'ko': '스핀',
    },
    'select': {
      'vi': 'Chọn',
      'en': 'Select',
      'zh': '选择',
      'ja': '選択',
      'ko': '선택',
    },
    'hint': {
      'vi': 'Gợi ý',
      'en': 'Hint',
      'zh': '提示',
      'ja': 'ヒント',
      'ko': '힌트',
    },
    'reset_shot': {
      'vi': 'ĐẶT LẠI',
      'en': 'RESET',
      'zh': '重置',
      'ja': 'リセット',
      'ko': '재설정',
    },
    'play_again': {
      'vi': 'Chơi lại',
      'en': 'Play Again',
      'zh': '再来一局',
      'ja': 'もう一度',
      'ko': '다시 하기',
    },
  };
}

/// Extension tiện lợi cho String để dịch nhanh: 'key'.tr
extension StringTranslationExtension on String {
  String get tr => LanguageService.instance.t(this);
}
