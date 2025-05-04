import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:snake_flame/direction.dart';
import 'package:snake_flame/snake_game.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    double gameHeight = screenWidth * 0.5;
    double gameWidth = gameHeight / (16 / 9);

    double iconSize = kIsWeb ? screenWidth * 0.02 : 40;

    final SnakeGame game = SnakeGame(context);

    final gameColumn = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 8,
          child: GameWidget(game: game),
        ),
        SizedBox(height: 16),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              IconButton(
                onPressed: () => game.updateDirection(Direction.up),
                icon: Icon(
                  Icons.keyboard_arrow_up,
                  size: iconSize,
                  color: Colors.green,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.keyboard_arrow_left,
                        size: iconSize, color: Colors.green),
                    onPressed: () => game.updateDirection(Direction.left),
                  ),
                  SizedBox(width: 50),
                  IconButton(
                    icon: Icon(Icons.keyboard_arrow_right,
                        size: iconSize, color: Colors.green),
                    onPressed: () => game.updateDirection(Direction.right),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.keyboard_arrow_down,
                    size: iconSize, color: Colors.green),
                onPressed: () => game.updateDirection(Direction.down),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
      ],
    );

    return Scaffold(
      body: Center(
        child: kIsWeb
            ? SizedBox(
                height: gameHeight,
                width: gameWidth,
                child: gameColumn,
              )
            : gameColumn,
      ),
    );
  }
}
