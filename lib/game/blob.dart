import 'dart:developer';
import 'dart:ui';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:space_shooter/game/food.dart';

import 'sim_game.dart';

class Blob extends PositionComponent with HasGameRef<BlobsSim> {
  static const _senseRadius = 50;
  static const _speed = 5;
  bool drawSenseCircle = true;

  /// The radius the blob takes.
  // TODO
  /// This may be replaced by 'size'.
  ///
  /// this detemines the blob's size.
  double blobRadius = 8;

  BlobBehaviour behaviour = BlobBehaviour.searching;

  /// The top energy the blob can have
  final double topEnergy;

  /// The current energy lvl the blob has
  double energyLvl;

  int foodCount = 0;
  bool isAlive = true;

  /// a blob is active when not at home or dead (i.e, alive on the board)
  bool get isActive => isAlive && behaviour != BlobBehaviour.atHome;

  /// The cords of the destination the blob is moving towards
  ///
  /// This can be the cords of food when [behaviour] is [BlobBehaviour.foundFood],
  /// or the border when [behaviour] is [BlobBehaviour.headingHome]
  Vector2? _destinationCords;

  Food? foundFood;

  Blob(this.topEnergy) : energyLvl = topEnergy;

  @override
  void render(Canvas canvas) {
    if (drawSenseCircle) {
      canvas.drawCircle(
        const Offset(0, 0),
        _senseRadius.toDouble(),
        Paint()..color = Color.fromARGB(99, 76, 94, 255),
      );
    }

    final paint = Paint();
    if (isAlive) {
      paint.color = const Color.fromARGB(255, 98, 0, 255);
    } else {
      paint.color = const Color.fromARGB(255, 255, 60, 0);
    }

    canvas.drawCircle(
      const Offset(0, 0),
      blobRadius,
      paint,
    );
    super.render(canvas);
  }

  @override
  void update(double dt) {
    switch (behaviour) {
      case BlobBehaviour.searching:
        _searchingHandler();
        break;
      case BlobBehaviour.foundFood:
        _foundFoodHandler();
        break;
      case BlobBehaviour.headingHome:
        _headingHomeHandler();
        break;
      case BlobBehaviour.atHome:
        _atHomeHandler();
        break;
    }
    _deductEnergy();
    if (!isAlive) {
      die();
    }
    super.update(dt);
  }

  void _searchingHandler() {
    var shouldKeepSearching = _shouldKeepSearching();
    if (!shouldKeepSearching) {
      behaviour = BlobBehaviour.headingHome;
      return;
    }

    // Chose random point if [_destinationCords] is null
    _destinationCords ??= getRandomPointCords();

    // Take a step to it
    final didArrive = _stepToDestination(_destinationCords!);
    if (didArrive) _destinationCords = null;

    // Look for food
    foundFood = _scanForFood();
    if (foundFood != null) {
      _destinationCords = Vector2(foundFood!.x, foundFood!.y);
      behaviour = BlobBehaviour.foundFood;
    }
  }

  void _foundFoodHandler() {
    final foodStillExist = gameRef.contains(foundFood!);
    if (foodStillExist) {
      // Take a step to it
      final isAtFood = _stepToDestination(_destinationCords!);

      if (isAtFood) {
        // eat it
        _eat();
      }
    } else {
      foundFood = null;
      _destinationCords = null;
      behaviour = BlobBehaviour.searching;
    }

    // check if energy is enough to stay and look for more food
    if (_shouldKeepSearching()) {
      behaviour = BlobBehaviour.searching;
    } else {
      behaviour = BlobBehaviour.headingHome;
    }
  }

  void _headingHomeHandler() {
    _destinationCords ??= getClosestBorderCordsFrom(x, y);

    final didArrive = _stepToDestination(_destinationCords!);

    if (didArrive) {
      _destinationCords = null;
      behaviour = BlobBehaviour.atHome;
    }
  }

  void _atHomeHandler() {
    energyLvl = topEnergy;
    foodCount = 0;
  }

