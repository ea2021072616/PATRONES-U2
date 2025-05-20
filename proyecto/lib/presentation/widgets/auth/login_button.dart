import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;
  final ConfettiController confettiController;
  final String text;

  const LoginButton({
    super.key,
    required this.onPressed,
    required this.loading,
    required this.confettiController,
    this.text = 'INICIAR SESIÓN',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: const Color(0xFF377CC8),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 0,
            textStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w600,
            ),
          ),
          child:
              loading
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : Text(text),
        ),
        ConfettiWidget(
          confettiController: confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          emissionFrequency: 0.12,
          numberOfParticles: 16,
          maxBlastForce: 18,
          minBlastForce: 8,
          gravity: 0.3,
          colors: const [
            Color(0xFF377CC8),
            Color(0xFF469B88),
            Color(0xFFED533D),
            Color(0xFF00C49A),
            Colors.white,
          ],
        ),
      ],
    );
  }
}
