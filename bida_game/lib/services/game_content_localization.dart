// BẢN ĐỊA HÓA TOÀN BỘ NỘI DUNG GẬY CƠ, THÀNH TỰU, HUY CHƯƠNG VÀ ĐIỀU KHIỂN BIDA
// Hỗ trợ 5 ngôn ngữ: Tiếng Việt (vi), English (en), 中文 (zh), 日本語 (ja), 한국어 (ko)

import 'dart:ui';

class GameContentLocalization {
  // =========================================================================
  // 1. TÊN GẬY CƠ (CUE NAMES)
  // =========================================================================
  static const Map<String, Map<String, String>> cueNames = {
    'standard_cue': {
      'vi': 'Gậy Gỗ Tân Thủ',
      'en': 'Standard Maple Cue',
      'zh': '新手枫木杆',
      'ja': '初心者メープルキュー',
      'ko': '초보자 메이플 큐',
    },
    'titan_striker': {
      'vi': 'Cơ Titan Thép',
      'en': 'Titan Steel Striker',
      'zh': '泰坦钢铁杆',
      'ja': 'タイタンストライカー',
      'ko': '타이탄 스틸 스트라이커',
    },
    'frostbite': {
      'vi': 'Cơ Băng Phong',
      'en': 'Frostbite Glacier',
      'zh': '寒冰霜冻杆',
      'ja': 'フロストバイト',
      'ko': '프로스트바이트 큐',
    },
    'golden_bull': {
      'vi': 'Cơ Kim Ngưu',
      'en': 'Golden Bull 24K',
      'zh': '金牛神殿杆',
      'ja': 'ゴールデンブル',
      'ko': '황금 황소자리 큐',
    },
    'cyber_neo': {
      'vi': 'Cơ Cyberpunk Neo',
      'en': 'Cyberpunk Neo 2077',
      'zh': '赛博新纪元 2077',
      'ja': 'サイバーネオ 2077',
      'ko': '사이버 네오 2077',
    },
    'phoenix_flame': {
      'vi': 'Cơ Hỏa Phụng',
      'en': 'Phoenix Flame Cue',
      'zh': '烈焰凤凰杆',
      'ja': '不死鳥の焔',
      'ko': '피닉스 플레임',
    },
    'dragon_god': {
      'vi': 'Cơ Đế Vương Rồng Vàng',
      'en': 'Imperial Golden Dragon',
      'zh': '至尊黄金神龙',
      'ja': '帝王金龍キュー',
      'ko': '황금 용 황제 큐',
    },
  };

  // =========================================================================
  // 2. MÔ TẢ GẬY CƠ (CUE DESCRIPTIONS)
  // =========================================================================
  static const Map<String, Map<String, String>> cueDescriptions = {
    'standard_cue': {
      'vi': 'Cây gậy khởi đầu bằng gỗ phong tự nhiên, đầm tay và dễ làm quen.',
      'en': 'Natural maple starter cue, solid grip and beginner-friendly.',
      'zh': '天然枫木新手入门球杆，手感扎实且容易上手。',
      'ja': '初心者向けの天然メープル製キュー。安定感があり扱いやすい。',
      'ko': '초보자용 천연 메이플 큐. 그립감이 안정적이며 다루기 쉽습니다.',
    },
    'titan_striker': {
      'vi': 'Lõi kim loại đúc nguyên khối chịu lực cao, gia cố đầu ngọn siêu cứng.',
      'en': 'Solid cast metal core with hardened tip for powerful strikes.',
      'zh': '高强度铸造一体金属核心，超硬杆头加固。',
      'ja': '高耐久の一体成型金属コアと超硬チップ。',
      'ko': '강력한 타구를 위한 견고한 일체형 금속 코어와 강화 팁.',
    },
    'frostbite': {
      'vi': 'Chế tác từ tinh thể băng vĩnh cửu Bắc Cực, tỏa ra hàn khí xanh lạnh ngắt.',
      'en': 'Crafted from Arctic permafrost crystals with chilled cyan aura.',
      'zh': '采用北极永冻冰晶打造，散发冰蓝冷冽寒芒。',
      'ja': '北極の永久凍土の氷晶から作られた冷気のキュー。',
      'ko': '북극의 영구 동토 결정으로 제작된 냉기 어린 큐.',
    },
    'golden_bull': {
      'vi': 'Dát vàng 24K nguyên chất chạm khắc biểu tượng cung hoàng đạo Kim Ngưu.',
      'en': '24K gold plated engraved with the celestial Taurus zodiac emblem.',
      'zh': '纯正24K镀金雕刻金牛座黄道星象图腾。',
      'ja': '純金24Kメッキと牡牛座の紋章が刻まれたキュー。',
      'ko': '순금 24K 도금과 황소자리 성좌 문양이 조각된 큐.',
    },
    'cyber_neo': {
      'vi': 'Công nghệ tương lai năm 2077 với vi mạch bán dẫn và đèn LED tím neon.',
      'en': 'Futuristic 2077 tech with semiconductor chips and violet neon glow.',
      'zh': '2077未来科技结合半导体微芯片与紫光霓虹。',
      'ja': '半導体回路とネオンパープルの2077年未来テクノロジー。',
      'ko': '반도체 회로와 퍼플 네온의 2077년 미래 기술.',
    },
    'phoenix_flame': {
      'vi': 'Được rèn từ tro tàn của Phượng Hoàng Lửa, thân gậy bốc cháy ngọn lửa bất tử.',
      'en': 'Forged from phoenix ashes, radiating undying mythical blaze.',
      'zh': '浴火重生的火凤凰遗灰淬炼而成，附带不灭神焰。',
      'ja': '不死鳥の灰から鍛えられた不滅の炎をまとうキュー。',
      'ko': '불사조의 재에서 벼려낸 불멸의 화염을 두른 큐.',
    },
    'dragon_god': {
      'vi': 'Báu vật hoàng gia ngàn năm tuổi, mang sức mạnh thần long chấn động thiên địa.',
      'en': 'Millennium royal treasure bearing dragon spirit of heaven and earth.',
      'zh': '千年皇室御用圣物，蕴含撼天动地的神龙威能。',
      'ja': '千年の皇室の秘宝、天地を揺るがす神龍の力。',
      'ko': '천년 황실의 보물, 천지를 뒤흔드는 황금 신룡의 힘.',
    },
  };

