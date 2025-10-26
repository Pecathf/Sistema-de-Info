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
            color: Colors.grey.withOpacity(0.1),
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

  Widget _buildStatisticsGrid(BuildContext context, bool isDesktop) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const Center(child: Text('Cargando estadísticas...'));
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
      ],
    );
  }

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