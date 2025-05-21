import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener intl en tu pubspec.yaml
import '../../data/models/productos_model.dart';

class CategoriaDetalleLogic {
  final String categoria;
  final String uid;

  CategoriaDetalleLogic({required this.categoria, required this.uid});

  // Verifica si la fecha es del mes y año actual (formato: dd/MM/yyyy HH:mm:ss)
  bool _esDelMesActual(String fechaEmision) {
    final hoy = DateTime.now();
    try {
      final fecha = DateFormat('dd/MM/yyyy HH:mm:ss').parse(fechaEmision);
      return fecha.year == hoy.year && fecha.month == hoy.month;
    } catch (e) {
      return false;
    }
  }

  /// Devuelve un stream de facturas (egresos) filtradas por usuario, categoría y mes actual
  Stream<List<CompraModel>> getFacturasFiltradas() {
    return FirebaseFirestore.instance
        .collection('egresos')
        .where('id_usuario', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CompraModel.fromMap(doc.data() as Map<String, dynamic>))
            .where((compra) =>
                _esDelMesActual(compra.fechaEmision) &&
                compra.productos.any((producto) => producto.categoria == categoria))
            .toList());
  }

  /// Devuelve un stream con el total gastado SOLO en la categoría seleccionada y mes actual
  Stream<double> getTotalGastado() {
    return FirebaseFirestore.instance
        .collection('egresos')
        .where('id_usuario', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CompraModel.fromMap(doc.data() as Map<String, dynamic>))
            .where((compra) => _esDelMesActual(compra.fechaEmision))
            .expand((compra) => compra.productos)
            .where((producto) => producto.categoria == categoria)
            .fold<double>(0.0, (sum, producto) => sum + producto.importe));
  }

  /// Devuelve un stream con el total gastado en TODAS las categorías y mes actual
  Stream<double> getTotalGastadoGeneral() {
    return FirebaseFirestore.instance
        .collection('egresos')
        .where('id_usuario', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CompraModel.fromMap(doc.data() as Map<String, dynamic>))
            .where((compra) => _esDelMesActual(compra.fechaEmision))
            .expand((compra) => compra.productos)
            .fold<double>(0.0, (sum, producto) => sum + producto.importe));
  }
}