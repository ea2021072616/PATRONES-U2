import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/auth/custom_text_field.dart';
import '../../../core/utils/validators.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();

  File? _profileImage;
  bool _uploadingImage = false;
  bool _pickingImage = false;

  @override
  void initState() {
    super.initState();
    final authViewModel = context.read<AuthViewModel>();
    _nameController = TextEditingController(
      text: authViewModel.userData?.nombreCompleto ?? '',
    );
    _phoneController = TextEditingController(
      text: authViewModel.userData?.telefono ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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
        await _uploadProfileImage(context);
      }
    } finally {
      _pickingImage = false;
    }
  }

  Future<void> _uploadProfileImage(BuildContext context) async {
    if (_profileImage == null) return;
    setState(() => _uploadingImage = true);
    final authViewModel = context.read<AuthViewModel>();
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${authViewModel.user?.uid}.jpg');
      await ref.putFile(_profileImage!);
      final url = await ref.getDownloadURL();
      if (!mounted) return;
      await authViewModel.updateProfileImage(authViewModel.user!.uid, url);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Imagen actualizada')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al subir imagen: $e')));
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  Future<void> _saveChanges(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();
    final scaffold = ScaffoldMessenger.of(context);

    try {
      await authViewModel.updateUserProfile(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;
      scaffold.showSnackBar(
        const SnackBar(content: Text('Cambios guardados exitosamente')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      scaffold.showSnackBar(
        SnackBar(content: Text('Error al guardar: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final userData = authViewModel.userData;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: const Color(0xFF00C49A),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveChanges(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Imagen de perfil editable
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundImage:
                              _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : (userData?.photoUrl != null &&
                                          userData!.photoUrl!.isNotEmpty
                                      ? NetworkImage(userData!.photoUrl!)
                                      : null),
                          backgroundColor: const Color(0xFFE9F5F3),
                          child:
                              (userData?.photoUrl == null &&
                                      _profileImage == null)
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
                            onPressed: _uploadingImage ? null : _pickImage,
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

                  _buildReadOnlyField(
                    'ID de Usuario',
                    authViewModel.user?.uid ?? 'No disponible',
                    Icons.fingerprint,
                  ),
                  const SizedBox(height: 20),
                  _buildReadOnlyField(
                    'Correo Electrónico',
                    authViewModel.user?.email ?? 'No disponible',
                    Icons.email,
                  ),
                  const SizedBox(height: 30),

                  // Nombre editable
                  CustomTextField(
                    controller: _nameController,
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

                  // Teléfono editable
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Teléfono',
                    hint: 'Ejemplo: 987654321',
                    keyboardType: TextInputType.phone,
                    validator: Validators.phone,
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          authViewModel.loading
                              ? null
                              : () => _saveChanges(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C49A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          authViewModel.loading
                              ? const CircularProgressIndicator()
                              : const Text(
                                'GUARDAR CAMBIOS',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
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

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey),
              const SizedBox(width: 12),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}