  // =========================================================================
  // 3. KỸ NĂNG NỘI TẠI GẬY CƠ (CUE PERKS)
  // =========================================================================
  static const Map<String, Map<String, String>> cuePerks = {
    'standard_cue': {
      'vi': 'Cân bằng cơ bản, không có nội tại phụ.',
      'en': 'Standard balance, no special perks.',
      'zh': '基础平衡，无特殊被动。',
      'ja': '基本バランス、特殊能力なし。',
      'ko': '기본 밸런스, 특수 효과 없음.',
    },
    'titan_striker': {
      'vi': 'Heavy Break: Tăng thêm 15% xung lực khi đánh vỡ cụm bi khai cuộc.',
      'en': 'Heavy Break: +15% impact force on break shot.',
      'zh': '强力开球: 开球冲杆冲击力提升15%。',
      'ja': 'ヘビーブレイク: ブレイクショットの衝撃力+15%。',
      'ko': '헤비 브레이크: 브레이크 샷 충격력 +15%.',
    },
    'frostbite': {
      'vi': 'Ice Aim: Tia ngắm cực kỳ ổn định, làm chậm nhịp rung khi căn lực.',
      'en': 'Ice Aim: Ultra-stable aim guide, reduced jitter while aiming.',
      'zh': '冰霜瞄准: 瞄准导线极度稳定，蓄力时大幅防抖。',
      'ja': 'アイスエイム: 照準ガイドが極めて安定、エイムのブレを軽減。',
      'ko': '아이스 에임: 조준선이 흔들림 없이 극도로 안정됩니다.',
    },
    'golden_bull': {
      'vi': 'Jackpot Touch: Nhận thêm 10% Vàng thưởng sau mỗi trận thắng.',
      'en': 'Jackpot Touch: +10% bonus Coins on match victory.',
      'zh': '财运眷顾: 获胜时额外获得10%金币奖励。',
      'ja': 'ジャックポット: 勝利時に獲得コイン+10%。',
      'ko': '잭팟 터치: 경기 승리 시 추가 골드 +10%.',
    },
    'cyber_neo': {
      'vi': 'Laser Line: Kéo dài tia ngắm thêm 20% và hiển thị đường rẽ bi rực sáng.',
      'en': 'Laser Line: +20% Aim guideline length with glowing reflection lines.',
      'zh': '激光瞄准: 瞄准线延长20%并高亮反弹折射轨迹。',
      'ja': 'レーザーライン: 照準ガイドが20%延長、反射ラインが鮮明に表示。',
      'ko': '레이저 라인: 조준선 20% 연장 및 반사 궤적 발광 표시.',
    },
    'phoenix_flame': {
      'vi': 'Inferno Spin: Tăng vọt 25% độ giật trô bóng lùi và cu-lê tiến tới.',
      'en': 'Inferno Spin: +25% Topspin follow and extreme draw surge.',
      'zh': '炼狱旋转: 强力低杆拉杆与高杆推杆效能暴增25%。',
      'ja': 'インフェルノスピン: トップスピンとドローの威力が25%上昇。',
      'ko': '인페르노 스핀: 밀어치기와 끌어치기 회전 효과가 25% 급증.',
    },
    'dragon_god': {
      'vi': 'Dragon Heart: Hoàn lại 50% tiền cược nếu thua ván; Vệt lửa rồng hộ mệnh.',
      'en': 'Dragon Heart: Refund 50% wager on defeat; Guardian dragon fire trail.',
      'zh': '龙之心魄: 惜败时退还50%金币筹码; 神龙守护焰痕。',
      'ja': 'ドラゴンハート: 敗北時に参加費の50%を返還、守護龍の軌跡。',
      'ko': '드래곤 하트: 패배 시 참가비 50% 환급, 수호룡 화염 궤적.',
    },
  };

