import 'dart:collection';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snake_flame/direction.dart';
import 'package:snake_flame/images.dart';

class SnakeGame extends FlameGame {
  final int side = 12;
  late int totalGrids;
  late Queue<int> snake;
  late Set<int> snakeSet;
  late List<List<Direction>> directionGrid;
  late Direction direction;
  late int foodIndex;
  int points = 0;
  late Random random;
  double cellSize = 0;
  bool isGameOver = false;

  final BuildContext context;

  SnakeGame(this.context);

  // Sprites
  late Sprite headLeft,
      headRight,
      headTop,
      headBottom,
      snakeLeft,
      snakeRight,
      snakeTop,
      snakeBottom;
  late Sprite tailLeft, tailRight, tailBottom, tailTop;
  late Sprite quadrantFirst, quadrantSecond, quadrantThird, quadrantFourth;
  late Sprite bodyHorizontal, bodyVertical;
  late Sprite foodSprite;

  @override
  Future<void> onLoad() async {
    await loadAssets();
    totalGrids = side * side;
    initialiseGame();
  }

  Future<void> loadAssets() async {
    headLeft = await loadSprite(AssetImages.headLeftPath);
    headRight = await loadSprite(AssetImages.headRightPath);
    headTop = await loadSprite(AssetImages.headTopPath);
    headBottom = await loadSprite(AssetImages.headBottomPath);
    tailLeft = await loadSprite(AssetImages.tailLeftPath);
    tailRight = await loadSprite(AssetImages.tailRightPath);
    tailBottom = await loadSprite(AssetImages.tailBottomPath);
    tailTop = await loadSprite(AssetImages.tailTopPath);
    quadrantFirst = await loadSprite(AssetImages.quadrantFirst);
    quadrantSecond = await loadSprite(AssetImages.quadrantSecond);
    quadrantThird = await loadSprite(AssetImages.quadrantThird);
    quadrantFourth = await loadSprite(AssetImages.quadrantFourth);
    bodyHorizontal = await loadSprite(AssetImages.bodyHorizontalPath);
    bodyVertical = await loadSprite(AssetImages.bodyVerticalPath);
    foodSprite = await loadSprite(AssetImages.fruit);
    snakeLeft = await loadSprite(AssetImages.snakeLeft);
    snakeRight = await loadSprite(AssetImages.snakeRight);
    snakeTop = await loadSprite(AssetImages.snakeTop);
    snakeBottom = await loadSprite(AssetImages.snakeBottom);
  }

  void initialiseGame() {
    snake = Queue();
    snakeSet = {};
    directionGrid =
        List.generate(side, (_) => List.generate(side, (_) => Direction.right));
    direction = Direction.right;
    random = Random();

    int start = random.nextInt(totalGrids);
    snake.addFirst(start);
    snakeSet.add(start);
    foodIndex = generateFood();

    points = 0;
    isGameOver = false;
    cellSize = size.x / side;
  }

  int generateFood() {
    int index;
    do {
      index = random.nextInt(totalGrids);
    } while (snakeSet.contains(index));
    return index;
  }

  void updateDirection(Direction newDirection) {
    // Prevent reversing direction
    if (_isOppositeDirection(newDirection)) return;

    HapticFeedback.heavyImpact();

    final row = _row(snake.first);
    final col = _col(snake.first);

    // Only update if it's a valid direction change
    directionGrid[row][col] = newDirection;
    direction = newDirection;
  }

  bool _isOppositeDirection(Direction newDir) {
    return (direction == Direction.left && newDir == Direction.right) ||
        (direction == Direction.right && newDir == Direction.left) ||
        (direction == Direction.up && newDir == Direction.down) ||
        (direction == Direction.down && newDir == Direction.up);
  }

