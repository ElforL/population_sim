import 'dart:ui';

import 'package:flame/components.dart';

import 'sim_game.dart';

class Food extends PositionComponent with HasGameRef<BlobsSim> {
  double radius;

  Food([this.radius = 3]);

  @override
  Future<void>? onLoad() {
    size = Vector2(radius, radius);
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color.fromARGB(255, 0, 124, 41);
    canvas.drawCircle(
      const Offset(0, 0),
      radius,
      paint,
    );

    super.render(canvas);
  }

  void die() {
    gameRef.remove(this);
  }
}