  // =========================================================================
  // 4. PHẨM CẤP GẬY CƠ (CUE RARITY)
  // =========================================================================
  static const Map<String, Map<String, String>> cueRarities = {
    'common': {
      'vi': 'Thường',
      'en': 'Common',
      'zh': '普通',
      'ja': 'ノーマル',
      'ko': '일반',
    },
    'rare': {
      'vi': 'Hiếm',
      'en': 'Rare',
      'zh': '稀有',
      'ja': 'レア',
      'ko': '희귀',
    },
    'epic': {
      'vi': 'Sử Thi',
      'en': 'Epic',
      'zh': '史诗',
      'ja': 'エピック',
      'ko': '에픽',
    },
    'legendary': {
      'vi': 'Huyền Thoại',
      'en': 'Legendary',
      'zh': '传说',
      'ja': 'レジェンド',
      'ko': '전설',
    },
  };

  // =========================================================================
  // 5. TIÊU ĐỀ THÀNH TỰU (ACHIEVEMENT TITLES)
  // =========================================================================
  static const Map<String, Map<String, String>> achievementTitles = {
    'first_win': {
      'vi': 'Phát Cơ Đầu Tiên',
      'en': 'First Strike',
      'zh': '初战告捷',
      'ja': '初勝利の一撃',
      'ko': '첫 번째 승리',
    },
    'cue_enthusiast': {
      'vi': 'Tín Đồ Bida',
      'en': 'Cue Enthusiast',
      'zh': '球杆爱好者',
      'ja': 'キュー愛好家',
      'ko': '큐 마니아',
    },
    'spin_trick': {
      'vi': 'Biến Hóa Điểm Chạm',
      'en': 'Spin Mastermind',
      'zh': '变幻击球点',
      'ja': 'スピンの魔術師',
      'ko': '스핀 마스터',
    },
    'combo_hunter': {
      'vi': 'Thợ Săn Combo',
      'en': 'Combo Hunter',
      'zh': '连环捕手',
      'ja': 'コンボハンター',
      'ko': '콤보 헌터',
    },
    'daily_puzzle_clear': {
      'vi': 'Bậc Thầy Giải Thế',
      'en': 'Puzzle Solver',
      'zh': '残局破解大师',
      'ja': 'パズルマスター',
      'ko': '퍼즐 해결사',
    },
    'win_streak_3': {
      'vi': 'Tam Liên Thắng',
      'en': 'Triple Triumph',
      'zh': '三连绝胜',
      'ja': '3連勝の栄光',
      'ko': '3연승의 주역',
    },
    'cue_collector': {
      'vi': 'Nhà Sưu Tập Cơ Thủ',
      'en': 'Arsenal Collector',
      'zh': '球杆收藏家',
      'ja': 'キューコレクター',
      'ko': '큐 수집가',
    },
    'rich_player': {
      'vi': 'Đại Gia Phố Bida',
      'en': 'Billiards Tycoon',
      'zh': '台球街大亨',
      'ja': 'ビリヤード大富豪',
      'ko': '당구장 재벌',
    },
    'multiplayer_veteran': {
      'vi': 'Sát Thủ Đối Kháng',
      'en': 'Multiplayer Veteran',
      'zh': '联机老手',
      'ja': 'マルチプレイヤーの覇者',
      'ko': '멀티플레이 베테랑',
    },
    'bot_campaign_clear': {
      'vi': 'Khuất Phục Cao Thủ Bot',
      'en': 'AI Conqueror',
      'zh': '智破人机试炼',
      'ja': 'BOT完全制覇',
      'ko': '봇 군단 정복자',
    },
    'cue_level_max': {
      'vi': 'Tuyệt Đỉnh Thần Binh',
      'en': 'Master Weapon Max',
      'zh': '绝世神兵 MAX',
      'ja': '究極の神話キュー',
      'ko': '최강 신병 MAX',
    },
    'reach_level_10': {
      'vi': 'Cơ Thủ Kỳ Cựu',
      'en': 'Seasoned Veteran',
      'zh': '身经百战',
      'ja': '熟練のベテラン',
      'ko': '숙련된 베테랑',
    },
    'tournament_champion_legend': {
      'vi': 'Vua Giải Đấu 6 Brackets',
      'en': 'Tournament Supreme King',
      'zh': '锦标赛无冕之王',
      'ja': 'トーナメント覇王',
      'ko': '토너먼트의 제왕',
    },
    'billiard_god': {
      'vi': 'Huyền Thoại Bida Toàn Năng',
      'en': 'All-Round Billiard Legend',
      'zh': '全能台球传奇',
      'ja': '全能のビリヤードレジェンド',
      'ko': '올라운드 당구 전설',
    },
  };

