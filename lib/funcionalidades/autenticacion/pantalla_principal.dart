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
  // --- Widgets Auxiliares: Mantener (o modificar ligeramente) ---

  Widget _buildWelcomeHeader(String userName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola, $userName',
          style: const TextStyle(
            fontSize: 28, // Tamaño de fuente ajustado a Figma
            fontWeight: FontWeight.w500, // Peso de fuente ajustado
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
      padding: const EdgeInsets.symmetric(horizontal: 10), // Padding interno para la barra
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300), // Borde ligero para el campo
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
          // Botón "Todos los estados" a la derecha del campo de búsqueda
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

  // Se adapta para mostrar 4 tarjetas en una fila para desktop/web
  Widget _buildStatisticsGrid(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildEmptyStatistics();
    }

    // **NOTA:** Aquí usaré los valores de la imagen de Figma para mantener la coherencia visual.
    final stats = [
      {'title': 'PROYECTOS TOTALES', 'value': '12', 'subtitle': 'Total de proyectos', 'color': Colors.orange.shade700},
      {'title': 'PROYECTOS ACTIVOS', 'value': '8', 'subtitle': 'En progreso', 'color': Colors.orange.shade700},
      {'title': 'TAREAS PENDIENTES', 'value': '24', 'subtitle': 'Por completar', 'color': Colors.orange.shade700},
      {'title': 'COMPLETADOS', 'value': '4', 'subtitle': 'Finalizados', 'color': Colors.orange.shade700},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: stats.map((stat) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 16.0), // Espaciado entre tarjetas
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
      // Implementación básica para cuando no hay datos
      return const Center(child: Text('Cargando estadísticas...'));
  }

  Widget _buildStatCard(
      String title, String value, String subtitle, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200), // Borde ligero
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
                fontSize: 32, // Tamaño de fuente ajustado a Figma
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14, // Tamaño de fuente ajustado a Figma
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Columna de Proyectos Recientes (Izquierda) ---

  Widget _buildRecentProjects(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildEmptyProjects();
    }

    // Datos estáticos para simular la vista del Figma
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

  // --- Columna de Tareas Pendientes (Derecha) ---

  Widget _buildPendingTasksCard() {
    // Datos estáticos para simular la vista del Figma
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

  // --- Footer Modificado ---

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: Colors.grey[900], // Color de fondo oscuro como en Figma
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna Izquierda (Logo y Descripción)
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
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sistema de Gestión de proyectos para Ingeniería en la Universidad Metropolitana.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              // Columna Central (Links)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Links', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    TextButton(onPressed: () {}, child: Text('Iniciar Sesión', style: TextStyle(color: Colors.grey[400]))),
                    TextButton(onPressed: () {}, child: Text('Registro', style: TextStyle(color: Colors.grey[400]))),
                  ],
                ),
              ),
              // Columna Derecha (Ayuda y Contacto)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ayuda', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(
                      'Email: ayuda@proyectapp.unimet.edu.ve',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    Text(
                      'Contacto: 0202020200202',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 10),
                    // Icono de Instagram (simulado)
                    const Icon(Icons.camera_alt, color: Colors.white, size: 24),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Colors.grey),
          const SizedBox(height: 10),
          Center(
            child: Text(
              '2025 ProyectApp UNIMET. Derechos Reservados.',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Función de ayuda de formato de fecha (la dejamos igual)
  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'Fecha no disponible';
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${fecha.day} ${months[fecha.month - 1]} ${fecha.year}';
  }

  // --- AppBar Principal Modificado ---

  PreferredSizeWidget _buildDesktopAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 60,
      title: const Text(
        'ProyectApp',
        style: TextStyle(
          color: Color(0xFFE8751A), // Color naranja del logo (simulado)
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        TextButton(onPressed: () {}, child: const Text('Proyectos', style: TextStyle(color: Colors.black87))),
        TextButton(onPressed: () {}, child: const Text('Calendario', style: TextStyle(color: Colors.black87))),
        TextButton(onPressed: () {}, child: const Text('Estadísticas', style: TextStyle(color: Colors.black87))),
        const SizedBox(width: 20),
        // Ícono de Usuario (simulado)
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          child: const Text('U', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  // --- Método Build Principal Modificado ---

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Juan Fernandes'; // Usando el nombre de Figma

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildDesktopAppBar(), // Usa el AppBar de escritorio
      body: Column( // El cuerpo principal ahora es una columna que contendrá el scroll y el footer
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40.0), // Padding más generoso para escritorio
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header y Barra de Búsqueda
                  _buildWelcomeHeader(userName),
                  const SizedBox(height: 30),
                  _buildSearchBar(),
                  const SizedBox(height: 40),

                  // 2. Estadísticas
                  _buildStatisticsGrid(context),
                  const SizedBox(height: 40),

                  // 3. Contenido de Dos Columnas: Proyectos y Tareas
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Columna Izquierda (Proyectos Recientes) - Ocupa más espacio
                      Expanded( // <--- CORREGIDO: SE REMOVIÓ 'const'
                        flex: 3,
                        child: _buildRecentProjects(context), // Es una llamada a método de instancia, no constante
                      ),
                      const SizedBox(width: 40), // Espacio entre columnas
                      // Columna Derecha (Tareas Pendientes) - Ocupa menos espacio
                      Expanded( // <--- CORREGIDO: SE REMOVIÓ 'const'
                        flex: 2,
                        child: _buildPendingTasksCard(), // Es una llamada a método de instancia, no constante
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          // 4. Footer al final
          _buildFooter(),
        ],
      ),
    );
  }
}