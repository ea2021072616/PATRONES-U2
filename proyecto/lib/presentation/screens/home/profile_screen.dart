import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _goToEditProfile(BuildContext context) {
    context.pushNamed('edit-profile'); // Usa ruta nombrada
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final userData = authViewModel.userData;
    final user = authViewModel.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade800, Colors.teal.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: kToolbarHeight),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                (user?.photoURL ?? userData?.photoUrl) != null
                                    ? NetworkImage(
                                      (user?.photoURL ?? userData?.photoUrl)!,
                                    )
                                    : null,
                            child:
                                (user?.photoURL ?? userData?.photoUrl) == null
                                    ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.teal,
                                    )
                                    : null,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _goToEditProfile(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Usamos nombreCompleto del modelo o displayName de Firebase Auth
                    Text(
                      userData?.nombreCompleto ??
                          user?.displayName ??
                          'Usuario',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Usamos email del modelo o de Firebase Auth
                    Text(
                      userData?.email ?? user?.email ?? 'correo@ejemplo.com',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 24),
              _buildProfileSection(
                context,
                title: 'Mi Cuenta',
                items: [
                  _ProfileItem(
                    icon: Icons.person_outline,
                    title: 'Editar Perfil',
                    onTap: () => context.pushNamed('edit-profile'),
                  ),
                  _ProfileItem(
                    icon: Icons.lock_outline,
                    title: 'Seguridad',
                    onTap: () => context.push('/security'),
                  ),
                  _ProfileItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notificaciones',
                    onTap: () => context.push('/notifications'),
                  ),
                ],
              ),
              _buildProfileSection(
                context,
                title: 'Preferencias',
                items: [
                  _ProfileItem(
                    icon: Icons.dark_mode_outlined,
                    title: 'Tema Oscuro',
                    trailing: Switch(
                      value: false,
                      onChanged: (value) {},
                      activeColor: Colors.teal,
                    ),
                  ),
                  _ProfileItem(
                    icon: Icons.language,
                    title: 'Idioma',
                    trailing: const Text('Español'),
                    onTap: () => context.push('/language'),
                  ),
                ],
              ),
              _buildProfileSection(
                context,
                title: 'Más',
                items: [
                  _ProfileItem(
                    icon: Icons.help_outline,
                    title: 'Ayuda',
                    onTap: () => context.push('/help'),
                  ),
                  _ProfileItem(
                    icon: Icons.info_outline,
                    title: 'Acerca de',
                    onTap: () => context.push('/about'),
                  ),
                  _ProfileItem(
                    icon: Icons.logout,
                    title: 'Cerrar Sesión',
                    color: Colors.red,
                    onTap: () => _showLogoutDialog(context, authViewModel),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context, {
    required String title,
    required List<_ProfileItem> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children:
                  items
                      .map(
                        (item) => Column(
                          children: [
                            ListTile(
                              leading: Icon(
                                item.icon,
                                color: item.color ?? Colors.teal,
                              ),
                              title: Text(
                                item.title,
                                style: TextStyle(
                                  color: item.color ?? Colors.black,
                                ),
                              ),
                              trailing:
                                  item.trailing ??
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
                                  ),
                              onTap: item.onTap,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            if (item != items.last)
                              Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                                color: Colors.grey.shade200,
                              ),
                          ],
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(
    BuildContext context,
    AuthViewModel authViewModel,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                final scaffold = ScaffoldMessenger.of(context);

                try {
                  await authViewModel.logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                } catch (e) {
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Text('Error al cerrar sesión: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class _ProfileItem {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final Color? color;
  final VoidCallback? onTap;

  _ProfileItem({
    required this.icon,
    required this.title,
    this.trailing,
    this.color,
    this.onTap,
  });
}
