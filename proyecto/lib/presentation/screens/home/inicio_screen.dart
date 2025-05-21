import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/inicio_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'package:VanguardMoney/data/models/productos_model.dart';
import 'package:percent_indicator/percent_indicator.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({Key? key}) : super(key: key);

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  double? limiteGastoDiario;
  bool _cargandoLimite = true;

  @override
  void initState() {
    super.initState();
    _cargarLimite();
  }

  Future<void> _cargarLimite() async {
    final auth = Provider.of<AuthViewModel>(context, listen: false);
    final limite = await auth.getLimiteGastoDiario();
    setState(() {
      limiteGastoDiario = limite;
      _cargandoLimite = false;
    });
  }

  void _cambiarLimite() async {
    final controller = TextEditingController(
      text: limiteGastoDiario?.toStringAsFixed(2) ?? '',
    );
    final result = await showDialog<double>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Configurar límite diario'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Nuevo límite'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  final value = double.tryParse(controller.text);
                  if (value != null && value > 0) {
                    Navigator.pop(context, value);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
    if (result != null) {
      final auth = Provider.of<AuthViewModel>(context, listen: false);
      await auth.setLimiteGastoDiario(result);
      setState(() {
        limiteGastoDiario = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthViewModel>(context, listen: false);
    final viewModel =
        auth.user != null
            ? InicioViewModel(
              auth.user!.uid,
              auth.userData?.nombreCompleto ?? 'Usuario',
            )
            : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen Financiero'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _cambiarLimite,
            tooltip: 'Configurar límite diario',
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarLimite),
        ],
      ),
      body:
          viewModel == null
              ? const Center(child: Text('Usuario no autenticado'))
              : _cargandoLimite
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(BuildContext context, InicioViewModel viewModel) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSaludo(viewModel),
          _buildResumenDia(viewModel),
          const SizedBox(height: 20),
          _buildUltimosEgresos(viewModel),
        ],
      ),
    );
  }

  Widget _buildSaludo(InicioViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          viewModel.getSaludo(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildResumenDia(InicioViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Gastos del Día',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<double>(
              stream: viewModel.getTotalHoy(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                final gasto = snapshot.data ?? 0.0;
                final limite = limiteGastoDiario ?? 0.0;
                final percent =
                    (limite > 0) ? (gasto / limite).clamp(0.0, 1.0) : 0.0;

                Color color;
                if (percent < 0.5) {
                  color = Colors.green;
                } else if (percent < 0.8) {
                  color = Colors.orange;
                } else {
                  color = Colors.red;
                }

                String estado;
                if (percent < 0.5) {
                  estado = "Good";
                } else if (percent < 0.8) {
                  estado = "Warning";
                } else {
                  estado = "Te excediste";
                }

                return Column(
                  children: [
                    CircularPercentIndicator(
                      radius: 80.0,
                      lineWidth: 16.0,
                      percent: percent,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '\S/ ${gasto.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            limiteGastoDiario == null
                                ? 'Límite: No definido'
                                : 'de \S/ ${limiteGastoDiario!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      progressColor: color,
                      backgroundColor: Colors.grey[200]!,
                      circularStrokeCap: CircularStrokeCap.round,
                      animation: true,
                      arcType: ArcType.HALF,
                      arcBackgroundColor: Colors.grey[300]!,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      estado,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 16,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUltimosEgresos(InicioViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y botón "Ver todos"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Últimos Egresos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  context.go('/egresos');
                },
                child: const Text('Ver todos'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<CompraModel>>(
            stream: viewModel.getUltimasCompras(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              final compras = snapshot.data ?? [];
              return compras.isEmpty
                  ? const Text('No hay egresos recientes')
                  : Column(
                    children:
                        compras
                            .map((compra) => _buildItemCompra(compra))
                            .toList(),
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemCompra(CompraModel compra) {
    DateTime? fecha;
    try {
      fecha = DateFormat('dd/MM/yyyy HH:mm:ss').parse(compra.fechaEmision);
    } catch (e) {
      fecha = null;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    compra.lugarCompra,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${compra.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            if (fecha != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  DateFormat('dd MMM yyyy - HH:mm').format(fecha),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
            const SizedBox(height: 8),
            ...compra.productos
                .take(2)
                .map(
                  (producto) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 8),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            producto.descripcion,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${producto.importe.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
            if (compra.productos.length > 2)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '+ ${compra.productos.length - 2} productos más',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
