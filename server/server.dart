import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Standalone Dart WebSocket Server for 8-Ball Billiards
/// Hỗ trợ: Ghép trận ngẫu nhiên 1v1, Phòng mã PIN 6 số,
/// Đồng bộ theo thời gian thực (Real-time), Reconnect khi bị ngắt kết nối tạm thời,
/// và Xử thua công bằng khi đầu hàng từ Menu Cài đặt (Forfeit).
void main(List<String> args) async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);

  print('====================================================');
  print('🎱 DART BIDA WEBSOCKET SERVER ĐANG CHẠY TRÊN CỔNG: $port');
  print('   - HTTP Health Check: http://localhost:$port/health');
  print('   - WebSocket Endpoint: ws://localhost:$port');
  print('====================================================');

  final rooms = <String, Room>{};
  final clients = <WebSocket, ClientSession>{};
  final matchmakingQueue = <WebSocket>[];

  server.listen((HttpRequest request) async {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      final ws = await WebSocketTransformer.upgrade(request);
      final clientId = 'dart_player_${Random().nextInt(999999)}';
      final session = ClientSession(id: clientId);
      clients[ws] = session;

      print('[+] Client kết nối: $clientId (Tổng: ${clients.length})');
      sendJson(ws, {'type': 'connected', 'clientId': clientId});

      ws.listen(
        (data) {
          try {
            final json = jsonDecode(data.toString()) as Map<String, dynamic>;
            final type = json['type'] as String?;

            switch (type) {
              case 'set_profile':
                session.id = json['clientId']?.toString() ?? session.id;
                session.name = json['name']?.toString() ?? session.name;
                session.level = (json['level'] as num?)?.toInt() ?? session.level;
                session.coins = (json['coins'] as num?)?.toInt() ?? session.coins;
                break;

              case 'create_room':
                var code = (100000 + Random().nextInt(900000)).toString();
                while (rooms.containsKey(code)) {
                  code = (100000 + Random().nextInt(900000)).toString();
                }
                final room = Room(id: code, p1: ws);
                room.p1Id = session.id;
                room.p1Name = session.name;
                room.p1Level = session.level;
                room.p1Coins = session.coins;
                rooms[code] = room;

                session.roomId = code;
                session.role = 'p1';
                print('[Room] Tạo phòng #${code} bởi ${session.name}');
                sendJson(ws, {'type': 'room_created', 'roomId': code, 'role': 'host'});
                break;

              case 'join_room':
                final code = json['roomId']?.toString().trim() ?? '';
                final room = rooms[code];
                if (room == null) {
                  sendJson(ws, {'type': 'error', 'message': 'Phòng không tồn tại hoặc đã đóng!'});
                  return;
                }
                if (room.p2 != null && room.p2DisconnectedAt == null) {
                  sendJson(ws, {'type': 'error', 'message': 'Phòng này đã đủ người!'});
                  return;
                }
                room.p2 = ws;
                room.p2Id = session.id;
                room.p2Name = session.name;
                room.p2Level = session.level;
                room.p2Coins = session.coins;
                room.state = 'playing';

                session.roomId = code;
                session.role = 'p2';

                sendJson(ws, {'type': 'room_joined', 'roomId': code, 'role': 'client'});
                if (room.p1 != null) {
                  sendJson(room.p1!, {
                    'type': 'opponent_joined',
                    'opponentName': session.name,
                    'opponentLevel': session.level,
                    'opponentCoins': session.coins,
                  });
                }
                sendJson(ws, {
                  'type': 'opponent_joined',
                  'opponentName': room.p1Name,
                  'opponentLevel': room.p1Level,
                  'opponentCoins': room.p1Coins,
                });
                final startMsg = {'type': 'match_start', 'roomId': code, 'firstTurn': 1};
                if (room.p1 != null) sendJson(room.p1!, startMsg);
                sendJson(room.p2!, startMsg);
                break;

              case 'quick_match':
                matchmakingQueue.remove(ws);
                if (matchmakingQueue.isNotEmpty) {
                  final oppWs = matchmakingQueue.removeAt(0);
                  final oppSession = clients[oppWs];
                  var code = (100000 + Random().nextInt(900000)).toString();
                  final room = Room(id: code, p1: oppWs, p2: ws);
                  room.state = 'playing';
                  room.p1Id = oppSession?.id ?? 'p1';
                  room.p1Name = oppSession?.name ?? 'Cơ Thủ 1';
                  room.p1Level = oppSession?.level ?? 1;
                  room.p1Coins = oppSession?.coins ?? 1000;
                  room.p2Id = session.id;
                  room.p2Name = session.name;
                  room.p2Level = session.level;
                  room.p2Coins = session.coins;
                  rooms[code] = room;

                  if (oppSession != null) {
                    oppSession.roomId = code;
                    oppSession.role = 'p1';
                  }
                  session.roomId = code;
                  session.role = 'p2';

                  sendJson(oppWs, {
                    'type': 'match_found',
                    'roomId': code,
                    'role': 'host',
                    'opponentName': session.name,
                    'opponentLevel': session.level,
                    'opponentCoins': session.coins,
                    'firstTurn': 1,
                  });
                  sendJson(ws, {
                    'type': 'match_found',
                    'roomId': code,
                    'role': 'client',
                    'opponentName': oppSession?.name ?? 'Đối thủ',
                    'opponentLevel': oppSession?.level ?? 1,
                    'opponentCoins': oppSession?.coins ?? 1000,
                    'firstTurn': 1,
                  });
                } else {
                  matchmakingQueue.add(ws);
                  sendJson(ws, {'type': 'matchmaking_waiting', 'message': 'Đang tìm đối thủ...'});
                }
                break;

              case 'cancel_matchmaking':
                matchmakingQueue.remove(ws);
                sendJson(ws, {'type': 'matchmaking_cancelled'});
                break;

              // Reconnect lại phòng đang thi đấu dở
              case 'reconnect_match':
                final reqRoomId = json['roomId']?.toString().trim();
                final reqClientId = json['clientId']?.toString() ?? session.id;
                final reqRole = json['role']?.toString();

                if (reqRoomId != null && rooms.containsKey(reqRoomId)) {
                  final room = rooms[reqRoomId]!;
                  if (room.state == 'playing') {
                    bool matched = false;
                    if (reqRole == 'p1' || reqClientId == room.p1Id) {
                      room.p1 = ws;
                      room.p1DisconnectedAt = null;
                      session.roomId = reqRoomId;
                      session.role = 'p1';
                      matched = true;
                    } else if (reqRole == 'p2' || reqClientId == room.p2Id) {
                      room.p2 = ws;
                      room.p2DisconnectedAt = null;
                      session.roomId = reqRoomId;
                      session.role = 'p2';
                      matched = true;
                    }

                    if (matched) {
                      room.disconnectTimer?.cancel();
                      room.disconnectTimer = null;
                      print('[Reconnect] Client ${session.name} (${session.role}) kết nối lại phòng #$reqRoomId');

                      sendJson(ws, {
                        'type': 'reconnected_success',
                        'roomId': room.id,
                        'role': session.role,
                        'opponentName': session.role == 'p1' ? room.p2Name : room.p1Name,
                        'opponentLevel': session.role == 'p1' ? room.p2Level : room.p1Level,
                        'opponentCoins': session.role == 'p1' ? room.p2Coins : room.p1Coins,
                        'lastBalls': room.lastBalls,
                        'currentTurn': room.currentTurn,
                      });

                      final opp = session.role == 'p1' ? room.p2 : room.p1;
                      if (opp != null) {
                        sendJson(opp, {
                          'type': 'opponent_reconnected',
                          'message': 'Đối thủ đã kết nối lại! Tiếp tục trận đấu.',
                        });
                      }
                      return;
                    }
                  }
                }
                sendJson(ws, {'type': 'reconnect_failed', 'message': 'Trận đấu không tồn tại hoặc đã kết thúc.'});
                break;

              // Đầu hàng / Rời trận từ Menu Setting (Xử thua cho người gửi)
              case 'forfeit':
                final roomId = json['roomId']?.toString() ?? session.roomId;
                if (roomId != null && rooms.containsKey(roomId)) {
                  final room = rooms[roomId]!;
                  final winnerRole = session.role == 'p1' ? 'p2' : 'p1';
                  final target = session.role == 'p1' ? room.p2 : room.p1;

                  print('[Forfeit] Người chơi ${session.name} (${session.role}) đã đầu hàng tại phòng #$roomId. $winnerRole thắng!');
                  if (target != null) {
                    sendJson(target, {
                      'type': 'opponent_forfeited',
                      'winnerRole': winnerRole,
                      'message': 'Đối thủ đã rời trận đấu. Bạn giành chiến thắng!',
                    });
                  }
                  room.disconnectTimer?.cancel();
                  rooms.remove(roomId);
                }
                break;

              case 'sync_balls':
                if (session.roomId != null && rooms.containsKey(session.roomId)) {
                  final room = rooms[session.roomId]!;
                  room.lastBalls = json['balls'] as List<dynamic>?;
                  final target = ws == room.p1 ? room.p2 : room.p1;
                  if (target != null) sendJson(target, json);
                }
                break;

              case 'aim':
              case 'spin':
              case 'shoot':
              case 'ball_in_hand':
              case 'restart':
              case 'player_info':
              case 'chat':
                if (session.roomId != null && rooms.containsKey(session.roomId)) {
                  final room = rooms[session.roomId]!;
                  final target = ws == room.p1 ? room.p2 : room.p1;
                  if (target != null) {
                    sendJson(target, json);
                  }
                }
                break;
            }
          } catch (e) {
            print('Lỗi xử lý packet: $e');
          }
        },
        onDone: () {
          matchmakingQueue.remove(ws);
          if (session.roomId != null && rooms.containsKey(session.roomId)) {
            final room = rooms[session.roomId]!;
            if (room.state == 'playing') {
              final isP1 = ws == room.p1;
              if (isP1) {
                room.p1 = null;
                room.p1DisconnectedAt = DateTime.now();
              } else {
                room.p2 = null;
                room.p2DisconnectedAt = DateTime.now();
              }
              final target = isP1 ? room.p2 : room.p1;
              if (target != null) {
                sendJson(target, {
                  'type': 'opponent_disconnected',
                  'message': 'Đối thủ bị mất kết nối tạm thời! Trận đấu vẫn diễn ra theo thời gian thực.',
                  'graceSeconds': 120,
                });
              }
              print('[Disconnect] Client ${session.name} ngắt kết nối. Phòng #${room.id} tiếp tục chạy theo thời gian thực (chờ reconnect 120s)...');

              // Bắt đầu đếm ngược 120s nếu không reconnect
              room.disconnectTimer?.cancel();
              room.disconnectTimer = Timer(const Duration(seconds: 120), () {
                if (rooms.containsKey(room.id)) {
                  final activeOpp = isP1 ? room.p2 : room.p1;
                  if (activeOpp != null) {
                    sendJson(activeOpp, {
                      'type': 'opponent_forfeited',
                      'winnerRole': isP1 ? 'p2' : 'p1',
                      'message': 'Đối thủ không kết nối lại sau 120s. Bạn giành chiến thắng!',
                    });
                  }
                  rooms.remove(room.id);
                  print('[Timeout] Đã đóng phòng #${room.id} do đối thủ bỏ trận.');
                }
              });
            } else {
              // Phòng đang đợi khách ở sảnh
              if (room.p1 != null && room.p1 != ws) {
                sendJson(room.p1!, {'type': 'opponent_left', 'message': 'Đối thủ đã thoát'});
              }
              rooms.remove(session.roomId);
            }
          }
          clients.remove(ws);
          print('[-] Client ngắt kết nối socket: ${session.id} (Còn: ${clients.length})');
        },
      );
    } else {
      // HTTP Health check
      request.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({
          'status': 'ok',
          'service': 'bida-dart-websocket-server',
          'onlineClients': clients.length,
          'activeRooms': rooms.length,
        }))
        ..close();
    }
  });
}

void sendJson(WebSocket ws, Map<String, dynamic> data) {
  try {
    ws.add(jsonEncode(data));
  } catch (_) {}
}

class ClientSession {
  String id;
  String name = 'Cơ Thủ';
  int level = 1;
  int coins = 1000;
  String? roomId;
  String? role;

  ClientSession({required this.id});
}

class Room {
  final String id;
  WebSocket? p1;
  WebSocket? p2;
  String p1Id = '';
  String p2Id = '';
  String p1Name = 'Cơ Thủ 1';
  String p2Name = 'Cơ Thủ 2';
  int p1Level = 1;
  int p2Level = 1;
  int p1Coins = 1000;
  int p2Coins = 1000;
  String state = 'waiting';
  DateTime createdAt;
  DateTime? p1DisconnectedAt;
  DateTime? p2DisconnectedAt;
  Timer? disconnectTimer;
  List<dynamic>? lastBalls;
  int currentTurn = 1;

  Room({
    required this.id,
    required this.p1,
    this.p2,
  }) : createdAt = DateTime.now();
}
