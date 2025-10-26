import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets_principal.dart';  // Importa widgets y colores
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart';
import 'package:sistem_proyect/funcionalidades/autenticacion/pantalla_inicio_sesion.dart'; // RUTA ACTUALIZADA



class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}
class _PantallaPrincipalState extends State<PantallaPrincipal> {
<<<<<<< HEAD
<<<<<<< HEAD
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Usuario';
    final userInitials = _getUserInitials(userName);

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
        actions: [
          GestureDetector(
            onTap: () {
              // Navegar a editar perfil después
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  userInitials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.grey[600]),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.grey[600]),
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(userName),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildStatisticsGrid(),
            const SizedBox(height: 32),
            _buildRecentProjects(),
            const SizedBox(height: 32),
            _buildPendingTasks(),
            const SizedBox(height: 32),
            _buildFooter(),
          ],
        ),
      ),
    );
=======

  static const Color _naranjaPrincipal = Color(0xFFE8751A); 
=======
>>>>>>> Jabrieliz
  
  final AuthService _authService = AuthService();

  Future<void> _cerrarSesion(BuildContext context) async {
    // 1. Cierra la sesión en Firebase
    await _authService.signOut();

    // 2. Navega a la pantalla de Login (PantallaInicioSesion) y elimina todas las rutas anteriores
    // Esto asegura que el usuario no pueda volver a la principal con el botón de retroceso.
    Navigator.of(context).pushAndRemoveUntil(
      // Se asume que PantallaInicioSesion existe y es la clase correcta para la ruta:
      MaterialPageRoute(builder: (context) => const PantallaInicioSesion()), 
      (Route<dynamic> route) => false, // La condición (false) elimina todas las rutas
    );
  }
  void _editarPerfil() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de editar perfil próximamente')),
    );
  }

  void _mostrarMenuPerfil(BuildContext context, Offset offset) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx - 150, offset.dy + 10, offset.dx, offset.dy),
      items: [
        PopupMenuItem(
          onTap: () => Future.delayed(Duration.zero, _editarPerfil),
          child: const Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 12), Text('Editar Perfil')]),
        ),
        PopupMenuItem(
          onTap: () => Future.delayed(Duration.zero, () => _cerrarSesion(context)),
          child: const Row(children: [Icon(Icons.logout, color: Colors.red, size: 20), SizedBox(width: 12), Text('Cerrar Sesión', style: TextStyle(color: Colors.red))]),
        ),
      ],
    );
  }

  String _getUserInitial(String? userName) => userName?.isNotEmpty == true ? userName![0].toUpperCase() : 'U';

  PreferredSizeWidget _buildAppBar(String userInitial, bool isDesktop) {
    final profileWidget = GestureDetector(
      onTapDown: (details) => _mostrarMenuPerfil(context, details.globalPosition),
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: EdgeInsets.only(right: isDesktop ? 20 : 16),
        decoration: BoxDecoration(
          color: AppColors.primaryOrange,  // CORREGIDO: Usa AppColors.primaryOrange directamente
          shape: BoxShape.circle,
        ),
        child: Text(userInitial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    if (isDesktop) {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 60,
        title: Text(
          'ProyectApp',
          style: TextStyle(
            color: AppColors.primaryOrange,  // CORREGIDO: Usa AppColors.primaryOrange directamente
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Proyectos', style: TextStyle(color: Colors.black87))),
          TextButton(onPressed: () {}, child: const Text('Calendario', style: TextStyle(color: Colors.black87))),
          TextButton(onPressed: () {}, child: const Text('Estadísticas', style: TextStyle(color: Colors.black87))),
          const SizedBox(width: 20),
          profileWidget,
        ],
      );
    } else {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Dashboard', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            onPressed: () {},
          ),
          profileWidget,
        ],
      );
    }
<<<<<<< HEAD
    return userName[0].toUpperCase();
