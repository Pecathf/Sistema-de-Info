import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sistem_proyect/central/constantes/colores.dart';

class PantallaEditarPerfil extends StatefulWidget {
  const PantallaEditarPerfil({super.key});

  @override
  State<PantallaEditarPerfil> createState() => _PantallaEditarPerfilState();
}

class _PantallaEditarPerfilState extends State<PantallaEditarPerfil> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  void _cargarDatosUsuario() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nombreController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
      _correoController.text = user.email ?? '';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _usuarioController.dispose();
    _correoController.dispose();
    _ciudadController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  void _guardarCambios() {
    if (_formKey.currentState!.validate()) {
      // Aquí iría la lógica para guardar los cambios
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
    }
  }

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
      actions: isDesktop
          ? [
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
              const SizedBox(width: 20),
            ]
          : null,
    );
  }

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

  Widget _buildProfileForm(bool isMobile) {
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
              controller: _emailController,
              label: 'Email',
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _usuarioController,
              label: 'Nombre de Usuario',
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _correoController,
              label: 'Correo Electrónico',
              hintText: 'ejemplo@correo.com',
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _ciudadController,
              label: 'Ciudad',
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _contrasenaController,
              label: 'Contraseña',
              obscureText: true,
              hintText: '••••••••',
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _guardarCambios,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Guardar',
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