  double _accumulatedTime = 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    _accumulatedTime += dt;
    if (_accumulatedTime >= 0.25) {
      _moveSnake();
      _accumulatedTime = 0;
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Game Over'),
        content: Text('The snake crashed! What would you like to do?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              initialiseGame(); // restart game
            },
            child: Text('Restart'),
          ),
          if (!kIsWeb)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Future.delayed(Duration(milliseconds: 100), () {
                  // exit app gracefully
                  SystemNavigator.pop();
                });
              },
              child: Text('Exit'),
            ),
        ],
      ),
    );
  }

  void _moveSnake() {
    final head = snake.first;
    final next = _nextPosition(head);

    if (snakeSet.contains(next)) {
      HapticFeedback.heavyImpact();
      isGameOver = true;
      _showGameOverDialog();
      return;
    }

    final row = _row(next);
    final col = _col(next);
    directionGrid[row][col] = direction;

    snake.addFirst(next);
    snakeSet.add(next);

    if (next == foodIndex) {
      points++;
      foodIndex = generateFood();
    } else {
      final removed = snake.removeLast();
      snakeSet.remove(removed);
    }
  }

  int _nextPosition(int index) {
    switch (direction) {
      case Direction.left:
        return (index % side == 0) ? index + side - 1 : index - 1;
      case Direction.right:
        return (index % side == side - 1) ? index - (side - 1) : index + 1;
      case Direction.up:
        return (index - side < 0) ? index + (totalGrids - side) : index - side;
      case Direction.down:
        return (index + side >= totalGrids) ? index % side : index + side;
      default:
        return index;
    }
  }

  int _row(int index) => index ~/ side;
  int _col(int index) => index % side;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    drawGrid(canvas);

    for (int i = 0; i < snake.length; i++) {
      final index = snake.elementAt(i);
      final row = _row(index);
      final col = _col(index);
      final x = col * cellSize;
      final y = row * cellSize;

      if (i == 0) {
        Direction actualHeadDirection;

        if (snake.length > 1) {
          final next = snake.elementAt(1);
          final curr = snake.first;
          final dr = _wrappedDelta(_row(next), _row(curr), side);
          final dc = _wrappedDelta(_col(next), _col(curr), side);

          if (dr == -1) {
            actualHeadDirection = Direction.up;
          } else if (dr == 1) {
            actualHeadDirection = Direction.down;
          } else if (dc == -1) {
            actualHeadDirection = Direction.left;
          } else {
            actualHeadDirection = Direction.right;
          }

          final headSprite = _getHeadSprite(actualHeadDirection);
          headSprite.render(canvas,
              position: Vector2(x, y), size: Vector2(cellSize, cellSize));
        } else {
          // Snake length is 1, use alternate sprites
          Sprite singleHeadSprite;
          switch (direction) {
            case Direction.left:
              singleHeadSprite = snakeLeft;
              break;
            case Direction.right:
              singleHeadSprite = snakeRight;
              break;
            case Direction.up:
              singleHeadSprite = snakeTop;
              break;
            case Direction.down:
              singleHeadSprite = snakeBottom;
              break;
            default:
              singleHeadSprite = snakeRight;
          }

          singleHeadSprite.render(canvas,
              position: Vector2(x, y), size: Vector2(cellSize, cellSize));
        }

        // // Determine the actual head direction based on the next segment position
        // Direction actualHeadDirection;
        // if (snake.length > 1) {
        //   final next = snake.elementAt(1);
        //   final curr = snake.first;
        //   final dr = _wrappedDelta(_row(next), _row(curr), side);
        //   final dc = _wrappedDelta(_col(next), _col(curr), side);

        //   if (dr == -1) {
        //     actualHeadDirection = Direction.up;
        //   } else if (dr == 1) {
        //     actualHeadDirection = Direction.down;
        //   } else if (dc == -1) {
        //     actualHeadDirection = Direction.left;
        //   } else {
        //     actualHeadDirection = Direction.right;
        //   }
        // } else {
        //   // Default to current direction if only 1 segment (head) exists
        //   actualHeadDirection = direction;
        // }

        // // Get the correct head sprite
        // final headSprite = _getHeadSprite(actualHeadDirection);

        // // Render the head sprite
        // headSprite.render(canvas,
        //     position: Vector2(x, y), size: Vector2(cellSize, cellSize));

        // // final headDirection = directionGrid[row][col];
        // // final headSprite = _getHeadSprite(headDirection);
        // // headSprite.render(canvas,
        // //     position: Vector2(x, y), size: Vector2(cellSize, cellSize));
      } else if (i == snake.length - 1) {
        final tail = snake.elementAt(i);
        final beforeTail = snake.elementAt(i - 1);
        final tailSprite = _getTailSprite(tail, beforeTail);
        tailSprite.render(canvas,
            position: Vector2(x, y), size: Vector2(cellSize, cellSize));
      } else {
        final prev = snake.elementAt(i - 1);
        final curr = snake.elementAt(i);
        final next = snake.elementAt(i + 1);
        final bodySprite = _getBodySprite(prev, curr, next);
        bodySprite.render(canvas,
            position: Vector2(x, y), size: Vector2(cellSize, cellSize));
      }
    }

    final foodRow = _row(foodIndex);
    final foodCol = _col(foodIndex);
    final foodX = foodCol * cellSize;
    final foodY = foodRow * cellSize;
    foodSprite.render(canvas,
        position: Vector2(foodX, foodY), size: Vector2(cellSize, cellSize));
  }

  Sprite _getHeadSprite(Direction dir) {
    switch (dir) {
      case Direction.left:
        return headLeft;
      case Direction.right:
        return headRight;
      case Direction.up:
        return headTop;
      case Direction.down:
        return headBottom;
      default:
        return headRight;
    }
  }

  Sprite _getTailSprite(int tailIndex, int beforeTailIndex) {
    final tailRow = _row(tailIndex);
    final tailCol = _col(tailIndex);

    final beforeTailRow = _row(beforeTailIndex);
    final beforeTailCol = _col(beforeTailIndex);

    if (beforeTailRow == tailRow) {
      return beforeTailCol < tailCol ? tailLeft : tailRight;
    } else if (beforeTailCol == tailCol) {
      return beforeTailRow < tailRow ? tailTop : tailBottom;
    }

    return tailRight;
  }

  Sprite _getBodySprite(int prevIndex, int currIndex, int nextIndex) {
    final prevRow = _row(prevIndex);
    final prevCol = _col(prevIndex);
    final currRow = _row(currIndex);
    final currCol = _col(currIndex);
    final nextRow = _row(nextIndex);
    final nextCol = _col(nextIndex);

    final dRow1 = _wrappedDelta(prevRow, currRow, side);
    final dCol1 = _wrappedDelta(prevCol, currCol, side);
    final dRow2 = _wrappedDelta(currRow, nextRow, side);
    final dCol2 = _wrappedDelta(currCol, nextCol, side);

    // Straight
    if (dRow1 == 0 && dRow2 == 0) return bodyHorizontal;
    if (dCol1 == 0 && dCol2 == 0) return bodyVertical;

    // First quadrant
    if ((dCol1 == 1 && dRow2 == -1) || (dRow1 == 1 && dCol2 == -1)) {
      return quadrantFirst;
    }

    // Second quadrant
    if ((dCol1 == -1 && dRow2 == -1) || (dRow1 == 1 && dCol2 == 1)) {
      return quadrantSecond;
    }

    // Third quadrant
    if ((dCol1 == -1 && dRow2 == 1) || (dRow1 == -1 && dCol2 == 1)) {
      return quadrantThird;
    }

    // Fourth quadrant
    if ((dCol1 == 1 && dRow2 == 1) || (dRow1 == -1 && dCol2 == -1)) {
      return quadrantFourth;
    }

    return bodyHorizontal;
  }

  int _wrappedDelta(int from, int to, int max) {
    int delta = to - from;
    if (delta == max - 1) return -1;
    if (delta == -(max - 1)) return 1;
    return delta;
  }

  void drawGrid(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFFBDBDBD)
      ..style = PaintingStyle.stroke;

    for (int row = 0; row < side; row++) {
      for (int col = 0; col < side; col++) {
        final x = col * cellSize;
        final y = row * cellSize;
        canvas.drawRect(Rect.fromLTWH(x, y, cellSize, cellSize), paint);
      }
    }
  }

  // Expose getters
  Queue<int> get snakePositions => snake;
  int get food => foodIndex;
  List<List<Direction>> get directions => directionGrid;
}
