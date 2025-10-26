import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_proyect/central/constantes/colores.dart';

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
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _confirmarContrasenaController =
      TextEditingController();

  bool _isLoading = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
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
                // Actualizar campos con datos de Firestore
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
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }

  // Guarda los cambios del perfil en Firebase Auth y Firestore
  void _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      // Verificar que las contraseñas coincidan si se proporcionó una nueva
      if (_contrasenaController.text.trim().isNotEmpty &&
          _contrasenaController.text != _confirmarContrasenaController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Las contraseñas no coinciden'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Actualizar displayName en Firebase Auth
          if (_nombreController.text.trim().isNotEmpty) {
            await user.updateDisplayName(_nombreController.text.trim());
          }

          // Actualizar email en Firebase Auth si cambió
          if (_correoController.text.trim() != user.email) {
            await user.verifyBeforeUpdateEmail(_correoController.text.trim());
          }

          // Actualizar contraseña en Firebase Auth si se proporcionó una nueva
          if (_contrasenaController.text.trim().isNotEmpty) {
            await user.updatePassword(_contrasenaController.text.trim());
          }

          // Actualizar datos en Firestore
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .update({
            'nombre': _nombreController.text.trim(),
            'cedula': _cedulaController.text.trim(),
            'email': _correoController.text.trim(),
          });

          // Recargar el usuario para reflejar los cambios
          await user.reload();

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );

          // Recargar los datos actualizados
          _cargarDatosUsuario();
        }
      } on FirebaseAuthException catch (e) {
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
            content: Text('Error al actualizar perfil: $e'),
            backgroundColor: Colors.red,
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
  }

  // Construye el AppBar con navegación adaptativa
  PreferredSizeWidget _buildAppBar(bool isDesktop) {
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
      actions: isDesktop
          ? [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Inicio',
                          style: TextStyle(color: Colors.black87)),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Proyectos',
                          style: TextStyle(color: Colors.black87)),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Calendario',
                          style: TextStyle(color: Colors.black87)),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Estadísticas',
                          style: TextStyle(color: Colors.black87)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
            ]
          : null,
    );
  }

  // Campo de texto genérico reutilizable
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
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
          decoration: InputDecoration(
            hintText: hintText,
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
          decoration: InputDecoration(
            hintText: hintText,
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
              color: Colors.grey.withOpacity(0.1),
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
            color: Colors.grey.withOpacity(0.1),
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
              hintText: 'ejemplo@correo.com',
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _cedulaController,
              label: 'Cédula',
              hintText: 'V30980220',
            ),
            const SizedBox(height: 20),
            _buildPasswordField(
              controller: _contrasenaController,
              label: 'Contraseña',
              obscureText: _obscurePassword,
              hintText: '••••••••',
              onToggle: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Deja en blanco si no deseas cambiarla',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            _buildPasswordField(
              controller: _confirmarContrasenaController,
              label: 'Confirmar contraseña',
              obscureText: _obscureConfirmPassword,
              hintText: '••••••••',
              onToggle: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _guardarCambios,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
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
                      'Guardar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
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
        ...items
            .map((item) => Padding(
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
            .toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
