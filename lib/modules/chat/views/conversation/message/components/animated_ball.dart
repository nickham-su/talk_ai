import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 动画圆球
class AnimatedBall extends StatefulWidget {
  const AnimatedBall({Key? key}) : super(key: key);

  @override
  _AnimatedBallState createState() => _AnimatedBallState();
}

class _AnimatedBallState extends State<AnimatedBall>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this)
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Ball(
      // scale: Tween<double>(begin: 0.5, end: 1).animate(_controller),
      scale: CustomAnimate().animate(_controller),
    );
  }
}

/// 圆球
class Ball extends StatelessWidget {
  final Animation<double> scale;

  const Ball({Key? key, required this.scale}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: Get.theme.colorScheme.primary),
      ),
    );
  }
}

/// 自定义动画
class CustomAnimate extends Animatable<double> {
  CustomAnimate();

  @override
  double transform(double t) {
    late double result;
    if (t == 0.0 || t == 1.0) {
      result = t;
    } else {
      result = Curves.easeInOut.transform(t);
    }
    return result * 0.4 + 0.6;
  }
}
