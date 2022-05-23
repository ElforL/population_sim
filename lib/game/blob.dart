import 'dart:ui';

import 'package:flame/components.dart';

import 'sim_game.dart';

class Blob extends PositionComponent with HasGameRef<BlobsSim> {
  static const _senseRadius = 10;

  BlobBehaviour behaviour = BlobBehaviour.searching;

  /// The top energy the blob can have
  final double topEnergy;

  /// The current energy lvl the blob has
  double energyLvl;

  int foodCount = 0;
  bool isAlive = true;

  /// The cords of the destination the blob is moving towards
  ///
  /// This can be the cords of food when [behaviour] is [BlobBehaviour.foundFood],
  /// or the border when [behaviour] is [BlobBehaviour.headingHome]
  Vector2? _destinationCords;

  Blob(this.topEnergy) : energyLvl = topEnergy;

  @override
  void render(Canvas canvas) {
    // TODO: implement update
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
      gameRef.remove(this);
    }
    super.update(dt);
  }

  void _searchingHandler() {
    // Chose random point if [_destinationCords] is null
    _destinationCords ??= _getRandomPointCords();

    // Take a step to it
    _stepToDestination(_destinationCords!);

    // Look for food
    Vector2? foundFoodCords; // = _lookForFood();
    if (foundFoodCords != null) {
      _destinationCords = foundFoodCords;
      behaviour = BlobBehaviour.foundFood;
    }
  }

  void _foundFoodHandler() {
    // TODO

    // Take a step to it
    _stepToDestination(_destinationCords!);

    if (true /* TODO: food is close */) {
      // eat it
      ++foodCount;
      // TODO check if this actually remove the food or should i change it to `.removeWhere()`.
      //  In case `.remove()` remove the ref of Vector2 element in it and [_destinationCords] doesn't match any.
      // this 👆 is such bad english i'm sorry me but i think you'll get it :).
      gameRef.foodCords.remove(_destinationCords);
      _destinationCords = null;

      // check if energy is enough to stay and look for more food
      if (_shouldKeepSearching()) {
        behaviour = BlobBehaviour.searching;
      } else {
        behaviour = BlobBehaviour.headingHome;
      }
    }
  }

  void _headingHomeHandler() {
    // TODO
  }
  void _atHomeHandler() {
    // TODO
  }

  void _deductEnergy() {
    // TODO

    final amountToDeduct = 5;
    energyLvl -= amountToDeduct;

    if (energyLvl <= 0) {
      isAlive = false;
    }
  }

  void _stepToDestination(Vector2 cords) {
    // TODO
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
    return energyLvl > topEnergy * 0.20;
    // TODO consider a different approach? like the energy it needs to reach the border?
    //  and update docs comments if changed
  }

  Vector2 _getRandomPointCords() {
    // TODO
    return Vector2(5, 5);
  }

  Vector2 _getClosestBorderCords() {
    // TODO
    return Vector2(0, 0);
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
