# 🎱 Game Bida 8 Bóng 2D (Billiard 8-Ball)

Game Bida 8 Bóng (8-Ball Pool) phong cách hiện đại, trực quan, hỗ trợ chơi 2 người trên cùng thiết bị hoặc so tài với máy (CPU Bot). Trò chơi được xây dựng trên nền tảng Flutter + Flame + Forge2D, tối ưu hóa giao diện xoay ngang, tự động thích ứng hoàn hảo trên mọi thiết bị di động.

---

## 📑 Mục Lục
1. [Công Nghệ Sử Dụng](#-công-nghệ-sử-dụng)
2. [Tính Năng Kỹ Thuật Đã Triển Khai](#-tính-năng-kỹ-thuật-đã-triển-khai)
3. [Luật Chơi Chuẩn 8-Ball](#-luật-chơi-chi-tiết-chuẩn-8-ball)
4. [Hướng Dẫn Thao Tác](#-hướng-dẫn-thao-tác)
5. [📘 Game Design Document (GDD)](#-bản-thiết-kế-trò-chơi-game-design-document---gdd)
   - [5.1. Định Vị & Tầm Nhìn Dự Án](#51-định-vị--tầm-nhìn-dự-án)
   - [5.2. Kiến Trúc Vòng Lặp Game (Game Loops)](#52-kiến-trúc-vòng-lặp-game-game-loops)
   - [5.3. Hệ Thống Chế Độ Chơi (Replayability Modes)](#53-hệ-thống-chế-độ-chơi-tạo-tính-chơi-lại-cao-replayability)
   - [5.4. Tính Năng & Hoạt Động Giữ Chân Người Chơi (Retention & Live-Ops)](#54-tính-năng--hoạt-động-giữ-chân-người-chơi-retention--live-ops)
   - [5.5. Hệ Thống Shop Cửa Hàng & Nâng Cấp Gậy Cơ (Cue Mastery & Shop RPG)](#55-hệ-thống-shop-cửa-hàng--nâng-cấp-gậy-cơ-cue-mastery--shop-rpg)
   - [5.6. Kinh Tế Trong Game (In-Game Economy)](#56-kinh-tế-trong-game-in-game-economy)
6. [🗺️ Lộ Trình Phát Triển (Product Roadmap)](#-lộ-trình-phát-triển-product-roadmap)

---

## 🛠️ Công Nghệ Sử Dụng

Dự án được xây dựng trên nền tảng công nghệ đa nền tảng hiện đại, đảm bảo hiệu năng cao và chuyển động 60 FPS mượt mà:

- **Flutter**: Bộ công cụ phát triển giao diện người dùng đa nền tảng hàng đầu của Google, giúp game chạy mượt trên Android, iOS, Web và Desktop.
- **Flame Game Engine**: Engine game 2D chuyên dụng cho Flutter, quản lý vòng lặp game (game loop), thời gian thực và kết xuất hình ảnh ổn định.
- **Forge2D (Box2D Physics Engine)**: Động cơ vật lý tiêu chuẩn quốc tế mô phỏng chân thực va chạm cơ học, góc nảy băng, ma sát lăn mặt nỉ và lực quán tính của bi.
- **Đồ họa Vector Thuần (CustomPaint)**: Cây cơ trên thanh lực và hệ thống ngắm bắn được vẽ trực tiếp bằng vector, đảm bảo độ nét tuyệt đối trên mọi độ phân giải màn hình.

---

## 🌟 Tính Năng Kỹ Thuật Đã Triển Khai

- 🤖 **Chế độ chơi đa dạng**:
  - **Chơi 2 Người (PvP)**: Thi đấu lần lượt với bạn bè trên cùng màn hình.
  - **Đấu với Máy (Vs CPU)**: Tùy chọn 2 cấp độ: **Bot Dễ** (dành cho người mới tập chơi) và **Bot Khó** (AI phân tích hình học thông minh, ngắm bóng và căn lực chính xác, biết tự né phạm lỗi).
- 🌪️ **Vật lý xoáy bi thực tế**:
  - Tùy chỉnh điểm chạm đầu cơ trên bi cái để tạo hiệu ứng: **Cu-lê** (tiến tới sau va chạm), **Trô bóng** (giật lùi lại) và **Áp-phê Trái / Phải** (đổi góc nảy khi đập băng).
  - Tự động hoàn trả vị trí tâm bi sau mỗi cú đánh.
- ⚡ **Thanh lực tương tác sống động**:
  - Cây cơ trên thanh đo tự động **lún sâu xuống** theo mức kéo lực của ngón tay (kèm vệt hào quang năng lượng đổi màu Xanh $\to$ Vàng $\to$ Đỏ).
- 📱 **Giao diện tự co giãn (Responsive)**:
  - Tự động thích ứng hoàn hảo với mọi kích cỡ màn hình điện thoại (kể cả các dòng máy nhỏ như iPhone SE, Android phổ thông hay máy có tai thỏ / camera nốt ruồi), không bao giờ bị tràn viền hay che mất bàn chơi.
- 🎯 **Tia ngắm thông minh**: Hiển thị đường đi dự kiến của bi cái và hướng chuyển động của bi mục tiêu sau va chạm.

---

## 📖 Luật Chơi Chi Tiết (Chuẩn 8-Ball)

### 1. Phân chia nhóm bi
Bàn bida gồm 1 bi cái (bi trắng) và 15 bi mục tiêu được chia làm 2 nhóm:
- **Bi Trơn (Solids)**: Đánh số từ **1 đến 7** (màu đơn sắc).
- **Bi Sọc (Stripes)**: Đánh số từ **9 đến 15** (có dải sọc trắng ở giữa).
- **Bi Đen Số 8**: Bi quyết định ván đấu.

> *Nhóm bi của mỗi người chơi chỉ được xác định sau cú đánh khai cuộc khi có người đưa thành công quả bi đầu tiên vào lỗ một cách hợp lệ.*

### 2. Quy tắc đánh theo lượt
- Mỗi người chơi chỉ được ngắm và chạm cơ vào **nhóm bi của mình** đầu tiên.
- Nếu đưa được ít nhất một bi thuộc nhóm của mình vào lỗ hợp lệ, người chơi sẽ **được đánh tiếp**.
- Nếu không có bi nào vào lỗ hoặc phạm luật, lượt chơi sẽ **chuyển sang đối thủ**.

### 3. Các lỗi phạm luật (Foul)
Người chơi sẽ bị tính là phạm lỗi nếu:
1. Đánh bi cái rơi vào lỗ.
2. Đánh bi cái không chạm trúng bất kỳ quả bi nào trên bàn.
3. Đánh bi cái chạm bi của đối thủ hoặc chạm bi số 8 đầu tiên (khi chưa dọn hết nhóm của mình).
4. Bi cái và bi mục tiêu sau va chạm không có quả nào chạm băng hoặc rơi vào lỗ.

### 4. Quyền đặt bi tự do (Ball-in-Hand)
- Khi một bên phạm lỗi (Foul), người chơi kế tiếp sẽ nhận quyền **Ball-in-Hand**.
- Người chơi có quyền dùng tay chạm và đặt bi cái ở **bất kỳ vị trí nào** trên mặt bàn để thực hiện cú đánh tiếp theo.

### 5. Điều kiện Thắng / Thua
- **Chiến Thắng**: Người chơi dọn sạch toàn bộ các bi thuộc nhóm của mình và sau đó đánh bi số 8 vào lỗ một cách hợp lệ.
- **Thua Ngay Lập Tức**:
  - Đánh rơi bi số 8 vào lỗ khi chưa ăn hết nhóm bi của mình.
  - Đánh bi số 8 vào lỗ đồng thời làm bi cái rơi vào lỗ.
  - Làm bi số 8 văng ra khỏi bàn thi đấu.

---

## 🎮 Hướng Dẫn Thao Tác

1. **Ngắm hướng**: Chạm và rê ngón tay trên mặt bàn để xoay hướng ngắm của cây cơ.
2. **Chỉnh xoáy (nếu muốn)**: Bấm vào biểu tượng bi cái ở góc trên bên phải để chọn điểm tiếp xúc cơ (Cu-lê, Trô bóng hoặc Áp-phê).
3. **Kéo lực & Bắn**:
   - Chạm vào thanh đo bên trái và vuốt xuống dưới. Cây cơ sẽ lún dần theo tay bạn.
   - Thả tay ra để thực hiện cú đánh với lực tương ứng.
4. **Di chuyển bi cái (khi có Ball-in-Hand)**: Chạm giữ trực tiếp vào bi cái, kéo đến vị trí mong muốn trên bàn và thả tay.
5. **Cài đặt / Chơi lại**: Bấm vào biểu tượng bánh răng cưa ở thanh trên cùng để đổi đối thủ (Bot Dễ, Bot Khó, Người) hoặc khởi động lại ván đấu mới.

---

## 📘 BẢN THIẾT KẾ TRÒ CHƠI (GAME DESIGN DOCUMENT - GDD)

### 5.1. Định Vị & Tầm Nhìn Dự Án

- **Thể loại**: Casual Sports / Mid-core Billiards Simulator kết hợp yếu tố RPG nhẹ (Gậy cơ, Thuộc tính, Rương báu).
- **Nền tảng mục tiêu**: Mobile (Android / iOS), mở rộng Web (HTML5/Canvas) & PC.
- **Target Audience**: 
  - Game thủ yêu thích thể thao bida, thi đấu kỹ năng logic hình học (16 - 45 tuổi).
  - Người chơi casual tìm kiếm game giải trí ngắn (vòng lặp 3 - 5 phút/ván).
- **USP (Unique Selling Proposition)**:
  - Cảm giác vật lý bi lăn, áp-phê và nảy băng chân thực chuẩn Box2D.
  - Điều khiển cảm ứng trực quan, tối ưu cho màn hình cảm ứng di động.
  - Hệ thống chế độ chơi đa tầng kết hợp yếu tố sưu tập Gậy Cơ và giải đố Trickshot độc đáo.

---

### 5.2. Kiến Trúc Vòng Lặp Game (Game Loops)

Để giữ chân người chơi quay lại nhiều lần trong ngày và gắn bó theo tháng, cấu trúc game được xây dựng dựa trên 3 vòng lặp lồng ghép chặt chẽ:

```
+-------------------------------------------------------------------------------+
|                       RETENTION LOOP (Tuần / Tháng)                          |
|  - Bida Pass (Battle Pass 30 ngày)   - Giải Đấu Tuần (Weekly Leagues)         |
|  - Sưu tập Gậy Huyền Thoại           - Sự kiện Cuối Tuần (Weekend Rush)       |
+-------------------------------------------------------------------------------+
                                        ^
                                        | (Tích lũy Điểm / Cup / Huy Chương)
+-------------------------------------------------------------------------------+
|                         META GAME LOOP (Hàng Ngày)                            |
|  [Cược Vàng Vào Bàn] ---> [Mở Rương Thời Gian] ---> [Nâng Cấp Chỉ Số Gậy]     |
|          ^                                                   |                |
|          |----------- [Hoàn Thành Nhiệm Vụ Ngày] <-----------+                |
+-------------------------------------------------------------------------------+
                                        ^
                                        | (Vàng, XP, Mảnh Thẻ Cơ)
+-------------------------------------------------------------------------------+
|                         CORE GAME LOOP (Trong Ván)                            |
|  [Ghép Trận] -> [Đọc Thế Bi] -> [Chỉnh Áp-phê / Lực] -> [Cú Đánh] -> [Kết Quả]|
+-------------------------------------------------------------------------------+
```

#### A. Core Game Loop (Vòng lặp Ván đấu - Thời gian: 3 - 5 phút)
Vòng lặp micro mang lại dopamine tức thì thông qua từng đường cơ chuẩn xác:
1. **Match Entry**: Chọn bàn cược / Cấp độ thử thách -> Đặt cược Vàng (Coins).
2. **Table Assessment**: Quan sát cụm bi, phân tích góc phản xạ và đường bóng mục tiêu.
3. **Execution**: Chỉnh điểm chạm bi cái (Áp-phê xoáy) $\to$ Căn tia ngắm $\to$ Kéo thanh lực và nhả ngón tay.
4. **Instant Feedback**: Hiệu ứng va chạm âm thanh, tia sáng khi bi rơi vào lỗ, cảm giác bóng giật trô mượt mà.
5. **Outcome & Reward**: 
   - **Thắng**: Nhận gấp đôi tiền cược, Điểm kinh nghiệm (XP), Điểm Trophy tăng hạng, Rương phần thưởng (Chest).
   - **Thua**: Mất tiền cược, bảo toàn một phần XP động viên, kích thích tâm lý phục thù (Loss Aversion).

#### B. Meta Game Loop (Vòng lặp Ngày - Tiến Trình & Thu Thập)
Vòng lặp thúc đẩy cảm giác tiến bộ rõ rệt (Sense of Progression):
- Thắng ván nhận **Rương Báu** (yêu cầu thời gian 3h / 8h / 12h để mở).
- Mở rương thu thập **Mảnh Gậy Cơ (Cue Shards)** và **Vàng**.
- Nâng cấp gậy cơ yêu thích: Tăng độ dài tia ngắm, tăng lực đánh, tăng độ xoáy áp-phê.
- Đạt mốc Cup cao hơn để mở khóa các **Bàn Cược Thành Phố mới** với mức thưởng và độ khó cao hơn.

#### C. Retention Loop (Vòng lặp Giữ Chân D1, D7, D30)
- **D1 (Ngày hôm sau)**: Đăng nhập nhận thưởng chuỗi Daily Login; Rương 8 tiếng đã sẵn sàng mở; 1 lượt quay miễn phí **Lucky Shot**.
- **D7 (Tuần đầu tiên)**: Tham gia tổng kết Bảng xếp hạng tuần (Top 10 nhận thăng hạng League và Rương Vàng); Hoàn thành mốc nhiệm vụ Weekly Quests.
- **D30 (Tháng đầu tiên)**: Đạt mốc level 30 của Bida Pass; Mở khóa Gậy Huyền Thoại độc quyền của mùa giải; Đua top Clan / Hội Quán.

---

### 5.3. Hệ Thống Chế Độ Chơi Tạo Tính Chơi Lại Cao (Replayability)

Để ngăn ngừa cảm giác nhàm chán khi chỉ đánh 8 bóng thông thường, game xây dựng một hệ sinh thái 6 chế độ chơi chuyên biệt:

| Chế Độ Chơi | Mục Tiêu Chính | Yếu Tố Kích Thích Người Chơi | Cơ Chế Phần Thưởng |
| :--- | :--- | :--- | :--- |
| **1. Đấu Hạng 1v1 (Ranked Arena)** | Đua top thành phố, cược tiền, thăng hạng | Cạnh tranh PvP khốc liệt, tâm lý cược thắng lớn | Vàng x2, Trophy Points, Rương Đấu Trường |
| **2. Giải Đố Thế Bi (Trickshot Puzzles)** | Giải 100+ thế bi thế khó (bắn qua khe, 3 băng, trô giật) | Kích thích trí tuệ logic, vượt ải 3 sao | Sao thành tích, Mảnh gậy cơ Trickshot độc quyền |
| **3. Giải Đấu Cúp 8 Người (Knockout Cup)** | Đấu loại trực tiếp 3 vòng liên tiếp | Cảm giác vô địch kịch tính như giải eSports thật | Cúp Vô Địch danh giá, Rương Kim Cương |
| **4. Bida Siêu Tốc (Speed Pool / Rush)** | Dọn sạch bàn trong 60s, combo ăn bi liên tiếp | Nhịp độ cực nhanh, xả stress tức thì | Điểm Combo kỷ lục, Vé tham gia vòng quay VIP |
| **5. Khiêu Chiến Boss AI (Boss Master)** | Đấu với các AI có phong cách đánh đặc biệt | Thử thách vượt ngưỡng, học hỏi lối đánh hiểm | Skin bàn chơi độc lạ, Avatar vinh danh |
| **6. Giao Lưu Bạn Bè & Clan (Club Matches)** | So tài không mất phí cược, rèn luyện kỹ năng | Tính xã hội, thi thố với người quen | Điểm cống hiến Bang Hội, Huy hiệu tình bạn |

#### Chi tiết các chế độ độc đáo:
1. **Ranked City Arenas (Hệ thống Sàn Đấu Theo Cấp)**:
   - **Hà Nội Club** (Cược 100 Vàng) $\to$ **Sài Gòn Lounge** (Cược 500 Vàng) $\to$ **Tokyo Arena** (Cược 2,500 Vàng) $\to$ **Las Vegas Strip** (Cược 10,000 Vàng, áp dụng luật chỉ định lỗ khi đánh bi số 8) $\to$ **Monaco VIP** (Cược 50,000 Vàng, tắt tia ngắm - Pro Mode).
2. **Chế độ Trickshot (Thử Thách Thế Bi Huyền Thoại)**:
   - Hệ thống map phân tầng dạng bàn cờ (World Map).
   - Mỗi màn chơi đặt người chơi vào một tình thế ngặt nghèo: Ví dụ bi mục tiêu bị kẹt giữa 2 bi đối phương, yêu cầu người chơi phải áp-phê trô 2 băng hoặc nhảy bi (Jump shot) để ăn điểm.
   - Thang đánh giá 1 - 3 sao tạo động lực chơi lại để đạt điểm tuyệt đối.

---

### 5.4. Tính Năng & Hoạt Động Giữ Chân Người Chơi (Retention & Live-Ops)

Để người chơi có lý do mở game **ít nhất 3 - 5 lần mỗi ngày**:

#### 1. Mini-game "Cú Đánh Vàng" (Lucky Shot / Golden Shot)
- Mỗi ngày người chơi được **1 lượt bắn miễn phí**.
- Mặt bàn chỉ có 1 bi cái và 1 bi vàng cùng một hồng tâm đa tầng đồng tâm (Vàng $\to$ Đỏ $\to$ Xanh).
- Người chơi thực hiện đúng 1 cú đánh duy nhất để dừng bi vàng càng sát tâm càng tốt.
- Phần thưởng từ hồng tâm cực kỳ giá trị: Mảnh gậy Huyền Thoại, Kim Cương hoặc hàng chục nghìn Vàng.
- Có thể mua thêm vé lượt đánh vàng thứ 2 bằng Kim Cương hoặc xem video quảng cáo.

#### 2. Hệ Thống Rương Thời Gian (Chest Timer System)
- Người chơi có **4 slot chứa Rương**. Thắng trận sẽ nhận rương ngẫu nhiên:
  - **Rương Gỗ**: Mở sau 3 giờ (Chứa Vàng + Mảnh gậy Thường).
  - **Rương Bạc**: Mở sau 8 giờ (Chứa Vàng + Mảnh gậy Hiếm).
  - **Rương Vàng**: Mở sau 12 giờ (Chứa Mảnh gậy Sử Thi + Kim Cương).
  - **Rương Huyền Thoại**: Mở sau 24 giờ (Đảm bảo rơi gậy Huyền Thoại).
- *Hiệu ứng tâm lý*: Tạo trigger nhắc nhở người chơi quay lại game khi rương đã sẵn sàng mở.

#### 3. Chuỗi Thắng & Tinh Thần Bất Bại (Win Streak Multiplier)
- Thắng liên tiếp 2, 3, 5 trận sẽ kích hoạt hiệu ứng vệt sáng xung quanh Avatar.
- Phần thưởng nhân hệ số $1.2\times \to 1.5\times \to 2.0\times$ cho Vàng và XP.
- Kích thích người chơi tiếp tục chơi ván kế tiếp để không bị đứt chuỗi.

#### 4. Bida Pass (Battle Pass Mùa Giải - 30 Ngày)
- Gồm 2 nhánh: **Free Pass** (Mọi người chơi) và **VIP Pass** (Mở bằng Kim Cương / IAP).
- Tích lũy điểm Bida Pass thông qua việc ăn bi vào lỗ trong mọi chế độ chơi.
- Cấp 30 trao tặng: Gậy Cơ Giới Hạn Mùa (không thể mua được trong cửa hàng sau khi mùa giải kết thúc).

#### 5. Bảng Xếp Hạng Hàng Tuần (Weekly League Division)
- Phân bậc: **Đồng $\to$ Bạc $\to$ Vàng $\to$ Bạch Kim $\to$ Kim Cương $\to$ Thách Đấu**.
- Mỗi nhóm giải gồm 50 người chơi ngẫu nhiên cùng đẳng cấp.
- Thứ 2 hàng tuần: Top 10 người đứng đầu thăng hạng và nhận Rương Vàng lớn; Top 5 người cuối bảng bị tụt hạng.

---

### 5.5. Hệ Thống Shop Cửa Hàng & Nâng Cấp Gậy Cơ (Cue Mastery & Shop RPG)

Gậy cơ trong game không chỉ đơn thuần là vật phẩm ngoại trang (Skin) mà là **trọng tâm của hệ thống tiến trình RPG**. Game áp dụng cơ chế kép: **Người chơi phải cày đạt mốc cấp độ (Level-Gated)** để mở khóa quyền mua trong Cửa Hàng, sau đó **chi trả một lượng tiền tệ nhất định (Vàng / Kim Cương)** để sở hữu. Mỗi cây cơ sở hữu bộ chỉ số riêng biệt và **càng nâng lên cấp cao thì chỉ số và hiệu ứng càng trở nên uy lực**.

#### 1. Cơ Chế Mở Khóa Shop Theo Cấp Độ (Player Level Milestone)
Nhằm tạo động lực cày cuốc (Grind Motivation) bền bỉ và ngăn chặn tình trạng Pay-to-Win cực đoan ngay từ đầu:
- **Level Requirement**: Người chơi cần tích lũy điểm kinh nghiệm (XP) qua các ván đấu PvP, vượt ải Trickshot và làm nhiệm vụ để thăng cấp tài khoản (Cấp 1 $\to$ 100).
- Mỗi mốc Level sẽ **mở khóa (Unlock Slot)** một cây cơ hoặc skin mới trong Shop. Khi chưa đủ cấp, vật phẩm sẽ hiển thị ở trạng thái **Khóa (Locked)** kèm thông tin: *"Cần đạt Cấp độ X để mở mua"*.
- **Mua Bằng Tiền Tệ Tương Xứng**: Sau khi đạt cấp độ yêu cầu, người chơi sử dụng **Vàng (Gold)** cày được hoặc **Kim Cương (Diamond)** để mua đứt cây cơ vào kho đồ cá nhân.

#### 2. Hệ Thống 4 Chỉ Số Riêng Biệt Cho Từng Cây Cơ
Mỗi cây cơ có bảng chỉ số cơ bản (Base Stats) và trần phát triển tối đa (Max Stats) hoàn toàn khác nhau:
1. **Force (Lực đánh)**: Gia tăng vận tốc tối đa của bi khi bắn hết lực (hỗ trợ phá bi khai cuộc uy lực và các cú đánh dội băng tầm xa).
2. **Aim (Độ dài tia ngắm)**: Kéo dài tia laser dẫn hướng hỗ trợ ngắm, giúp người chơi dễ dàng căn góc bi mục tiêu ở khoảng cách xa qua mép bàn.
3. **Spin (Độ nhạy Áp-phê)**: Tăng biên độ lực xoáy Cu-lê (đẩy tới), Trô bóng (giật lùi) và biến thiên góc nảy khi bi va vào băng nỉ.
4. **Time (Thời gian suy nghĩ)**: Cộng thêm từ **+2s đến +8s** đếm ngược trong lượt đánh, cực kỳ quý giá ở các ván đấu cược cao và tình huống thế bi phức tạp.

#### 3. Cơ Chế Càng Lên Cấp Càng Mạnh (Cue Upgrade System: Lv.1 ➔ Lv.10)
Sau khi mua gậy từ Shop, người chơi có thể tiếp tục đầu tư nâng cấp cây cơ đó lên tối đa **Cấp 10 (Max Mastery Level)**:
- **Nguyên liệu thăng cấp**: Yêu cầu thu thập **Mảnh Thẻ Cơ (Cue Shards)** (nhận từ mở Rương báu, chuỗi thắng, shop thẻ luân phiên) + **Vàng nâng cấp** (chi phí vàng tăng dần theo cấp độ).
- **Tiến trình tăng tiến sức mạnh (Stat Scaling)**:
  - *Lv. 1 - 3 (Sơ cấp)*: Tăng nhẹ lực đánh và kéo dài thêm một đoạn tia ngắm cơ bản.
  - *Lv. 4 - 7 (Trung cấp)*: Mở rộng đáng kể độ nhạy áp-phê và cộng thêm thời gian suy nghĩ mỗi lượt.
  - *Lv. 8 - 10 (Thần thánh)*: Đạt đỉnh trần chỉ số, mở khóa **Nội Tại Bị Động Đặc Biệt (Unique Passive Perk)** và **Hiệu ứng Hình ảnh Hào quang (VFX Aura)**.

#### 4. Bảng Mẫu Gậy Cơ Tiêu Biểu Trong Cửa Hàng (Shop Showcase)

| Tên Gậy Cơ | Phẩm Cấp | Cấp Yêu Cầu | Giá Mua Shop | Chỉ Số Ban Đầu (Lv.1)<br>`[Lực / Ngắm / Xoáy / Giờ]` | Chỉ Số Tối Đa (Lv.10)<br>`[Lực / Ngắm / Xoáy / Giờ]` | Kỹ Năng / Nội Tại Khi Đạt Lv.10 |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **Gậy Gỗ Tân Thủ** *(Standard)* | ⚪ Common | **Lv. 1** | *Miễn phí* | `2 / 2 / 1 / 1` | `4 / 4 / 3 / 2` | Không có nội tại (Dành cho tân thủ làm quen) |
| **Cơ Titan Thép** *(Titan Striker)* | ⚪ Common | **Lv. 5** | 3,000 Vàng | `4 / 3 / 2 / 2` | `7 / 5 / 4 / 4` | **Heavy Break**: Tăng +15% lực phá bi khai cuộc |
| **Cơ Băng Phong** *(Frostbite)* | 🔵 Rare | **Lv. 12** | 18,000 Vàng | `5 / 5 / 4 / 3` | `8 / 8 / 7 / 6` | **Ice Aim**: Làm chậm 20% tốc độ dao động thanh đo lực |
| **Cơ Kim Ngưu** *(Golden Bull)* | 🔵 Rare | **Lv. 22** | 50,000 Vàng | `6 / 5 / 5 / 4` | `9 / 8 / 8 / 6` | **Jackpot Touch**: Thưởng thêm +10% Vàng khi thắng trận |
| **Cơ Cyberpunk Neo** *(Neon Vector)*| 🟣 Epic | **Lv. 35** | 150,000 Vàng | `7 / 7 / 6 / 5` | `11 / 11 / 10 / 8` | **Laser Line**: Tia ngắm bi cái và bi mục tiêu hiển thị sáng gấp đôi |
| **Cơ Hỏa Phụng** *(Phoenix Flame)* | 🟣 Epic | **Lv. 48** | 450 Kim Cương | `8 / 8 / 8 / 6` | `12 / 12 / 12 / 9` | **Inferno Spin**: Độ giật trô bóng tăng vọt +25% khoảng cách lùi |
| **Cơ Đế Vương Rồng Vàng** *(Dragon)*| 🟡 Legendary| **Lv. 60** | 1,500 Kim Cương| `10 / 10 / 9 / 8` | `15 / 15 / 15 / 12` | **Dragon Heart**: Hoàn lại 50% tiền cược nếu thua; Vệt lửa bay quanh bi |

> [!TIP]
> **Chiến Lược Cân Bằng Gameplay**:
> Mặc dù gậy cấp cao có tia ngắm dài và lực bắn tốt hơn, yếu tố quyết định thắng thua trong ván đấu vẫn dựa trên **óc quan sát hình học và khả năng điều bi của người chơi**. Tại các phòng thi đấu đỉnh cao (như Monaco VIP), hệ thống sẽ tắt bỏ hoàn toàn tia ngắm (Pro Mode), buộc các cơ thủ phải dựa vào trực giác và kỹ năng thực tế.

#### 5. Hiệu Ứng Ngoại Trang & Âm Thanh Càng Lên Cao Càng Đẹp (Visual & Audio Feedback)
- **Cấp 1 - 4**: Giữ thiết kế mộc nguyên bản của gậy.
- **Cấp 5 - 7**: Xuất hiện các xung điện/năng lượng ánh sáng chạy dọc sống gậy mỗi khi kéo thanh lực.
- **Cấp 8 - 9**: Kích hoạt **Vệt Khói / Ánh Sáng Chạy Theo Bóng (Ball Trail)** khi bi cái di chuyển (vệt băng tuyết, vệt laser neon, vệt tia lửa đỏ).
- **Cấp 10 (Mastery)**: Toàn thân gậy phát hào quang rực rỡ, kèm hiệu ứng **Nổ Lỗ Bida Độc Quyền (Custom Pocket VFX & SFX)** khi đưa bi mục tiêu thành công vào lỗ.

---

### 5.6. Kinh Tế Trong Game (In-Game Economy)

Để duy trì tính công bằng và cân bằng lâu dài:

```
[NGUỒN THU CỦA NGƯỜI CHƠI (SOURCES)]
├── Thắng trận PvP / Tournaments
├── Mở Rương Thời Gian (Chests)
├── Hoàn thành Nhiệm Vụ Ngày & Thành Tựu
├── Vòng Quay Lucky Shot & Daily Free Coin
└── Bida Pass Milestones
                 │
                 ▼
       [HỆ THỐNG TIỀN TỆ]
       ├── Vàng (Soft Currency): Dùng để đặt cược, nâng cấp gậy
       ├── Kim Cương (Hard Currency): Dùng để mở rương ngay, mua VIP Pass
       └── Mảnh Gậy (Cue Shards): Dùng để ghép và nâng cấp gậy
                 │
                 ▼
[CƠ CHẾ TIÊU THỤ & CHỐNG LẠM PHÁT (SINKS)]
├── Phí xâu bàn cược (Rake Fee 10% mỗi ván thắng)
├── Phí nâng cấp cấp độ Gậy Cơ (Upgrade Fee tăng theo level)
├── Phí nạp năng lượng gậy (Recharge cue sau số ván nhất định)
└── Mua phụ kiện (Skin nỉ bàn, khung Avatar, Sticker chat)
```

---

## 🗺️ LỘ TRÌNH PHÁT TRIỂN (PRODUCT ROADMAP)

Lộ trình phát triển được chia làm 5 giai đoạn chiến lược, từ hoàn thiện trải nghiệm cốt lõi đến mở rộng mạng lưới Online Realtime và cộng đồng:

```
[Giai Đoạn 1: Core Engine]  ===>  [Giai Đoạn 2: Meta & RPG]  ===>  [Giai Đoạn 3: Online Realtime]
     (ĐÃ HOÀN THIỆN)                (TRỌNG TÂM KẾ TIẾP)                  (QUÝ 3/2026)
  - Vật lý Box2D chuẩn xác        - Hệ thống Gậy Cơ & Stats           - WebSocket Realtime 1v1
  - Áp-phê, Cu-lê, Trô bóng       - Rương Thưởng & Nhiệm Vụ           - Phòng Đấu Cược Thành Phố
  - Bot AI Dễ & Khó               - Chế độ Trickshot Puzzles          - Hệ thống Elo & Anti-Cheat
  - Responsive Mọi Màn Hình       - Shop & Hệ Thống Kinh Tế           - Chat Emoji & Voice Note

                                        ||
                                        \/
[Giai Đoạn 5: Esports & Mở Rộng] <=== [Giai Đoạn 4: Live-Ops & Guild]
        (QUÝ 1/2027)                             (QUÝ 4/2026)
  - Chế độ 9-Ball & Snooker Mini        - Giải Đấu Cúp 8 Người (Tournaments)
  - Pro Mode (Tắt hoàn toàn tia ngắm)   - Bida Pass (Battle Pass 30 Ngày)
  - Cross-platform PC / Web             - Hội Quán / Bang Hội (Club Wars)
  - Giải đấu tranh cúp Mùa Giải         - Sự Kiện Giới Hạn Cuối Tuần
```

### Chi Tiết Kế Hoạch Từng Giai Đoạn:

#### 📍 Giai Đoạn 1: Nền Tảng Cốt Lõi (Core Engine & Polish) — *[Đã Hoàn Thành]*
- [x] Tích hợp engine vật lý Forge2D / Box2D: Va chạm bi - bi, bi - băng bàn chuẩn xác.
- [x] Cơ chế Áp-phê (Spin Control): Cu-lê đẩy tới, Trô giật lùi, xoáy nảy góc băng.
- [x] Hệ thống thanh kéo lực tương tác mượt mà, chuyển màu năng lượng.
- [x] Bộ luật 8-Ball hoàn chỉnh: Chia bi Trơn/Sọc, Foul, Quyền đặt bi tự do (Ball-in-Hand), Điều kiện thắng/thua với Bi số 8.
- [x] AI Bot 2 cấp độ: Dễ (giải trí) và Khó (tính toán hình học, tự né phạm lỗi).
- [x] UI Responsive tự động co giãn theo tỷ lệ màn hình điện thoại.

#### 📍 Giai Đoạn 2: Meta-Game, Hệ Thống Gậy & Giải Đố (Single-Player Depth) — *[Ưu Tiên Triển Khai]*
- [ ] **Hệ thống Shop Cửa Hàng & Mở Khóa Gậy Theo Cấp (Level-Gated Cue Shop)**:
  - Cơ chế cày cấp độ (Grind Level) để mở khóa quyền mua gậy trong Shop bằng Vàng/Kim Cương.
  - Thiết kế 20+ mẫu gậy cơ với 4 chỉ số riêng biệt (Force, Aim, Spin, Time) và nội tại đặc biệt.
  - Hệ thống thăng cấp gậy (Level 1 $\to$ Level 10): Càng lên cấp cao chỉ số càng mạnh, mở khóa vệt sáng bóng (Ball Trail) và hào quang độc quyền.
- [ ] **Chế độ Thử Thách Thế Bi (Trickshot Puzzles)**:
  - Xây dựng 60 màn chơi thế bi từ cơ bản đến nâng cao.
  - Tính điểm sao và mở khóa phần thưởng.
- [ ] **Vòng lặp kinh tế cơ bản (Economy & Progression)**:
  - Hệ thống tích lũy Vàng, Rương thưởng sau chiến thắng.
  - Hệ thống Nhiệm Vụ Hàng Ngày (Daily Quests).
  - Vòng quay may mắn (Daily Spin) & Cú đánh vàng (Lucky Shot).

#### 📍 Giai Đoạn 3: Đấu Mạng Thời Gian Thực (Online Realtime Multiplayer)
- [ ] Xây dựng Server Realtime (sử dụng WebSocket / Nakama / Supabase / Node.js).
- [ ] Cơ chế Matchmaking 1v1 tự động ghép cặp người chơi theo điểm kỹ năng Elo.
- [ ] Đồng bộ hóa trạng thái vật lý giữa 2 máy khách với độ trễ thấp (<80ms).
- [ ] Hệ thống Bàn Cược theo Thành Phố (Hà Nội, Sài Gòn, Las Vegas...).
- [ ] Tích hợp hệ thống Chat nhanh, Emoji hoạt hình chọc tức đối thủ.
- [ ] Cơ chế chống gian lận (Anti-Cheat Server-side Validation).

#### 📍 Giai Đoạn 4: Giải Đấu, Bang Hội & Vận Hành Trực Tuyến (Live-Ops & Social)
- [ ] **Giải Đấu Cúp 8 Người (8-Player Knockout Cup)**:
  - Cây thi đấu loại trực tiếp 3 vòng, hiển thị bảng đấu trực quan.
- [ ] **Bida Pass Mùa Giải**:
  - Chu kỳ 30 ngày với chuỗi nhiệm vụ và phần thưởng độc quyền.
- [ ] **Hệ thống Hội Quán (Pool Clubs / Clans)**:
  - Lập bang hội cùng bạn bè, đóng góp điểm cúp nâng cấp Club.
  - Giao hữu nội bộ không mất tiền cược.
- [ ] **Sự kiện cuối tuần (Weekend Events)**:
  - Nhân đôi Vàng bàn cược, Thử thách đánh không tia ngắm.

#### 📍 Giai Đoạn 5: Đa Nền Tảng & Esports Mở Rộng
- [ ] Hỗ trợ thêm các thể thức thi đấu mới: **9-Ball Pool** và **Bida Carom / 3 Băng mini**.
- [ ] Xuất bản bản build mượt mà trên trình duyệt Web (HTML5 Canvas) và Windows/macOS.
- [ ] Chế độ Khán Giả (Spectator Mode) phục vụ livestream và các giải đấu eSports cộng đồng.
- [ ] Tối ưu hóa dung lượng cài đặt (<50MB) và thời gian tải game tức thì.
