import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../game_config.dart';
import '../peace_break_game.dart';

class PlayArea extends PositionComponent
    with DragCallbacks, TapCallbacks, HasGameReference<PeaceBreakGame> {
  PlayArea() : super(size: Vector2(kGameWidth, kGameHeight));

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    game.movePaddle(event.localPosition.x);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    game.movePaddle(event.localPosition.x);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    game.movePaddle(event.localStartPosition.x + event.localDelta.x);
  }
}
