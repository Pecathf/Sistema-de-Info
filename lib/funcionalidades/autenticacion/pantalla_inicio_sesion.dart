import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart';
import 'pantalla_registro.dart';
import 'package:sistem_proyect/central/constantes/colores.dart';

// Importamos la Pantalla Principal
import 'pantalla_principal.dart';

class PantallaInicioSesion extends StatefulWidget {
  const PantallaInicioSesion({super.key});

  @override
  State<PantallaInicioSesion> createState() => _PantallaInicioSesionState();
}

class _PantallaInicioSesionState extends State<PantallaInicioSesion> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Lógica de inicio de sesión
  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Intentar iniciar sesión
      await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Si el login fue exitoso, desactivamos el indicador ANTES de navegar.
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      // 2. Navegar a la Pantalla Principal
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const PantallaPrincipal(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Ocurrió un error inesperado.';

      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        message = 'Credenciales inválidas. Verifica email y contraseña.';
      } else if (e.code == 'invalid-email') {
        message = 'El formato del email es incorrecto.';
      } else if (e.code == 'too-many-requests') {
        message =
            'Se han bloqueado todos los intentos de esta cuenta debido a demasiados intentos fallidos.';
      }

      // Corregido: Usar debugPrint en lugar de print
      debugPrint('Error de FirebaseAuth: ${e.code}');

      // Solución para 'setState called after dispose'.
      if (mounted) {
        setState(() {
          _errorMessage = message;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Corregido: Usar debugPrint en lugar de print
      debugPrint('Error General: ${e.toString()}');

      // Solución para 'setState called after dispose'.
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Diseño para pantallas grandes (Web/Desktop)
          if (constraints.maxWidth > 800) {
            return Center(
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  width: 800,
                  height: 550,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 350),
                            child: _buildFormContent(context,
                                title: 'Inicio de Sesión'),
                          ),
                        ),
                      ),
                      // Panel lateral de Branding
                      Container(
                        width: 300,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryOrange,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                        ),
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              '¡Bienvenido al gestor de proyectos!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            // Diseño para móvil/pantalla pequeña
            return _buildFormContent(context, title: 'Iniciar Sesión');
          }
        },
      ),
    );
  }

  // Widget auxiliar para el contenido del formulario
  Widget _buildFormContent(BuildContext context, {required String title}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBackground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),

            _buildTextField(
              controller: _emailController,
              labelText: 'Correo Electrónico',
              keyboardType: TextInputType.emailAddress,
              icon: Icons.email,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Introduce tu correo' : null,
            ),
            const SizedBox(height: 15),

            _buildTextField(
                controller: _passwordController,
                labelText: 'Contraseña',
                obscureText: true,
                icon: Icons.lock,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduce tu contraseña';
                  }
                  // Corregido: Se añade llaves para cumplir con curly_braces_in_flow_control_structures
                  return null;
                }),
            const SizedBox(height: 20),

            // Mensajes de error
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(_errorMessage!,
                    style: const TextStyle(color: Colors.red)),
              ),

            // Botón de Entrar
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white)
                  : const Text('Iniciar Sesión',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            const SizedBox(height: 25),

            // Logo y Enlace a Registro
            const Text(
              'ProyectApp',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryOrange,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PantallaRegistro()));
                    },
              child: Text('¿No tienes cuenta? Regístrate aquí',
                  style: TextStyle(color: AppColors.darkBackground)),
            ),
          ],
        ),
      ),
    );
  }

  // Función auxiliar para los campos de texto estilizados
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        // Usamos un borde completo
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.lightGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryOrange, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }
}
