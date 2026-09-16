import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

enum BallGroup { solids, stripes }

// Khởi tạo instance của game ở ngoài cùng để UI có thể lắng nghe trạng thái (Turn-base)
final BilliardGame gameInstance = BilliardGame();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AspectRatio(
              aspectRatio: 2 / 1,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: GameWidget(game: gameInstance),
                  ),
                  Positioned(
                    left: 8,
                    top: 56,
                    bottom: 56,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onVerticalDragUpdate: (details) {
                        gameInstance.adjustShotPower(
                          details.primaryDelta! / 180,
                        );
                      },
                      onVerticalDragEnd: (_) => gameInstance.shootWithPower(),
                      child: ValueListenableBuilder<double>(
                        valueListenable: gameInstance.shotPower,
                        builder: (context, power, child) {
                          return Container(
                            width: 42,
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.58),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(color: Colors.white12),
                                FractionallySizedBox(
                                  heightFactor: power,
                                  widthFactor: 1,
                                  alignment: Alignment.bottomCenter,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: power > 0.75
                                          ? Colors.redAccent
                                          : Colors.amber,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Giao diện UI lắng nghe sự thay đổi lượt chơi từ Game
                  Positioned(
                    top: 10,
                    left: 20,
                    right: 20,
                    child: ValueListenableBuilder<int>(
                      valueListenable: gameInstance.groupVersion,
                      builder: (context, _, child) {
                        return ValueListenableBuilder<int>(
                          valueListenable: gameInstance.currentTurn,
                          builder: (context, turn, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildPlayerCard(
                                  "Player 1",
                                  Colors.blue,
                                  turn == 1,
                                  gameInstance.playerScores[1] ?? 0,
                                  gameInstance.groupLabel(1),
                                  gameInstance.groupBalls(1),
                                ),
                                _buildPlayerCard(
                                  "Player 2",
                                  Colors.red,
                                  turn == 2,
                                  gameInstance.playerScores[2] ?? 0,
                                  gameInstance.groupLabel(2),
                                  gameInstance.groupBalls(2),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Builder(
                      builder: (context) => Center(
                        child: IconButton(
                          tooltip: 'Cài đặt',
                          icon: const Icon(Icons.settings),
                          color: Colors.white,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
                          onPressed: () => _showSettings(context),
                        ),
                      ),
                    ),
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: gameInstance.matchVersion,
                    builder: (context, _, child) {
                      if (!gameInstance.rackOver) {
                        return const SizedBox.shrink();
                      }
                      return Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.72),
                          child: Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 360),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF173A32),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.amber, width: 2),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.emoji_events,
                                    color: Colors.amber,
                                    size: 54,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    gameInstance.winningPlayer == null
                                        ? 'Rack kết thúc'
                                        : 'Player ${gameInstance.winningPlayer} thắng!',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tỷ số  ${gameInstance.playerScores[1] ?? 0} - ${gameInstance.playerScores[2] ?? 0}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  FilledButton.icon(
                                    onPressed: gameInstance.restartMatch,
                                    icon: const Icon(Icons.replay),
                                    label: const Text('Chơi lại'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: ValueListenableBuilder<String>(
                      valueListenable: gameInstance.ruleMessage,
                      builder: (context, message, child) {
                        return Center(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.72),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: Text(
                                message,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void _showSettings(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cài đặt'),
      content: const Text('Chọn thao tác cho trận đấu hiện tại.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            _showDeclareLoss(context);
          },
          icon: const Icon(Icons.flag),
          label: const Text('Xử thua'),
        ),
        FilledButton.icon(
          onPressed: () {
            gameInstance.restartMatch();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.restart_alt),
          label: const Text('Bắt đầu lại'),
        ),
      ],
    ),
  );
}

void _showDeclareLoss(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Chọn người thua'),
      content: const Text('Player nào bị xử thua trận này?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            gameInstance.declareLoss(1);
            Navigator.pop(context);
          },
          child: const Text('Player 1 thua'),
        ),
        TextButton(
          onPressed: () {
            gameInstance.declareLoss(2);
            Navigator.pop(context);
          },
          child: const Text('Player 2 thua'),
        ),
      ],
    ),
  );
}

Widget _buildPlayerCard(
  String name,
  Color color,
  bool isTurn,
  int score,
  String groupLabel,
  List<int> groupBalls,
) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.transparent,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isTurn)
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 12,
              ),
            if (isTurn) const SizedBox(width: 4),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          'Tỷ số: $score',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
        if (groupLabel.isNotEmpty)
          Text(
            groupLabel,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        if (groupBalls.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final number in groupBalls)
                Padding(
                  padding: const EdgeInsets.only(right: 2, top: 3),
                  child: Opacity(
                    opacity: gameInstance.isBallPocketed(number) ? 0.25 : 1,
                    child: Image.asset(
                      'assets/images/ball_$number.png',
                      width: 19,
                      height: 19,
                    ),
                  ),
                ),
            ],
          ),
      ],
    ),
  );
}

