import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:space_shooter/game/sim_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  final blobsSim = BlobsSim(
    20,
    20,
  );

  var gameWidget = SimulatorWidget(game: blobsSim);

  runApp(MaterialApp(
    home: Padding(
      padding: const EdgeInsets.all(20),
      child: gameWidget,
    ),
  ));
}

Center _skewed(SimulatorWidget gameWidget) {
  return Center(
    child: Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // perspective
        ..rotateX(-0.5),
      alignment: FractionalOffset.center,
      child: SizedBox(
        height: 600,
        width: 600,
        child: gameWidget,
      ),
    ),
  );
}

class SimulatorWidget extends StatefulWidget {
  const SimulatorWidget({
    Key? key,
    required this.game,
  }) : super(key: key);

  final BlobsSim game;

  @override
  State<SimulatorWidget> createState() => _SimulatorWidgetState();
}

class _SimulatorWidgetState extends State<SimulatorWidget> {
  void onKey(RawKeyEvent event) {
    var isSpace = event.logicalKey == LogicalKeyboardKey.space;
    final isPressed = event.isKeyPressed(LogicalKeyboardKey.space);
    if (isSpace && !event.repeat && isPressed) {
      setState(() {
        widget.game.isRunning = !widget.game.isRunning;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      onKey: onKey,
      focusNode: FocusNode(),
      child: Stack(
        children: [
          GameWidget(
            game: widget.game,
          ),
          if (!widget.game.isRunning) const Text('Paused'),
        ],
      ),
    );
  }
}
