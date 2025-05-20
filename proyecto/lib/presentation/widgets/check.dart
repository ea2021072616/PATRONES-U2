import 'dart:ui';
import 'package:flutter/material.dart';

class CheckOverlay extends StatelessWidget {
  const CheckOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          Center(
            child: Image.asset('assets/check.png', width: 120, height: 120),
          ),
        ],
      ),
    );
  }
}