class BilliardGame extends Forge2DGame with PanDetector {
  BilliardGame()
    : super(
        gravity: Vector2.zero(),
        contactListener: BilliardContactListener(),
      );

  // Biến quản lý lượt chơi (Turn base)
  ValueNotifier<int> currentTurn = ValueNotifier<int>(1);
  ValueNotifier<String> ruleMessage = ValueNotifier<String>(
    'Player 1: break shot',
  );
  ValueNotifier<double> shotPower = ValueNotifier<double>(0.05);
  ValueNotifier<int> groupVersion = ValueNotifier<int>(0);
  ValueNotifier<int> matchVersion = ValueNotifier<int>(0);
  final Map<int, int> playerScores = {1: 0, 2: 0};
  int? winningPlayer;

  late CueBall cueBall;
  final List<PoolBall> poolBalls = [];
  Vector2? dragStart;
  Vector2? dragCurrent;
  bool shotInProgress = false;
  double settledTime = 0;
  bool breakShot = true;
  bool rackOver = false;
  bool ballInHand = false;
  bool movingCueBall = false;
  final Map<int, BallGroup> playerGroups = {};
  bool objectBallHitRailThisShot = false;
  int objectBallsHitRails = 0;

  double maxDragDistance = 180.0;
  double forceMultiplier = 4400.0;
  double aimAngle = 0.0;
  static const double rollingVelocityMultiplier = 10.0;
  static const double rollingFriction = 0.16;
  static const double maximumBallSpeed = 1000.0;

  // Khai báo kích thước động
  late double ballRadius;
  late Vector2 playAreaTopLeft;
  late Vector2 playAreaBottomRight;
  bool physicsReady = false;

  @override
  Color backgroundColor() => const Color(0xFF0F7A3E);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    BilliardContactListener.activeGame = this;

    // Gắn trực tiếp bộ lắng nghe va chạm vào ContactManager của thế giới vật lý
    final tableSprite = await Sprite.load('pool_table.png');
    add(SpriteComponent(sprite: tableSprite, size: size));

    // TÍNH TOÁN KÍCH THƯỚC ĐỘNG TỪ BỨC ẢNH CỦA BẠN
    // Ép lùi ranh giới vật lý vào trong (tránh đập viền gỗ)
    final double paddingX = size.x * 0.06;
    final double paddingY = size.y * 0.10;
    playAreaTopLeft = Vector2(paddingX, paddingY);
    playAreaBottomRight = Vector2(size.x - paddingX, size.y - paddingY);

    // Scale bi tự động bằng 4% chiều cao màn hình (Rất to và rõ)
    ballRadius = size.y * 0.04;

    addAll(createBoundaries());
    addAll(createPockets());
    spawnTriangleBalls();

