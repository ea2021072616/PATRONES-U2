import 'package:VanguardMoney/presentation/screens/home/category_screen.dart';
import 'package:VanguardMoney/presentation/screens/home/inicio_screen.dart';
import 'package:VanguardMoney/presentation/screens/home/planes_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:VanguardMoney/presentation/viewmodels/auth_viewmodel.dart';
import 'package:VanguardMoney/presentation/screens/auth/login_screen.dart';
import 'package:VanguardMoney/presentation/screens/auth/register_screen.dart';
import 'package:VanguardMoney/presentation/screens/auth/edit_profile_screen.dart';
import 'package:VanguardMoney/presentation/screens/home/home_screen.dart';
import 'package:VanguardMoney/presentation/screens/home/profile_screen.dart';
import 'package:VanguardMoney/presentation/screens/complementos/todosEgresos_view.dart';
import 'package:VanguardMoney/presentation/screens/home/ia_scaner_screen.dart';
import 'package:VanguardMoney/presentation/screens/complementos/planes_edit_view.dart'; // Agrega este import

// Asegúrate de importar tus pantallas de planes y categorías si existen
// import 'package:VanguardMoney/presentation/screens/home/planes_screen.dart';
// import 'package:VanguardMoney/presentation/screens/home/categories_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  initialLocation: '/auth/login',
  debugLogDiagnostics: true,
  navigatorKey: _rootNavigatorKey,
  redirect: (BuildContext context, GoRouterState state) async {
    final auth = Provider.of<AuthViewModel>(context, listen: false);
    final isLoggedIn = auth.user != null;
    final isAuthRoute = state.matchedLocation.startsWith('/auth');
    final isInitializing = state.matchedLocation == '/';

    if (isInitializing) {
      return isLoggedIn ? '/home' : '/auth/login';
    }

    if (!isLoggedIn && !isAuthRoute) return '/auth/login';
    if (isLoggedIn && isAuthRoute) return '/home';
    return null;
  },
  routes: [
    // Rutas de autenticación
    GoRoute(
      path: '/auth/login',
      name: 'login',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder:
          (context, state) =>
              MaterialPage(key: state.pageKey, child: const LoginScreen()),
    ),
    GoRoute(
      path: '/auth/register',
      name: 'register',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder:
          (context, state) =>
              MaterialPage(key: state.pageKey, child: const RegisterScreen()),
    ),

    // Flujo principal con ShellRoute (para el menú inferior)
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => HomeScreen(child: child),
      routes: [
        // Pantalla principal
        GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child:
                    const InicioScreen(), // Contenido manejado por HomeScreen
              ),
          routes: [
            // Scanner (se muestra sobre el home)
            GoRoute(
              path: 'scanner',
              name: 'scanner',
              pageBuilder:
                  (context, state) => MaterialPage(
                    key: state.pageKey,
                    child: IaScanerScreen(
                      apiKey: 'AIzaSyAPwGfQo9eI2KubbXhabdH8ESDRR4s5Llo',
                    ),
                  ),
            ),
          ],
        ),
        // Ruta para Planes
        GoRoute(
          path: '/planes',
          name: 'planes',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: PlanesVisualizacionScreen(), // Aquí muestras la pantalla de Planes
              ),
        ),
        // Ruta para Categorías
        GoRoute(
          path: '/categories',
          name: 'categories',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child:
                    CategoryScreen(), // Reemplaza por tu pantalla de Categorías
                // child: CategoriesScreen(),
              ),
        ),
        // Perfil
        GoRoute(
          path: '/profile',
          name: 'profile',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const ProfileScreen(),
              ),
        ),
      ],
    ),

    // Rutas que requieren navegación completa (sin menú inferior)
    GoRoute(
      path: '/edit-profile',
      name: 'edit-profile',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder:
          (context, state) => MaterialPage(
            key: state.pageKey,
            child: const EditProfileScreen(),
          ),
    ),
    GoRoute(
      path: '/egresos',
      name: 'egresos',
      pageBuilder:
          (context, state) =>
              NoTransitionPage(key: state.pageKey, child: TodosEgresosScreen()),
    ),
  ],
);

class NoTransitionPage extends CustomTransitionPage<void> {
  NoTransitionPage({required super.key, required super.child})
    : super(transitionsBuilder: (_, __, ___, child) => child);
}
