import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets_principal.dart';
import 'pantalla_editar_perfil.dart';
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart';
import 'package:sistem_proyect/funcionalidades/autenticacion/pantalla_inicio_sesion.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final AuthService _authService = AuthService();
  bool _isProfileHovered = false;

  Future<void> _cerrarSesion() async {
    try {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const PantallaInicioSesion()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  void _editarPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PantallaEditarPerfil()),
    );
  }

  void _mostrarMenuPerfil(BuildContext context, Offset offset) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          offset.dx - 150, offset.dy + 50, offset.dx, offset.dy),
      items: [
        PopupMenuItem(
          onTap: () => Future.delayed(Duration.zero, _editarPerfil),
          child: const Row(children: [
            Icon(Icons.edit, size: 20),
            SizedBox(width: 12),
            Text('Editar Perfil')
          ]),
        ),
        PopupMenuItem(
          onTap: () => Future.delayed(Duration.zero, _cerrarSesion),
          child: const Row(children: [
            Icon(Icons.logout, color: Colors.red, size: 20),
            SizedBox(width: 12),
            Text('Cerrar Sesión', style: TextStyle(color: Colors.red))
          ]),
        ),
      ],
    );
  }

  String _getUserInitial(String? userName) =>
      userName?.isNotEmpty == true ? userName![0].toUpperCase() : 'U';

  PreferredSizeWidget _buildAppBar(String userInitial, bool isDesktop) {
    final profileWidget = MouseRegion(
      onEnter: (_) => setState(() => _isProfileHovered = true),
      onExit: (_) => setState(() => _isProfileHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (details) =>
            _mostrarMenuPerfil(context, details.globalPosition),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          margin: EdgeInsets.only(right: isDesktop ? 20 : 16),
          decoration: BoxDecoration(
            color: AppColors.primaryOrange,
            shape: BoxShape.circle,
            boxShadow: _isProfileHovered
                ? [
                    BoxShadow(
                      color: AppColors.primaryOrange.withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          transform: Matrix4.identity()..scale(_isProfileHovered ? 1.05 : 1.0),
          child: Text(userInitial,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
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
            color: AppColors.primaryOrange,
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
          profileWidget,
        ],
      );
    } else {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Dashboard',
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
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
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightGrey),
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

  Widget _buildStatisticsGrid(BuildContext context, bool isDesktop) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const Center(child: Text('Cargando estadísticas...'));
    }

    final children = statData
        .map(
          (stat) => StatCard(
            title: stat['title'] as String,
            value: stat['value'] as String,
            subtitle: stat['subtitle'] as String,
            color: stat['color'] as Color,
          ),
        )
        .toList();

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children
            .map((card) => Expanded(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: card)))
            .toList(),
      );
    } else {
      final double cardWidth = (MediaQuery.of(context).size.width / 2) - 40;
      return Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        children: children
            .map((card) => SizedBox(width: cardWidth, child: card))
            .toList(),
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
            color: AppColors.lightBackground,
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

  // Nuevo Footer al estilo de la pantalla de bienvenida
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
                  ['Proyectos', 'Calendario', 'Estadísticas'],
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

          // Derechos de autor
          const Text(
            '2025 ProyectApp UNIMET. Derechos Reservados.',
            style: TextStyle(color: Colors.black54, fontSize: 12),
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
    final user = FirebaseAuth.instance.currentUser;
    final String userName =
        user?.displayName ?? user?.email?.split('@').first ?? 'Usuario';
    final String userInitial = _getUserInitial(userName);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 800;
        final double horizontalPadding = isDesktop ? 40.0 : 20.0;
        final double verticalSpacing = isDesktop ? 40.0 : 30.0;

        if (isDesktop) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: _buildAppBar(userInitial, isDesktop),
            body: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding, vertical: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeHeader(userName),
                        SizedBox(height: verticalSpacing),
                        _buildSearchBar(),
                        SizedBox(height: verticalSpacing),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildStatisticsGrid(context, isDesktop),
                                  SizedBox(height: verticalSpacing),
                                  _buildRecentProjectsList(),
                                ],
                              ),
                            ),
                            SizedBox(width: verticalSpacing),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const PendingTasksCard(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: verticalSpacing),
                      ],
                    ),
                  ),
                  // Footer fuera del padding
                  _buildFooter(context, false),
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: _buildAppBar(userInitial, isDesktop),
            body: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding, vertical: 30.0),
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
                        SizedBox(height: verticalSpacing),
                      ],
                    ),
                  ),
                  // Footer fuera del padding
                  _buildFooter(context, true),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
