import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_proyect/funcionalidades/autenticacion/pantalla_inicio_sesion.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _cedulaController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nombreController.dispose();
    _cedulaController.dispose();
    super.dispose();
  }

  Future<void> _registrarUsuario() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Crear usuario en Firebase Authentication
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Actualizar el nombre del usuario
      await userCredential.user
          ?.updateDisplayName(_nombreController.text.trim());

      // Guardar información adicional en Firestore
      try {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userCredential.user!.uid)
            .set({
          'nombre': _nombreController.text.trim(),
          'email': _emailController.text.trim(),
          'cedula': _cedulaController.text.trim(),
          'fechaCreacion': FieldValue.serverTimestamp(),
        });
      } catch (firestoreError) {
        debugPrint(
            'Advertencia: No se pudo guardar en Firestore: $firestoreError');
      }

      if (!mounted) return;

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Registro exitoso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Esperar y regresar a la pantalla anterior
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al registrar usuario';

      switch (e.code) {
        case 'weak-password':
          mensaje = 'La contraseña es muy débil';
          break;
        case 'email-already-in-use':
          mensaje = 'Este correo ya está registrado';
          break;
        case 'invalid-email':
          mensaje = 'El correo electrónico no es válido';
          break;
        case 'operation-not-allowed':
          mensaje = 'Operación no permitida';
          break;
        default:
          mensaje = 'Error: ${e.message}';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'ProyectApp',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Título Registro
                  Text(
                    'Registro',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tu cuenta en ProyectApp',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Campo de Nombre completo
                  _buildCustomTextField(
                    controller: _nombreController,
                    labelText: 'Nombre completo',
                    hintText: 'Juan del Carmen',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su nombre';
                      }
                      if (value.length < 3) {
                        return 'El nombre debe tener al menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo de Correo Electrónico
                  _buildCustomTextField(
                    controller: _emailController,
                    labelText: 'Correo Electrónico',
                    hintText: 'ejemplo@correo.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su correo';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Ingrese un correo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo de Cédula
                  _buildCustomTextField(
                    controller: _cedulaController,
                    labelText: 'Cédula',
                    hintText: 'V3DB00220',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su cédula';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo de Contraseña
                  _buildPasswordField(
                    controller: _passwordController,
                    labelText: 'Contraseña',
                    obscureText: _obscurePassword,
                    onToggle: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese una contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo de Confirmar Contraseña
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirmar contraseña',
                    obscureText: _obscureConfirmPassword,
                    onToggle: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor confirme su contraseña';
                      }
                      if (value != _passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Botón de Crear Cuenta
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade100,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _registrarUsuario,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Crear Cuenta',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Footer informativo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'ProyectApp',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gestión de Proyectos',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '¿Ya tienes cuenta?',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _isLoading
                                  ? null
                                  : () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const PantallaInicioSesion(),
                                        ),
                                      );
                                    },
                              child: Text(
                                'Iniciar sesión aquí',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    TextInputType? keyboardType,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[500],
                ),
                onPressed: onToggle,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}
