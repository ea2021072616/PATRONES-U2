import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:VanguardMoney/presentation/screens/home/profile_screen.dart';

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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed('scanner'),
        backgroundColor: const Color(0xFF377CC8),
        elevation: 4,
        shape: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF377CC8),
                const Color(0xFF377CC8).withOpacity(0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF377CC8).withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.qr_code_scanner,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _ModernBottomBar(
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
        return Center(
          child: Text(
            'Pantalla Principal',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 28,
              color: const Color(0xFF242424),
            ),
          ),
        );
      case 1:
        return Center(
          child: Text(
            'Pantalla de Planes',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 28,
              color: const Color(0xFF242424),
            ),
          ),
        );
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

class _ModernBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _ModernBottomBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Inicio',
      ),
      _NavItem(
        icon: Icons.assignment_outlined,
        activeIcon: Icons.assignment_rounded,
        label: 'Planes',
      ),
      _NavItem(
        icon: Icons.category_outlined,
        activeIcon: Icons.category_rounded,
        label: 'Categorías',
      ),
      _NavItem(
        icon: Icons.person_outlined,
        activeIcon: Icons.person_rounded,
        label: 'Perfil',
      ),
    ];

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          Row(
            children:
                items.map((item) {
                  final index = items.indexOf(item);
                  final isActive = currentIndex == index;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(index),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 80,
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder:
                                  (child, animation) => ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                              child: Icon(
                                isActive ? item.activeIcon : item.icon,
                                key: ValueKey(
                                  isActive
                                      ? 'active_$index'
                                      : 'inactive_$index',
                                ),
                                color:
                                    isActive
                                        ? const Color(0xFF377CC8)
                                        : Colors.grey.shade500,
                                size: isActive ? 28 : 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight:
                                    isActive
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                color:
                                    isActive
                                        ? const Color(0xFF377CC8)
                                        : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          // Indicador activo
          if (currentIndex >= 0)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuart,
              left:
                  MediaQuery.of(context).size.width /
                  items.length *
                  currentIndex,
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width / items.length,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF377CC8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
