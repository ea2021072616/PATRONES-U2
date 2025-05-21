import 'dart:ui';
import 'package:flutter/material.dart';

class StatusOverlay extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color iconColor;
  final double iconSize;

  const StatusOverlay({
    super.key,
    required this.message,
    this.icon = Icons.check_circle_outline,
    this.iconColor = Colors.green,
    this.iconSize = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Fondo difuminado y gradiente animado
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF377CC8),
                    Color(0xFF469B88),
                    Color(0xFFED533D),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.1, 0.7, 1.0],
                ),
              ),
              child: Container(color: Colors.black.withOpacity(0.45)),
            ),
          ),
          // Tarjeta flotante con sombra y animación
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              builder:
                  (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 36,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.25),
                      blurRadius: 32,
                      spreadRadius: 2,
                      offset: const Offset(0, 12),
                    ),
                  ],
                  border: Border.all(
                    color: iconColor.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            iconColor.withOpacity(0.25),
                            iconColor.withOpacity(0.10),
                            Colors.transparent,
                          ],
                          radius: 0.8,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: iconSize,
                        shadows: [
                          Shadow(
                            color: iconColor.withOpacity(0.4),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                        shadows: [Shadow(color: Colors.black38, blurRadius: 8)],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