    cueBall = CueBall(Vector2(size.x * 0.25, size.y / 2), ballRadius);
    add(cueBall);
    _updateAimVector(ballRadius * 2);
  }

  List<Wall> createBoundaries() {
    return [
      Wall(
        playAreaTopLeft,
        Vector2(playAreaBottomRight.x, playAreaTopLeft.y),
      ), // Băng trên
      Wall(
        Vector2(playAreaBottomRight.x, playAreaTopLeft.y),
        playAreaBottomRight,
      ), // Băng phải
      Wall(
        Vector2(playAreaTopLeft.x, playAreaBottomRight.y),
        playAreaBottomRight,
      ), // Băng dưới
      Wall(
        playAreaTopLeft,
        Vector2(playAreaTopLeft.x, playAreaBottomRight.y),
      ), // Băng trái
    ];
  }

  // Khởi tạo 6 Lỗ Bida
  List<Pocket> createPockets() {
    final double pr = ballRadius * 1.5; // Kích thước lỗ to hơn bi một chút
    final midX = size.x / 2;
    return [
      Pocket(playAreaTopLeft, pr), // Lỗ Góc trái trên
      Pocket(Vector2(midX, playAreaTopLeft.y), pr), // Lỗ Giữa trên
      Pocket(
        Vector2(playAreaBottomRight.x, playAreaTopLeft.y),
        pr,
      ), // Góc phải trên
      Pocket(
        Vector2(playAreaTopLeft.x, playAreaBottomRight.y),
        pr,
      ), // Góc trái dưới
      Pocket(Vector2(midX, playAreaBottomRight.y), pr), // Giữa dưới
      Pocket(playAreaBottomRight, pr), // Góc phải dưới
    ];
  }

  void spawnTriangleBalls() {
    final startX = size.x * 0.70;
    final centerY = size.y / 2;
    final colWidth = ballRadius * 1.732;
    final gap = 0.1;

    int ballNumber = 1;
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col <= row; col++) {
        final x = startX + row * colWidth;
        final y = centerY + (col - row / 2) * (ballRadius * 2 + gap);
        final ball = PoolBall(
          Vector2(x, y),
          'ball_$ballNumber.png',
          ballRadius,
          ballNumber,
        );
        poolBalls.add(ball);
        add(ball);
        ballNumber++;
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!physicsReady) {
      physicsReady =
          cueBall.isMounted && poolBalls.every((ball) => ball.isMounted);
      if (!physicsReady) {
        return;
      }
    }
    _applyClothPhysics(dt);
    if (!shotInProgress) {
      return;
    }

    final cueStopped = cueBall.body.linearVelocity.length < 0.35;
    final ballsStopped = poolBalls.every(
      (ball) => ball.isRemoved || ball.body.linearVelocity.length < 0.35,
    );
    if (cueStopped && ballsStopped) {
      settledTime += dt;
      if (settledTime > 0.25) {
        finishShot();
      }
    } else {
      settledTime = 0;
    }
  }

  void _applyClothPhysics(double dt) {
    final frictionFactor = math.max(0.0, 1.0 - rollingFriction * dt);
    _applyClothPhysicsToBody(cueBall.body, frictionFactor);
    for (final ball in poolBalls) {
      if (ball.isRemoved) {
        continue;
      }
      _applyClothPhysicsToBody(ball.body, frictionFactor);
    }
  }

  void _applyClothPhysicsToBody(Body body, double frictionFactor) {
    final velocity = body.linearVelocity;
    velocity.scale(frictionFactor);
    if (velocity.length > maximumBallSpeed) {
      velocity.scale(maximumBallSpeed / velocity.length);
    }
    if (velocity.length < 0.08) {
      velocity.setZero();
    }
  }

  // Chuyển lượt chơi sau mỗi cú đánh
  void switchTurn() {
    currentTurn.value = currentTurn.value == 1 ? 2 : 1;
  }

  void declareLoss(int loser) {
    if (rackOver || shotInProgress || (loser != 1 && loser != 2)) {
      return;
    }
    winningPlayer = loser == 1 ? 2 : 1;
    playerScores[winningPlayer!] = playerScores[winningPlayer!]! + 1;
    ruleMessage.value = 'Player $loser bị xử thua';
    rackOver = true;
    ballInHand = false;
    matchVersion.value++;
  }

  void restartMatch() {
    if (!physicsReady) {
      return;
    }
    for (final ball in poolBalls) {
      ball.removeFromParent();
    }
    poolBalls.clear();
    cueBall.removeFromParent();

    currentTurn.value = 1;
    ruleMessage.value = 'Player 1: break shot';
    shotPower.value = 0.05;
    playerGroups.clear();
    groupVersion.value++;
    shotInProgress = false;
    breakShot = true;
    rackOver = false;
    winningPlayer = null;
    ballInHand = false;
    movingCueBall = false;
    settledTime = 0;
    aimAngle = 0;
    physicsReady = false;

    spawnTriangleBalls();
    cueBall = CueBall(Vector2(size.x * 0.25, size.y / 2), ballRadius);
    add(cueBall);
    cueBall.isAiming = true;
    _updateAimVector(ballRadius * 2);
    matchVersion.value++;
  }

  void setShotPower(double value) {
    shotPower.value = value;
  }

  void adjustShotPower(double delta) {
    if (shotInProgress || rackOver || ballInHand) {
      return;
    }
    shotPower.value = (shotPower.value + delta).clamp(0.05, 1.0);
    cueBall.isAiming = true;
    cueBall.strokeDistance = maxDragDistance * shotPower.value;
  }

  void shootWithPower() {
    if (!physicsReady ||
        shotInProgress ||
        ballInHand ||
        rackOver ||
        shotPower.value <= 0.05) {
      return;
    }
    final direction = Vector2(math.cos(aimAngle), math.sin(aimAngle));
    final targetSpeed =
        forceMultiplier * shotPower.value * rollingVelocityMultiplier;
    cueBall.body.applyLinearImpulse(
      direction * cueBall.body.mass * targetSpeed,
    );
    cueBall.body.linearVelocity.setFrom(direction * targetSpeed);
    shotInProgress = true;
    objectBallHitRailThisShot = false;
    objectBallsHitRails = 0;
    for (final ball in poolBalls) {
      ball.pocketedThisShot = false;
    }
    cueBall.pocketedThisShot = false;
    cueBall.hitObjectThisShot = false;
    cueBall.firstObjectBallHit = null;
    settledTime = 0;
    shotPower.value = 0.05;
    cueBall.strokeDistance = 0;
    cueBall.isAiming = false;
  }

  void rotateAimToPoint(Vector2 touchPosition) {
    if (shotInProgress || rackOver || ballInHand) {
      return;
    }
    final offset = touchPosition - cueBall.body.position;
    if (offset.length2 > 4) {
      aimAngle = math.atan2(offset.y, offset.x);
      cueBall.isAiming = true;
      _updateAimVector(ballRadius * 2);
    }
  }

  void rotateAim(double delta) {
    if (shotInProgress || rackOver) {
      return;
    }
    aimAngle += delta;
    if (dragStart != null) {
      _updateAimVector(
        dragCurrent == null ? 0 : (dragStart! - dragCurrent!).length,
      );
    }
  }

  void _updateAimVector(double length) {
    cueBall.aimVector =
        Vector2(math.cos(aimAngle), math.sin(aimAngle)) * length;
  }

  @override
  void onPanStart(DragStartInfo info) {
    if (shotInProgress || rackOver) {
      return;
    }
    dragStart = info.eventPosition.widget;
    dragCurrent = dragStart;
    if (ballInHand) {
      movingCueBall =
          (dragStart! - cueBall.body.position).length <= ballRadius * 2.5;
      if (movingCueBall) {
        cueBall.isAiming = false;
      }
      return;
    }
    rotateAimToPoint(dragStart!);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    dragCurrent = info.eventPosition.widget;
    if (dragStart != null) {
      if (movingCueBall) {
        moveCueBallTo(dragCurrent!);
        return;
      }
      rotateAimToPoint(dragCurrent!);
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (movingCueBall) {
      movingCueBall = false;
      ballInHand = false;
      cueBall.isAiming = true;
      _updateAimVector(ballRadius * 2);
    }
    dragStart = null;
    dragCurrent = null;
  }

  void moveCueBallTo(Vector2 requestedPosition) {
    final position = Vector2(
      requestedPosition.x.clamp(
        playAreaTopLeft.x + ballRadius,
        playAreaBottomRight.x - ballRadius,
      ),
      requestedPosition.y.clamp(
        playAreaTopLeft.y + ballRadius,
        playAreaBottomRight.y - ballRadius,
      ),
    );
    final overlapsBall = poolBalls.any(
      (ball) =>
          !ball.isRemoved &&
          (ball.body.position - position).length < ballRadius * 2.05,
    );
    if (!overlapsBall) {
      cueBall.isSunk = false;
      cueBall.body.setTransform(position, 0);
      cueBall.body.linearVelocity.setZero();
      cueBall.body.angularVelocity = 0;
    }
  }

  void finishShot() {
    shotInProgress = false;
    cueBall.isAiming = true;
    _updateAimVector(ballRadius * 2);
    final currentPlayer = currentTurn.value;
    final pocketedThisShot = poolBalls
        .where((ball) => ball.pocketedThisShot)
        .toList();
    final eightPocketed = pocketedThisShot.any((ball) => ball.number == 8);
    final group = playerGroups[currentPlayer];
    final firstHit = cueBall.firstObjectBallHit;
    final legalTargetHit =
        firstHit == null ||
        (firstHit != 8 && (group == null || ballGroup(firstHit) == group)) ||
        (firstHit == 8 && group != null && allGroupBallsPocketed(group));
    final foul =
        cueBall.pocketedThisShot ||
        !cueBall.hitObjectThisShot ||
        !legalTargetHit ||
        (breakShot && pocketedThisShot.isEmpty && objectBallsHitRails < 4);

    if (foul) {
      if (eightPocketed) {
        ruleMessage.value = 'Foul: 8-ball on an illegal shot';
        winningPlayer = currentPlayer == 1 ? 2 : 1;
        playerScores[winningPlayer!] = playerScores[winningPlayer!]! + 1;
        rackOver = true;
      } else {
        ruleMessage.value = 'Foul - ball in hand';
        switchTurn();
        ballInHand = true;
        cueBall.isSunk = false;
        cueBall.isAiming = false;
      }
    } else if (eightPocketed) {
      final canWin = group != null && allGroupBallsPocketed(group);
      if (canWin) {
        ruleMessage.value = 'Player $currentPlayer wins the rack!';
        winningPlayer = currentPlayer;
        playerScores[currentPlayer] = playerScores[currentPlayer]! + 1;
      } else {
        ruleMessage.value = 'Player $currentPlayer loses: 8-ball early';
        winningPlayer = currentPlayer == 1 ? 2 : 1;
        playerScores[winningPlayer!] = playerScores[winningPlayer!]! + 1;
      }
      rackOver = true;
    } else if (breakShot) {
      breakShot = false;
      ruleMessage.value = pocketedThisShot.isNotEmpty
          ? 'Player $currentPlayer continues'
          : 'Player ${currentPlayer == 1 ? 2 : 1} turn';
      if (pocketedThisShot.isEmpty) {
        switchTurn();
      }
    } else if (group == null &&
        pocketedThisShot.any((ball) => ball.number != 8)) {
      assignGroupAfterBreak(pocketedThisShot);
      ruleMessage.value = 'Player $currentPlayer continues';
    } else if (pocketedThisShot.any(
      (ball) => ballGroup(ball.number) == group,
    )) {
      ruleMessage.value = 'Player $currentPlayer continues';
    } else {
      ruleMessage.value = 'Player ${currentPlayer == 1 ? 2 : 1} turn';
      switchTurn();
    }
    groupVersion.value++;
    matchVersion.value++;
  }

  BallGroup ballGroup(int number) =>
      number < 8 ? BallGroup.solids : BallGroup.stripes;

  void assignGroupAfterBreak(List<PoolBall> pocketed) {
    final candidates = pocketed.where((ball) => ball.number != 8).toList();
    final firstObject = candidates.isEmpty ? null : candidates.first;
    if (firstObject != null) {
      playerGroups[currentTurn.value] = ballGroup(firstObject.number);
      playerGroups[currentTurn.value == 1
          ? 2
          : 1] = ballGroup(firstObject.number) == BallGroup.solids
          ? BallGroup.stripes
          : BallGroup.solids;
      groupVersion.value++;
    }
  }

  String groupLabel(int player) {
    final group = playerGroups[player];
    if (group == BallGroup.solids) {
      return 'Bi trơn 1-7';
    }
    if (group == BallGroup.stripes) {
      return 'Bi sọc 9-15';
    }
    return '';
  }

  List<int> groupBalls(int player) {
    final group = playerGroups[player];
    if (group == null) {
      return const [];
    }
    return group == BallGroup.solids
        ? List<int>.generate(7, (index) => index + 1)
        : List<int>.generate(7, (index) => index + 9);
  }

  bool isBallPocketed(int number) => poolBalls.any(
    (ball) => ball.number == number && (ball.isSunk || ball.isRemoved),
  );

  bool allGroupBallsPocketed(BallGroup group) => poolBalls
      .where((ball) => ballGroup(ball.number) == group)
      .every((ball) => ball.isRemoved || ball.isSunk);

  void registerRailHit(Object bodyOwner) {
    if (bodyOwner is PoolBall && !bodyOwner.isSunk) {
      objectBallHitRailThisShot = true;
      objectBallsHitRails++;
    }
  }

  PoolBall? targetForAim(Vector2 direction) {
    PoolBall? target;
    var nearestDistance = double.infinity;
    for (final ball in poolBalls) {
      if (ball.isRemoved || ball.isSunk) {
        continue;
      }
      final offset = ball.body.position - cueBall.body.position;
      final forwardDistance = offset.dot(direction);
      if (forwardDistance <= 0) {
        continue;
      }
      final sideDistance = (offset - direction * forwardDistance).length;
      if (sideDistance <= ballRadius * 1.25 &&
          forwardDistance < nearestDistance) {
        nearestDistance = forwardDistance;
        target = ball;
      }
    }
    return target;
  }

  AimGuide? guideForAim(Vector2 direction) {
    final normalizedDirection = direction.normalized();
    AimGuide? guide;
    var nearestDistance = double.infinity;
    final collisionDistance = ballRadius * 2;

    for (final ball in poolBalls) {
      if (ball.isRemoved || ball.isSunk) {
        continue;
      }
      final offset = ball.body.position - cueBall.body.position;
      final projectedDistance = offset.dot(normalizedDirection);
      if (projectedDistance <= 0) {
        continue;
      }
      final perpendicular = offset - normalizedDirection * projectedDistance;
      final perpendicularDistance = perpendicular.length;
      if (perpendicularDistance > collisionDistance) {
        continue;
      }
      final alongCircle = math.sqrt(
        math.max(
          0,
          collisionDistance * collisionDistance -
              perpendicularDistance * perpendicularDistance,
        ),
      );
      final impactDistance = projectedDistance - alongCircle;
      if (impactDistance <= 0 || impactDistance >= nearestDistance) {
        continue;
      }
      final impactPoint =
          cueBall.body.position + normalizedDirection * impactDistance;
      final objectDirection = (ball.body.position - impactPoint).normalized();
      guide = AimGuide(ball, impactPoint, objectDirection);
      nearestDistance = impactDistance;
    }
    return guide;
  }
}

