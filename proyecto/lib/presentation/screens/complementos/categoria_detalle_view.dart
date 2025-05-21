import 'package:VanguardMoney/data/models/productos_model.dart';
import 'package:VanguardMoney/presentation/viewmodels/auth_viewmodel.dart';
import 'package:VanguardMoney/presentation/viewmodels/categoria_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriaDetalleView extends StatelessWidget {
  final String categoria;

  const CategoriaDetalleView({Key? key, required this.categoria}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<AuthViewModel>(context, listen: false).user?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado.')),
      );
    }

    final logic = CategoriaDetalleLogic(categoria: categoria, uid: uid);

    return Scaffold(
      appBar: AppBar(title: Text('Facturas: $categoria')),
      body: Column(
        children: [
          // Total gastado
          StreamBuilder<double>(
            stream: logic.getTotalGastado(),
            builder: (context, snapshot) {
              final total = snapshot.data ?? 0.0;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Total gastado: \$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              );
            },
          ),
          // Lista de facturas
          Expanded(
            child: StreamBuilder<List<CompraModel>>(
              stream: logic.getFacturasFiltradas(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay facturas en esta categoría.'));
                }

                final facturasFiltradas = snapshot.data!;

                return ListView.separated(
                  itemCount: facturasFiltradas.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final factura = facturasFiltradas[index];
                    return ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text('Factura: ${factura.lugarCompra}'),
                      subtitle: Text('Fecha: ${factura.fechaEmision}\nTotal: \$${factura.total.toStringAsFixed(2)}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FacturaDetalleView(factura: factura, categoria: categoria),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Puedes mover también FacturaDetalleView aquí si lo deseas
class FacturaDetalleView extends StatelessWidget {
  final CompraModel factura;
  final String categoria;

  const FacturaDetalleView({Key? key, required this.factura, required this.categoria}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productos = factura.productos.where((p) => p.categoria == categoria).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Factura')),
      body: ListView.separated(
        itemCount: productos.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final producto = productos[index];
          return ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: Text(producto.descripcion),
            subtitle: Text('Monto: \$${producto.importe.toStringAsFixed(2)}'),
          );
        },
      ),
    );
  }
}