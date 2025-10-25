import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart';
import 'package:sistem_proyect/central/constantes/colores.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final AuthService _authService = AuthService();

  // Variables estáticas de color, usando AppColors para consistencia
  static const Color _naranjaPrincipal = AppColors.primaryOrange;
  static const Color _franjaFooter = AppColors.primaryOrange;

  // **********************************************
  // LÓGICA DE CIERRE DE SESIÓN
  // **********************************************
  Future<void> _cerrarSesion(BuildContext context) async {
    await _authService.signOut();
  }

  // **********************************************
// MÉTODO PARA EDITAR PERFIL
// **********************************************
  void _editarPerfil() {
    // TODO: Implementar navegación a pantalla de editar perfil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de editar perfil próximamente'),
        duration: Duration(seconds: 2),
      ),
    );
  }

// **********************************************
// MÉTODO PARA MOSTRAR EL MENÚ DE PERFIL
// **********************************************
  void _mostrarMenuPerfil(BuildContext context, Offset offset) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx - 150,
        offset.dy + 10,
        offset.dx,
        offset.dy,
      ),
      items: [
        PopupMenuItem(
          child: Row(
            children: const [
              Icon(Icons.edit, color: Colors.black87, size: 20),
              SizedBox(width: 12),
              Text('Editar Perfil'),
            ],
          ),
          onTap: () {
            Future.delayed(Duration.zero, () => _editarPerfil());
          },
        ),
        PopupMenuItem(
          child: Row(
            children: const [
              Icon(Icons.logout, color: Colors.red, size: 20),
              SizedBox(width: 12),
              Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            ],
          ),
          onTap: () {
            Future.delayed(Duration.zero, () => _cerrarSesion(context));
          },
        ),
      ],
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  // **********************************************
  // MÉTODOS AUXILIARES DEL DASHBOARD
  // **********************************************

  String _getUserInitial(String? userName) {
    if (userName == null || userName.isEmpty) {
      return 'U';
    }
    return userName[0].toUpperCase();
  }

  Widget _buildWelcomeHeader(String userName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola, $userName',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Bienvenido de vuelta! Aquí tienes un resumen de tus proyectos.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    // Definición de Color con opacidad 0.05
    Color boxShadowColor = Color.fromRGBO(
        (Colors.grey.r * 255.0).round() & 0xff,
        (Colors.grey.g * 255.0).round() & 0xff,
        (Colors.grey.b * 255.0).round() & 0xff,
        0.05);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            // CORRECCIÓN: Reemplazar withOpacity con Color.fromRGBO
            color: boxShadowColor,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar proyectos...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {},
            icon:
                const Icon(Icons.filter_list, color: Colors.black54, size: 20),
            label: const Text(
              'Todos los estados',
              style:
                  TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // MODIFICADO: Ahora recibe 'isDesktop' para cambiar el layout.
  Widget _buildStatisticsGrid(BuildContext context, bool isDesktop) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildEmptyStatistics();
    }

    final stats = [
      {
        'title': 'PROYECTOS TOTALES',
        'value': '12',
        'subtitle': 'Total de proyectos',
        'color': _naranjaPrincipal
      },
      {
        'title': 'PROYECTOS ACTIVOS',
        'value': '8',
        'subtitle': 'En progreso',
        'color': Colors.blue
            .shade700 // Cambiado a un color secundario para diferenciación visual
      },
      {
        'title': 'TAREAS PENDIENTES',
        'value': '24',
        'subtitle': 'Por completar',
        'color': Colors.red.shade700
      },
      {
        'title': 'COMPLETADOS',
        'value': '4',
        'subtitle': 'Finalizados',
        'color': Colors.green.shade700
      },
    ];

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: stats
            .map((stat) => Expanded(
                  child: Padding(
                    // Separación uniforme entre tarjetas
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildStatCard(
                      stat['title'] as String,
                      stat['value'] as String,
                      stat['subtitle'] as String,
                      stat['color'] as Color,
                    ),
                  ),
                ))
            .toList(),
      );
    } else {
      // Layout para móvil/tablet: Wrap para que las tarjetas fluyan en 2 columnas.
      return Wrap(
        spacing: 16.0, // Espacio horizontal entre tarjetas
        runSpacing: 16.0, // Espacio vertical entre filas
        children: stats
            .map((stat) => SizedBox(
                  // Calcula un ancho para que quepan 2 elementos con espacio.
                  width: (MediaQuery.of(context).size.width / 2) - 40,
                  child: _buildStatCard(
                    stat['title'] as String,
                    stat['value'] as String,
                    stat['subtitle'] as String,
                    stat['color'] as Color,
                  ),
                ))
            .toList(),
      );
    }
  }

  Widget _buildEmptyStatistics() {
    return const Center(child: Text('Cargando estadísticas...'));
  }

  Widget _buildStatCard(
      String title, String value, String subtitle, Color color) {
    Color boxShadowColor = Color.fromRGBO(
        (color.r * 255.0).round() & 0xff,
        (color.g * 255.0).round() & 0xff,
        (color.b * 255.0).round() & 0xff,
        0.05);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10), // Aumentado el radio
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            // CORRECCIÓN: Reemplazar withOpacity con Color.fromRGBO
            color: boxShadowColor,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Mayor padding interno
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 36, // Tamaño de valor aumentado
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectRow(String title, String subtitle, String status) {
    Color statusColor;
    Color statusBgColor;

    switch (status) {
      case 'Activo':
        statusColor = Colors.green.shade700;
        statusBgColor = Colors.green.shade100;
        break;
      case 'Pendiente':
        statusColor = Colors.amber.shade700;
        statusBgColor = Colors.amber.shade100;
        break;
      case 'Completado':
        statusColor = Colors.blue.shade700;
        statusBgColor = Colors.blue.shade100;
        break;
      default:
        statusColor = Colors.grey.shade700;
        statusBgColor = Colors.grey.shade100;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.folder_open,
              color: AppColors.primaryOrange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13, // Reducido ligeramente
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 6), // Mayor padding
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius:
                  BorderRadius.circular(16), // Más redondeado (Pill shape)
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentProjects(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildEmptyProjects();
    }

    // Datos simulados (dejados como están)
    final recentProjects = [
      {
        'name': 'Integración de Sistemas Automatizados',
        'created': '15 Sep 2025',
        'members': 5,
        'tasks': 12,
        'status': 'Activo'
      },
      {
        'name': 'Migración a la Nube Empresarial',
        'created': '10 Sep 2025',
        'members': 3,
        'tasks': 8,
        'status': 'Pendiente'
      },
      {
        'name': 'Desarrollo de Protocolos de Seguridad Informática',
        'created': '5 Sep 2025',
        'members': 4,
        'tasks': 15,
        'status': 'Completado'
      },
      {
        'name': 'Rediseño de Base de Datos',
        'created': '1 Sep 2025',
        'members': 2,
        'tasks': 6,
        'status': 'Activo'
      },
    ];

    Color boxShadowColor = Color.fromRGBO(
        (Colors.grey.r * 255.0).round() & 0xff,
        (Colors.grey.g * 255.0).round() & 0xff,
        (Colors.grey.b * 255.0).round() & 0xff,
        0.1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Proyectos Recientes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                // CORRECCIÓN: Reemplazar withOpacity con Color.fromRGBO
                color: boxShadowColor,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: recentProjects.map((project) {
              return _buildProjectRow(
                project['name'] as String,
                'Creado: ${project['created']} • ${project['members']} miembros • ${project['tasks']} tareas',
                project['status'] as String,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyProjects() {
    return const Center(child: Text('Cargando proyectos...'));
  }

  Widget _buildPendingTasksCard() {
    final pendingTasks = [
      {
        'name': 'Diseño de wireframes',
        'status': 'Completado',
        'date': '18 de Septiembre',
        'color': Colors.green
      },
      {
        'name': 'Integración con CMS',
        'status': 'Pendiente',
        'date': 'Mañana',
        'color': Colors.orange
      },
      {
        'name': 'Desarrollo del frontend',
        'status': 'Urgente',
        'date': '11:00 pm',
        'color': Colors.red
      },
      {
        'name': 'Revisión de arquitectura',
        'status': 'Pendiente',
        'date': 'Hoy',
        'color': Colors.red
      },
    ];

    Color boxShadowColor = Color.fromRGBO(
        (Colors.grey.r * 255.0).round() & 0xff,
        (Colors.grey.g * 255.0).round() & 0xff,
        (Colors.grey.b * 255.0).round() & 0xff,
        0.1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            // CORRECCIÓN: Reemplazar withOpacity con Color.fromRGBO
            color: boxShadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tareas Pendientes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // CORRECCIÓN: Eliminar .toList() innecesario en el spread
          ...pendingTasks.map((task) => _buildTaskRow(
                task['name'] as String,
                task['status'] as String,
                task['date'] as String,
                task['color'] as Color,
              )),
        ],
      ),
    );
  }

  Widget _buildTaskRow(String name, String status, String date, Color color) {
    Color statusBgColor = Color.fromRGBO(
        (color.r * 255.0).round() & 0xff,
        (color.g * 255.0).round() & 0xff,
        (color.b * 255.0).round() & 0xff,
        0.1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Centrado vertical
        children: [
          Icon(
            status == 'Completado'
                ? Icons.check_circle_outline
                : Icons
                    .pending_actions_outlined, // Ícono más adecuado para tareas
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    // CORRECCIÓN: Reemplazar withOpacity con Color.fromRGBO
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // MODIFICADO: Ahora recibe 'isDesktop' para cambiar el layout del footer.
  Widget _buildFooter(bool isDesktop) {
    // Usamos AppColors en lugar de colores codificados para mantener la consistencia
    Color footerColor = AppColors.darkBackground; // Usando el fondo oscuro
    Color footerTextColor =
        Colors.white; // Usando texto blanco sobre fondo oscuro

    // Contenido de las secciones
    Widget mainContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ProyectApp',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: footerTextColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sistema de Gestión de proyectos para Ingeniería en la Universidad Metropolitana.',
          style: TextStyle(
            fontSize: 14,
            // CORRECCIÓN: Reemplazar withOpacity con Color.fromRGBO
            color: Color.fromRGBO(
                (footerTextColor.r * 255.0).round() & 0xff,
                (footerTextColor.g * 255.0).round() & 0xff,
                (footerTextColor.b * 255.0).round() & 0xff,
                0.8),
          ),
        ),
      ],
    );

    Widget linksSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Links',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: footerTextColor)),
        TextButton(
            onPressed: () => _cerrarSesion(context),
            // CORRECCIÓN: Reemplazar withOpacity con Color.fromRGBO
            child: Text('Cerrar Sesión',
                style: TextStyle(
                    color: Color.fromRGBO(
                        (footerTextColor.r * 255.0).round() & 0xff,
                        (footerTextColor.g * 255.0).round() & 0xff,
                        (footerTextColor.b * 255.0).round() & 0xff,
                        0.8)))),
        TextButton(
            onPressed: () {},
            // CORRECCIÓN: Reemplazar withOpacity con Color.fromRGBO
            child: Text('Mi Perfil',
                style: TextStyle(
                    color: Color.fromRGBO(
                        (footerTextColor.r * 255.0).round() & 0xff,
                        (footerTextColor.g * 255.0).round() & 0xff,
                        (footerTextColor.b * 255.0).round() & 0xff,
                        0.8)))),
      ],
    );

    Widget helpSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ayuda',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: footerTextColor)),
        const SizedBox(height: 8),
        Text(
          'Email: ayuda@proyectapp.unimet.edu.ve',
          style:
              // CORRECCIÓN: Reemplazar withOpacity con Color.fromRGBO
              TextStyle(
                  fontSize: 12,
                  color: Color.fromRGBO(
                      (footerTextColor.r * 255.0).round() & 0xff,
                      (footerTextColor.g * 255.0).round() & 0xff,
                      (footerTextColor.b * 255.0).round() & 0xff,
                      0.8)),
        ),
        Text(
          'Contacto: 0202020200202',
          style:
              // CORRECCIÓN: Reemplazar withOpacity con Color.fromRGBO
              TextStyle(
                  fontSize: 12,
                  color: Color.fromRGBO(
                      (footerTextColor.r * 255.0).round() & 0xff,
                      (footerTextColor.g * 255.0).round() & 0xff,
                      (footerTextColor.b * 255.0).round() & 0xff,
                      0.8)),
        ),
        const SizedBox(height: 10),
        Icon(Icons.support_agent, color: footerTextColor, size: 24),
      ],
    );

    // Color para el texto final del footer
    Color finalTextColor = Colors.white;
    Color finalTextColorWithOpacity = Color.fromRGBO(
        (finalTextColor.r * 255.0).round() & 0xff,
        (finalTextColor.g * 255.0).round() & 0xff,
        (finalTextColor.b * 255.0).round() & 0xff,
        0.8);

    return Container(
      width: double.infinity,
      color: footerColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isDesktop ? 40 : 20),
            child: isDesktop
                ? Row(
                    // Desktop: 3 columnas
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: mainContent),
                      const SizedBox(width: 40),
                      Expanded(child: linksSection),
                      Expanded(child: helpSection),
                    ],
                  )
                : Column(
                    // Mobile: 3 secciones apiladas
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      mainContent,
                      const SizedBox(height: 20),
                      linksSection,
                      const SizedBox(height: 20),
                      helpSection,
                    ],
                  ),
          ),
          Container(
            height: 30,
            width: double.infinity,
            color: _franjaFooter,
            child: Center(
              child: Text(
                '2025 ProyectApp UNIMET. Derechos Reservados.',
                style: TextStyle(
                    // CORRECCIÓN: Reemplazar withOpacity con Color.fromRGBO
                    color: finalTextColorWithOpacity,
                    fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Método auxiliar (Mantenido como comentario para preservar el código, evitando la advertencia unused_element)
  /* String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'Fecha no disponible';
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return '${fecha.day} ${months[fecha.month - 1]} ${fecha.year}';
  }
  */

  // Método que construye un AppBar simple para móvil y el completo para desktop
  PreferredSizeWidget _buildAppBar(String userInitial, bool isDesktop) {
    if (isDesktop) {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 60,
        title: const Text(
          'ProyectApp',
          style: TextStyle(
            color: _naranjaPrincipal,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {},
              child: const Text('Proyectos',
                  style: TextStyle(color: Colors.black87))),
          TextButton(
              onPressed: () {},
              child: const Text('Calendario',
                  style: TextStyle(color: Colors.black87))),
          TextButton(
              onPressed: () {},
              child: const Text('Estadísticas',
                  style: TextStyle(color: Colors.black87))),
          const SizedBox(width: 20),
          GestureDetector(
            onTapDown: (TapDownDetails details) {
              _mostrarMenuPerfil(context, details.globalPosition);
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: _naranjaPrincipal,
                  shape: BoxShape.circle,
                ),
                child: Text(userInitial,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      );
    } else {
      // AppBar simplificado para móvil/tablet
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Dashboard',
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            onPressed: () {
              // Lógica de búsqueda móvil (si es necesario)
            },
          ),
          GestureDetector(
            onTapDown: (TapDownDetails details) {
              _mostrarMenuPerfil(context, details.globalPosition);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: _naranjaPrincipal,
                  shape: BoxShape.circle,
                ),
                child: Text(userInitial,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      );
    }
  }

  // --- Método Build Principal (MODIFICADO para Responsividad) ---

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String userName =
        user?.displayName ?? user?.email?.split('@').first ?? 'Usuario';
    final String userInitial = _getUserInitial(userName);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Definición del punto de quiebre (breakpoint) para escritorio
        final bool isDesktop = constraints.maxWidth > 800;
        final double horizontalPadding = isDesktop ? 40.0 : 20.0;
        final double verticalSpacing = isDesktop ? 40.0 : 30.0;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: _buildAppBar(userInitial, isDesktop),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding, vertical: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Cabecera de Bienvenida
                      _buildWelcomeHeader(userName),
                      SizedBox(height: verticalSpacing),

                      // 2. Barra de Búsqueda (Ocupa todo el ancho)
                      _buildSearchBar(),
                      SizedBox(height: verticalSpacing),

                      // 3. Grid de Estadísticas (Responsive)
                      _buildStatisticsGrid(context, isDesktop),
                      SizedBox(height: verticalSpacing),

                      // 4. Contenido Principal: Proyectos y Tareas (Responsive)
                      isDesktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _buildRecentProjects(context),
                                ),
                                const SizedBox(width: 40),
                                Expanded(
                                  flex: 2,
                                  child: _buildPendingTasksCard(),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Se apilan verticalmente para pantallas pequeñas
                                _buildRecentProjects(context),
                                SizedBox(height: verticalSpacing),
                                _buildPendingTasksCard(),
                              ],
                            ),
                      SizedBox(height: verticalSpacing),
                    ],
                  ),
                ),
              ),
              // 5. Footer (Responsive)
              _buildFooter(isDesktop),
            ],
          ),
        );
      },
    );
  }
}
