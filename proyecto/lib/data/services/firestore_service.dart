import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Guarda la información inicial del usuario en Firestore.
  Future<void> saveUserInfo({
    required String uid,
    required String nombreCompleto,
    required String email,
    required String telefono,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'nombreCompleto': nombreCompleto,
        'email': email,
        'telefono': telefono,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al guardar usuario en Firestore: $e');
    }
  }

  /// Obtiene la información del usuario por UID.
  Future<Map<String, dynamic>> getUserInfo(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>? ?? {};
    } catch (e) {
      throw Exception('Error al leer usuario de Firestore: $e');
    }
  }

  /// Actualiza la información del usuario. Solo actualiza los campos enviados.
  Future<void> updateUserInfo({
    required String uid,
    String? nombreCompleto,
    String? telefono,
    String? photoUrl,
  }) async {
    final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};
    if (nombreCompleto != null) data['nombreCompleto'] = nombreCompleto;
    if (telefono != null) data['telefono'] = telefono;
    if (photoUrl != null) data['photoUrl'] = photoUrl;

    if (data.length == 1) return; // No hay datos para actualizar
    await _firestore.collection('users').doc(uid).update(data);
  }

  /// Actualiza solo el límite de gasto diario
  Future<void> updateLimiteGastoDiario({
    required String uid,
    required double limite,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'limiteGastoDiario': limite,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Obtiene el límite de gasto diario
  Future<double?> getLimiteGastoDiario(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data()!.containsKey('limiteGastoDiario')) {
      return (doc.data()!['limiteGastoDiario'] as num).toDouble();
    }
    return null;
  }
}
