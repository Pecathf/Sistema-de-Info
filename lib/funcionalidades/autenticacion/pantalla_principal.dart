import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Usuario';

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
            // Header de bienvenida
            _buildWelcomeHeader(userName),
            const SizedBox(height: 20),

            // Barra de búsqueda
            _buildSearchBar(),
            const SizedBox(height: 24),

            // Estadísticas
            _buildStatisticsGrid(),
            const SizedBox(height: 32),

            // Proyectos recientes
            _buildRecentProjects(),
            const SizedBox(height: 32),

            // Footer informativo
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(String userName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola, $userName',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200, // ✅ SOLUCIÓN - Sin withOpacity
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Buscar proyectos...',
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
            'PROYECTOS TOTALES', '12', 'Total de proyectos', Colors.blue),
        _buildStatCard('PROYECTOS ACTIVOS', '8', 'En progreso', Colors.green),
        _buildStatCard(
            'TAREAS PENDIENTES', '24', 'Por completar', Colors.orange),
        _buildStatCard('COMPLETADOS', '4', 'Finalizados', Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, String subtitle, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200, // ✅ SOLUCIÓN - Sin withOpacity
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentProjects() {
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
        _buildProjectCard(
          'Integración de Sistemas Automatizados',
          '18 Sep 2025',
          5,
          12,
        ),
        _buildProjectCard(
          'Migración a la Nube Empresarial',
          '10 Sep 2025',
          3,
          6,
        ),
        _buildProjectCard(
          'Desarrollo de Protocolos de Seguridad Informática',
          '5 Sep 2025',
          4,
          15,
        ),
        _buildProjectCard(
          'Rediseño de Base de Datos',
          '1 Sep 2025',
          2,
          6,
        ),
      ],
    );
  }

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
            color: Colors.grey.shade200, // ✅ SOLUCIÓN - Sin withOpacity
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
              'Creado: $fecha - $miembros miembros - $tareas tareas',
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

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200, // ✅ SOLUCIÓN - Sin withOpacity
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ProyectApp',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sistema de Gestión de proyectos para Ingeniería en la Universidad Intergrediana',
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
                    'Ayudita',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Email: ayudita@proyectApp.usfirmet.edu.vn',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Contacto: 01010121000002',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('Iniciar Sesión'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Registro'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
