import 'package:flutter/material.dart';
import '../../central/constantes/colores.dart';

class PantallaEditarPerfil extends StatefulWidget {
  const PantallaEditarPerfil({Key? key}) : super(key: key);

  @override
  State<PantallaEditarPerfil> createState() => _PantallaEditarPerfilState();
}

class _PantallaEditarPerfilState extends State<PantallaEditarPerfil> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _controladorNombre;
  late TextEditingController _controladorUsuario;
  late TextEditingController _controladorCorreo;
  late TextEditingController _controladorCodula;
  late TextEditingController _controladorContrasena;

  bool _contrasenaVisible = false;
  int _indiceNavegacion = 0;

  @override
  void initState() {
    super.initState();
    _controladorNombre = TextEditingController(text: 'Juana del carreón');
    _controladorUsuario = TextEditingController(text: 'Juantajol');
    _controladorCorreo = TextEditingController(text: 'diemolo@correo.com');
    _controladorCodula = TextEditingController(text: 'v3D010220');
    _controladorContrasena = TextEditingController(text: '......... ');
  }

  @override
  void dispose() {
    _controladorNombre.dispose();
    _controladorUsuario.dispose();
    _controladorCorreo.dispose();
    _controladorCodula.dispose();
    _controladorContrasena.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Row(
        children: [
          // Panel lateral izquierdo - Menú
          _buildPanelLateral(),

          // Contenido principal
          Expanded(
            child: _buildContenidoPrincipal(),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelLateral() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        border: Border(right: BorderSide(color: AppColors.lightGrey)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del panel lateral
          Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              'ProyectApp',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Menú de navegación
          _buildItemMenu(Icons.dashboard, 'Panel de Estadísticas', 0),
          _buildItemMenu(Icons.folder, 'Proyectos', 1),
          _buildItemMenu(Icons.calendar_today, 'Calendario', 2),
          _buildItemMenu(Icons.bar_chart, 'Estadísticas', 3),
          _buildItemMenu(Icons.person, 'Perfil', 4),
          _buildItemMenu(Icons.settings, 'Configuración', 5),

          Spacer(),

          // Footer del panel lateral
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '2022 Emprendedor DINNET',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Beneficios Institucionales',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemMenu(IconData icon, String texto, int indice) {
    return ListTile(
      leading: Icon(icon, color: Colors.white.withOpacity(0.8)),
      title: Text(
        texto,
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 14,
        ),
      ),
      onTap: () {
        setState(() {
          _indiceNavegacion = indice;
        });
      },
      tileColor: _indiceNavegacion == indice
          ? AppColors.primaryOrange.withOpacity(0.2)
          : Colors.transparent,
    );
  }

  Widget _buildContenidoPrincipal() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header superior
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Forma 97',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.darkBackground.withOpacity(0.6),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.notifications, color: AppColors.darkBackground),
                  SizedBox(width: 16),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryOrange,
                    child: Text(
                      'J',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 24),

          // Título principal
          Text(
            'Perfil de usuario',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBackground,
            ),
          ),

          SizedBox(height: 32),

          // Formulario de perfil
          Container(
            width: 600,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCampoPerfil('Nombre completo', _controladorNombre),
                  SizedBox(height: 20),
                  _buildCampoPerfil('Nombre de Usuario', _controladorUsuario),
                  SizedBox(height: 20),
                  _buildCampoPerfil('Correo Electrónico', _controladorCorreo),
                  SizedBox(height: 20),
                  _buildCampoPerfil('Codula', _controladorCodula),
                  SizedBox(height: 20),
                  _buildCampoContrasena(),
                  SizedBox(height: 32),

                  // Botones de acción
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Guardar cambios
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text('Guardar'),
                      ),
                      SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () {
                          // Cancelar
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          side: BorderSide(color: AppColors.lightGrey),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(color: AppColors.darkBackground),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 40),

          // Información adicional
          Container(
            width: 600,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ProyectApp',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBackground,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Sistema de escisión de proyectos para ingerirlo en la Universidad Interprofesora',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.darkBackground.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 16),

                // Enlaces de autenticación
                Row(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Iniciar sesión',
                        style: TextStyle(color: AppColors.accentColor),
                      ),
                    ),
                    SizedBox(width: 16),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Registro',
                        style: TextStyle(color: AppColors.accentColor),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Información de contacto
                Divider(color: AppColors.lightGrey),
                SizedBox(height: 16),
                Text(
                  'Aplicado:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkBackground,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Email: ory.debergproyectApp.artimest.edu.vn',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.darkBackground.withOpacity(0.6),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Contacto: 000000000002',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.darkBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampoPerfil(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.darkBackground.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 6),
        Container(
          height: 45,
          child: TextFormField(
            controller: controller,
            style: TextStyle(
              color: AppColors.darkBackground,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: AppColors.lightGrey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: AppColors.lightGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: AppColors.primaryOrange),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCampoContrasena() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contraseña',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.darkBackground.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 6),
        Container(
          height: 45,
          child: TextFormField(
            controller: _controladorContrasena,
            obscureText: !_contrasenaVisible,
            style: TextStyle(
              color: AppColors.darkBackground,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: AppColors.lightGrey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: AppColors.lightGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: AppColors.primaryOrange),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _contrasenaVisible ? Icons.visibility : Icons.visibility_off,
                  size: 18,
                  color: AppColors.darkBackground.withOpacity(0.5),
                ),
                onPressed: () {
                  setState(() {
                    _contrasenaVisible = !_contrasenaVisible;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
