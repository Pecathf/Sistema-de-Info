import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'funcionalidades/autenticacion/firebase_options.dart';

import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart';

import 'package:sistem_proyect/funcionalidades/autenticacion/pantalla_principal.dart';
import 'package:sistem_proyect/funcionalidades/autenticacion/pantalla_inicio_sesion.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // INICIALIZAR FIREBASE
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Envolvemos la aplicación con un StreamProvider que expone el estado de
  // autenticación (User) a través de la jerarquía de widgets.
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
      return PantallaPrincipal();
    }
  }
}