  // =========================================================================
  // 6. MÔ TẢ THÀNH TỰU (ACHIEVEMENT DESCRIPTIONS)
  // =========================================================================
  static const Map<String, Map<String, String>> achievementDescriptions = {
    'first_win': {
      'vi': 'Giành chiến thắng trận đấu bida đầu tiên của bạn.',
      'en': 'Win your very first billiard match.',
      'zh': '赢得您的第一场台球比赛。',
      'ja': '最初のビリヤードマッチで勝利を収めよう。',
      'ko': '첫 번째 당구 경기에서 승리하세요.',
    },
    'cue_enthusiast': {
      'vi': 'Sở hữu ít nhất 2 cây gậy cơ trong Cửa Hàng.',
      'en': 'Own at least 2 cue sticks in the Shop.',
      'zh': '在商城中拥有至少2支球杆。',
      'ja': 'ショップで2本以上のキューを所持しよう。',
      'ko': '상점에서 2개 이상의 큐를 소유하세요.',
    },
    'spin_trick': {
      'vi': 'Tùy chỉnh kỹ thuật Áp-phê (Cu-lê hoặc Trô bóng) trong trận đấu.',
      'en': 'Customize cue ball spin (Follow or Draw) during a match.',
      'zh': '在对局中自定义加塞击球点 (高杆或低杆)。',
      'ja': '試合中にスピン（トップスピンまたはドロー）を調整しよう。',
      'ko': '경기 중 스핀(밀어치기 또는 끌어치기)을 조정하세요.',
    },
    'combo_hunter': {
      'vi': 'Thực hiện chuỗi ăn Combo từ 2 bi cùng nhóm trở lên trong 1 cơ.',
      'en': 'Perform a combo by potting 2+ balls of your group in a single shot.',
      'zh': '一杆内击落2颗或以上同组目标球达成连击。',
      'ja': '1ショットで同グループのボールを2個以上沈めてコンボを決めよう。',
      'ko': '한 번의 샷으로 같은 그룹 공을 2개 이상 연속으로 넣으세요.',
    },
    'daily_puzzle_clear': {
      'vi': 'Hoàn thành thử thách Thế Bi Hàng Ngày (Daily Trickshot).',
      'en': 'Clear the Daily Puzzle challenge.',
      'zh': '成功通过每日残局挑战。',
      'ja': 'デイリーパズルチャレンジをクリアしよう。',
      'ko': '일일 퍼즐 챌린지를 클리어하세요.',
    },
    'win_streak_3': {
      'vi': 'Giành tổng cộng từ 3 trận thắng trở lên.',
      'en': 'Accumulate 3 or more match victories.',
      'zh': '累计获得至少3场比赛胜利。',
      'ja': '通算3勝以上を達成しよう。',
      'ko': '누적 3승 이상을 달성하세요.',
    },
    'cue_collector': {
      'vi': 'Mở khóa và sở hữu từ 4 cây gậy cơ trở lên trong bộ sưu tập.',
      'en': 'Unlock and own 4 or more cue sticks in your collection.',
      'zh': '在收藏中解锁并拥有4支或以上球杆。',
      'ja': 'コレクションで4本以上のキューをアンロックしよう。',
      'ko': '컬렉션에서 4개 이상의 큐를 잠금 해제하세요.',
    },
    'rich_player': {
      'vi': 'Tích lũy tài sản đạt từ 25.000 Vàng trở lên.',
      'en': 'Accumulate a balance of 25,000 Coins or more.',
      'zh': '财富积累达到25,000金币以上。',
      'ja': '所持金を25,000コイン以上貯めよう。',
      'ko': '누적 자산 25,000 골드 이상을 달성하세요.',
    },
    'multiplayer_veteran': {
      'vi': 'Chiến thắng trận đấu mạng nhiều người chơi (Local/Online).',
      'en': 'Win a multiplayer match (Local Network or Online).',
      'zh': '赢得一场多人对战 (局域网或在线网络)。',
      'ja': 'マルチプレイヤーマッチ（ローカルまたはオンライン）で勝利しよう。',
      'ko': '멀티플레이 경기(로컬 또는 온라인)에서 승리하세요.',
    },
    'bot_campaign_clear': {
      'vi': 'Vượt qua trọn vẹn 7 Ải Thử Thách Bot Campaign.',
      'en': 'Conquer all 7 stages in the Bot Campaign.',
      'zh': '成功通关人机战役全部7关考验。',
      'ja': 'BOTキャンペーン全7ステージを突破しよう。',
      'ko': '봇 캠페인 7개 스테이지를 모두 돌파하세요.',
    },
    'cue_level_max': {
      'vi': 'Nâng cấp bất kỳ cây gậy cơ nào đạt cấp độ tối đa (Level 10).',
      'en': 'Upgrade any cue stick to maximum level (Level 10).',
      'zh': '将任意球杆升至满级 (10级)。',
      'ja': 'いずれかのキューを最大レベル（Lv.10）まで強化しよう。',
      'ko': '아무 큐나 최대 레벨(레벨 10)까지 강화하세요.',
    },
    'reach_level_10': {
      'vi': 'Nâng cấp trình độ nhân vật đạt từ Cấp 10 (Lv.10) trở lên.',
      'en': 'Reach player Level 10 or higher.',
      'zh': '玩家角色等级提升至10级或以上。',
      'ja': 'プレイヤーレベルをLv.10以上に到達させよう。',
      'ko': '플레이어 레벨 10 이상에 도달하세요.',
    },
    'tournament_champion_legend': {
      'vi': 'Vượt qua toàn bộ 6 vòng đấu Brackets khốc liệt và nâng cao cúp Vô Địch!',
      'en': 'Triumph over all 6 Tournament Brackets and hoist the Champion Cup!',
      'zh': '通过全部6轮残酷的锦标赛，高举冠军奖杯！',
      'ja': '激闘の全6ブラケットを制覇し、優勝カップを掲げよう！',
      'ko': '치열한 토너먼트 6개 브래킷을 모두 제패하고 우승컵을 들어 올리세요!',
    },
    'billiard_god': {
      'vi': 'Sở hữu trên 100.000 Vàng và đạt 50 trận thắng vẻ vang.',
      'en': 'Hold over 100,000 Coins and achieve 50 glorious victories.',
      'zh': '坐拥100,000以上金币并斩获50场辉煌胜利。',
      'ja': '100,000コイン以上を保有し、栄光の50勝を達成しよう。',
      'ko': '100,000 이상의 골드를 보유하고 50승의 영광을 달성하세요.',
    },
  };

