import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

enum MultiplayerRole { none, host, client }

enum MultiplayerConnectionState {
  disconnected,
  hosting,
  connecting,
  connected,
}

class LocalMultiplayerService extends ChangeNotifier {
  static final LocalMultiplayerService instance = LocalMultiplayerService._internal();

  LocalMultiplayerService._internal();

  static const int port = 8888;

  MultiplayerRole role = MultiplayerRole.none;
  MultiplayerConnectionState connectionState = MultiplayerConnectionState.disconnected;

  String? localIp;
  ServerSocket? _serverSocket;
  Socket? _activeSocket;
  StreamSubscription? _socketSubscription;

  // Callback nhận gói tin từ đối thủ để game xử lý
  void Function(Map<String, dynamic> data)? onMessageReceived;

  bool get isConnected => connectionState == MultiplayerConnectionState.connected;
  bool get isHost => role == MultiplayerRole.host;

  /// Lấy địa chỉ IP mạng nội bộ của máy (WiFi hoặc Hotspot)
  Future<String?> getLocalIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback && addr.type == InternetAddressType.IPv4) {
            localIp = addr.address;
            return localIp;
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting local IP: $e');
    }
    localIp = '127.0.0.1';
    return localIp;
  }

  /// Mở phòng (Host) trên cổng 8888 và chờ người chơi khác kết nối
  Future<bool> startHosting() async {
    await disconnect();
    await getLocalIpAddress();

    try {
      _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      role = MultiplayerRole.host;
      connectionState = MultiplayerConnectionState.hosting;
      notifyListeners();

      _serverSocket!.listen((Socket client) {
        if (_activeSocket != null) {
          // Chỉ cho phép 1 đối thủ kết nối cùng lúc
          client.destroy();
          return;
        }
        _activeSocket = client;
        role = MultiplayerRole.host;
        connectionState = MultiplayerConnectionState.connected;
        notifyListeners();
        _listenToSocket(_activeSocket!);
      });

      return true;
    } catch (e) {
      debugPrint('Error startHosting: $e');
      connectionState = MultiplayerConnectionState.disconnected;
      notifyListeners();
      return false;
    }
  }

  /// Kết nối vào phòng của đối thủ qua IP
  Future<bool> connectToHost(String hostIp) async {
    await disconnect();
    role = MultiplayerRole.client;
    connectionState = MultiplayerConnectionState.connecting;
    notifyListeners();

    try {
      final socket = await Socket.connect(
        hostIp.trim(),
        port,
        timeout: const Duration(seconds: 6),
      );
      _activeSocket = socket;
      connectionState = MultiplayerConnectionState.connected;
      notifyListeners();
      _listenToSocket(_activeSocket!);
      return true;
    } catch (e) {
      debugPrint('Error connectToHost: $e');
      connectionState = MultiplayerConnectionState.disconnected;
      role = MultiplayerRole.none;
      notifyListeners();
      return false;
    }
  }

  void _listenToSocket(Socket socket) {
    _socketSubscription = socket
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
      (line) {
        if (line.trim().isEmpty) return;
        try {
          final data = jsonDecode(line) as Map<String, dynamic>;
          onMessageReceived?.call(data);
        } catch (e) {
          debugPrint('Error parsing message from opponent: $e');
        }
      },
      onDone: () {
        debugPrint('Opponent disconnected');
        disconnect();
      },
      onError: (err) {
        debugPrint('Socket error: $err');
        disconnect();
      },
    );
  }

  /// Gửi gói tin JSON tới đối thủ
  void sendData(Map<String, dynamic> data) {
    if (_activeSocket != null && isConnected) {
      try {
        final line = '${jsonEncode(data)}\n';
        _activeSocket!.write(line);
      } catch (e) {
        debugPrint('Error sending data: $e');
      }
    }
  }

  void sendAim({required double angle, required double power}) {
    sendData({'type': 'aim', 'angle': angle, 'power': power});
  }

  void sendSpin({required double dx, required double dy}) {
    sendData({'type': 'spin', 'dx': dx, 'dy': dy});
  }

  void sendShoot({required double power}) {
    sendData({'type': 'shoot', 'power': power});
  }

  void sendBallInHand({required double x, required double y}) {
    sendData({'type': 'ball_in_hand', 'x': x, 'y': y});
  }

  void sendRestart() {
    sendData({'type': 'restart'});
  }

  /// Ngắt kết nối
  Future<void> disconnect() async {
    try {
      await _socketSubscription?.cancel();
      _socketSubscription = null;
      _activeSocket?.destroy();
      _activeSocket = null;
      await _serverSocket?.close();
      _serverSocket = null;
    } catch (e) {
      debugPrint('Error closing sockets: $e');
    }
    role = MultiplayerRole.none;
    connectionState = MultiplayerConnectionState.disconnected;
    notifyListeners();
  }
}
