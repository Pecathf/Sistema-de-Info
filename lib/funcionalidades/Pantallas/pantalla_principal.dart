import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/Widgets/widgets_principal.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/proyectos/pantalla_listado_proyectos.dart'; 
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/Widgets/shared_footer_widget.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/Widgets/profile_menu_widget.dart';


class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final AuthService _authService = AuthService();
  bool _isAdmin = false;
  bool _isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    _checkIfAdmin();
  }

  Future<void> _checkIfAdmin() async {
    final isAdmin = await _authService.isAdmin();
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
        _isLoadingRole = false;
      });
    }
  }


  String _getUserInitial(String? userName) =>
      userName?.isNotEmpty == true ? userName![0].toUpperCase() : 'U';

  PreferredSizeWidget _buildAppBar(String userInitial, bool isDesktop) {
    final Color avatarColor = _isAdmin ? AppColors.accentColor : AppColors.primaryOrange;

    final profileWidget = HoverableProfileAvatar(
    userInitial: userInitial,
    avatarColor: avatarColor,
    isDesktop: isDesktop,
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
        centerTitle: false,
        actions: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const PantallaListadoProyectos()));
                    }, 
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
              ],
            ),
          ),
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
        Row(
          children: [
            Text(
              'Hola, $userName',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            if (_isAdmin) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentColor.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.accentColor, width: 1),
                ),
                child: const Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentColor,
                  ),
                ),
              ),
            ],
          ],
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
            color: Colors.grey.withValues(alpha:0.1),
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
                color: Colors.grey.withValues(alpha:0.1),
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
    final String userName =
        user?.displayName ?? user?.email?.split('@').first ?? 'Usuario';
    final String userInitial = _getUserInitial(userName);

    if (_isLoadingRole) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
                  SharedFooter(
                    primaryOrange: AppColors.primaryOrange,
                    accentBlue: AppColors.accentColor,
                  ),
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
                  SharedFooter(
                    primaryOrange: AppColors.primaryOrange,
                    accentBlue: AppColors.accentColor,
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}