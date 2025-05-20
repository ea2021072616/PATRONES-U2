import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Método para registrar usuario con email y contraseña
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      await user?.sendEmailVerification();
      return user;
    } catch (e) {
      throw Exception('Error al registrar: $e');
    }
  }

  // Método para iniciar sesión con email y contraseña
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  // Método para iniciar sesión con Google
  Future<User?> signInWithGoogle() async {
    try {
      // Iniciar el flujo de autenticación con Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // Obtener los detalles de autenticación
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Crear una credencial para Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciar sesión en Firebase con la credencial de Google
      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      throw Exception('Error al iniciar sesión con Google: $e');
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _googleSignIn.signOut(); // Cerrar sesión en Google también
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
