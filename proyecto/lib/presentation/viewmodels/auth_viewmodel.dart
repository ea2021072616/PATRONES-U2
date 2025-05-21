import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:VanguardMoney/data/services/firestore_service.dart';
import 'package:VanguardMoney/data/services/auth_service.dart';
import 'package:VanguardMoney/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Asegúrate de tener este import

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _user;
  User? get user => _user;

  bool _loading = false;
  bool get loading => _loading;

  UserModel? _userData;
  UserModel? get userData => _userData;

  // Constructor: inicializa el usuario actual si existe
  AuthViewModel() {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      loadUserData();
    }
  }

  // Método privado para manejar loading y notificar listeners
  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  /// Carga la información del usuario desde Firestore
  Future<void> loadUserData() async {
    if (_user != null) {
      final data = await _firestoreService.getUserInfo(_user!.uid);
      if (data.isNotEmpty) {
        _userData = UserModel.fromMap(data);
      } else {
        _userData = null;
      }
      notifyListeners();
    }
  }

  /// Registro de usuario que retorna el UID
  Future<String?> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    _setLoading(true);
    try {
      final userCredential = await _authService.signUpWithEmail(
        email,
        password,
      );
      if (userCredential != null) {
        await _firestoreService.saveUserInfo(
          uid: userCredential.uid,
          nombreCompleto: fullName,
          email: email,
          telefono: phone,
        );
        _user = userCredential;
        await loadUserData();
        return userCredential.uid;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('El correo ya está registrado.');
      } else {
        throw Exception('Error al registrar usuario: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Guardar la URL de la imagen de perfil en Firestore
  Future<void> updateProfileImage(String userId, String imageUrl) async {
    try {
      await _firestoreService.updateUserInfo(uid: userId, photoUrl: imageUrl);
      await loadUserData();
    } catch (e) {
      throw Exception('Error al actualizar imagen de perfil: $e');
    }
  }

  /// Inicio de sesión con email y contraseña
  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _authService.signInWithEmail(email, password);
      await loadUserData();
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Inicio de sesión con Google
  Future<void> loginWithGoogle() async {
    _setLoading(true);
    try {
      _user = await _authService.signInWithGoogle();
      if (_user != null) {
        final userDoc = await _firestoreService.getUserInfo(_user!.uid);
        if (userDoc.isEmpty) {
          await _firestoreService.saveUserInfo(
            uid: _user!.uid,
            nombreCompleto: _user!.displayName ?? 'Usuario Google',
            email: _user!.email ?? '',
            telefono: _user!.phoneNumber ?? '',
          );
        }
        await loadUserData();
      }
    } catch (e) {
      throw Exception('Error al iniciar sesión con Google: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Enviar correo para restablecer contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('No se pudo enviar el correo de recuperación: $e');
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    _userData = null;
    notifyListeners();
  }

  /// Actualizar datos del usuario en Firestore
  Future<void> updateUserProfile({
    required String fullName,
    required String phone,
  }) async {
    _setLoading(true);
    try {
      if (_user == null) throw Exception('No hay usuario autenticado');
      await _firestoreService.updateUserInfo(
        uid: _user!.uid,
        nombreCompleto: fullName,
        telefono: phone,
      );
      await loadUserData();
    } catch (e) {
      throw Exception('No se pudo actualizar el perfil: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<double?> getLimiteGastoDiario() async {
    if (_user == null) return null;
    return await _firestoreService.getLimiteGastoDiario(_user!.uid);
  }

  /// Guardar o actualizar el límite de gasto diario en Firestore
  Future<void> setLimiteGastoDiario(double limite) async {
    if (_user == null) return;
    await _firestoreService.updateLimiteGastoDiario(
      uid: _user!.uid,
      limite: limite,
    );
    await loadUserData();
    notifyListeners();
  }

  /// Escucha los cambios en la sesión
  Stream<User?> get authState => _authService.authStateChanges;
}
