import 'dart:ui';
import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:space_shooter/game/blob.dart';
import 'package:space_shooter/game/food.dart';

class BlobsSim extends FlameGame {
  bool isRunning;

  int initialBlobCount;
  int initialFoodCount;

  /// which iteration the sim is in.
  ///
  /// each iteration/day ends when all blobs are either at home or dead.
  int day = 1;

  /// How many blobs are not home or dead.
  // TODO this is called every update. Optimize it.
  int get activeBlobsCount => children.where((element) => element is Blob && element.isActive).length;

  BlobsSim(
    this.initialBlobCount,
    this.initialFoodCount, {
    this.isRunning = true,
  });

  @override
  Future<void>? onLoad() {
    for (var i = 0; i < initialBlobCount; i++) {
      final blob = Blob(250);
      add(blob);
      final randomCords = blob.getRandomPointCords();
      final borderCords = blob.getClosestBorderCordsFrom(randomCords.x, randomCords.y);
      blob.position = borderCords;
    }

    _addFood();

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    // Draw background
    Rect bgRect = Rect.fromLTWH(0, 0, canvasSize.x, canvasSize.y);
    Paint bgPaint = Paint();
    bgPaint.color = const Color.fromARGB(255, 194, 194, 194);
    canvas.drawRect(bgRect, bgPaint);

    super.render(canvas);
  }

  @override
  void update(double dt) {
    if (isRunning) {
      final isEndOfDay = activeBlobsCount == 0;
      if (isEndOfDay) {
        _newDay();
      }
      super.update(dt);
    }
  }

  void _newDay() {
    // Increase day count
    ++day;

    // Add food
    _addFood();

    // Set blobs' behaviour to searching
    for (var element in children) {
      if (element is Blob) {
        element.behaviour = BlobBehaviour.searching;
        // TODO increase its age
      }
    }
  }

  /// add [initialFoodCount] of [Food] on the board randomly
  ///
  /// [padding] is the distance from the edges that won't have [Food].
  /// [Food] will not be added in this distance from the edges.
  void _addFood([double padding = 50]) {
    children.removeWhere((element) => element is Food);

    for (var i = 0; i < initialFoodCount; i++) {
      final rX = math.Random().nextDouble() * (canvasSize.x - padding * 2);
      final rY = math.Random().nextDouble() * (canvasSize.y - padding * 2);
      final food = Food()..position = Vector2(rX + padding, rY + padding);
      add(food);
    }
  }
}
