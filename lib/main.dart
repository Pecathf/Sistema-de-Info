import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart';
import 'package:sistem_proyect/funcionalidades/autenticacion/pantalla_inicio_sesion.dart';
import 'package:sistem_proyect/funcionalidades/autenticacion/pantalla_principal.dart'; // Mismo nombre

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    StreamProvider<User?>.value(
      value: AuthService().authStateChanges,
      initialData: null,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema Proyecto MVC Sencillo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();

    if (user == null) {
      return const PantallaInicioSesion();
    } else {
      return const PantallaPrincipal(); // ✅ NUEVA PANTALLA PRINCIPAL MEJORADA
    }
  }
}
