// lib/funcionalidades/autenticacion/pantalla_inicio_sesion.dart

import 'package:flutter/material.dart';
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart';
import 'pantalla_registro.dart'; // Importa la pantalla de registro

class PantallaInicioSesion extends StatefulWidget {
  const PantallaInicioSesion({super.key});

  @override
  State<PantallaInicioSesion> createState() => _PantallaInicioSesionState();
}

class _PantallaInicioSesionState extends State<PantallaInicioSesion> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleSignIn() async {
    try {
      await AuthService().signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
      // Si tiene éxito, el AuthWrapper redirigirá automáticamente.
    } catch (e) {
      // *** Corrección para evitar el error 'BuildContext' ***
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration:
                  const InputDecoration(labelText: 'Correo Electrónico'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _handleSignIn,
              child: const Text('Entrar'),
            ),

            // Botón para ir a REGISTRO
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaRegistro(),
                  ),
                );
              },
              child: const Text('¿No tienes cuenta? Regístrate aquí.'),
            ),
          ],
        ),
      ),
    );
  }
}
