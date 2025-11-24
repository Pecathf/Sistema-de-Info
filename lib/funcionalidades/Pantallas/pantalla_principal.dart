import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/proyectos/pantalla_listado_proyectos.dart';
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/Widgets/shared_footer_widget.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/Widgets/profile_menu_widget.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/calendario/pantalla_calendario.dart';
import 'package:sistem_proyect/central/constantes/modelos/project_model.dart';
import 'package:sistem_proyect/central/constantes/modelos/task_model.dart';
import 'package:sistem_proyect/central/constantes/servicios/project_service.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/proyectos/pantalla_detalle_proyecto.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/tareas/pantalla_detalle_tarea.dart';
import 'package:sistem_proyect/central/constantes/colores.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:sistem_proyect/funcionalidades/estadisticas/pantalla_estadisticas_admin.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final AuthService _authService = AuthService();
  final ProjectService _projectService = ProjectService();

  bool _isAdmin = false;
  bool _isLoadingRole = true;
  List<String> _recentProjectIds = [];
  Stream<QuerySnapshot>? _tareasStream;

  int _tareasPendientesCount = 0;
  int _tareasCompletadasCount = 0;
  StreamSubscription<QuerySnapshot>? _tareasSubscription;

  @override
  void initState() {
    super.initState();
    _checkIfAdmin();
    _loadRecentProjects();
    _initializeTareasStream();
  }

  @override
  void dispose() {
    _tareasSubscription?.cancel();
    super.dispose();
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

  void _initializeTareasStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Query GENERAL para estadísticas (TODAS las tareas del usuario)
      final queryGeneral = FirebaseFirestore.instance
          .collection('tareas')
          .where('miembrosUid', arrayContains: currentUser.uid);

      // Query ESPECÍFICO para la lista (SOLO tareas pendientes)
      final queryPendientes = FirebaseFirestore.instance
          .collection('tareas')
          .where('miembrosUid', arrayContains: currentUser.uid)
          .where('estado', isEqualTo: 'Pendiente');

      // 1. Stream para MOSTRAR en la lista (solo pendientes)
      _tareasStream = queryPendientes.snapshots();

      // 2. Suscripción para ESTADÍSTICAS (todas las tareas)
      _tareasSubscription = queryGeneral.snapshots().listen((snapshot) {
        if (mounted) {
          int pendientes = 0;
          int completadas = 0;

          if (snapshot.docs.isNotEmpty) {
            for (var doc in snapshot.docs) {
              final estado = (doc['estado'] as String).toLowerCase().trim();
              if (estado == 'pendiente') {
                pendientes++;
              } else if (estado == 'completada') {
                completadas++;
              }
            }
          }

          setState(() {
            _tareasPendientesCount = pendientes;
            _tareasCompletadasCount = completadas;
          });
        }
      });
    }
  }

  // Cargar IDs de proyectos visitados recientemente
  Future<void> _loadRecentProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final recentIds = prefs.getStringList('recent_projects') ?? [];

    if (mounted) {
      setState(() {
        _recentProjectIds = recentIds;
      });
    }
  }

  // Guardar proyecto visitado
  Future<void> _saveRecentProject(String projectId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recentIds = prefs.getStringList('recent_projects') ?? [];

    recentIds.remove(projectId);
    recentIds.insert(0, projectId);
    if (recentIds.length > 5) {
      recentIds = recentIds.sublist(0, 5);
    }

    await prefs.setStringList('recent_projects', recentIds);

    if (mounted) {
      setState(() {
        _recentProjectIds = recentIds;
      });
    }
  }

  String _getUserInitial(String? userName) =>
      userName?.isNotEmpty == true ? userName![0].toUpperCase() : 'U';

  PreferredSizeWidget _buildAppBar(String userInitial, bool isDesktop) {
    final Color avatarColor =
        _isAdmin ? AppColors.accentColor : AppColors.primaryOrange;

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
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const PantallaCalendario()));
                    },
                    child: const Text('Calendario',
                        style: TextStyle(color: Colors.black87))),
                // ⚠️ AGREGAR CONDICIÓN if (_isAdmin)
                if (_isAdmin)
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const PantallaEstadisticasAdmin()));
                      },
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
                  color: AppColors.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.accentColor, width: 1),
                ),
                child: Text(
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

  Widget _buildStatisticsGrid(BuildContext context, bool isDesktop) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('Cargando estadísticas...'));
    }

    return StreamBuilder<List<Proyecto>>(
      stream: _projectService.getProyectosStream(),
      builder: (context, projectSnapshot) {
        if (projectSnapshot.connectionState == ConnectionState.waiting &&
            !projectSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final proyectos = projectSnapshot.data ?? [];
        final totalProyectos = proyectos.length;

        final proyectosActivos = proyectos.where((p) {
          final estado = p.estado.toLowerCase().trim();
          return estado == 'activo' || estado == 'en progreso';
        }).length;

        final statCards = [
          _buildStatCard(
            title: 'Proyectos Totales',
            value: totalProyectos.toString(),
            subtitle:
                _isAdmin ? 'Todos los proyectos' : 'Proyectos donde participas',
            color: AppColors.primaryOrange,
          ),
          _buildStatCard(
            title: 'Proyectos Activos',
            value: proyectosActivos.toString(),
            subtitle: 'En desarrollo',
            color: AppColors.estadoActivo,
          ),
          _buildStatCard(
            title: 'Tareas Pendientes',
            value: _tareasPendientesCount.toString(),
            subtitle: 'Asignadas a ti',
            color: AppColors.prioridadAlta,
          ),
          _buildStatCard(
            title: 'Tareas Completadas',
            value: _tareasCompletadasCount.toString(),
            subtitle: 'Finalizadas',
            color: AppColors.estadoCompletado,
          ),
        ];

        if (isDesktop) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: statCards
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
            children: statCards
                .map((card) => SizedBox(width: cardWidth, child: card))
                .toList(),
          );
        }
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
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
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentProjectsList() {
    if (_recentProjectIds.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.folder_open, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No hay proyectos recientes',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los proyectos que visites aparecerán aquí',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: _recentProjectIds.map((projectId) {
              return FutureBuilder<Proyecto?>(
                future: _projectService.getProyectoById(projectId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.hasError) {
                    return const SizedBox.shrink();
                  }

                  final proyecto = snapshot.data!;
                  return _buildProjectRow(proyecto);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectRow(Proyecto proyecto) {
    Color statusColor;
    switch (proyecto.estado.toLowerCase()) {
      case 'completado':
        statusColor = AppColors.estadoCompletado;
        break;
      case 'en progreso':
        statusColor = AppColors.estadoEnProgreso;
        break;
      case 'activo':
        statusColor = AppColors.estadoActivo;
        break;
      default:
        statusColor = Colors.grey;
    }

    return InkWell(
      onTap: () async {
        await _saveRecentProject(proyecto.id);
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PantallaDetalleProyecto(projectId: proyecto.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.folder,
                color: AppColors.primaryOrange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    proyecto.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Creado: ${DateFormat('d MMM, y').format(proyecto.fechaCreacion)} • ${proyecto.miembrosUid.length} miembros',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor, width: 1),
              ),
              child: Text(
                proyecto.estado.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingTasksCard() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Cargando tareas...'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _tareasStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.check_circle_outline,
                    size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'No tienes tareas asignadas',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        // Convertir a TaskModel y ordenar por fecha de vencimiento
        List<TaskModel> tareas = snapshot.data!.docs.map((doc) {
          return TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        // Ordenar por fecha de vencimiento
        tareas.sort((a, b) {
          if (a.fechaVencimiento == null) return 1;
          if (b.fechaVencimiento == null) return -1;
          return a.fechaVencimiento!.compareTo(b.fechaVencimiento!);
        });

        // Tomar solo las primeras 5 tareas
        final tareasAMostrar = tareas.take(5).toList();

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
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: tareasAMostrar.map((tarea) {
                  return _buildTaskRow(tarea);
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskRow(TaskModel tarea) {
    Color statusColor;
    Color priorityColor;

    // Color según estado
    switch (tarea.estado.toLowerCase()) {
      case 'completada':
        statusColor = AppColors.estadoCompletado;
        break;
      case 'en progreso':
        statusColor = AppColors.estadoEnProgreso;
        break;
      case 'pendiente':
        statusColor = AppColors.estadoActivo;
        break;
      default:
        statusColor = Colors.grey;
    }

    // Color según prioridad
    switch (tarea.prioridad.toLowerCase()) {
      case 'alta':
        priorityColor = AppColors.prioridadAlta;
        break;
      case 'media':
        priorityColor = AppColors.prioridadMedia;
        break;
      case 'baja':
        priorityColor = AppColors.prioridadBaja;
        break;
      default:
        priorityColor = Colors.grey;
    }

    // Verificar si está vencida
    final isOverdue = tarea.fechaVencimiento != null &&
        tarea.fechaVencimiento!.isBefore(DateTime.now()) &&
        tarea.estado != 'Completada';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaDetalleTarea(tarea: tarea),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tarea.estado == 'Completada'
                    ? statusColor
                    : Colors.transparent,
                border: Border.all(
                  color: statusColor,
                  width: 2,
                ),
              ),
              child: tarea.estado == 'Completada'
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tarea.nombre,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      decoration: tarea.estado == 'Completada'
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 12,
                          color: isOverdue ? Colors.red : Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        tarea.fechaVencimiento != null
                            ? DateFormat('d MMM, y')
                                .format(tarea.fechaVencimiento!)
                            : 'Sin fecha',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOverdue ? Colors.red : Colors.grey.shade600,
                          fontWeight:
                              isOverdue ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (isOverdue) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'VENCIDA',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tarea.prioridad,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: priorityColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tarea.estado,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
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
                                  _buildPendingTasksCard(),
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
                        _buildStatisticsGrid(context, isDesktop),
                        SizedBox(height: verticalSpacing),
                        _buildRecentProjectsList(),
                        SizedBox(height: verticalSpacing),
                        _buildPendingTasksCard(),
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
