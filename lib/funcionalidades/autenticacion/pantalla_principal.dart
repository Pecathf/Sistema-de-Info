import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart'; 

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {

  static const Color _naranjaPrincipal = Color(0xFFE8751A); 
  
  static const Color _fondoFooter = Color(0xFF212121); 
  static const Color _franjaFooter = _naranjaPrincipal; 
  static const Color _textoFooter = Colors.white; 

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
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
          TextButton(
            onPressed: () {},
            child: const Text(
              'Todos los estados',
              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

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
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
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
    }

    final recentProjects = [
      {'name': 'Integración de Sistemas Automatizados', 'created': '15 Sep 2025', 'members': 5, 'tasks': 12, 'status': 'Activo'},
      {'name': 'Migración a la Nube Empresarial', 'created': '10 Sep 2025', 'members': 3, 'tasks': 8, 'status': 'Pendiente'},
      {'name': 'Desarrollo de Protocolos de Seguridad Informática', 'created': '5 Sep 2025', 'members': 4, 'tasks': 15, 'status': 'Completado'},
      {'name': 'Rediseño de Base de Datos', 'created': '1 Sep 2025', 'members': 2, 'tasks': 6, 'status': 'Activo'},
    ];


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
                color: Colors.grey.withOpacity(0.1),
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          ),
        ],
      ),
    );
  }


  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: _fondoFooter, 
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
                          color: _textoFooter,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sistema de Gestión de proyectos para Ingeniería en la Universidad Metropolitana.',
                        style: TextStyle(
                          fontSize: 14,
                          color: _textoFooter.withOpacity(0.8),
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
                      const Text('Links', style: TextStyle(fontWeight: FontWeight.bold, color: _textoFooter)),
                      TextButton(onPressed: () {}, child: Text('Iniciar Sesión', style: TextStyle(color: _textoFooter.withOpacity(0.8)))),
                      TextButton(onPressed: () {}, child: Text('Registro', style: TextStyle(color: _textoFooter.withOpacity(0.8)))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ayuda', style: TextStyle(fontWeight: FontWeight.bold, color: _textoFooter)),
                      const SizedBox(height: 8),
                      Text(
                        'Email: ayuda@proyectapp.unimet.edu.ve',
                        style: TextStyle(fontSize: 12, color: _textoFooter.withOpacity(0.8)),
                      ),
                      Text(
                        'Contacto: 0202020200202',
                        style: TextStyle(fontSize: 12, color: _textoFooter.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 10),
                      const Icon(Icons.camera_alt, color: _textoFooter, size: 24),
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
                style: TextStyle(color: _textoFooter.withOpacity(0.8), fontSize: 12),
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String? firebaseDisplayName = user?.displayName;
    final String userName = firebaseDisplayName ?? 'Juan Fernandes';
    
    final String userInitial = _getUserInitial(userName); 

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildDesktopAppBar(userInitial), 
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeHeader(userName),
                  const SizedBox(height: 30),
                  _buildSearchBar(),
                  const SizedBox(height: 40),

                  _buildStatisticsGrid(context),
                  const SizedBox(height: 40),

                  Row(
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
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }
}