class AimGuide {
  final PoolBall target;
  final Vector2 impactPoint;
  final Vector2 objectDirection;

  AimGuide(this.target, this.impactPoint, this.objectDirection);
}

// ================= LỚP VẬT LÝ =================

class Wall extends BodyComponent {
  final Vector2 start;
  final Vector2 end;
  Wall(this.start, this.end);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(start, end);
    final fixtureDef = FixtureDef(shape, friction: 0.18, restitution: 0.64);
    final createdBody = world.createBody(BodyDef(type: BodyType.static))
      ..createFixture(fixtureDef);
    createdBody.userData = this;
    return createdBody;
  }
}

// Lớp quản lý va chạm chung cho toàn bộ bàn bida
class BilliardContactListener extends ContactListener {
  static BilliardGame? activeGame;

  @override
  void beginContact(Contact contact) {
    final fixtureA = contact.fixtureA;
    final fixtureB = contact.fixtureB;

    final bodyA = fixtureA.body;
    final bodyB = fixtureB.body;

    // Kiểm tra nếu một bên là Lỗ (Pocket) và bên còn lại là Bi (Ball)
    _checkPocketCollision(bodyA, bodyB);
    _checkPocketCollision(bodyB, bodyA);
    _checkBallCollision(bodyA, bodyB);
    _checkRailCollision(bodyA, bodyB);
    _checkRailCollision(bodyB, bodyA);
  }

