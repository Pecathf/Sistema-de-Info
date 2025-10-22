import 'package:flutter/material.dart';
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 

class PantallaPrincipal extends StatelessWidget {
 
   PantallaPrincipal({super.key});

  final AuthService _authService = AuthService(); 

 
  Future<void> _cerrarSesion(BuildContext context) async {
  
    await _authService.signOut();
    
  
  }

  @override
  Widget build(BuildContext context) {
   
    final user = FirebaseAuth.instance.currentUser; 
    
    final userName = user?.displayName ?? user?.email ?? 'Usuario';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema Principal'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _cerrarSesion(context), 
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline, 
                color: Colors.green, 
                size: 80,
              ),
              const SizedBox(height: 20),
             
              Text(
                '¡Bienvenido(a), $userName!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Has iniciado sesión correctamente. Usa el botón de cerrar sesión para salir.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}