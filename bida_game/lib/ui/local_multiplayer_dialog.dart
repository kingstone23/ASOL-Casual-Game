import 'package:flutter/material.dart';
import '../services/local_multiplayer_service.dart';

class LocalMultiplayerDialog extends StatefulWidget {
  final VoidCallback onConnected;

  const LocalMultiplayerDialog({super.key, required this.onConnected});

  @override
  State<LocalMultiplayerDialog> createState() => _LocalMultiplayerDialogState();
}

class _LocalMultiplayerDialogState extends State<LocalMultiplayerDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _ipController = TextEditingController();
  bool _isActionInProgress = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    LocalMultiplayerService.instance.getLocalIpAddress().then((ip) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _startHosting() async {
    setState(() {
      _isActionInProgress = true;
      _errorMessage = null;
    });

    final success = await LocalMultiplayerService.instance.startHosting();
    if (!mounted) return;

    setState(() {
      _isActionInProgress = false;
    });

    if (!success) {
      setState(() {
        _errorMessage = 'Không thể mở phòng. Vui lòng kiểm tra kết nối WiFi!';
      });
    }
  }

  Future<void> _connectToHost() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập địa chỉ IP của máy tạo phòng!';
      });
      return;
    }

    setState(() {
      _isActionInProgress = true;
      _errorMessage = null;
    });

    final success = await LocalMultiplayerService.instance.connectToHost(ip);
    if (!mounted) return;

    setState(() {
      _isActionInProgress = false;
    });

    if (success) {
      Navigator.of(context).pop();
      widget.onConnected();
    } else {
      setState(() {
        _errorMessage = 'Không tìm thấy phòng ở IP $ip. Hãy đảm bảo 2 máy chung 1 WiFi hoặc 1 máy bật Hotspot!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: ListenableBuilder(
        listenable: LocalMultiplayerService.instance,
        builder: (context, _) {
          final service = LocalMultiplayerService.instance;

          // Nếu máy Host đã có đối thủ kết nối -> tự động đóng dialog vào game
          if (service.isConnected && service.isHost) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.of(context).pop();
                widget.onConnected();
              }
            });
          }

          return Container(
            constraints: const BoxConstraints(maxWidth: 580, maxHeight: 460),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D1B2A), Color(0xFF1B2838), Color(0xFF09131D)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF1E88E5).withValues(alpha: 0.6),
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black87, blurRadius: 25),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Column(
                children: [
                  // --- HEADER ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    color: const Color(0xFF070F18),
                    child: Row(
                      children: [
                        const Icon(Icons.wifi, color: Color(0xFF42A5F5), size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          'ĐẤU MẠNG CỤC BỘ (WIFI / HOTSPOT)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            service.disconnect();
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.close, color: Colors.white70),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  // TAB BAR
                  TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFF00E5FF),
                    labelColor: const Color(0xFF00E5FF),
                    unselectedLabelColor: Colors.white54,
                    tabs: const [
                      Tab(icon: Icon(Icons.hub), text: 'TẠO PHÒNG (HOST)'),
                      Tab(icon: Icon(Icons.login), text: 'VÀO PHÒNG (JOIN)'),
                    ],
                  ),

                  // TAB CONTENT
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // TAB 1: TẠO PHÒNG
                        _buildHostTab(service),

                        // TAB 2: VÀO PHÒNG
                        _buildJoinTab(service),
                      ],
                    ),
                  ),

                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      color: Colors.red.shade900.withValues(alpha: 0.8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHostTab(LocalMultiplayerService service) {
    final isHosting = service.connectionState == MultiplayerConnectionState.hosting;
    final myIp = service.localIp ?? 'Đang tải IP...';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                const Text(
                  'ĐỊA CHỈ IP MÁY CỦA BẠN:',
                  style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  myIp,
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '💡 Hướng dẫn: Đảm bảo 2 máy kết nối chung một mạng WiFi\n(hoặc một máy bật "Điểm phát sóng di động / Hotspot" cho máy kia bắt).',
            style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          if (isHosting) ...[
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: Color(0xFF00E5FF)),
                ),
                SizedBox(width: 10),
                Text(
                  'Đang mở phòng... Chờ đối thủ kết nối...',
                  style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => service.disconnect(),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text('HỦY PHÒNG'),
            ),
          ] else ...[
            FilledButton.icon(
              onPressed: _isActionInProgress ? null : _startHosting,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.wifi_tethering),
              label: const Text('MỞ PHÒNG CHỜ ĐỐI THỦ', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJoinTab(LocalMultiplayerService service) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'NHẬP ĐỊA CHỈ IP CỦA MÁY TẠO PHÒNG:',
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            constraints: const BoxConstraints(maxWidth: 320),
            child: TextField(
              controller: _ipController,
              keyboardType: TextInputType.text,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Ví dụ: 192.168.1.15',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.black38,
                prefixIcon: const Icon(Icons.settings_ethernet, color: Color(0xFF00E5FF)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isActionInProgress ? null : _connectToHost,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: _isActionInProgress
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
                  )
                : const Icon(Icons.link),
            label: const Text('KẾT NỐI VÀO PHÒNG', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