  void _checkRailCollision(Body first, Body second) {
    if (first.userData is Wall && second.userData is PoolBall) {
      activeGame?.registerRailHit(second.userData!);
    }
  }

  void _checkBallCollision(Body first, Body second) {
    final cue = first.userData is CueBall
        ? first.userData as CueBall
        : second.userData is CueBall
        ? second.userData as CueBall
        : null;
    final target = first.userData is PoolBall
        ? first.userData as PoolBall
        : second.userData is PoolBall
        ? second.userData as PoolBall
        : null;
    if (cue != null && target != null) {
      cue.hitObjectThisShot = true;
      cue.firstObjectBallHit ??= target.number;
    }
  }

  void _checkPocketCollision(Body pocketBody, Body ballBody) {
    if (pocketBody.userData is Pocket && ballBody.userData is PoolBall) {
      final ball = ballBody.userData as PoolBall;
      ball.isSunk = true;
      ball.pocketedThisShot = true;
    } else if (pocketBody.userData is Pocket && ballBody.userData is CueBall) {
      final cueBall = ballBody.userData as CueBall;
      cueBall.isSunk = true;
      cueBall.pocketedThisShot = true;
    }
  }

  @override
  void endContact(Contact contact) {}

  @override
  void preSolve(Contact contact, Manifold oldManifold) {}

