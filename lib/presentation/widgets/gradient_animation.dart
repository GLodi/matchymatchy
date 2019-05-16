import 'package:flutter/material.dart';

class GradientAnimation extends StatefulWidget {
  final LinearGradient begin;
  final LinearGradient end;
  final AnimationController controller;
  final double height;

  const GradientAnimation({
    Key key,
    @required this.controller,
    @required this.begin,
    @required this.end,
    @required this.height,
  }) : super(key: key);

  @override
  _GradientAnimationState createState() => _GradientAnimationState();
}

class _GradientAnimationState extends State<GradientAnimation> {
  Animation<LinearGradient> _animation;

  @override
  void initState() {
    _animation = LinearGradientTween(
      begin: widget.begin,
      end: widget.end,
    ).animate(widget.controller);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: widget.height,
          ),
          decoration: BoxDecoration(
            gradient: _animation.value,
          ),
        );
      },
    );
  }
}

class LinearGradientTween extends Tween<LinearGradient> {
  LinearGradientTween({
    LinearGradient begin,
    LinearGradient end,
  }) : super(begin: begin, end: end);

  @override
  LinearGradient lerp(double t) => LinearGradient.lerp(begin, end, t);
}
