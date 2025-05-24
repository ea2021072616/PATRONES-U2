import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:VanguardMoney/presentation/screens/home/profile_screen.dart';
import 'package:VanguardMoney/presentation/widgets/home/custom_nav_bar.dart';
import 'package:VanguardMoney/presentation/widgets/home/scanner_fab.dart';
import 'package:VanguardMoney/presentation/screens/home/inicio_screen.dart';
import 'package:VanguardMoney/presentation/screens/complementos/planes_edit_view.dart'; // Agrega este import

class HomeScreen extends StatefulWidget {
  final Widget? child;

  const HomeScreen({super.key, this.child});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/planes')) return 1;
    if (location.startsWith('/categories')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: widget.child ?? _buildDefaultContent(currentIndex),
      floatingActionButton: ScannerFab(
        onPressed: () => context.pushNamed('scanner'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/planes');
              break;
            case 2:
              context.go('/categories');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildDefaultContent(int index) {
    switch (index) {
      case 0:
        return const InicioScreen();
      case 1:
        return PlanesScreen();
      case 3:
        return const ProfileScreen();
      default:
        return Center(
          child: Text(
            'Pantalla no definida',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: const Color(0xFFED533D),
            ),
          ),
        );
    }
  }
}