  // =========================================================================
  // 7. ĐỘ KHÓ THÀNH TỰU (ACHIEVEMENT DIFFICULTY)
  // =========================================================================
  static const Map<String, Map<String, String>> achievementDifficulties = {
    'easy': {
      'vi': 'Dễ',
      'en': 'Easy',
      'zh': '简单',
      'ja': 'イージー',
      'ko': '쉬움',
    },
    'medium': {
      'vi': 'Trung Bình',
      'en': 'Medium',
      'zh': '中等',
      'ja': 'ノーマル',
      'ko': '보통',
    },
    'hard': {
      'vi': 'Khó',
      'en': 'Hard',
      'zh': '困难',
      'ja': 'ハード',
      'ko': '어려움',
    },
    'expert': {
      'vi': 'Siêu Khó',
      'en': 'Expert',
      'zh': '专家',
      'ja': 'エキスパート',
      'ko': '전문가',
    },
    'legendary': {
      'vi': 'Huyền Thoại',
      'en': 'Legendary',
      'zh': '传奇',
      'ja': 'レジェンド',
      'ko': '전설',
    },
  };

  // =========================================================================
  // 8. TÊN HUY CHƯƠNG (MEDAL NAMES)
  // =========================================================================
  static const Map<String, Map<String, String>> medalNames = {
    'tournament_champion': {
      'vi': 'Cúp Quán Quân Tournament',
      'en': 'Tournament Champion Cup',
      'zh': '锦标赛总冠军杯',
      'ja': 'トーナメント優勝カップ',
      'ko': '토너먼트 챔피언 컵',
    },
    'tournament_runner_up': {
      'vi': 'Huy Chương Á Quân',
      'en': 'Tournament Runner-Up',
      'zh': '锦标赛亚军奖牌',
      'ja': '準優勝メダル',
      'ko': '준우승 메달',
    },
    'tournament_semis': {
      'vi': 'Huy Chương Tứ Cường',
      'en': 'Semi-Finalist Medal',
      'zh': '四强殿堂奖牌',
      'ja': 'セミファイナルメダル',
      'ko': '4강 진출 메달',
    },
    'sharpshooter': {
      'vi': 'Huy Chương Thiện Xạ',
      'en': 'Sharpshooter Medal',
      'zh': '神准神枪手',
      'ja': 'スナイパーメダル',
      'ko': '명사수 메달',
    },
    'trickshot_master': {
      'vi': 'Thần Cơ Diệu Toán',
      'en': 'Master Trickshot',
      'zh': '神机妙算',
      'ja': 'トリックショットマスター',
      'ko': '신기묘산 마스터',
    },
    'bot_slayer': {
      'vi': 'Huy Hiệu Trùm Bot',
      'en': 'Bot Slayer Crest',
      'zh': '击破者勋章',
      'ja': 'BOTスレイヤー紋章',
      'ko': '봇 슬레이어 훈장',
    },
    'cue_master': {
      'vi': 'Bậc Thầy Gậy Cơ',
      'en': 'Cue Craftmaster',
      'zh': '球杆宗师',
      'ja': 'キュー職人',
      'ko': '큐 마스터 장인',
    },
    'grandmaster': {
      'vi': 'Đại Kiện Tướng Bida',
      'en': 'Billiard Grandmaster',
      'zh': '台球特级大师',
      'ja': 'グランドマスター',
      'ko': '당구 대기수',
    },
    'wealthy_striker': {
      'vi': 'Triệu Phú Phố Bida',
      'en': 'Billiards Millionaire',
      'zh': '百万金库大亨',
      'ja': 'ミリオネアストライカー',
      'ko': '당구장 백만장자',
    },
    'bronze_champion': {
      'vi': 'Cơ Thủ Tinh Anh',
      'en': 'Elite Striker',
      'zh': '精英新星球手',
      'ja': 'エリートストライカー',
      'ko': '엘리트 당구인',
    },
  };

