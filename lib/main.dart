import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:sistem_proyect/funcionalidades/autenticacion/pantalla_bienvenida.dart';
import 'package:sistem_proyect/central/constantes/colores.dart';
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart';
import 'funcionalidades/autenticacion/pantalla_principal.dart';
import 'funcionalidades/autenticacion/firebase_options.dart';

void main() async {
  // 1. Inicialización de Widgets y Firebase
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // 2. MultiProvider para inyectar el AuthService
    MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// WIDGET PRINCIPAL DE LA APLICACIÓN

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProyectApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Configuración del tema usando los colores definidos
        primaryColor: AppColors.primaryOrange,
        scaffoldBackgroundColor: AppColors.lightBackground,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.orange,
        ).copyWith(
          secondary: AppColors.primaryOrange,
        ),
        useMaterial3: true,
      ),
      // AuthWrapper decide la pantalla inicial
      home: const AuthWrapper(),
    );
  }
}

// WIDGET DE GESTIÓN DE AUTENTICACIÓN

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            ),
          );
        }

        final User? user = snapshot.data;

        // 2. Lógica de Redirección
        // Si el usuario NO está autenticado, muestra la Pantalla de Bienvenida
        if (user == null) {
          return const PantallaBienvenida(); // Redirige a la pantalla de bienvenida
        }

        // Si el usuario SÍ está autenticado, muestra la Pantalla Principal
        else {
          return const PantallaPrincipal(); // Redirige a la pantalla principal
        }
      },
    );
  }
}
