import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:VanguardMoney/core/routes/go_router.dart';
import 'package:VanguardMoney/presentation/viewmodels/auth_viewmodel.dart';
import 'package:VanguardMoney/presentation/viewmodels/planes_viewmodel.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicialización de servicios

  runApp(const VanguardMoney());
}

class VanguardMoney extends StatelessWidget {
  const VanguardMoney({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => PlanesViewModel()), // <-- Agrega esta línea
      ],
      child: MaterialApp.router(
        title: 'VanguardMoney',
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}
