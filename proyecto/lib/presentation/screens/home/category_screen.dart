import 'package:VanguardMoney/presentation/screens/complementos/categoria_detalle_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/categoria_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

class CategoryScreen extends StatelessWidget {
  CategoryScreen({Key? key}) : super(key: key);

  // Lista de categorías por defecto
  final List<String> categorias = const [
    'Alimentos',
    'Hogar',
    'Ropa',
    'Salud',
    'Tecnología',
    'Entretenimiento',
    'Transporte',
    'Mascotas',
    'Otros',
  ];

  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<AuthViewModel>(context, listen: false).user?.uid;
    final logic = uid != null
        ? CategoriaDetalleLogic(categoria: '', uid: uid)
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      body: Column(
        children: [
          // Total gastado en todas las categorías
          if (logic != null)
            StreamBuilder<double>(
              stream: logic.getTotalGastadoGeneral(),
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
          Expanded(
            child: ListView.separated(
              itemCount: categorias.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.category),
                  title: Text(categorias[index]),
                  onTap: () {
                    // Redirige a la pantalla de detalle de categoría
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CategoriaDetalleView(categoria: categorias[index]),
                      ),
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
