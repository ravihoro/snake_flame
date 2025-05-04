import 'package:flutter/material.dart';

class IntroPageAnimation {
  final AnimationController controller;
  final Animation<double> backdropOpacity;
  final Animation<double> backdropBlur;
  final Animation<double> startButton;

  IntroPageAnimation(this.controller)
      : backdropOpacity = Tween<double>(begin: 0.5, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.000,
              0.500,
              curve: Curves.ease,
            ),
          ),
        ),
        backdropBlur = Tween<double>(begin: 0.0, end: 5.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.000,
              0.500,
              curve: Curves.ease,
            ),
          ),
        ),
        startButton = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.300,
              0.800,
              curve: Curves.elasticOut,
            ),
          ),
        );
}
