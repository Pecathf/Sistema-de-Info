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

    // Comprobación de que las contraseñas coincidan
    if (_passwordController.text != _confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Las contraseñas no coinciden'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Crear usuario en Firebase Authentication (MÉTODO DIRECTO)
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // 2. Actualizar el nombre del usuario
      await userCredential.user
          ?.updateDisplayName(_nombreController.text.trim());

      // 3. Guardar información adicional en Firestore
      try {
        await FirebaseFirestore.instance
            .collection('usuarios') // Colección usada en la versión anterior
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

      // 4. CERRAR SESIÓN INMEDIATAMENTE después del registro
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      // 5. Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Registro exitoso! Ahora puedes iniciar sesión.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // 6. Redirigir a la pantalla de Inicio de Sesión
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      // CAMBIO CLAVE: Usar pushAndRemoveUntil para eliminar TODAS las rutas anteriores
      // Esto asegura que la PantallaInicioSesion sea la nueva raíz, simulando el "inicio desde 0".
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const PantallaInicioSesion(),
        ),
        (Route<dynamic> route) =>
            false, // Predicado que siempre retorna falso, eliminando todas las rutas.
      );
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
    // Definir la imagen de fondo con un filtro oscuro
    const String backgroundImage =
        'assets/fondo_login.jpg'; // Reemplaza con tu imagen de fondo

    return Scaffold(
<<<<<<< HEAD
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título Registro
                _buildSectionTitle('Registro'),
                const SizedBox(height: 8),

                // Nombre completo
                _buildLabel('Nombre completo'),
                const SizedBox(height: 4),
                _buildCustomTextField(
                  controller: _nombreController,
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

                // Correo Electrónico
                _buildLabel('Correo Electrónico'),
                const SizedBox(height: 4),
                _buildCustomTextField(
                  controller: _emailController,
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

                // Cédula
                _buildLabel('Cédula'),
                const SizedBox(height: 4),
                _buildCustomTextField(
                  controller: _cedulaController,
                  hintText: 'V3DB00220',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su cédula';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Contraseña
                _buildLabel('Contraseña'),
                const SizedBox(height: 4),
                _buildPasswordField(
                  controller: _passwordController,
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

                // Confirmar Contraseña
                _buildLabel('Confirmar contraseña'),
                const SizedBox(height: 4),
                _buildPasswordField(
                  controller: _confirmPasswordController,
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

                // Línea divisoria
                Container(
                  height: 1,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),
                const SizedBox(height: 24),

                // Botón Crea Cuenta
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registrarUsuario,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
                            'Crea Cuenta',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),

                // Footer informativo
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
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
                      const SizedBox(height: 4),
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
                          const SizedBox(width: 4),
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
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
=======
      body: Stack(
        children: [
          // Fondo de imagen
          Positioned.fill(
            child: Image.asset(
              backgroundImage,
              fit: BoxFit.cover,
            ),
          ),
          // Capa de color oscuro semitransparente sobre la imagen de fondo
          Positioned.fill(
            child: Container(
              color: Colors.black
                  .withOpacity(0.5), // Ajusta la opacidad si es necesario
            ),
          ),
          Center(
            child: Container(
              // Contenedor principal que agrupa los dos cuadros
              constraints: const BoxConstraints(
                  maxWidth: 800,
                  maxHeight: 600), // Limita el tamaño total del módulo
              decoration: BoxDecoration(
                color: Colors
                    .white, // Color de fallback, aunque los hijos lo cubrirán
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Lado Izquierdo (Naranja)
                  Expanded(
                    flex: 1, // Ocupa 1/3 del espacio
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF7A00), // Naranja del diseño
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '¡Crea una cuenta!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Lado Derecho (Formulario Blanco)
                  Expanded(
                    flex: 2, // Ocupa 2/3 del espacio
                    child: Container(
                      padding: const EdgeInsets.all(40.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize
                                .min, // Para que la columna no ocupe más espacio del necesario
                            children: [
                              _buildSectionTitle('Registro'),
                              const SizedBox(height: 24),

                              _buildLabel('Nombre completo'),
                              const SizedBox(height: 8),
                              _buildCustomTextField(
                                controller: _nombreController,
                                hintText: 'Juana del Carmen',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingrese su nombre';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              _buildLabel('Correo Electrónico'),
                              const SizedBox(height: 8),
                              _buildCustomTextField(
                                controller: _emailController,
                                hintText: 'ejemplo@correo.com',
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingrese su correo';
                                  }
                                  if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Ingrese un correo válido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              _buildLabel('Cédula'),
                              const SizedBox(height: 8),
                              _buildCustomTextField(
                                controller: _cedulaController,
                                hintText: 'V30980220',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingrese su cédula';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              _buildLabel('Contraseña'),
                              const SizedBox(height: 8),
                              _buildPasswordField(
                                controller: _passwordController,
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

                              _buildLabel('Confirmar contraseña'),
                              const SizedBox(height: 8),
                              _buildPasswordField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                onToggle: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
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
                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      _isLoading ? null : _registrarUsuario,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(
                                        0xFFFF7A00), // Naranja para el botón
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
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
                                      : const Text('Crear Cuenta'),
                                ),
                              ),
                              const SizedBox(
                                  height: 32), // Espacio antes del footer

                              // Footer del formulario
                              Column(
                                children: [
                                  Text(
                                    'ProyectApp',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
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
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: _isLoading
                                            ? null
                                            : () {
                                                // Usar pushAndRemoveUntil aquí también para asegurar un estado limpio
                                                Navigator.of(context)
                                                    .pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const PantallaInicioSesion(),
                                                  ),
                                                  (Route<dynamic> route) =>
                                                      false,
                                                );
                                              },
                                        child: const Text(
                                          'Iniciar sesión aquí',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(
                                                0xFFFF7A00), // Naranja para el enlace
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
>>>>>>> Gloria
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          errorStyle: const TextStyle(
            fontSize: 12,
          ),
        ),
        style: const TextStyle(fontSize: 14),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: '••••••••',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[500],
              size: 20,
            ),
            onPressed: onToggle,
          ),
          errorStyle: const TextStyle(
            fontSize: 12,
          ),
        ),
        style: const TextStyle(fontSize: 14, letterSpacing: 1.5),
        validator: validator,
      ),
    );
  }
}