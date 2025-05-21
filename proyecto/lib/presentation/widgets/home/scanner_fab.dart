import 'package:flutter/material.dart';

class ScannerFab extends StatelessWidget {
  final VoidCallback onPressed;
  const ScannerFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: const Color(0xFF377CC8),
      elevation: 4,
      shape: const CircleBorder(),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF377CC8),
              const Color(0xFF377CC8).withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF377CC8).withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
      ),
    );
  }
}
