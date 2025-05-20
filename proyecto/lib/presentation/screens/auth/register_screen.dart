import 'dart:io';
import 'package:confetti/confetti.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/auth/custom_text_field.dart';
import '../../widgets/auth/login_button.dart';
import '../../widgets/auth/or_divider.dart';
import '../../../core/utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  File? _profileImage;
  bool _uploadingImage = false;
  bool _pickingImage = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_pickingImage) return;
    _pickingImage = true;
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } finally {
      _pickingImage = false;
    }
  }

  Future<String?> _uploadProfileImage(String userId) async {
    if (_profileImage == null) return null;
    setState(() => _uploadingImage = true);
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$userId.jpg');
      await ref.putFile(_profileImage!);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    } finally {
      setState(() => _uploadingImage = false);
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final authVM = context.read<AuthViewModel>();
    final scaffold = ScaffoldMessenger.of(context);

    try {
      final userId = await authVM.register(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        fullName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );
      String? imageUrl;
      if (userId != null) {
        imageUrl = await _uploadProfileImage(userId);
        if (imageUrl != null) {
          await authVM.updateProfileImage(userId, imageUrl);
        }
      }
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundImage:
                              _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : null,
                          backgroundColor: const Color(0xFFE9F5F3),
                          child:
                              _profileImage == null
                                  ? const Icon(
                                    Icons.person,
                                    size: 48,
                                    color: Color(0xFF00C49A),
                                  )
                                  : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Color(0xFF00C49A),
                            ),
                            onPressed: _pickImage,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_uploadingImage)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: LinearProgressIndicator(),
                    ),
                  const SizedBox(height: 24),

                  // Nombre
                  CustomTextField(
                    controller: _nameCtrl,
                    label: 'Nombre Completo',
                    hint: 'Ejemplo: Juan Pérez',
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu nombre';
                      }
                      if (value.length < 3) {
                        return 'Nombre demasiado corto';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Teléfono
                  CustomTextField(
                    controller: _phoneCtrl,
                    label: 'Teléfono',
                    hint: 'Ejemplo: 987654321',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu teléfono';
                      }
                      final phoneRegex = RegExp(r'^[0-9]{9}$');
                      if (!phoneRegex.hasMatch(value)) {
                        return 'Ingresa un teléfono válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Correo
                  CustomTextField(
                    controller: _emailCtrl,
                    label: 'Correo electrónico',
                    hint: 'ejemplo@correo.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 20),

                  // Contraseña
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
                  const SizedBox(height: 20),

                  // Confirmar contraseña
                  CustomTextField(
                    controller: _confirmPasswordCtrl,
                    label: 'Confirmar Contraseña',
                    hint: '••••••••',
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF9DA7D0),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value != _passwordCtrl.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Botón de registro
                  LoginButton(
                    text: 'REGISTRARSE',
                    loading: authVM.loading,
                    confettiController: ConfettiController(
                      duration: const Duration(seconds: 1),
                    ),
                    onPressed:
                        authVM.loading ? null : () => _submitForm(context),
                  ),
                  const SizedBox(height: 24),

                  // Separador
                  const OrDivider(),
                  const SizedBox(height: 24),

                  // Botón para ir a login
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: '¿Ya tienes una cuenta? ',
                        style: TextStyle(
                          color: const Color(0xFF9DA7D0),
                          fontFamily: 'PlusJakartaSans',
                        ),
                        children: [
                          TextSpan(
                            text: 'Iniciar Sesión',
                            style: TextStyle(
                              color: const Color(0xFF00C49A),
                              fontWeight: FontWeight.w700,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    context.go('/auth/login');
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
      ),
    );
  }
}