  // =========================================================================
  // 9. MÔ TẢ HUY CHƯƠNG (MEDAL DESCRIPTIONS)
  // =========================================================================
  static const Map<String, Map<String, String>> medalDescriptions = {
    'tournament_champion': {
      'vi': 'Danh hiệu cao quý nhất dành cho cơ thủ thống trị cả 6 Brackets của giải đấu.',
      'en': 'Highest honor awarded to the player dominating all 6 Tournament Brackets.',
      'zh': '颁发给统领全部6轮锦标赛王者的至高荣耀。',
      'ja': '全6ブラケットを制圧したプレイヤーに贈られる最高峰の栄誉。',
      'ko': '토너먼트 6개 브래킷을 모두 제패한 플레이어에게 주어지는 최고 영예.',
    },
    'tournament_runner_up': {
      'vi': 'Khẳng định bản lĩnh kiên cường khi bước chân vào trận Đại Chung Kết Bracket 6.',
      'en': 'Testament to resilience in battling through to the Grand Finals of Bracket 6.',
      'zh': '战至巅峰总决赛第6轮的坚韧证明。',
      'ja': '第6ブラケットのグランドファイナルまで勝ち抜いた証。',
      'ko': '브래킷 6 결승전에 진출한 굳건한 실력의 증표.',
    },
    'tournament_semis': {
      'vi': 'Vượt qua vòng Tứ Kết và ghi tên mình vào Bán Kết Bracket 4.',
      'en': 'Advanced beyond the Quarter-Finals into the Semi-Finals of Bracket 4.',
      'zh': '突围1/4决赛，成功跻身第4轮半决赛。',
      'ja': '準々決勝を突破し、第4ブラケット準決勝へ進出。',
      'ko': '준준결승을 넘어 브래킷 4 준결승에 진출했습니다.',
    },
    'sharpshooter': {
      'vi': 'Dành cho cơ thủ có nhãn quan siêu phàm, ghi combo ăn nhiều bi liên hoàn.',
      'en': 'Awarded for extraordinary vision, sinking multiple balls in a single combo.',
      'zh': '专属拥有非凡视野、实现多球连环清台的卓越球手。',
      'ja': '1ショットで複数ボールを連続で沈める神技の持ち主へ。',
      'ko': '한 샷으로 여러 공을 연달아 포켓에 넣는 탁월한 시야의 소유자.',
    },
    'trickshot_master': {
      'vi': 'Giải mã thành công thế bi hiểm hóc của nhiệm vụ Hàng Ngày.',
      'en': 'Successfully decoded difficult trickshot layouts in Daily Puzzles.',
      'zh': '成功破解每日任务中刁钻险要的残局阵型。',
      'ja': '難解なデイリーパズルを見事に解き明かした証。',
      'ko': '어려운 일일 트릭샷 퍼즐 배치를 완벽하게 풀어냈습니다.',
    },
    'bot_slayer': {
      'vi': 'Đánh bại Boss Bot cao nhất trong chuỗi 7 Ải Thử Thách Chiến Dịch.',
      'en': 'Defeated the supreme Bot Boss in the 7-stage Campaign.',
      'zh': '在7关人机战役试炼中战胜最高阶首领机器人。',
      'ja': '7段階のBOTキャンペーンで最強ボスを討伐した証。',
      'ko': '7단계 봇 캠페인에서 최상위 보스 봇을 물리쳤습니다.',
    },
    'cue_master': {
      'vi': 'Sở hữu và rèn đúc gậy cơ đạt mốc nâng cấp Level 5 trở lên.',
      'en': 'Forged and upgraded a cue stick to Level 5 or higher.',
      'zh': '锻造并将任意球杆强化至5级以上。',
      'ja': 'キューをLv.5以上に鍛え上げた証。',
      'ko': '큐를 레벨 5 이상으로 강화 및 단련했습니다.',
    },
    'grandmaster': {
      'vi': 'Minh chứng cho đẳng cấp cơ thủ kỳ cựu đạt Cấp độ 10+.',
      'en': 'Proof of veteran status reaching player Level 10 or higher.',
      'zh': '玩家角色达到10级以上的名宿凭证。',
      'ja': 'プレイヤーレベル10に到達した熟練者の証。',
      'ko': '플레이어 레벨 10 이상에 도달한 베테랑의 증표.',
    },
    'wealthy_striker': {
      'vi': 'Sở hữu khối tài sản từ 20.000 Vàng trong két sắt cá nhân.',
      'en': 'Hold a fortune of 20,000+ Coins in your personal vault.',
      'zh': '个人金库中坐拥20,000以上金币巨资。',
      'ja': '個人金庫に20,000コイン以上の富を築いた証。',
      'ko': '개인 금고에 20,000 골드 이상의 재산을 축적했습니다.',
    },
    'bronze_champion': {
      'vi': 'Ghi dấu ấn những bước đầu tiên trên đấu trường bi-a chuyên nghiệp.',
      'en': 'Marked your first milestone in competitive billiards.',
      'zh': '在专业竞技台球舞台上迈出坚实的第一步。',
      'ja': '競技ビリヤードの世界で最初の一歩を踏み出した証。',
      'ko': '프로 당구 무대에서 첫 발자국을 남겼습니다.',
    },
  };

