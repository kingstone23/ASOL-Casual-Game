# Bida Game 2D

Game bida 8 bóng dành cho 2 người chơi trên cùng một thiết bị. Game được làm bằng Flutter, Flame và Forge2D.

## Tính năng

- Chơi 2 người theo lượt.
- Bàn bida hiển thị ngang, phù hợp với điện thoại.
- Điều khiển bằng cảm ứng hoặc chuột.
- Kéo trên bàn để ngắm hướng đánh.
- Kéo thanh lực bên trái xuống để tăng lực, thả ra để đánh.
- Có đường ngắm và dự đoán hướng bi.
- Bi có va chạm, nảy băng và ma sát giống chuyển động trên bàn bida.
- Có 6 lỗ bida.
- Có luật bi trơn, bi sọc, bi số 8 và foul.
- Có chế độ di chuyển bi cái tự do khi bị `Ball in hand`.
- Có nút cài đặt để bắt đầu lại trận đấu.

## Luật chơi chính

- Bi số 1 đến 7 là **bi trơn**.
- Bi số 9 đến 15 là **bi sọc**.
- Bi số 8 là bi cuối cùng cần đánh.
- Sau khi chia nhóm, mỗi người chỉ được đánh nhóm bi của mình.
- Đánh đúng bi và đưa bi vào lỗ thì được đánh tiếp.
- Không đưa bi hợp lệ vào lỗ hoặc đánh sai nhóm thì đổi lượt.
- Đánh bi cái vào lỗ sẽ bị foul và người chơi tiếp theo được đặt bi cái tự do.
- Đánh bi số 8 quá sớm sẽ thua.
- Đánh bi số 8 sau khi dọn hết nhóm của mình sẽ thắng.

## Cách chơi

1. Kéo ngón tay trên bàn để chọn hướng cây cơ.
2. Kéo thanh lực bên trái xuống để tăng lực.
3. Thả thanh lực để đánh.
4. Nếu được `Ball in hand`, chạm vào bi cái và kéo đến vị trí mong muốn rồi thả ra.
5. Nhấn nút bánh răng để bắt đầu lại trận đấu.

## Cài đặt và chạy

### Yêu cầu

- Flutter SDK.
- Android Studio nếu chạy Android.
- Xcode và macOS nếu chạy iOS.

## Tài nguyên chính

- `lib/main.dart`: mã nguồn game.
- `assets/images/`: hình bàn, bi và cây cơ.
- `pubspec.yaml`: thư viện và tài nguyên của project.

## Giới hạn hiện tại

- Chưa có âm thanh.
- Chưa có chơi online.
- Chưa có đối thủ máy.
- Một số luật thi đấu chuyên nghiệp chưa được mô phỏng đầy đủ.

## Hướng phát triển

- Thêm âm thanh và hiệu ứng.
- Thêm chế độ chơi với máy.
- Thêm chơi online.
- Thêm hiệu ứng xoáy bi.
- Cải thiện giao diện và luật thi đấu.
