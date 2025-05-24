import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/productos_model.dart';

class EditarJsonRecibidoViewModel extends ChangeNotifier {
  late CompraModel _compra;

  CompraModel get compra => _compra;

  // Cargar datos desde un Map (por ejemplo, el JSON recibido)
  void cargarDesdeJson(Map<String, dynamic> json) {
    _compra = CompraModel.fromMap(json);
    notifyListeners();
  }

  // Editar todos los campos principales de la compra
  void actualizarCompra({
    required String fechaEmision,
    required double subtotal,
    required double impuestos,
    required double total,
    required String lugarCompra,
    required String categoriaSuperior,
  }) {
    _compra = CompraModel(
      idUsuario: _compra.idUsuario,
      fechaEmision: fechaEmision,
      subtotal: subtotal,
      impuestos: impuestos,
      total: total,
      lugarCompra: lugarCompra,
      categoriaSuperior: categoriaSuperior,
      productos: _compra.productos,
    );
    notifyListeners();
  }

  // Editar campos de la compra (solo lugar de compra)
  void actualizarLugarCompra(String nuevoLugar) {
    _compra = CompraModel(
      idUsuario: _compra.idUsuario,
      fechaEmision: _compra.fechaEmision,
      subtotal: _compra.subtotal,
      impuestos: _compra.impuestos,
      total: _compra.total,
      lugarCompra: nuevoLugar,
      categoriaSuperior: _compra.categoriaSuperior,
      productos: _compra.productos,
    );
    notifyListeners();
  }

  // Editar la categoría superior de la compra
  void actualizarCategoriaSuperior(String nuevaCategoria) {
    _compra = CompraModel(
      idUsuario: _compra.idUsuario,
      fechaEmision: _compra.fechaEmision,
      subtotal: _compra.subtotal,
      impuestos: _compra.impuestos,
      total: _compra.total,
      lugarCompra: _compra.lugarCompra,
      categoriaSuperior: nuevaCategoria,
      productos: _compra.productos,
    );
    notifyListeners();
  }

  // Editar un producto específico
  void actualizarProducto(int index, ProductoModel nuevoProducto) {
    final productosActualizados = List<ProductoModel>.from(_compra.productos);
    productosActualizados[index] = ProductoModel(
      descripcion: nuevoProducto.descripcion,
      importe: nuevoProducto.importe,
      categoria: nuevoProducto.categoria,
    );
    _compra = CompraModel(
      idUsuario: _compra.idUsuario,
      fechaEmision: _compra.fechaEmision,
      subtotal: _compra.subtotal,
      impuestos: _compra.impuestos,
      total: _compra.total,
      lugarCompra: _compra.lugarCompra,
      categoriaSuperior: _compra.categoriaSuperior,
      productos: productosActualizados,
    );
    notifyListeners();
  }

  // Guardar la compra en Firestore
  Future<void> guardarEnFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('egresos')
          .add(_compra.toMap());
    } catch (e) {
      debugPrint('Error al guardar en Firestore: $e');
    }
  }

  // Obtener el modelo como Map para guardar en Firestore o enviar a otra pantalla
  Map<String, dynamic> obtenerJsonActualizado() {
    return _compra.toMap();
  }
}