  // =========================================================================
  // 10. ĐIỀU KIỆN MỞ KHÓA HUY CHƯƠNG (MEDAL REQUIREMENTS)
  // =========================================================================
  static const Map<String, Map<String, String>> medalRequirements = {
    'tournament_champion': {
      'vi': 'Vô địch chế độ Giải Đấu Tournament 6 Brackets',
      'en': 'Win the 6-Bracket Tournament Championship',
      'zh': '夺得6轮巡回锦标赛总冠军',
      'ja': '全6ブラケットトーナメントで優勝',
      'ko': '6강 토너먼트 대회 우승',
    },
    'tournament_runner_up': {
      'vi': 'Lọt vào trận Chung Kết Bracket 6 của Tournament',
      'en': 'Reach the Grand Finals (Bracket 6) of Tournament',
      'zh': '打入锦标赛第6轮巅峰总决赛',
      'ja': '第6ブラケット決勝戦に進出',
      'ko': '토너먼트 브래킷 6 결승전 진출',
    },
    'tournament_semis': {
      'vi': 'Vượt qua Bracket 3 để tiến vào Bán Kết Tournament',
      'en': 'Pass Bracket 3 to enter Tournament Semi-Finals',
      'zh': '通过第3轮晋级锦标赛半决赛',
      'ja': '第3ブラケットを突破して準決勝へ進出',
      'ko': '브래킷 3을 통과하여 준결승 진출',
    },
    'sharpshooter': {
      'vi': 'Thực hiện chuỗi ăn Combo bi trong trận đấu',
      'en': 'Perform a ball combo pocket in a match',
      'zh': '在对局中达成目标球连击进袋',
      'ja': '試合中にボールコンボを成功させる',
      'ko': '경기 중 콤보 샷 성공',
    },
    'trickshot_master': {
      'vi': 'Chiến thắng chế độ Thế Bi Hàng Ngày',
      'en': 'Clear Daily Puzzle Mode',
      'zh': '通关每日残局挑战模式',
      'ja': 'デイリーパズルモードをクリア',
      'ko': '일일 퍼즐 모드 클리어',
    },
    'bot_slayer': {
      'vi': 'Vượt qua ải 7 trong Chiến Dịch Bot',
      'en': 'Clear Stage 7 in Bot Campaign',
      'zh': '通过人机战役第7关',
      'ja': 'BOTキャンペーン第7ステージをクリア',
      'ko': '봇 캠페인 7단계 클리어',
    },
    'cue_master': {
      'vi': 'Nâng cấp bất kỳ cây gậy nào lên cấp 5+',
      'en': 'Upgrade any cue to Level 5 or higher',
      'zh': '将任意球杆升级至5级或以上',
      'ja': 'いずれかのキューをLv.5以上に強化',
      'ko': '아무 큐나 레벨 5 이상으로 강화',
    },
    'grandmaster': {
      'vi': 'Đạt Cấp độ người chơi Lv.10 trở lên',
      'en': 'Reach player Level 10 or higher',
      'zh': '达到玩家角色10级或以上',
      'ja': 'プレイヤーレベル10に到達',
      'ko': '플레이어 레벨 10 이상 달성',
    },
    'wealthy_striker': {
      'vi': 'Tích lũy đạt trên 20.000 Vàng',
      'en': 'Accumulate over 20,000 Coins',
      'zh': '财富累计突破20,000金币',
      'ja': '所持金20,000コイン以上を達成',
      'ko': '누적 20,000 골드 이상 달성',
    },
    'bronze_champion': {
      'vi': 'Chiến thắng trận đấu đầu tiên',
      'en': 'Win your first match',
      'zh': '获得第一场比赛胜利',
      'ja': '初マッチで勝利',
      'ko': '첫 경기 승리',
    },
  };

  // =========================================================================
  // 11. PHẨM CẤP HUY CHƯƠNG (MEDAL RARITY)
  // =========================================================================
  static const Map<String, Map<String, String>> medalRarities = {
    'bronze': {
      'vi': 'Đồng',
      'en': 'Bronze',
      'zh': '青铜',
      'ja': 'ブロンズ',
      'ko': '브론즈',
    },
    'silver': {
      'vi': 'Bạc',
      'en': 'Silver',
      'zh': '白银',
      'ja': 'シルバー',
      'ko': '실버',
    },
    'gold': {
      'vi': 'Vàng',
      'en': 'Gold',
      'zh': '黄金',
      'ja': 'ゴールド',
      'ko': '골드',
    },
    'diamond': {
      'vi': 'Kim Cương',
      'en': 'Diamond',
      'zh': '钻石',
      'ja': 'ダイヤ',
      'ko': '다이아몬드',
    },
    'mythic': {
      'vi': 'Thần Thoại',
      'en': 'Mythic',
      'zh': '神话',
      'ja': 'ミシック',
      'ko': '신화',
    },
  };

