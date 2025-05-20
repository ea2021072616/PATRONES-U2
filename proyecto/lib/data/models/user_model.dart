class UserModel {
  final String uid;
  final String nombreCompleto;
  final String email;
  final String telefono;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.nombreCompleto,
    required this.email,
    required this.telefono,
    this.photoUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      nombreCompleto: map['nombreCompleto'] ?? '',
      email: map['email'] ?? '',
      telefono: map['telefono'] ?? '',
      photoUrl: map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nombreCompleto': nombreCompleto,
      'email': email,
      'telefono': telefono,
      'photoUrl': photoUrl,
    };
  }
}
