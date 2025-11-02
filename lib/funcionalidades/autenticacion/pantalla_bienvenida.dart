import 'package:flutter/material.dart';
import 'package:sistem_proyect/central/constantes/colores.dart';
import 'pantalla_inicio_sesion.dart';
import 'pantalla_registro.dart';

// Definición de la URL base para el fondo de imagen de la pantalla de bienvenida
const String _imageUrl = 'https://picsum.photos/1920/1080?random=1';

// PANTALLA DE BIENVENIDA

class PantallaBienvenida extends StatelessWidget {
  const PantallaBienvenida({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      // Utilizamos Stack para colocar la imagen de fondo detrás del contenido
      body: Stack(
        children: [
          // 1. Fondo de Imagen con Overlay Oscuro
          _buildBackground(),

          // 2. Contenido Principal Centrado
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 50, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 3. Barra Superior (Simplificada)
                    _buildTopBar(context),
                    SizedBox(height: isMobile ? 50 : 100),

                    // 4. Sección Principal de Título y Botones
                    _buildMainSection(context, isMobile),
                    SizedBox(height: isMobile ? 60 : 80),

                    // 5. Cuadrícula de Módulos
                    _buildModulesGrid(context),
                    SizedBox(height: isMobile ? 60 : 80),

                    // 6. Footer
                    _buildFooter(context, isMobile),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fondo de Imagen con Filtro
  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          // La imagen de fondo
          image: const NetworkImage(_imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            // Overlay oscuro para hacer el texto legible
            AppColors.darkBackground.withValues(alpha:0.7),
            BlendMode.darken,
          ),
        ),
      ),
    );
  }

  // Barra de Navegación Superior
  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        const Text(
          'ProyectApp',
          style: TextStyle(
            color: AppColors.primaryOrange,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  // Sección Principal con Título y Botones de Acción
  Widget _buildMainSection(BuildContext context, bool isMobile) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      child: Column(
        children: [
          // Título Principal
          Text(
            'Gestión de Proyectos e Investigación',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 36 : 58,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          // Subtítulo
          const Text(
            'Tu único punto de control. Centraliza equipos, tareas y recursos para asegurar el éxito de tu proyecto.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 40),

          // Botones de Acción
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildActionButton(
                context,
                'Quiero Empezar',
                AppColors.primaryOrange,
                // Navega a Registro
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PantallaRegistro())),
              ),
              _buildActionButton(
                context,
                'Iniciar Sesión',
                AppColors.primaryOrange.withValues(alpha:0.8),
                // Navega a Inicio de Sesión
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PantallaInicioSesion())),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Botón de Acción Principal Reutilizable
  Widget _buildActionButton(
      BuildContext context, String text, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        elevation: 5,
      ),
      child: Text(text),
    );
  }

  // Cuadrícula de Módulos (Características)
  Widget _buildModulesGrid(BuildContext context) {
    // Lista de módulos con iconos y nombres
    final List<Map<String, dynamic>> modules = [
      {'icon': Icons.trending_up, 'title': 'Gestión de proyectos'},
      {'icon': Icons.assignment, 'title': 'Panel de Tareas'},
      {'icon': Icons.groups, 'title': 'Gestión de Recursos'},
      {'icon': Icons.bar_chart, 'title': 'Panel de Estadísticas'},
      {'icon': Icons.chat, 'title': 'Centro de Colaboración'},
      {'icon': Icons.schedule, 'title': 'Calendario e hitos'},
    ];

    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      constraints: const BoxConstraints(maxWidth: 1000),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: modules.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 2 : 3, // 3 columnas en desktop, 2 en móvil
          mainAxisSpacing: 30,
          crossAxisSpacing: 30,
          childAspectRatio: 1.0, // Tarjetas cuadradas
        ),
        itemBuilder: (context, index) {
          final module = modules[index];
          return _buildModuleCard(
              module['title'] as String, module['icon'] as IconData);
        },
      ),
    );
  }

  // Tarjeta de Módulo individual
  Widget _buildModuleCard(String title, IconData icon) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          // Acción futura al tocar el módulo (puede ser una descripción)
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 60,
                color: AppColors
                    .darkBackground, // Usar un color que contraste con el fondo blanco
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBackground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Pie de Página (Footer)
  Widget _buildFooter(BuildContext context, bool isMobile) {
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      // Mismo color naranja que el borde superior en el Figma
      decoration: const BoxDecoration(
        border:
            Border(top: BorderSide(color: AppColors.primaryOrange, width: 4)),
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
                // Columna 1: Información de ProyectApp
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

                // Columna 2: Links
                _buildFooterSection(
                  'Links',
                  ['Iniciar Sesión', 'Registro'],
                  isMobile,
                ),
                SizedBox(height: isMobile ? 30 : 0, width: isMobile ? 0 : 50),

                // Columna 3: Ayuda y Contacto
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

                // Columna 4: Icono de Red Social
                Column(
                  children: [
                    const Icon(
                      Icons.camera_alt, // Ícono de Instagram/Red Social
                      color: Colors.white,
                      size: 30,
                    ),
                    const SizedBox(height: 5),
                    Text('Instagram',
                        style: TextStyle(color: Colors.white.withValues(alpha:0.8))),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(color: Colors.white12),

          // Derechos de autor
          Text(
            '2025 ProyectApp UNIMET. Derechos Reservados.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Sección genérica del Footer
  Widget _buildFooterSection(String title, List<String> items, bool isMobile,
      {bool isTitleBold = false, bool isContact = false}) {
    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isContact
                ? AppColors.accentColor
                : Colors.white, // El Figma usa azul para "Ayuda"
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
                      color: isContact
                          ? Colors.white70
                          : Colors.white.withValues(alpha:0.8),
                      fontSize: 14,
                    ),
                    textAlign: isMobile ? TextAlign.center : TextAlign.left,
                  ),
                ))
      ],
    );
  }
}
