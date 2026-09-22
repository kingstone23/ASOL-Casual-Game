# 🎱 Game Bida 8 Bóng 2D (Billiard 8-Ball)

Game Bida 8 Bóng (8-Ball Pool) phong cách hiện đại, trực quan, hỗ trợ chơi 2 người trên cùng thiết bị hoặc so tài với máy (CPU Bot). Trò chơi được tối ưu hóa giao diện xoay ngang, tự động vừa vặn trên mọi dòng điện thoại thông minh từ nhỏ đến lớn.

---

## 🛠️ Công Nghệ Sử Dụng

Dự án được xây dựng trên nền tảng công nghệ đa nền tảng hiện đại, đảm bảo hiệu năng cao và chuyển động mượt mà:

- **Flutter**: Bộ công cụ phát triển giao diện người dùng đa nền tảng hàng đầu của Google, giúp game chạy mượt trên Android, iOS, Web và Desktop.
- **Flame Game Engine**: Engine game 2D chuyên dụng cho Flutter, quản lý vòng lặp game (game loop), thời gian thực và kết xuất hình ảnh 60 FPS ổn định.
- **Forge2D (Box2D Physics Engine)**: Động cơ vật lý tiêu chuẩn quốc tế mô phỏng chân thực va chạm cơ học, góc nảy băng, ma sát lăn mặt nỉ và lực quán tính của bi.
- **Đồ họa Vector Thuần (CustomPaint)**: Cây cơ trên thanh lực và hệ thống ngắm bắn được vẽ trực tiếp bằng vector, đảm bảo độ nét tuyệt đối trên mọi độ phân giải màn hình mà không lo giật lag hay lỗi tải ảnh.

---

## 🌟 Tính Năng Nổi Bật

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
