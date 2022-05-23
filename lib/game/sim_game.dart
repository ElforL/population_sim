import 'dart:ui';

import 'package:flame/game.dart';

class BlobsSim extends FlameGame {
  bool isRunning = false;

  int initialBlobCount;
  int initialFoodCount;

  List<Vector2> foodCords = [];

  BlobsSim(
    this.initialBlobCount,
    this.initialFoodCount,
  );

  @override
  void render(Canvas canvas) {
    if (isRunning) {
      // TODO: implement render
    }
    super.render(canvas);
  }

  @override
  void update(double dt) {
    if (isRunning) {
      // TODO: implement update
    }
    super.update(dt);
  }
}
