import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../services/online_multiplayer_service.dart';

class OnlineMultiplayerDialog extends StatefulWidget {
  final void Function(String roomId, bool isHost) onConnected;

  const OnlineMultiplayerDialog({super.key, required this.onConnected});

  @override
  State<OnlineMultiplayerDialog> createState() => _OnlineMultiplayerDialogState();
}

class _OnlineMultiplayerDialogState extends State<OnlineMultiplayerDialog> {
  late final TextEditingController _serverController;
  final TextEditingController _roomPinController = TextEditingController();
  bool _isConnecting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    String defaultUrl = 'ws://127.0.0.1:8080';
    if (!kIsWeb && Platform.isAndroid) {
      defaultUrl = 'ws://10.0.2.2:8080';
    }
    _serverController = TextEditingController(text: defaultUrl);

    final service = OnlineMultiplayerService.instance;
    service.onMatchStart = (roomId, isHost) {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onConnected(roomId, isHost);
      }
    };
  }

  @override
  void dispose() {
    _serverController.dispose();
    _roomPinController.dispose();
    super.dispose();
  }

  Future<void> _ensureConnected() async {
    final service = OnlineMultiplayerService.instance;
    if (service.isConnected) return;

    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    final success = await service.connect(url: _serverController.text.trim());
    if (mounted) {
      setState(() {
        _isConnecting = false;
        if (!success) {
          _errorMessage = 'Không thể kết nối đến máy chủ WebSocket!\n'
              '• Nếu chạy trên Windows: Chọn "Máy này (127.0.0.1)"\n'
              '• Nếu chạy trên Giả lập Android: Chọn "Giả lập Android (10.0.2.2)"\n'
              '• Nếu chạy trên Điện thoại qua Wi-Fi: Chọn "Wi-Fi LAN (192.168.1.22)"\n'
              '• Server hiện đã được khởi động sẵn trên cổng 8080.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 700;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 32,
        vertical: isMobile ? 12 : 24,
      ),
      child: Container(
        width: 720,
        decoration: BoxDecoration(
          color: const Color(0xFF0F1E19),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF00B0FF), width: 1.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.85),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ListenableBuilder(
          listenable: OnlineMultiplayerService.instance,
          builder: (context, _) {
            final service = OnlineMultiplayerService.instance;

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Header
                  _buildHeader(context),

                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Server URL Configuration
                        _buildServerConfig(service),
                        const SizedBox(height: 14),

                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade900.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.redAccent),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],

                        // Main Action Cards (3 Chế Độ: Ghép Tự Động, Tạo Phòng PIN, Nhập PIN)
                        if (service.connectionState == OnlineConnectionState.findingMatch) ...[
                          _buildMatchmakingWaiting(service),
                        ] else if (service.connectionState == OnlineConnectionState.waitingInRoom) ...[
                          _buildWaitingInRoom(service),
                        ] else ...[
                          _buildOnlineModes(service),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF142B24),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(bottom: BorderSide(color: Color(0xFF00B0FF), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF00B0FF), Color(0xFF0081CB)],
              ),
            ),
            child: const Icon(Icons.public, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ĐẤU ONLINE TOÀN CẦU (WEBSOCKET)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  'Ghép trận ngẫu nhiên hoặc tạo phòng riêng với bạn bè qua Internet',
                  style: TextStyle(color: Color(0xFF80D8FF), fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white70),
            tooltip: 'Đóng',
          ),
        ],
      ),
    );
  }

  Widget _buildServerConfig(OnlineMultiplayerService service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                service.isConnected ? Icons.cloud_done : Icons.cloud_queue,
                color: service.isConnected ? const Color(0xFF00E676) : Colors.orangeAccent,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _serverController,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: 'Nhập địa chỉ máy chủ (ws:// hoặc wss://)',
                    hintStyle: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isConnecting
                    ? null
                    : () async {
                        if (service.isConnected) {
                          await service.disconnect();
                        } else {
                          await _ensureConnected();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: service.isConnected ? const Color(0xFFC62828) : const Color(0xFF00B0FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isConnecting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        service.isConnected ? 'Ngắt Kết Nối' : 'Kết Nối',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Chọn nhanh:',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
              _buildPresetChip('Máy này (127.0.0.1)', 'ws://127.0.0.1:8080'),
              _buildPresetChip('Giả lập Android (10.0.2.2)', 'ws://10.0.2.2:8080'),
              _buildPresetChip('Wi-Fi LAN (192.168.1.22)', 'ws://192.168.1.22:8080'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, String url) {
    final isSelected = _serverController.text.trim() == url;
    return InkWell(
      onTap: () {
        setState(() {
          _serverController.text = url;
          _errorMessage = null;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00B0FF).withValues(alpha: 0.25) : Colors.white10,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF00B0FF) : Colors.white24,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF80D8FF) : Colors.white70,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineModes(OnlineMultiplayerService service) {
    return Column(
      children: [
        // Mode 1: Ghép Trận Nhanh (Quick Match)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF42A5F5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.flash_on, color: Color(0xFFFFD54F), size: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TÌM TRẬN NHANH 1V1 (AUTO MATCHMAKING)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tự động ghép cặp với cơ thủ khác đang online',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _ensureConnected();
                  if (service.isConnected) {
                    service.startQuickMatch();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD54F),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('TÌM TRẬN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Mode 2 & 3: Tạo Phòng PIN & Nhập Mã PIN
        Row(
          children: [
            // Tạo Phòng PIN (Host)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF132F24),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00E676)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.add_circle, color: Color(0xFF00E676), size: 30),
                    const SizedBox(height: 6),
                    const Text(
                      'TẠO PHÒNG MỚI',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Nhận mã PIN 6 số cho bạn bè',
                      style: TextStyle(color: Colors.white60, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        await _ensureConnected();
                        if (service.isConnected) {
                          service.createRoom();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('MỞ PHÒNG', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Nhập Mã PIN (Join)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2B36),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00B0FF)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.login, color: Color(0xFF00B0FF), size: 30),
                    const SizedBox(height: 6),
                    const Text(
                      'NHẬP MÃ PHÒNG',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _roomPinController,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Mã PIN 6 số',
                          hintStyle: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final pin = _roomPinController.text.trim();
                        if (pin.isEmpty) return;
                        await _ensureConnected();
                        if (service.isConnected) {
                          service.joinRoom(pin);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B0FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('VÀO PHÒNG', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMatchmakingWaiting(OnlineMultiplayerService service) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD54F)),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(color: Color(0xFFFFD54F), strokeWidth: 3),
          ),
          const SizedBox(height: 14),
          const Text(
            'ĐANG TÌM ĐỐI THỦ XỨNG TẦM...',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'Hệ thống đang kết nối bạn với cơ thủ trực tuyến khác',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              service.cancelQuickMatch();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
            ),
            child: const Text('HỦY TÌM TRẬN', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingInRoom(OnlineMultiplayerService service) {
    final roomId = service.currentRoomId ?? '------';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF132F24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF00E676)),
      ),
      child: Column(
        children: [
          const Text(
            'PHÒNG ĐÃ SẴN SÀNG!',
            style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.w900, fontSize: 15),
          ),
          const SizedBox(height: 6),
          const Text(
            'Chia sẻ mã PIN dưới đây cho đối thủ để cùng vào bàn đấu:',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
            ),
            child: Text(
              roomId,
              style: const TextStyle(
                color: Color(0xFFFFD54F),
                fontWeight: FontWeight.w900,
                fontSize: 28,
                letterSpacing: 4.0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(color: Colors.tealAccent, strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text(
                'Đang chờ đối thủ nhập mã...',
                style: TextStyle(color: Colors.tealAccent, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () {
              service.disconnect();
            },
            child: const Text('Hủy & Rời Phòng', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
