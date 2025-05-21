import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../data/models/productos_model.dart';

class InicioViewModel extends ChangeNotifier {
  final String uid;
  final String userName; // Agregamos nombre de usuario para el saludo
  InicioViewModel(this.uid, this.userName);

  // Método para obtener el saludo según la hora del día
  String getSaludo() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días, $userName';
    if (hour < 19) return 'Buenas tardes, $userName';
    return 'Buenas noches, $userName';
  }

  // Obtener las últimas 5 compras (consulta optimizada)
  Stream<List<CompraModel>> getUltimasCompras() {
    return FirebaseFirestore.instance
        .collection('egresos')
        .where('id_usuario', isEqualTo: uid)
        .orderBy('fechaEmision', descending: true)
        .limit(5)
        .snapshots()
        .handleError((error) => print("Error en getUltimasCompras: $error"))
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) =>
                        CompraModel.fromMap(doc.data() as Map<String, dynamic>),
                  )
                  .toList(),
        );
  }

  // Obtener el total gastado en el mes actual (consulta optimizada)
  Stream<double> getTotalMesActual() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    return FirebaseFirestore.instance
        .collection('egresos')
        .where('id_usuario', isEqualTo: uid)
        .where(
          'fechaEmision',
          isGreaterThanOrEqualTo: DateFormat(
            'dd/MM/yyyy',
          ).format(firstDayOfMonth),
        )
        .where(
          'fechaEmision',
          isLessThanOrEqualTo: DateFormat('dd/MM/yyyy').format(lastDayOfMonth),
        )
        .snapshots()
        .handleError((error) => print("Error en getTotalMesActual: $error"))
        .map(
          (snapshot) => snapshot.docs.fold<double>(
            0.0,
            (sum, doc) => sum + (doc.data()['total'] as num).toDouble(),
          ),
        );
  }

  // Obtener las categorías con más gastos (top 3, consulta optimizada)
  Stream<Map<String, double>> getTopCategorias() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    return FirebaseFirestore.instance
        .collection('egresos')
        .where('id_usuario', isEqualTo: uid)
        .where(
          'fechaEmision',
          isGreaterThanOrEqualTo: DateFormat(
            'dd/MM/yyyy',
          ).format(firstDayOfMonth),
        )
        .where(
          'fechaEmision',
          isLessThanOrEqualTo: DateFormat('dd/MM/yyyy').format(lastDayOfMonth),
        )
        .snapshots()
        .handleError((error) => print("Error en getTopCategorias: $error"))
        .map((snapshot) {
          final categorias = <String, double>{};

          for (final doc in snapshot.docs) {
            final productos = (doc.data()['productos'] as List<dynamic>).map(
              (p) => ProductoModel.fromMap(p as Map<String, dynamic>),
            );

            for (final producto in productos) {
              categorias[producto.categoria] =
                  (categorias[producto.categoria] ?? 0.0) + producto.importe;
            }
          }

          final sortedEntries =
              categorias.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

          return Map.fromEntries(sortedEntries.take(3));
        });
  }

  Stream<double> getTotalHoy() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return FirebaseFirestore.instance
        .collection('egresos')
        .where('id_usuario', isEqualTo: uid)
        .where(
          'fechaEmision',
          isGreaterThanOrEqualTo: DateFormat(
            'dd/MM/yyyy HH:mm:ss',
          ).format(startOfDay),
        )
        .where(
          'fechaEmision',
          isLessThanOrEqualTo: DateFormat(
            'dd/MM/yyyy HH:mm:ss',
          ).format(endOfDay),
        )
        .snapshots()
        .map((snapshot) {
          double total = 0;
          for (var doc in snapshot.docs) {
            total += (doc.data()['total'] ?? 0).toDouble();
          }
          return total;
        });
  }

  // Obtener todos los egresos del usuario (sin límite)
  Stream<List<CompraModel>> getAllCompras() {
    return FirebaseFirestore.instance
        .collection('egresos')
        .where('id_usuario', isEqualTo: uid)
        .orderBy('fechaEmision', descending: true)
        .snapshots()
        .handleError((error) => print("Error en getAllCompras: $error"))
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) =>
                        CompraModel.fromMap(doc.data() as Map<String, dynamic>),
                  )
                  .toList(),
        );
  }
}
