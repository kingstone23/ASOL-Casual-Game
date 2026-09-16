# 8-Ball Pool 2D - Flutter & Flame Forge2D Game

Một tựa game bida 8 bóng (8-Ball Pool) chuyên nghiệp được phát triển bằng Flutter và sử dụng động cơ vật lý 2D Flame (Forge2D / Box2D). Đồ án tập trung tái hiện chân thực các định luật vật lý va chạm cơ học, hệ thống ngắm bắn dự đoán đường đi (bao gồm cả A-băng và khúc xạ bi), chế độ chơi 2 người trên cùng một thiết bị (Local 2-Player Turn-based) với giao diện tối giản, hiện đại.

## Các Tính Năng Nổi Bật

### 1. Mô phỏng Vật lý Chuyên nghiệp (Physics Engine)
- Động cơ Box2D (Forge2D): Xây dựng trên nền tảng vật lý tính toán gia tốc, lực ma sát nỉ (linearDamping), độ đàn hồi va chạm (restitution) và hệ số khối lượng (density) của bi.
- Động lực học va chạm: Phân biệt chính xác giữa va chạm băng bàn (phản xạ gương góc tới bằng góc phản xạ) và va chạm bi-bi (truyền động lượng theo đường pháp tuyến và trượt theo đường tiếp tuyến).

### 2. Hệ Thống Ngắm Bắn & Dự Đoán Thông Minh (Advanced Aiming & Raycasting)
- Raycast Prediction: Sử dụng thuật toán phóng tia (RayCastCallback) để quét trước đường đi của bi cái trong môi trường vật lý.
- Đường ngắm A-Băng (Bank Shot Prediction): Tự động tính toán góc nảy khi bi cái chuẩn bị đập vào băng bàn.
- Điểm báo va chạm: Hiển thị điểm tiếp xúc trực quan trên thân bi mục tiêu kèm theo hướng văng của bi cái sau khi truyền động lực.

### 3. Cơ Chế Lượt Chơi & Luật Chơi 2 Người (Local Multiplayer Turn-Based)
- Hệ thống quản lý lượt chơi luân phiên giữa Player 1 và Player 2 sử dụng ValueNotifier kết nối trực tiếp mô hình game với giao diện UI ngoài bàn.
- Cơ chế cảm biến lỗ bida (Sensors & Pockets) tự động nhận diện khi bi rơi xuống 6 lỗ, tự động xóa bi mục tiêu khỏi bàn và xử lý phạt khi bi cái lọt lỗ.

### 4. Đồ Họa & Tối Ưu Trải Nghiệm (Game Feel)
- Tỷ lệ khung hình chuẩn bàn bida: Thiết kế giao diện ngang (Landscape Mode) tối ưu hóa không gian hiển thị trên cả Web, Desktop và Mobile.
- Sprite-based Rendering: Hỗ trợ hiển thị hình ảnh chi tiết của mặt bàn vân gỗ và bộ 15 bi màu sắc nét, kết hợp cơ chế khóa/mở góc xoay giúp hình ảnh con số luôn trực quan.

## Công Nghệ Sử Dụng

- Framework: Flutter (Dart)
- Game Engine: Flame Engine
- Physics Engine: Flame Forge2D (Port của Box2D)
- State Management: Flutter ValueNotifier & Flame Lifecycle hooks.

## Cấu Trúc Thư Mục Dự Án

bida_game/
│
├── assets/
│   └── images/
│       ├── pool_table.png      # Hình nền mặt bàn bida
│       ├── cue_ball.png        # Hình ảnh bi cái (bi trắng)
│       ├── cue_stick.png       # Hình ảnh cơ bida (tùy chọn)
│       └── ball_1.png ... ball_15.png  # Hình ảnh 15 bi mục tiêu
│
├── lib/
│   └── main.dart               # Mã nguồn chính (Game logic, Physics, UI, Raycasting)
│
├── pubspec.yaml                # Cấu hình assets và dependencies
└── README.md                   # Tài liệu mô tả đồ án

## Hướng Dẫn Cài Đặt & Chạy Trò Chơi

Đảm bảo bạn đã cài đặt sẵn môi trường Flutter SDK trên máy tính.

1. Clone hoặc tải mã nguồn về máy:
   cd bida_game

2. Cài đặt các thư viện phụ thuộc:
   flutter pub get

3. Chạy ứng dụng (Hỗ trợ Chrome, Desktop hoặc Mobile):
   - Chạy trên trình duyệt Chrome:
     flutter run -d chrome
   - Chạy trên thiết bị Desktop (Windows/macOS/Linux):
     flutter run -d windows

## Hướng Dẫn Cách Chơi

1. Ngắm bắn: Nhấn giữ chuột (hoặc chạm tay) vào khu vực gần bi cái, kéo ngược về phía sau giống như hành động kéo gậy bida lấy đà.
2. Quan sát: Theo dõi đường ray trắng (đường ngắm chính) và đường ray vàng (đường dự đoán A-băng hoặc hướng bi trượt) để canh góc chính xác.
3. Đánh bóng: Thả tay ra để thực hiện cú đánh. Lực đánh sẽ phụ thuộc vào khoảng cách bạn kéo gậy.
4. Chuyển lượt: Sau mỗi cú đánh kết thúc, hệ thống sẽ tự động chuyển đổi lượt chơi giữa Player 1 (Xanh) và Player 2 (Đỏ).
5. Mục tiêu: Đưa các viên bi mục tiêu rơi vào 1 trong 6 lỗ bida trên bàn để giành chiến thắng.

## Hướng Phát Triển Tương Lai (Roadmap)
- [ ] Bổ sung âm thanh va chạm chân thực (Sound Effects) khi bi chạm băng, chạm bi và rơi xuống lỗ.
- [ ] Hoàn thiện luật chơi chuẩn 8-ball (Phân chia bi sọc / bi trơn cho từng người sau cú đánh khai cuộc - Break shot).
- [ ] Thêm chế độ chơi với máy (AI Opponent) sử dụng thuật toán Minimax cơ bản.

Phát triển bởi Bảo - Đồ án lập trình game sinh viên năm 4.