  // =========================================================================
  // 12. DIỄN GIẢI ĐIỂM XOÁY BI CÁI (SPIN DESCRIPTION)
  // =========================================================================
  static String describeSpin(Offset spin, String lang) {
    if (spin.distance < 0.08) {
      return switch (lang) {
        'en' => 'Center ball (No spin)',
        'zh' => '球心 (标准击球, 无旋转)',
        'ja' => '中心 (無回転)',
        'ko' => '수구 중심 (무회전)',
        _ => 'Tâm bi (Đánh thường, không xoáy)',
      };
    }
    final parts = <String>[];
    if (spin.dy < -0.15) {
      final p = (-spin.dy * 100).round();
      final text = switch (lang) {
        'en' => 'Follow (Top) $p%',
        'zh' => '高杆推杆 $p%',
        'ja' => 'トップスピン $p%',
        'ko' => '상단 밀어치기 $p%',
        _ => 'Cu-lê $p%',
      };
      parts.add(text);
    } else if (spin.dy > 0.15) {
      final p = (spin.dy * 100).round();
      final text = switch (lang) {
        'en' => 'Draw (Bottom) $p%',
        'zh' => '低杆拉杆 $p%',
        'ja' => 'ドロースピン $p%',
        'ko' => '하단 끌어치기 $p%',
        _ => 'Trô bóng $p%',
      };
      parts.add(text);
    }
    if (spin.dx < -0.15) {
      final p = (-spin.dx * 100).round();
      final text = switch (lang) {
        'en' => 'Left English $p%',
        'zh' => '左加塞 $p%',
        'ja' => '左スピン $p%',
        'ko' => '좌측 회전 $p%',
        _ => 'Áp-phê Trái $p%',
      };
      parts.add(text);
    } else if (spin.dx > 0.15) {
      final p = (spin.dx * 100).round();
      final text = switch (lang) {
        'en' => 'Right English $p%',
        'zh' => '右加塞 $p%',
        'ja' => '右スピン $p%',
        'ko' => '우측 회전 $p%',
        _ => 'Áp-phê Phải $p%',
      };
      parts.add(text);
    }
    if (parts.isEmpty) {
      return switch (lang) {
        'en' => 'Near center',
        'zh' => '接近球心',
        'ja' => '中心付近',
        'ko' => '중심 근처',
        _ => 'Gần tâm bi',
      };
    }
    return parts.join(' • ');
  }

  static String getCueName(String id, String lang, [String fallback = '']) {
    return cueNames[id]?[lang] ?? cueNames[id]?['en'] ?? cueNames[id]?['vi'] ?? fallback;
  }

  static String getCueDescription(String id, String lang, [String fallback = '']) {
    return cueDescriptions[id]?[lang] ?? cueDescriptions[id]?['en'] ?? cueDescriptions[id]?['vi'] ?? fallback;
  }

  static String getCuePerk(String id, String lang, [String fallback = '']) {
    return cuePerks[id]?[lang] ?? cuePerks[id]?['en'] ?? cuePerks[id]?['vi'] ?? fallback;
  }

  static String getCueRarity(String key, String lang, [String fallback = '']) {
    return cueRarities[key]?[lang] ?? cueRarities[key]?['en'] ?? cueRarities[key]?['vi'] ?? fallback;
  }

  static String getAchievementTitle(String id, String lang, [String fallback = '']) {
    return achievementTitles[id]?[lang] ?? achievementTitles[id]?['en'] ?? achievementTitles[id]?['vi'] ?? fallback;
  }

  static String getAchievementDescription(String id, String lang, [String fallback = '']) {
    return achievementDescriptions[id]?[lang] ?? achievementDescriptions[id]?['en'] ?? achievementDescriptions[id]?['vi'] ?? fallback;
  }

  static String getAchievementDifficulty(String key, String lang, [String fallback = '']) {
    return achievementDifficulties[key]?[lang] ?? achievementDifficulties[key]?['en'] ?? achievementDifficulties[key]?['vi'] ?? fallback;
  }

  static String getMedalName(String id, String lang, [String fallback = '']) {
    return medalNames[id]?[lang] ?? medalNames[id]?['en'] ?? medalNames[id]?['vi'] ?? fallback;
  }

  static String getMedalDescription(String id, String lang, [String fallback = '']) {
    return medalDescriptions[id]?[lang] ?? medalDescriptions[id]?['en'] ?? medalDescriptions[id]?['vi'] ?? fallback;
  }

  static String getMedalRequirement(String id, String lang, [String fallback = '']) {
    return medalRequirements[id]?[lang] ?? medalRequirements[id]?['en'] ?? medalRequirements[id]?['vi'] ?? fallback;
  }

  static String getMedalRarity(String key, String lang, [String fallback = '']) {
    return medalRarities[key]?[lang] ?? medalRarities[key]?['en'] ?? medalRarities[key]?['vi'] ?? fallback;
  }
}

