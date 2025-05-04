import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:snake_flame/direction.dart';
import 'package:snake_flame/snake_game.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isTablet(BuildContext context) =>
        MediaQuery.of(context).size.shortestSide >= 600 &&
        MediaQuery.of(context).size.shortestSide < 900;
    bool isDesktop(BuildContext context) =>
        MediaQuery.of(context).size.shortestSide >= 900;

    double screenWidth = MediaQuery.of(context).size.width;

    double gameHeight = screenWidth * 0.6;
    double gameWidth = gameHeight / (16 / 9);

    double iconSize =
        (isDesktop(context) || isTablet(context)) ? screenWidth * 0.04 : 40;

    final SnakeGame game = SnakeGame(context);

    final gameColumn = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 8,
          child: GameWidget(game: game),
        ),
        SizedBox(height: 16),
        Column(
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
        SizedBox(height: 16),
      ],
    );

    return Scaffold(
      body: Center(
        child: isTablet(context) || isDesktop(context)
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
