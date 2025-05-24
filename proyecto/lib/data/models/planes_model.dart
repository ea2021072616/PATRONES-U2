import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriaModel {
  final String nombre;
  final double montoMaximo;

  CategoriaModel({
    required this.nombre,
    required this.montoMaximo,
  });

  factory CategoriaModel.fromMap(Map<String, dynamic> map) {
    return CategoriaModel(
      nombre: map['nombre'] ?? '',
      montoMaximo: (map['montoMaximo'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'montoMaximo': montoMaximo,
    };
  }
}

class PlanMonetarioModel {
  final String id;
  final String uid;
  final double montoTotal;
  final List<CategoriaModel> categorias;
  final String? fecha; // <-- ahora es String
  final String? fechaLocal;

  PlanMonetarioModel({
    required this.id,
    required this.uid,
    required this.montoTotal,
    required this.categorias,
    this.fecha,
    this.fechaLocal,
  });

  factory PlanMonetarioModel.fromMap(Map<String, dynamic> map, String id) {
    return PlanMonetarioModel(
      id: id,
      uid: map['uid'] ?? '',
      montoTotal: (map['montoTotal'] as num?)?.toDouble() ?? 0.0,
      categorias: (map['categorias'] as List<dynamic>? ?? [])
          .map((cat) => CategoriaModel.fromMap(cat as Map<String, dynamic>))
          .toList(),
      fecha: map['fecha']?.toString(), // <-- convertir a String
      fechaLocal: map['fechaLocal'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'montoTotal': montoTotal,
      'categorias': categorias.map((cat) => cat.toMap()).toList(),
      'fecha': fecha,
      'fechaLocal': fechaLocal,
    };
  }
}