import 'package:flutter/material.dart';

class AnimatedHeader extends StatelessWidget {
  final AnimationController gradientController;
  final Animation<Color?> gradientStart;
  final Animation<Color?> gradientEnd;
  final List<dynamic> bubbles; // Usa tu clase _Bubble
  final Widget child;

  const AnimatedHeader({
    super.key,
    required this.gradientController,
    required this.gradientStart,
    required this.gradientEnd,
    required this.bubbles,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: gradientController,
      builder: (context, _) {
        return Container(
          height: 240,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gradientStart.value ?? const Color(0xFF377CC8),
                gradientEnd.value ?? const Color(0xFF469B88),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: Stack(
            children: [
              ...bubbles.map(
                (bubble) => Positioned(
                  left: bubble.left * MediaQuery.of(context).size.width,
                  top: bubble.top * 240,
                  child: Container(
                    width: bubble.size,
                    height: bubble.size,
                    decoration: BoxDecoration(
                      color: bubble.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              child,
            ],
          ),
        );
      },
    );
  }
}