  @override
  void postSolve(Contact contact, ContactImpulse impulse) {}
}

// Cảm biến Lỗ Bida
class Pocket extends BodyComponent {
  @override
  final Vector2 position;
  final double radius;
  Pocket(this.position, this.radius) : super(renderBody: false);

  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;
    // isSensor: true giúp bi lọt qua thay vì dội lại như đập tường
    final fixtureDef = FixtureDef(shape, isSensor: true);
    final createdBody = world.createBody(
      BodyDef(type: BodyType.static, position: position),
    )..createFixture(fixtureDef);
    createdBody.userData = this;
    return createdBody;
  }
}

// Lớp hỗ trợ tia ngắm A-Băng
class AimRayCastCallback extends RayCastCallback {
  final Body ignoreBody;
  Vector2? hitPoint, hitNormal;
  Fixture? hitFixture;

  AimRayCastCallback(this.ignoreBody);

  @override
  double reportFixture(
    Fixture fixture,
    Vector2 point,
    Vector2 normal,
    double fraction,
  ) {
    if (fixture.body == ignoreBody || fixture.isSensor) {
      return -1.0; // Xuyên qua Lỗ Bida
    }
    hitPoint = point.clone();
    hitNormal = normal.clone();
    hitFixture = fixture;
    return fraction;
  }
}