>>>>>>> Gloria
  }

  String _getUserInitials(String userName) {
    final names = userName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (userName.isNotEmpty) {
      return userName.substring(0, 1).toUpperCase();
    }
    return 'U';
=======
>>>>>>> Jabrieliz
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,  // Usa tu color de fondo claro
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightGrey),  // Usa tu gris suave
        boxShadow: [
          BoxShadow(
<<<<<<< HEAD
<<<<<<< HEAD
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
=======
            color: Colors.grey.withOpacity(0.05),
=======
            color: Colors.grey.withOpacity(0.1),
>>>>>>> Jabrieliz
            blurRadius: 4,
            offset: const Offset(0, 1),
>>>>>>> Gloria
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
            icon: const Icon(Icons.filter_list, color: Colors.black54, size: 20),
            label: const Text(
              'Todos los estados',
              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
<<<<<<< HEAD
  Widget _buildStatisticsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard('PROYECTOS TOTALES', '12', 'Total de proyectos',
            const Color(0xFFFF6B35)),
        _buildStatCard(
            'PROYECTOS ACTIVOS', '8', 'En progreso', const Color(0xFFFF6B35)),
        _buildStatCard('TAREAS PENDIENTES', '24', 'Por completar',
            const Color(0xFFFF6B35)),
        _buildStatCard(
            'COMPLETADOS', '4', 'Finalizados', const Color(0xFFFF6B35)),
      ],
=======
  Widget _buildStatisticsGrid(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildEmptyStatistics();
    }

    final stats = [
      {'title': 'PROYECTOS TOTALES', 'value': '12', 'subtitle': 'Total de proyectos', 'color': _naranjaPrincipal},
      {'title': 'PROYECTOS ACTIVOS', 'value': '8', 'subtitle': 'En progreso', 'color': _naranjaPrincipal},
      {'title': 'TAREAS PENDIENTES', 'value': '24', 'subtitle': 'Por completar', 'color': _naranjaPrincipal},
      {'title': 'COMPLETADOS', 'value': '4', 'subtitle': 'Finalizados', 'color': _naranjaPrincipal},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: stats.map((stat) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: _buildStatCard(
            stat['title'] as String,
            stat['value'] as String,
            stat['subtitle'] as String,
            stat['color'] as Color,
          ),
        ),
      )).toList(),
>>>>>>> Gloria
    );
  }

  Widget _buildEmptyStatistics() {
      return const Center(child: Text('Cargando estadísticas...'));
  }

  Widget _buildStatCard(
      String title, String value, String subtitle, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
<<<<<<< HEAD
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
=======
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
>>>>>>> Gloria
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
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

  Widget _buildRecentProjects(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildEmptyProjects();
=======
  Widget _buildStatisticsGrid(BuildContext context, bool isDesktop) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const Center(child: Text('Cargando estadísticas...'));
>>>>>>> Jabrieliz
    }

    final children = statData.map((stat) =>
        StatCard(
          title: stat['title'] as String,
          value: stat['value'] as String,
          subtitle: stat['subtitle'] as String,
          color: stat['color'] as Color,
        ),
    ).toList();

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children.map((card) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: card))).toList(),
      );
    } else {
      final double cardWidth = (MediaQuery.of(context).size.width / 2) - 40;
      return Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        children: children.map((card) => SizedBox(width: cardWidth, child: card)).toList(),
      );
    }
  }

  Widget _buildRecentProjectsList() {
    if (FirebaseAuth.instance.currentUser == null) {
      return const Center(child: Text('Cargando proyectos...'));
    }

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
<<<<<<< HEAD
        _buildProjectCard(
            'Integración de Sistemas Automatizados', '15 Sep 2023', 5, 12),
        _buildProjectCard(
            'Migración a la Nube Empresarial', '10 Sep 2023', 9, 6),
        _buildProjectCard('Desarrollo de Protocolos de Seguridad Informática',
            '5 Sep 2023', 4, 15),
        _buildProjectCard('Rediseño de Base de Datos', '1 Sep 2023', 2, 6),
=======
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightBackground,  // Usa tu fondo claro
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: recentProjects.map((project) {
              return ProjectRow(
                title: project['name'] as String,
                subtitle: 'Creado: ${project['created']} • ${project['info']}',
                status: project['status'] as String,
              );
            }).toList(),
          ),
        ),
>>>>>>> Gloria
      ],
    );
  }

<<<<<<< HEAD
<<<<<<< HEAD
  Widget _buildProjectCard(
      String title, String fecha, int miembros, int tareas) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 8),
            Text(
              'Creado: $fecha + $miembros miembros + $tareas tareas',
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

  Widget _buildPendingTasks() {
    return Column(
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
        _buildTaskItem('Diseño de interfaz Completo', '10.0 Incremento', false),
        _buildTaskItem('Integración con CMS', 'Pendiente Máxima', false),
        _buildTaskItem('Desarrollo del frontend', 'Urgente 11:00 pm', true),
      ],
    );
  }

  Widget _buildTaskItem(String task, String details, bool isCompleted) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: isCompleted,
            onChanged: (bool? value) {
              setState(() {
                // Lógica para cambiar estado
              });
            },
            activeColor: const Color(0xFFFF6B35),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                Text(
                  details,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
=======
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
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProjects() {
    return const Center(child: Text('Cargando proyectos...'));
  }

  Widget _buildPendingTasksCard() {
    final pendingTasks = [
      {'name': 'Diseño de wireframes', 'status': 'Completado', 'date': '18 de Septiembre', 'color': Colors.green},
      {'name': 'Integración con CMS', 'status': 'Pendiente', 'date': 'Mañana', 'color': Colors.orange},
      {'name': 'Desarrollo del frontend', 'status': 'Urgente', 'date': '11:00 pm', 'color': Colors.red},
    ];

>>>>>>> Gloria
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
<<<<<<< HEAD
            color: Colors.grey.shade200,
=======
            color: Colors.grey.withOpacity(0.1),
>>>>>>> Gloria
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
<<<<<<< HEAD
          const SizedBox(height: 8),
          const Text(
            'Sistema de Gestión de proyectos para Ingeniería en la Universidad Metropolitana',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ProyectApp',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Email: proyecta@proyectApp.unimar.edu.vn',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Contacto: 01023000000023',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('Inicio'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF6B35),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Registro'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF6B35),
                    ),
                  ),
                ],
              ),
            ],
