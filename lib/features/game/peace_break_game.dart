import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'dart:math';

import '../../services/inventory_service.dart';
import 'components/ball.dart';
import 'components/brick.dart';
import 'components/paddle.dart';
import 'components/play_area.dart';
import 'components/power_capsule.dart';
import 'game_config.dart';
import 'game_state.dart';
import 'levels.dart';
import 'power_up.dart';
import 'skins.dart';

class PeaceBreakGame extends FlameGame with HasCollisionDetection {
  PeaceBreakGame({required this.state, this.skins = const EquippedSkins()})
    : super(
        camera: CameraComponent.withFixedResolution(
          width: kGameWidth,
          height: kGameHeight,
        ),
      );

  final GameState state;
  int get stage => state.stage;

  late final Paddle paddle;
  late final Ball ball;

  int _remainingBricks = 0;
  bool _over = false;

  String loseReason = '';
  VoidCallback? onWin;

  final _random = Random();

  final EquippedSkins skins;

  final Map<PowerType, double> _activePowers = {};
  Map<PowerType, double> get activePowers => Map.unmodifiable(_activePowers);

  @override
  Color backgroundColor() => const Color(0xFF060A06);

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;

    paddle = Paddle(style: paddleStyle(skins.paddle));
    ball = Ball(
      position: Vector2(kGameWidth / 2, kPaddleY - 40),
      style: ballStyle(skins.ball),
    );

    world.addAll([PlayArea(), paddle, ball]);

    _buildWall();
    ball.launch();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_over) return;
    if (state.tick(dt)) _lose('Temps écoulé');

    if (_activePowers.isNotEmpty) {
      for (final type in _activePowers.keys.toList()) {
        final left = _activePowers[type]! - dt;
        if (left <= 0) {
          _expirePower(type);
        } else {
          _activePowers[type] = left;
        }
      }
    }
  }

  void _buildWall() {
    final def = level(stage);
    var count = 0;

    for (var row = 0; row < def.rows.length; row++) {
      final line = def.rows[row];
      for (var col = 0; col < kGridColumns && col < line.length; col++) {
        final hp = int.tryParse(line[col]);
        if (hp == null || hp <= 0) continue;

        world.add(
          Brick(
            position: Vector2(
              kGridMargin + col * (kBrickWidth + kBrickGap),
              kGridTop + row * (kBrickHeight + kBrickGap),
            ),
            hitPoints: hp,
          ),
        );
        count++;
      }
    }
    _remainingBricks = count;
  }

  void movePaddle(double x) {
    paddle.moveTo(x);
    if (ball.velocity.isZero()) ball.position.x = paddle.position.x;
  }

  void onBrickDestroyed(Brick brick) {
    state.rewardBrick(brick.initialHitPoints);
    _maybeDropPower(brick.absoluteCenter);
    _remainingBricks--;
    if (_remainingBricks <= 0) _win();
  }

  void _maybeDropPower(Vector2 at) {
    if (_random.nextDouble() > kDropChance) return;
    final type = PowerType.values[_random.nextInt(PowerType.values.length)];
    world.add(PowerCapsule(position: at.clone(), type: type));
  }

  void onBallLost() {
    if (_over) return;

    if (state.loseLife()) {
      _lose('Plus de vies');
      return;
    }
    _resetBall();
  }

  void _resetBall() {
    ball
      ..position = Vector2(paddle.position.x, kPaddleY - 40)
      ..velocity = Vector2.zero();
    ball.launch();
  }

  void _win() {
    if (_over) return;
    _over = true;
    state.applyVictoryBonuses();
    ball.velocity = Vector2.zero();
    pauseEngine();
    onWin?.call();
    overlays.add('won');
  }

  void _lose(String reason) {
    if (_over) return;
    _over = true;
    loseReason = reason;
    ball.velocity = Vector2.zero();
    pauseEngine();
    overlays.add('lost');
  }

  void togglePause() {
    if (_over) return;
    if (paused) {
      overlays.remove('paused');
      resumeEngine();
    } else {
      pauseEngine();
      overlays.add('paused');
    }
  }

  void applyPower(PowerType type) {
    switch (type) {
      case PowerType.extraLife:
        state.gainLife();
        return;
      case PowerType.widerPaddle:
        paddle.resizeTo(kPaddleWideWidth);
        _activePowers.remove(PowerType.narrowerPaddle);
      case PowerType.narrowerPaddle:
        paddle.resizeTo(kPaddleNarrowWidth);
        _activePowers.remove(PowerType.widerPaddle);
      case PowerType.fasterBall:
        ball.setSpeed(kBallFastSpeed);
    }
    _activePowers[type] = kPowerDuration;
    state.notifyPowers();
  }

  void _expirePower(PowerType type) {
    _activePowers.remove(type);
    switch (type) {
      case PowerType.widerPaddle:
      case PowerType.narrowerPaddle:
        paddle.resizeTo(kPaddleWidth);
      case PowerType.fasterBall:
        ball.setSpeed(kBallSpeed);
      case PowerType.extraLife:
        break;
    }
    state.notifyPowers();
  }
}
