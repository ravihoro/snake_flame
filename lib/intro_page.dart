import 'package:flutter/material.dart';
import 'package:snake_flame/home_page.dart';
import './intro_page_animation.dart';
import 'dart:ui';

class IntroPage extends StatelessWidget {
  final IntroPageAnimation animation;

  IntroPage({
    super.key,
    required AnimationController controller,
  }) : animation = IntroPageAnimation(controller);

  Widget _buildAnimation(BuildContext context, Widget? child) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: animation.backdropOpacity.value,
          child: Image.asset(
            'assets/images/snake.jpg',
            fit: BoxFit.cover,
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: animation.backdropBlur.value,
            sigmaY: animation.backdropBlur.value,
          ),
          child: Container(
            height: 100,
            width: 100,
            color: Colors.black.withOpacity(0.5),
            child: _startButton(context),
          ),
        ),
      ],
    );
  }

  Widget _startButton(BuildContext context) {
    return Center(
      child: Transform(
        transform: Matrix4.diagonal3Values(
          animation.startButton.value,
          animation.startButton.value,
          1.0,
        ),
        child: ElevatedButton(
          child: Text('Start'),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: animation.controller,
        builder: _buildAnimation,
      ),
    );
  }
}