=======
          const SizedBox(height: 16),
          ...pendingTasks.map((task) => _buildTaskRow(
            task['name'] as String,
            task['status'] as String,
            task['date'] as String,
            task['color'] as Color,
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildTaskRow(String name, String status, String date, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            status == 'Completado' ? Icons.check_circle_outline : Icons.warning_amber_rounded,
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
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
              ],
            ),
          ),
          Text(
            date,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
>>>>>>> Gloria
          ),
        ],
      ),
    );
  }


  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: const Color.fromARGB(255, 185, 188, 196), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ProyectApp',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sistema de Gestión de proyectos para Ingeniería en la Universidad Metropolitana.',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Links', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0))),
                      TextButton(onPressed: () {}, child: Text('Iniciar Sesión', style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.8)))),
                      TextButton(onPressed: () {}, child: Text('Registro', style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.8)))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ayuda', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0))),
                      const SizedBox(height: 8),
                      Text(
                        'Email: ayuda@proyectapp.unimet.edu.ve',
                        style: TextStyle(fontSize: 12, color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.8)),
                      ),
                      Text(
                        'Contacto: 0202020200202',
                        style: TextStyle(fontSize: 12, color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.8)),
                      ),
                      const SizedBox(height: 10),
                      const Icon(Icons.camera_alt, color: Color.fromARGB(255, 0, 0, 0), size: 24),
                    ],
                  ),
                ),
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
                style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.8), fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'Fecha no disponible';
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${fecha.day} ${months[fecha.month - 1]} ${fecha.year}';
  }


  PreferredSizeWidget _buildDesktopAppBar(String userInitial) {
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
        TextButton(onPressed: () {}, child: const Text('Proyectos', style: TextStyle(color: Colors.black87))),
        TextButton(onPressed: () {}, child: const Text('Calendario', style: TextStyle(color: Colors.black87))),
        TextButton(onPressed: () {}, child: const Text('Estadísticas', style: TextStyle(color: Colors.black87))),
        const SizedBox(width: 20),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: _naranjaPrincipal, 
            shape: BoxShape.circle,
          ),
          child: Text(
            userInitial, 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  // --- Método Build Principal ---

=======
>>>>>>> Jabrieliz
  @override
Widget build(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;
  final String userName = user?.displayName ?? user?.email?.split('@').first ?? 'Usuario';
  final String userInitial = _getUserInitial(userName);

  return LayoutBuilder(
    builder: (context, constraints) {
      final bool isDesktop = constraints.maxWidth > 800;
      final double horizontalPadding = isDesktop ? 40.0 : 20.0;
      final double verticalSpacing = isDesktop ? 40.0 : 30.0;

      // NUEVO: Layout horizontal para desktop
      if (isDesktop) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: _buildAppBar(userInitial, isDesktop),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeHeader(userName),
                      SizedBox(height: verticalSpacing),
                      _buildSearchBar(),
                      SizedBox(height: verticalSpacing),
                      // Layout horizontal: Izquierda (estadísticas + proyectos), Derecha (tareas)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,  // Más espacio para izquierda
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStatisticsGrid(context, isDesktop),
                                SizedBox(height: verticalSpacing),
                                _buildRecentProjectsList(),
                              ],
                            ),
                          ),
                          SizedBox(width: verticalSpacing),  // Espacio entre columnas
                          Expanded(
                            flex: 1,  // Menos espacio para derecha
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const PendingTasksCard(),
                                // Opcional: Agrega TaskCalendar aquí si lo quieres
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              AppFooter(
                isDesktop: isDesktop,
                onSignOut: _cerrarSesion,
              ),
            ],
          ),
        );
      } else {
        // Layout vertical para móvil/tablet (igual que antes)
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: _buildAppBar(userInitial, isDesktop),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeHeader(userName),
                      SizedBox(height: verticalSpacing),
                      _buildSearchBar(),
                      SizedBox(height: verticalSpacing),
                      _buildStatisticsGrid(context, isDesktop),
                      SizedBox(height: verticalSpacing),
                      _buildRecentProjectsList(),
                      SizedBox(height: verticalSpacing),
                      const PendingTasksCard(),
                    ],
                  ),
                ),
              ),
              AppFooter(
                isDesktop: isDesktop,
                onSignOut: _cerrarSesion,
              ),
            ],
          ),
        );
      }
    },
  );
}
}