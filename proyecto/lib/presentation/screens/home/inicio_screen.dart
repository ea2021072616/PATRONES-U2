import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Importa tus paquetes de Firebase
import 'package:cloud_firestore/cloud_firestore.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00D1B2), // Color de fondo superior
      body: SafeArea(
        child: Column(
          children: [
            // Header con saludo y notificación
            _HeaderSection(),
            // Widget para el gasto de hoy
            _GastoHoyCard(),
            // Widget para el gráfico circular y warning
            _WarningSection(),
            // Widget para últimas transacciones
            Expanded(child: _UltimasTransaccionesSection()),
          ],
        ),
      ),
    );
  }
}

// Header
class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, Bienvenido De Nuevo',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              Text(
                'Buen día Ericksito',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// Gasto Hoy Card
class _GastoHoyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Aquí puedes obtener el gasto de hoy desde Firebase
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gasto Hoy: s/ 0.00', // Aquí pon el dato real de Firebase
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: const Color(0xFF242424),
              ),
            ),
            Icon(Icons.settings, color: Colors.grey[700]),
          ],
        ),
      ),
    );
  }
}

// Warning y gráfico circular
class _WarningSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Aquí puedes usar un paquete como percent_indicator para el gráfico
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Aquí va el gráfico circular (puedes usar CircularPercentIndicator)
          Text(
            'Warning',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          Text(
            's/ 30',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 32,
              color: Colors.white,
            ),
          ),
          Text(
            'Última actualización 19/05/2025   s/ 50',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

// Últimas transacciones (con Firebase)
class _UltimasTransaccionesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ultimas Transacciones',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: const Color(0xFF242424),
                  ),
                ),
                TextButton(onPressed: () {}, child: Text('Ver todo')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('transacciones')
                        .orderBy('fecha', descending: true)
                        .limit(4)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Text('No hay transacciones recientes.');
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal[100],
                          child: Icon(
                            Icons.monetization_on,
                            color: Colors.teal[700],
                          ),
                        ),
                        title: Text(
                          data['categoria'] ?? '',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          data['tipo'] ?? '',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12),
                        ),
                        trailing: Text(
                          's/ ${data['monto'] ?? '0.00'}',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF377CC8),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
