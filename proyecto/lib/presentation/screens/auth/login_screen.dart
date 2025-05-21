import 'dart:async';
import 'dart:math';
import 'package:VanguardMoney/core/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../../viewmodels/auth_viewmodel.dart';
// Importa tus widgets personalizados:
import '../../widgets/auth/animated_header.dart';
import '../../widgets/auth/custom_text_field.dart';
import '../../widgets/auth/login_button.dart';
import '../../widgets/auth/or_divider.dart';
import '../../widgets/check.dart'; // <-- Importa tu overlay multifuncional

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _shake = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _gradientController;
  late Animation<Color?> _gradientStart;
  late Animation<Color?> _gradientEnd;

  late ConfettiController _confettiController;

  // Overlay de estado
  bool _showOverlay = false;
  String _overlayMessage = '';
  IconData _overlayIcon = Icons.check_circle_outline;
  Color _overlayColor = Colors.green;

  // Para las burbujas
  final int _bubbleCount = 12;
  late List<_Bubble> _bubbles;

  @override
  void initState() {
    super.initState();

    // Fade-in para el formulario
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // Gradiente animado
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _gradientStart = ColorTween(
      begin: const Color(0xFF377CC8),
      end: const Color(0xFF469B88),
    ).animate(_gradientController);

    _gradientEnd = ColorTween(
      begin: const Color(0xFF469B88),
      end: const Color(0xFF377CC8),
    ).animate(_gradientController);

    // Confetti
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );

    // Burbujas
    final random = Random();
    _bubbles = List.generate(_bubbleCount, (index) {
      return _Bubble(
        left: random.nextDouble(),
        top: random.nextDouble(),
        size: 16.0 + random.nextDouble() * 24.0,
        speed: 0.5 + random.nextDouble() * 1.5,
        color: Colors.white.withOpacity(0.15 + random.nextDouble() * 0.2),
      );
    });
    // Animar burbujas
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        for (final bubble in _bubbles) {
          bubble.top -= bubble.speed / 240;
          if (bubble.top < -0.1) {
            bubble.top = 1.1;
            bubble.left = random.nextDouble();
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _gradientController.dispose();
    _confettiController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loginWithGoogle() async {
    final authVM = context.read<AuthViewModel>();
    try {
      await authVM.loginWithGoogle();
      if (!mounted) return;
      setState(() {
        _showOverlay = true;
        _overlayMessage = '¡Login con Google exitoso!';
        _overlayIcon = Icons.check_circle;
        _overlayColor = Colors.green;
      });
      _confettiController.play();
      await Future.delayed(const Duration(milliseconds: 900));
      setState(() => _showOverlay = false);
      if (mounted) context.go('/home');
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    setState(() => _shake = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _shake = false);
    });
    setState(() {
      _showOverlay = true;
      _overlayMessage = message;
      _overlayIcon = Icons.error_outline;
      _overlayColor = Colors.red;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showOverlay = false);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFED533D),
      ),
    );
  }

  Future<void> _forgotPassword() async {
    final controller = TextEditingController();
    String? errorText;
    bool loading = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setState) => Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 32,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_reset,
                      size: 48,
                      color: Color(0xFF377CC8),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Recuperar contraseña',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        hintText: 'ejemplo@correo.com',
                        errorText: errorText,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      enabled: !loading,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon:
                            loading
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Icon(Icons.send),
                        label: const Text('Enviar enlace'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF377CC8),
                          foregroundColor:
                              Colors.white, // <-- Esto hace el texto blanco
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed:
                            loading
                                ? null
                                : () async {
                                  final email = controller.text.trim();
                                  if (email.isEmpty || !email.contains('@')) {
                                    setState(
                                      () => errorText = 'Correo inválido',
                                    );
                                    return;
                                  }
                                  setState(() {
                                    errorText = null;
                                    loading = true;
                                  });
                                  try {
                                    await context
                                        .read<AuthViewModel>()
                                        .sendPasswordResetEmail(email);
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                    setState(() {
                                      _showOverlay = true;
                                      _overlayMessage = '¡Correo enviado!';
                                      _overlayIcon = Icons.check_circle_outline;
                                      _overlayColor = Colors.green;
                                    });
                                    Future.delayed(
                                      const Duration(seconds: 2),
                                      () {
                                        if (mounted)
                                          setState(() => _showOverlay = false);
                                      },
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Se envió un correo para restablecer tu contraseña',
                                        ),
                                        backgroundColor: Color(0xFF469B88),
                                      ),
                                    );
                                  } catch (e) {
                                    setState(() {
                                      errorText =
                                          'No se pudo enviar el correo: ${e.toString()}';
                                      loading = false;
                                      _showOverlay = true;
                                      _overlayMessage =
                                          'No se pudo enviar el correo';
                                      _overlayIcon = Icons.error_outline;
                                      _overlayColor = Colors.red;
                                    });
                                    Future.delayed(
                                      const Duration(seconds: 2),
                                      () {
                                        if (mounted)
                                          setState(() => _showOverlay = false);
                                      },
                                    );
                                  }
                                },
                      ),
                    ),
                  ],
                ),
              ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Header animado
                AnimatedHeader(
                  gradientController: _gradientController,
                  gradientStart: _gradientStart,
                  gradientEnd: _gradientEnd,
                  bubbles: _bubbles,
                  child: SafeArea(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.account_balance_wallet,
                            size: 54,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Vanguard Money',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Controla tus finanzas fácilmente',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Formulario animado con fade y shake
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Transform.translate(
                          offset: Offset(
                            _shake
                                ? 16 * (_fadeAnimation.value % 2 == 0 ? 1 : -1)
                                : 0,
                            0,
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF242424),
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ingresa tus credenciales para continuar',
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFF9DA7D0),
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Campo Email
                          CustomTextField(
                            controller: _emailCtrl,
                            label: 'Correo electrónico',
                            hint: 'ejemplo@correo.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                          ),
                          const SizedBox(height: 20),

                          // Campo Contraseña
                          CustomTextField(
                            controller: _passwordCtrl,
                            label: 'Contraseña',
                            hint: '••••••••',
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF9DA7D0),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: Validators.password,
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed:
                                  authVM.loading ? null : _forgotPassword,
                              child: Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                  color: const Color(0xFF377CC8),
                                  fontFamily: 'PlusJakartaSans',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Botón de Login con animación de carga y confetti
                          LoginButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  await authVM.login(
                                    _emailCtrl.text.trim(),
                                    _passwordCtrl.text.trim(),
                                  );
                                  if (mounted) {
                                    setState(() {
                                      _showOverlay = true;
                                      _overlayMessage = '¡Login exitoso!';
                                      _overlayIcon = Icons.check_circle;
                                      _overlayColor = Colors.green;
                                    });
                                    _confettiController.play();
                                    await Future.delayed(
                                      const Duration(milliseconds: 900),
                                    );
                                    setState(() => _showOverlay = false);
                                    context.go('/home');
                                  }
                                } catch (e) {
                                  _showError(e.toString());
                                }
                              }
                            },
                            loading: authVM.loading,
                            confettiController: _confettiController,
                          ),
                          const SizedBox(height: 24),

                          // Separador
                          const OrDivider(),
                          const SizedBox(height: 24),

                          // Botón Google
                          OutlinedButton(
                            onPressed: authVM.loading ? null : _loginWithGoogle,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              foregroundColor: const Color(0xFF242424),
                              side: BorderSide(
                                color: Colors.grey.withOpacity(0.3),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/google_icon.png',
                                  height: 24,
                                  width: 24,
                                ),
                                const SizedBox(width: 12),
                                const Text('Continuar con Google'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Enlace a registro
                          Center(
                            child: Text.rich(
                              TextSpan(
                                text: '¿No tienes una cuenta? ',
                                style: TextStyle(
                                  color: const Color(0xFF9DA7D0),
                                  fontFamily: 'PlusJakartaSans',
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Regístrate',
                                    style: TextStyle(
                                      color: const Color(0xFFED533D),
                                      fontWeight: FontWeight.w700,
                                    ),
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () {
                                            context.go('/auth/register');
                                          },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showOverlay)
            StatusOverlay(
              message: _overlayMessage,
              icon: _overlayIcon,
              iconColor: _overlayColor,
            ),
        ],
      ),
    );
  }
}

// Clase para las burbujas animadas
class _Bubble {
  double left;
  double top;
  double size;
  double speed;
  Color color;
  _Bubble({
    required this.left,
    required this.top,
    required this.size,
    required this.speed,
    required this.color,
  });
}