class CueBall extends BodyComponent {
  final Vector2 initialPosition;
  final double radius;

  Vector2? aimVector, rayHitPoint, reflectionVector;
  Sprite? cueSprite;
  Sprite? cueStickSprite;
  double strokeDistance = 0;
  bool isAiming = true;
  bool isSunk = false;
  bool hitObjectThisShot = false;
  int? firstObjectBallHit;
  bool pocketedThisShot = false;

  CueBall(this.initialPosition, this.radius);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    cueSprite = await Sprite.load('cue_bal.png');
    cueStickSprite = await Sprite.load('cue_stick.png');
  }

  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(
      shape,
      restitution: 0.86,
      density: 0.8,
      friction: 0.32,
    );
    final createdBody = world.createBody(
      BodyDef(
        type: BodyType.dynamic,
        position: initialPosition,
        fixedRotation: true,
        linearDamping: 0.08,
        angularDamping: 0.8,
      ),
    )..createFixture(fixtureDef);
    createdBody.userData = this;
    return createdBody;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Nếu rớt lỗ -> Hồi sinh lại vị trí ban đầu (Hoặc bạn có thể tự thiết lập hệ thống giấu bi cái đi)
    if (isSunk) {
      body.setTransform(initialPosition, 0);
      body.linearVelocity.setZero();
      body.angularVelocity = 0;
      isSunk = false;
    }

    if (aimVector != null && aimVector!.length > 0.0) {
      final callback = AimRayCastCallback(body);
      final p1 = body.position;
      final direction = aimVector!.normalized();
      final p2 = p1 + (direction * 300.0);
      world.raycast(callback, p1, p2);

      if (callback.hitPoint != null &&
          callback.hitNormal != null &&
          callback.hitFixture != null) {
        rayHitPoint = callback.hitPoint;
        final v = direction;
        final n = callback.hitNormal!;
        final dotProduct = v.dot(n);

        if (callback.hitFixture!.shape.shapeType == ShapeType.circle) {
          Vector2 tangentVector = v - (n * dotProduct);
          reflectionVector = tangentVector.length2 > 0.001
              ? tangentVector.normalized()
              : Vector2.zero();
        } else {
          reflectionVector = (v - (n * 2.0 * dotProduct))..normalize();
        }
      } else {
        rayHitPoint = null;
        reflectionVector = null;
      }
    } else {
      rayHitPoint = null;
      reflectionVector = null;
    }
  }

  @override
  void render(Canvas canvas) {
    if (isAiming &&
        aimVector != null &&
        aimVector!.length > 0.0 &&
        cueStickSprite != null) {
      final direction = aimVector!.normalized();
      final stickLength = radius * 9.0;
      final stickHeight = stickLength * 433 / 575;
      // The sprite artwork is diagonal inside its image bounds, so cancel
      // that built-in angle before aligning it with the aiming line.
      final spriteAngle = math.atan2(433, 575);
      final cueAngle = math.atan2(direction.y, direction.x) + spriteAngle;

      canvas.save();
      canvas.translate(
        -direction.x * (radius + strokeDistance),
        -direction.y * (radius + strokeDistance),
      );
      canvas.rotate(cueAngle);
      cueStickSprite!.render(
        canvas,
        position: Vector2(-stickLength, 0),
        size: Vector2(stickLength, stickHeight),
      );
      canvas.restore();
    }

    if (cueSprite != null) {
      canvas.save();
      cueSprite!.render(
        canvas,
        position: Vector2(-radius, -radius),
        size: Vector2(radius * 2, radius * 2),
      );
      canvas.restore();
    }

    if (isAiming && aimVector != null) {
      canvas.save();
      final aimPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..strokeWidth = 0.4;
      final direction = aimVector!.normalized();
      final guide = (game as BilliardGame).guideForAim(direction);
      if (guide != null) {
        final targetOffset = guide.impactPoint - body.position;
        final targetCenterOffset = guide.target.body.position - body.position;
        final targetLineEnd =
            targetCenterOffset + guide.objectDirection * 180.0;
        canvas.drawLine(
          targetOffset.toOffset(),
          targetLineEnd.toOffset(),
          Paint()
            ..color = Colors.white.withOpacity(0.75)
            ..strokeWidth = 0.7,
        );
        canvas.drawCircle(
          targetCenterOffset.toOffset(),
          radius * 1.12,
          Paint()
            ..color = Colors.white.withOpacity(0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8,
        );
      }
      if (rayHitPoint != null && reflectionVector != null) {
        final localHitPoint = rayHitPoint! - body.position;
        canvas.drawLine(Offset.zero, localHitPoint.toOffset(), aimPaint);
        canvas.drawCircle(
          localHitPoint.toOffset(),
          0.6,
          Paint()..color = Colors.red.withOpacity(0.8),
        );
        canvas.drawLine(
          localHitPoint.toOffset(),
          (localHitPoint + (reflectionVector! * 30.0)).toOffset(),
          Paint()
            ..color = Colors.yellow.withOpacity(0.5)
            ..strokeWidth = 0.4,
        );
      } else {
        canvas.drawLine(Offset.zero, (aimVector! * 2.5).toOffset(), aimPaint);
      }
      canvas.restore();
    }
  }
}

class PoolBall extends BodyComponent {
  final Vector2 initialPosition;
  final double radius;
  final String imageName;
  final int number;
  Sprite? ballSprite;
  bool isSunk = false;
  bool pocketedThisShot = false;

  PoolBall(this.initialPosition, this.imageName, this.radius, this.number);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    ballSprite = await Sprite.load(imageName);
  }

  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(
      shape,
      restitution: 0.86,
      density: 0.8,
      friction: 0.32,
    );
    final createdBody = world.createBody(
      BodyDef(
        type: BodyType.dynamic,
        position: initialPosition,
        fixedRotation: true,
        linearDamping: 0.08,
        angularDamping: 0.8,
      ),
    )..createFixture(fixtureDef);
    createdBody.userData = this;
    return createdBody;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isSunk && !isRemoved) {
      removeFromParent(); // Xóa bi khỏi bàn khi lọt lỗ
    }
  }

  @override
  void render(Canvas canvas) {
    if (ballSprite != null) {
      canvas.save();
      // ĐÃ BỎ KHÓA GÓC XOAY
      ballSprite!.render(
        canvas,
        position: Vector2(-radius, -radius),
        size: Vector2(radius * 2, radius * 2),
      );
      canvas.restore();
    }
  }
}
