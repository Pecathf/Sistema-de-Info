import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_proyect/central/constantes/colores.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/pantalla_principal.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/proyectos/pantalla_listado_proyectos.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/calendario/pantalla_calendario.dart';
import 'package:sistem_proyect/funcionalidades/estadisticas/pantalla_estadisticas_admin.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/Widgets/profile_menu_widget.dart';
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart';

class PantallaEditarPerfil extends StatefulWidget {
  const PantallaEditarPerfil({super.key});

  @override
  State<PantallaEditarPerfil> createState() => _PantallaEditarPerfilState();
}

class _PantallaEditarPerfilState extends State<PantallaEditarPerfil> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _contrasenaActualController =
      TextEditingController();
  final TextEditingController _contrasenaNuevaController =
      TextEditingController();
  final TextEditingController _confirmarContrasenaController =
      TextEditingController();
  final AuthService _authService = AuthService();
  bool _isAdmin = false;
  bool _isLoadingRole = true;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _checkIfAdmin();
    _cargarDatosUsuario();
  }

  Future<void> _checkIfAdmin() async {
    final isAdmin = await _authService.isAdmin();
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
        _isLoadingRole = false;
      });
    }
  }

  // Carga los datos del usuario desde Firebase Auth y Firestore
  void _cargarDatosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Cargar datos de Firebase Auth
      _nombreController.text = user.displayName ?? '';
      _correoController.text = user.email ?? '';

      // Cargar datos adicionales de Firestore
      try {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          if (data != null) {
            if (mounted) {
              setState(() {
                _nombreController.text =
                    data['nombre'] ?? user.displayName ?? '';
                _correoController.text = data['email'] ?? user.email ?? '';
                _cedulaController.text = data['cedula'] ?? '';
                _isLoading = false;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        debugPrint('Error al cargar datos de Firestore: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _cedulaController.dispose();
    _contrasenaActualController.dispose();
    _contrasenaNuevaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }

  // Verifica que la contraseña actual sea correcta
  Future<bool> _verificarContrasenaActual(String contrasenaActual) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        return false;
      }

      // Intentar iniciar sesión con las credenciales para verificar
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: user.email!,
        password: contrasenaActual,
      );

      return true;
    } catch (e) {
      debugPrint('Error al verificar contraseña: $e');
      return false;
    }
  }

  // Guarda los cambios del perfil en Firebase Auth y Firestore
  void _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    // Verificar si el usuario quiere cambiar la contraseña
    final bool quiereCambiarContrasena =
        _contrasenaNuevaController.text.trim().isNotEmpty ||
            _confirmarContrasenaController.text.trim().isNotEmpty;

    if (quiereCambiarContrasena) {
      // Validar que se haya ingresado la contraseña actual
      if (_contrasenaActualController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes ingresar tu contraseña actual para cambiarla'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validar que la nueva contraseña tenga al menos 6 caracteres
      if (_contrasenaNuevaController.text.trim().length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('La nueva contraseña debe tener al menos 6 caracteres'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Verificar que las contraseñas nuevas coincidan
      if (_contrasenaNuevaController.text !=
          _confirmarContrasenaController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Las contraseñas nuevas no coinciden'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Si quiere cambiar la contraseña, verificar la actual primero
      if (quiereCambiarContrasena) {
        debugPrint('Verificando contraseña actual...');

        // Verificar que la contraseña actual sea correcta
        final contrasenaValida = await _verificarContrasenaActual(
            _contrasenaActualController.text.trim());

        if (!contrasenaValida) {
          debugPrint('Contraseña actual incorrecta');
          if (mounted) {
            setState(() {
              _isSaving = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('La contraseña actual es incorrecta'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        debugPrint('Contraseña actual correcta, actualizando...');

        try {
          // Actualizar la contraseña directamente
          await user
              .updatePassword(_contrasenaNuevaController.text.trim())
              .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Timeout al actualizar contraseña');
            },
          );
          debugPrint('Contraseña actualizada exitosamente');
        } on FirebaseAuthException catch (e) {
          debugPrint(
              'FirebaseAuthException al actualizar contraseña: ${e.code}');

          String mensaje = 'Error al cambiar contraseña';
          if (e.code == 'requires-recent-login') {
            mensaje =
                'Por seguridad, debes cerrar sesión y volver a iniciar para cambiar tu contraseña';
          } else if (e.code == 'weak-password') {
            mensaje = 'La contraseña es muy débil';
          }

          if (mounted) {
            setState(() {
              _isSaving = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(mensaje),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          return;
        } catch (e) {
          debugPrint('Error general al actualizar contraseña: $e');
          if (mounted) {
            setState(() {
              _isSaving = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al actualizar contraseña'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      // Actualizar displayName en Firebase Auth
      if (_nombreController.text.trim().isNotEmpty) {
        await user.updateDisplayName(_nombreController.text.trim());
      }

      // Actualizar datos en Firestore (solo nombre y cédula, NO el email)
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .update({
        'nombre': _nombreController.text.trim(),
        'cedula': _cedulaController.text.trim(),
      });

      // Recargar el usuario para reflejar los cambios
      await user.reload();

      if (!mounted) return;

      // Limpiar campos de contraseña después de guardar exitosamente
      _contrasenaActualController.clear();
      _contrasenaNuevaController.clear();
      _confirmarContrasenaController.clear();

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Recargar los datos actualizados
      _cargarDatosUsuario();
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} - ${e.message}');
      if (!mounted) return;

      String mensaje = 'Error al actualizar perfil';

      switch (e.code) {
        case 'requires-recent-login':
          mensaje =
              'Por seguridad, necesitas volver a iniciar sesión para cambiar estos datos';
          break;
        case 'weak-password':
          mensaje = 'La contraseña es muy débil';
          break;
        case 'email-already-in-use':
          mensaje = 'Este correo ya está en uso';
          break;
        case 'invalid-email':
          mensaje = 'El correo no es válido';
          break;
        default:
          mensaje = 'Error: ${e.message}';
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      debugPrint('Error general: $e');
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar perfil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Construye el AppBar con navegación adaptativa
  PreferredSizeWidget _buildAppBar(bool isDesktop) {
    final user = FirebaseAuth.instance.currentUser;
    final String userInitial =
        user?.email?.isNotEmpty == true ? user!.email![0].toUpperCase() : 'U';

    final Color avatarColor =
        _isAdmin ? AppColors.accentColor : AppColors.primaryOrange;

    final profileWidget = HoverableProfileAvatar(
      userInitial: userInitial,
      avatarColor: avatarColor,
      isDesktop: isDesktop,
    );

    if (isDesktop) {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 60,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ProyectApp',
          style: TextStyle(
            color: AppColors.primaryOrange,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón Menú
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const PantallaPrincipal(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text(
                    'Menú',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                const SizedBox(width: 20),

                // Botón Proyectos
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const PantallaListadoProyectos(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text(
                    'Proyectos',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                const SizedBox(width: 20),

                // Botón Calendario
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PantallaCalendario(),
                      ),
                    );
                  },
                  child: const Text(
                    'Calendario',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),

                // Botón Estadísticas (SOLO ADMIN)
                if (_isAdmin) ...[
                  const SizedBox(width: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const PantallaEstadisticasAdmin(),
                        ),
                      );
                    },
                    child: const Text(
                      'Estadísticas',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ],
            ),
          ),
          profileWidget,
          const SizedBox(width: 20),
        ],
      );
    } else {
      // APPBAR MÓVIL
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          profileWidget,
          const SizedBox(width: 10),
        ],
      );
    }
  }

  // Campo de texto genérico reutilizable
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    String? hintText,
    TextStyle? hintStyle,
    bool readOnly = false,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          readOnly: readOnly,
          enabled: !readOnly,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: readOnly ? Colors.grey[100] : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: readOnly ? Colors.grey[300]! : AppColors.primaryOrange,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: readOnly
                ? Icon(Icons.lock_outline, color: Colors.grey[400], size: 20)
                : null,
            counterText: '', // Oculta el contador de caracteres
          ),
          style: TextStyle(
            color: readOnly ? Colors.grey[600] : Colors.black87,
          ),
        ),
      ],
    );
  }

  // Campo de contraseña con botón para mostrar/ocultar
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          obscuringCharacter: '•',
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              letterSpacing: 0,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryOrange),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
              ),
              onPressed: onToggle,
            ),
          ),
          style: const TextStyle(
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  // Formulario principal con todos los campos del perfil
  Widget _buildProfileForm(bool isMobile) {
    if (_isLoading) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryOrange,
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Perfil de usuario',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _nombreController,
              label: 'Nombre completo',
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _correoController,
              label: 'Correo Electrónico',
              hintText: 'ejemplo@correo.unimet.edu.ve',
              readOnly: true,
            ),
            const SizedBox(height: 8),
            Text(
              'El correo electrónico no puede modificarse',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _cedulaController,
              label: 'Cédula',
              hintText: 'V12345678',
              maxLength: 9, // V + 8 dígitos
              hintStyle: TextStyle(color: Colors.grey[500]),
              inputFormatters: [
                TextInputFormatter.withFunction((oldValue, newValue) {
                  // Permitir solo dígitos después de remover la V
                  String text = newValue.text;

                  // Si está vacío, permitir
                  if (text.isEmpty) return newValue;

                  // Remover la V si existe para contar solo dígitos
                  String digitsOnly =
                      text.replaceAll('V', '').replaceAll('v', '');

                  // Filtrar solo números
                  digitsOnly = digitsOnly.replaceAll(RegExp(r'[^0-9]'), '');

                  // Limitar a 8 dígitos
                  if (digitsOnly.length > 8) {
                    digitsOnly = digitsOnly.substring(0, 8);
                  }

                  // Si no hay dígitos, devolver vacío
                  if (digitsOnly.isEmpty) {
                    return const TextEditingValue(text: '');
                  }

                  // Construir el texto final con V
                  String finalText = 'V$digitsOnly';

                  // Mantener el cursor al final
                  return TextEditingValue(
                    text: finalText,
                    selection:
                        TextSelection.collapsed(offset: finalText.length),
                  );
                }),
              ],
            ),
            const SizedBox(height: 32),

            // Sección de cambio de contraseña
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cambiar contraseña',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completa los siguientes campos solo si deseas cambiar tu contraseña',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    controller: _contrasenaActualController,
                    label: 'Contraseña actual',
                    obscureText: _obscureCurrentPassword,
                    hintText: 'Ingresa tu contraseña actual',
                    onToggle: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    controller: _contrasenaNuevaController,
                    label: 'Nueva contraseña',
                    obscureText: _obscureNewPassword,
                    hintText: 'Ingresa tu nueva contraseña',
                    onToggle: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mínimo 6 caracteres',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    controller: _confirmarContrasenaController,
                    label: 'Confirmar nueva contraseña',
                    obscureText: _obscureConfirmPassword,
                    hintText: 'Confirma tu nueva contraseña',
                    onToggle: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _guardarCambios,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Guardar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _isSaving ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Volver',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Footer con información de contacto y enlaces
  Widget _buildFooter(BuildContext context, bool isMobile) {
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: const Border(
            top: BorderSide(color: AppColors.primaryOrange, width: 4)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              mainAxisAlignment: isMobile
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
              crossAxisAlignment: isMobile
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                _buildFooterSection(
                  'ProyectApp',
                  [
                    'Sistema de gestión de proyectos para ingeniería',
                    'en la Universidad Metropolitana'
                  ],
                  isMobile,
                  isTitleBold: true,
                ),
                SizedBox(height: isMobile ? 30 : 0, width: isMobile ? 0 : 50),
                _buildFooterSection(
                  'Links',
                  ['Proyectos', 'Calendario', 'Estadísticas'],
                  isMobile,
                ),
                SizedBox(height: isMobile ? 30 : 0, width: isMobile ? 0 : 50),
                _buildFooterSection(
                  'Ayuda',
                  [
                    'Email: ayudalog@proyectapp.unimet.edu.ve',
                    'Contacto: 0202020200202'
                  ],
                  isMobile,
                  isContact: true,
                ),
                SizedBox(height: isMobile ? 30 : 0, width: isMobile ? 0 : 50),
                Column(
                  children: [
                    const Icon(
                      Icons.camera_alt,
                      color: Colors.black87,
                      size: 30,
                    ),
                    const SizedBox(height: 5),
                    const Text('Instagram',
                        style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey[300]),
          const Text(
            '2025 ProyectApp UNIMET. Derechos Reservados.',
            style: TextStyle(color: Colors.black54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Sección individual del footer
  Widget _buildFooterSection(String title, List<String> items, bool isMobile,
      {bool isTitleBold = false, bool isContact = false}) {
    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isContact ? AppColors.accentColor : Colors.black87,
            fontSize: 18,
            fontWeight: isTitleBold ? FontWeight.bold : FontWeight.w500,
          ),
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
        ),
        const SizedBox(height: 10),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                item,
                style: TextStyle(
                  color: isContact ? Colors.black54 : Colors.black87,
                  fontSize: 14,
                ),
                textAlign: isMobile ? TextAlign.center : TextAlign.left,
              ),
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar loading mientras se verifica el rol
    if (_isLoadingRole) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryOrange,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 800;
        final bool isMobile = constraints.maxWidth < 800;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: _buildAppBar(isDesktop),
          body: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 40,
                    vertical: isMobile ? 30 : 60,
                  ),
                  child: Center(
                    child: _buildProfileForm(isMobile),
                  ),
                ),
                _buildFooter(context, isMobile),
              ],
            ),
          ),
        );
      },
    );
  }
}
