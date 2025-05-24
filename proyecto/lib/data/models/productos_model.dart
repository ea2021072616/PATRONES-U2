class ProductoModel {
  final String descripcion;
  final double importe;
  final String categoria;

  ProductoModel({
    required this.descripcion,
    required this.importe,
    required this.categoria,
  });

  factory ProductoModel.fromMap(Map<String, dynamic> map) {
    return ProductoModel(
      descripcion: map['descripcion'] ?? '',
      importe: (map['importe'] ?? 0).toDouble(),
      categoria: map['categoria'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'descripcion': descripcion,
      'importe': importe,
      'categoria': categoria,
    };
  }
}

class CompraModel {
  final String idUsuario;
  final String fechaEmision;
  final double subtotal;
  final double impuestos;
  final double total;
  final String lugarCompra;
  final String categoriaSuperior;
  final List<ProductoModel> productos;

  CompraModel({
    required this.idUsuario,
    required this.fechaEmision,
    required this.subtotal,
    required this.impuestos,
    required this.total,
    required this.lugarCompra,
    required this.categoriaSuperior,
    required this.productos,
  });

  factory CompraModel.fromMap(Map<String, dynamic> map) {
    return CompraModel(
      idUsuario: map['id_usuario'] ?? '',
      fechaEmision: map['fechaEmision'] ?? '',
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      impuestos: (map['impuestos'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      lugarCompra: map['lugar_compra'] ?? '',
      categoriaSuperior: map['categoria_superior'] ?? '',
      productos: (map['productos'] as List<dynamic>? ?? [])
          .map((item) => ProductoModel.fromMap(item))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_usuario': idUsuario,
      'fechaEmision': fechaEmision,
      'subtotal': subtotal,
      'impuestos': impuestos,
      'total': total,
      'lugar_compra': lugarCompra,
      'categoria_superior': categoriaSuperior,
      'productos': productos.map((p) => p.toMap()).toList(),
    };
  }
}