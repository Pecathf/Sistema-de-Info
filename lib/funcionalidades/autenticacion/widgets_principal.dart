import 'package:flutter/material.dart';

// --- TU MÓDULO DE COLORES (Integrado aquí para simplicidad) ---
class AppColors {
  // Color Naranja Principal (El color de los botones y el panel lateral)
  static const Color primaryOrange = Color(0xFFFF6633); 
  // Color de fondo oscuro (Para texto principal y fondos oscuros)
  static const Color darkBackground = Color(0xFF2E2E2E);
  // Color de Fondo claro para los formularios
  static const Color lightBackground = Colors.white; 
  // Color del texto de la marca y enlaces
  static const Color accentColor = Color(0xFF3366FF); 
  // Color para campos de texto/bordes grises suaves
  static const Color lightGrey = Color(0xFFE0E0E0);
}

// --- CONSTANTES Y DATOS DUMMY (Usando tus colores) ---
const Color _naranjaPrincipal = AppColors.primaryOrange;  // Ahora usa tu color rojizo

const List<Map<String, dynamic>> statData = [
  {'title': 'PROYECTOS TOTALES', 'value': '12', 'subtitle': 'Total de proyectos', 'color': _naranjaPrincipal},
  {'title': 'PROYECTOS ACTIVOS', 'value': '8', 'subtitle': 'En progreso', 'color': Colors.blue},
  {'title': 'TAREAS PENDIENTES', 'value': '24', 'subtitle': 'Por completar', 'color': Colors.red},
  {'title': 'COMPLETADOS', 'value': '4', 'subtitle': 'Finalizados', 'color': Colors.green},
];

const List<Map<String, String>> recentProjects = [
  {'name': 'Integración de Sistemas Automatizados', 'created': '15 Sep 2025', 'info': '5 miembros • 12 tareas', 'status': 'Activo'},
  {'name': 'Migración a la Nube Empresarial', 'created': '10 Sep 2025', 'info': '3 miembros • 8 tareas', 'status': 'Pendiente'},
  {'name': 'Desarrollo de Protocolos de Seguridad Informática', 'created': '5 Sep 2025', 'info': '4 miembros • 15 tareas', 'status': 'Completado'},
  {'name': 'Rediseño de Base de Datos', 'created': '1 Sep 2025', 'info': '2 miembros • 6 tareas', 'status': 'Activo'},
];

const List<Map<String, dynamic>> pendingTasks = [
  {'name': 'Diseño de wireframes', 'status': 'Completado', 'date': '18 de Septiembre', 'color': Colors.green},
  {'name': 'Integración con CMS', 'status': 'Pendiente', 'date': 'Mañana', 'color': Colors.orange},
  {'name': 'Desarrollo del frontend', 'status': 'Urgente', 'date': '11:00 pm', 'color': Colors.red},
  {'name': 'Revisión de arquitectura', 'status': 'Pendiente', 'date': 'Hoy', 'color': Colors.red},
];

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightBackground,  // Usa tu color de fondo claro
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightGrey),  // Usa tu gris suave
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha:0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
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
                fontSize: 36,
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
}

class ProjectRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;

  const ProjectRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  Color _getStatusColor(String status, bool isBackground) {
    Color baseColor;
    switch (status) {
      case 'Activo':
        baseColor = Colors.green.shade700;
        break;
      case 'Pendiente':
        baseColor = Colors.amber.shade700;
        break;
      case 'Completado':
        baseColor = Colors.blue.shade700;
        break;
      default:
        baseColor = Colors.grey.shade700;
        break;
    }
    return isBackground ? baseColor.withValues(alpha:0.1) : baseColor;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.folder_open, color: AppColors.primaryOrange, size: 24),  // Usa tu naranja rojizo
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
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(status, true),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: _getStatusColor(status, false),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskRow extends StatelessWidget {
  final String name;
  final String status;
  final String date;
  final Color color;

  const TaskRow({
    super.key,
    required this.name,
    required this.status,
    required this.date,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            status == 'Completado' ? Icons.check_circle_outline : Icons.pending_actions_outlined,
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
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha:0.1),
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
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class PendingTasksCard extends StatelessWidget {
  const PendingTasksCard({super.key});

  @override
  Widget build(BuildContext context) {
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
        color: AppColors.lightBackground,  // Usa tu color de fondo claro
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: boxShadowColor,  // CORREGIDO: Usa Color.fromRGBO como en tu original
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
          ...pendingTasks.map((task) => TaskRow(  // CORREGIDO: Usa TaskRow directamente, sin .toList()
                name: task['name'] as String,
                status: task['status'] as String,
                date: task['date'] as String,
                color: task['color'] as Color,
              )),
        ],
      ),
    );
  }
}

class AppFooter extends StatelessWidget {
  final bool isDesktop;
  final Function(BuildContext) onSignOut;

  const AppFooter({
    super.key,
    required this.isDesktop,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    Color footerColor = const Color.fromARGB(255, 211, 215, 219);  // Usa tu fondo oscuro
    Color footerTextColor = const Color.fromARGB(255, 0, 0, 0);
    Color secondaryTextColor = footerTextColor.withValues(alpha:0.8);

    Widget mainContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ProyectApp',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.accentColor,  // Usa tu color de acento para la marca
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sistema de Gestión de proyectos para Ingeniería en la Universidad Metropolitana.',
          style: TextStyle(
            fontSize: 14,
            color: secondaryTextColor,
          ),
        ),
      ],
    );

    Widget linksSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Links', style: TextStyle(fontWeight: FontWeight.bold, color: footerTextColor)),
        TextButton(
          onPressed: () => onSignOut(context),
          child: Text('Cerrar Sesión', style: TextStyle(color: secondaryTextColor)),
        ),
        TextButton(
          onPressed: () {},
          child: Text('Mi Perfil', style: TextStyle(color: secondaryTextColor)),
        ),
      ],
    );

    Widget helpSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ayuda', style: TextStyle(fontWeight: FontWeight.bold, color: footerTextColor)),
        const SizedBox(height: 8),
        Text(
          'Email: ayuda@proyectapp.unimet.edu.ve',
          style: TextStyle(fontSize: 12, color: secondaryTextColor),
        ),
        Text(
          'Contacto: 0202020200202',
          style: TextStyle(fontSize: 12, color: secondaryTextColor),
        ),
        const SizedBox(height: 10),
        Icon(Icons.support_agent, color: footerTextColor, size: 24),
      ],
    );

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: mainContent),
                      const SizedBox(width: 40),
                      Expanded(child: linksSection),
                      Expanded(child: helpSection),
                    ],
                  )
                : Column(
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
            color: AppColors.primaryOrange,  // Usa tu naranja rojizo para la franja
            child: Center(
              child: Text(
                '2025 ProyectApp UNIMET. Derechos Reservados.',
                style: TextStyle(color: secondaryTextColor, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}