  void _eat() {
    // Checking if the food still exist is redundent because it should've been checked in `_foundFoodHandler()`
    // before calling `_eat()` but i'm keeping it for now just to be sure.
    // TODO remove?
    final foodStillExist = gameRef.contains(foundFood!);
    if (foodStillExist) {
      foodCount++;
      foundFood!.die();
    }
    foundFood = null;
    _destinationCords = null;
  }

  void die() {
    gameRef.remove(this);
  }

  void _deductEnergy() {
    if (behaviour == BlobBehaviour.atHome) return;

    // TODO create formula
    const amountToDeduct = 1;
    energyLvl -= amountToDeduct;

    if (energyLvl <= 0) {
      isAlive = false;
    }
  }

  /// Scans for [Food] in the [_senseRadius] and returns it.
  ///
  /// Returns null if non is found.
  Food? _scanForFood() {
    try {
      final detectedFood = gameRef.children.firstWhere((food) {
        if (food is! Food) return false;

        // To find food the sense circle and food need to collide. This happens when
        // the distance between the center points is less than the two radii added together.

        // The distance between two points: d = √(Δx² + Δy²)
        final dx = food.x - x;
        final dy = food.y - y;
        final distance = math.sqrt(dx * dx + dy * dy);

        return distance < food.radius + _senseRadius;
      });

      return detectedFood as Food;
    } on StateError catch (_) {
      // No food found.
      return null;
    } catch (e, stack) {
      log(e.toString(), stackTrace: stack);
    }
    return null;
  }

  /// Returns true if arrived
  bool _stepToDestination(Vector2 end) {
    final dx = end.x - x;
    final dy = end.y - y;
    final distance = end.distanceTo(Vector2(x, y));

    final xChange = (dx / distance) * _speed;
    final yChange = (dy / distance) * _speed;

    if (distance > blobRadius / 2) {
      x += xChange;
      y += yChange;
      return false;
    } else {
      // TODO should i remove this?
      // Snaps the blob to [end]
      x = end.x;
      y = end.y;
      return true;
    }
  }

  /// Returns
  /// - `true` if [foodCount] < 1,
  /// - `false` if [foodCount] >= 2
  /// - Otherwise: `true` if energy is above 20%
  bool _shouldKeepSearching() {
    if (foodCount < 1) {
      return true;
    }
    if (foodCount >= 2) {
      return false;
    }
    // Continue searching if energy is above 20%
    return energyLvl > topEnergy * 0.30;
    // TODO consider a different approach? like the energy it needs to reach the border?
    //  and update docs comments if changed
  }

  Vector2 getRandomPointCords() {
    final rX = math.Random().nextDouble() * gameRef.canvasSize.x;
    final rY = math.Random().nextDouble() * gameRef.canvasSize.y;
    return Vector2(rX, rY);
  }

  Vector2 getClosestBorderCordsFrom(double startX, double startY) {
    final width = gameRef.canvasSize.x;
    final height = gameRef.canvasSize.x;

    final distanceFromRight = gameRef.canvasSize.x - startX;
    final distanceFromBottom = gameRef.canvasSize.y - startY;

    bool closerToLeft = startX <= distanceFromRight;
    bool closerToTop = startY <= distanceFromBottom;

    if (closerToTop && closerToLeft) {
      // Top left quarter
      return Vector2(
        startX > startY ? startX : 0,
        startX > startY ? 0 : startY,
      );
    } else if (closerToTop && !closerToLeft) {
      // Top right quarter
      return Vector2(
        distanceFromRight > startY ? startX : width,
        distanceFromRight > startY ? 0 : startY,
      );
    } else if (!closerToTop && closerToLeft) {
      // Bottom left quarter
      return Vector2(
        startX > distanceFromBottom ? startX : 0,
        startX > distanceFromBottom ? height : startY,
      );
    } else {
      // Bottom right quarter
      return Vector2(
        distanceFromRight > distanceFromBottom ? startX : width,
        distanceFromRight > distanceFromBottom ? height : startY,
      );
    }
  }
}

enum BlobBehaviour {
  /// The blob is walking randomly searching for food
  searching,

  /// The blob found food and heading towards it
  foundFood,

  /// The blob got food and heading to the border
  headingHome,

  /// The blob is safe at the border
  atHome,
}
