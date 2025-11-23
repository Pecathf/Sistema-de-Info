import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sistem_proyect/central/constantes/colores.dart';
import 'package:sistem_proyect/central/constantes/modelos/project_model.dart'; // Importamos el modelo de proyecto
import 'package:sistem_proyect/central/constantes/modelos/usuario_model.dart';
import 'package:sistem_proyect/central/constantes/servicios/project_service.dart'; // Importamos el servicio de proyecto
import 'package:sistem_proyect/central/constantes/servicios/task_service.dart';
import 'package:sistem_proyect/central/constantes/servicios/user_data_service.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/Widgets/profile_menu_widget.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/Widgets/shared_footer_widget.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/pantalla_principal.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/proyectos/pantalla_listado_proyectos.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/calendario/pantalla_calendario.dart';

class PantallaEstadisticasAdmin extends StatefulWidget {
  const PantallaEstadisticasAdmin({super.key});

  @override
  State<PantallaEstadisticasAdmin> createState() =>
      _PantallaEstadisticasAdminState();
}

class _PantallaEstadisticasAdminState extends State<PantallaEstadisticasAdmin> {
  // Servicios
  final ProjectService _projectService = ProjectService();
  final TaskService _taskService = TaskService();
  final UserDataService _userDataService = UserDataService();

  // Datos
  List<Proyecto> _allProjects = []; // Lista de PROYECTOS
  bool _isLoading = true;

  // Variables para contadores de PROYECTOS
  int _totalProjects = 0;
  int _completedProjects = 0;
  int _runningProjects = 0; // En Progreso
  int _pendingProjects = 0; // Activos/Pendientes

  // Variables para Top Performers (Basado en tareas completadas)
  List<Usuario> _topUsers = [];
  Map<String, int> _userScores = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. Cargar Proyectos (Para KPIs y Gráficas)
    // Usamos 'first' para obtener el snapshot actual del stream
    final projects = await _projectService.getProyectosStream().first;

    // 2. Cargar Tareas (SOLO para calcular los mejores miembros)
    final tasks = await _taskService.getAllTasksGlobal();

    // Lógica para Top Performers (Miembros)
    Map<String, int> scores = {};
    for (var task in tasks) {
      if (task.estado == 'Completada') {
        for (var memberUid in task.miembrosUid) {
          scores[memberUid] = (scores[memberUid] ?? 0) + 1;
        }
      }
    }

    var sortedKeys = scores.keys.toList(growable: false)
      ..sort((k1, k2) => scores[k2]!.compareTo(scores[k1]!));

    List<String> topUids = sortedKeys.take(5).toList();
    List<Usuario> topUsersList = [];
    if (topUids.isNotEmpty) {
      topUsersList = await _userDataService.getUsuariosByIds(topUids);
    }

    if (mounted) {
      setState(() {
        // Asignar Proyectos
        _allProjects = projects;

        // Calcular KPIs de PROYECTOS
        _totalProjects = projects.length;
        _completedProjects =
            projects.where((p) => p.estado == 'Completado').length;
        _runningProjects =
            projects.where((p) => p.estado == 'En Progreso').length;
        // Consideramos 'Activo' como Pendiente (no ha terminado ni está full en progreso)
        _pendingProjects = projects
            .where((p) => p.estado == 'Activo' || p.estado == 'Pendiente')
            .length;

        // Asignar Top Users
        _userScores = scores;
        _topUsers = topUsersList;

        _isLoading = false;
      });
    }
  }

  String _getUserInitial(String? email) {
    return email != null && email.isNotEmpty ? email[0].toUpperCase() : 'A';
  }

  // --- APP BAR RESPONSIVO ---
  PreferredSizeWidget _buildAppBar(bool isDesktop) {
    final userInitial =
        _getUserInitial(FirebaseAuth.instance.currentUser?.email);

    final profileWidget = HoverableProfileAvatar(
      userInitial: userInitial,
      avatarColor: AppColors.accentColor,
      isDesktop: isDesktop,
    );

    if (isDesktop) {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Text('ProyectApp',
                style: TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 24)),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PantallaPrincipal())),
                      child: const Text('Menú',
                          style: TextStyle(color: Colors.black87))),
                  const SizedBox(width: 30),
                  TextButton(
                      onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const PantallaListadoProyectos())),
                      child: const Text('Proyectos',
                          style: TextStyle(color: Colors.black87))),
                  const SizedBox(width: 30),
                  TextButton(
                      onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PantallaCalendario())),
                      child: const Text('Calendario',
                          style: TextStyle(color: Colors.black87))),
                  const SizedBox(width: 30),
                  TextButton(
                      onPressed: () {},
                      child: const Text('Estadísticas',
                          style: TextStyle(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.bold))),
                ],
              ),
            ),
          ],
        ),
        actions: [profileWidget, const SizedBox(width: 20)],
      );
    } else {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Dashboard Proyectos',
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [profileWidget, const SizedBox(width: 10)],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth > 800;

      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: _buildAppBar(isDesktop),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Estadísticas de Proyectos",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),

                          // 1. SECCIÓN DE TARJETAS (KPIs de Proyectos)
                          if (isDesktop)
                            Row(
                              children: [
                                Expanded(
                                    child: _buildKpiCard(
                                        "Total Proyectos",
                                        "$_totalProjects",
                                        Icons.folder_special,
                                        Colors.blueAccent)),
                                const SizedBox(width: 16),
                                Expanded(
                                    child: _buildKpiCard(
                                        "Completados",
                                        "$_completedProjects",
                                        Icons.check_circle,
                                        Colors.green)),
                                const SizedBox(width: 16),
                                Expanded(
                                    child: _buildKpiCard(
                                        "En Progreso",
                                        "$_runningProjects",
                                        Icons.trending_up,
                                        AppColors.primaryOrange)),
                                const SizedBox(width: 16),
                                Expanded(
                                    child: _buildKpiCard(
                                        "Pendientes",
                                        "$_pendingProjects",
                                        Icons.hourglass_empty,
                                        Colors.redAccent)),
                              ],
                            )
                          else
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                _buildKpiCard(
                                    "Total Proyectos",
                                    "$_totalProjects",
                                    Icons.folder_special,
                                    Colors.blueAccent,
                                    width: (constraints.maxWidth - 48) / 2),
                                _buildKpiCard(
                                    "Completados",
                                    "$_completedProjects",
                                    Icons.check_circle,
                                    Colors.green,
                                    width: (constraints.maxWidth - 48) / 2),
                                _buildKpiCard(
                                    "En Progreso",
                                    "$_runningProjects",
                                    Icons.trending_up,
                                    AppColors.primaryOrange,
                                    width: (constraints.maxWidth - 48) / 2),
                                _buildKpiCard("Pendientes", "$_pendingProjects",
                                    Icons.hourglass_empty, Colors.redAccent,
                                    width: (constraints.maxWidth - 48) / 2),
                              ],
                            ),

                          const SizedBox(height: 30),

                          // 2. SECCIÓN DE GRÁFICOS
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      _buildProjectsActivityChart(), // Gráfico de Proyectos
                                      const SizedBox(height: 24),
                                      _buildTopPerformersCard(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 1,
                                  child:
                                      _buildProjectStatusPieChart(), // Gráfico de Proyectos
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _buildProjectsActivityChart(),
                                const SizedBox(height: 24),
                                _buildProjectStatusPieChart(),
                                const SizedBox(height: 24),
                                _buildTopPerformersCard(),
                              ],
                            ),
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
    });
  }

  // --- WIDGETS DE DISEÑO ---

  Widget _buildKpiCard(String title, String value, IconData icon, Color color,
      {double? width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBackground)),
        ],
      ),
    );
  }

  // Gráfico de Barras: PROYECTOS CREADOS
  Widget _buildProjectsActivityChart() {
    // 1. Cambiamos la lógica para contar PROYECTOS por día
    Map<int, int> projectsPerDay = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};

    // Usamos _allProjects en lugar de _allTasks
    for (var project in _allProjects) {
      int weekday = project.fechaCreacion.weekday;
      projectsPerDay[weekday] = (projectsPerDay[weekday] ?? 0) + 1;
    }

    int maxY = 5;
    projectsPerDay.forEach((_, v) {
      if (v > maxY) maxY = v;
    });

    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 30),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY.toDouble() + 2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      // --- ESTA ES LA CLAVE PARA QUE NO SE MONTEN ---
                      reservedSize:
                          40, // Reservamos 40px de espacio abajo para las letras
                      // ---------------------------------------------
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        );
                        String text;
                        switch (value.toInt()) {
                          case 1:
                            text = 'Lun';
                            break;
                          case 2:
                            text = 'Mar';
                            break;
                          case 3:
                            text = 'Mié';
                            break;
                          case 4:
                            text = 'Jue';
                            break;
                          case 5:
                            text = 'Vie';
                            break;
                          case 6:
                            text = 'Sáb';
                            break;
                          case 7:
                            text = 'Dom';
                            break;
                          default:
                            text = '';
                        }
                        return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8, // Espacio extra entre la barra y el texto
                            child: Text(text, style: style));
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  for (int i = 1; i <= 7; i++)
                    _makeBarGroup(i, projectsPerDay[i]?.toDouble() ?? 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.darkBackground,
          width: 16,
          borderRadius: BorderRadius.circular(4),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 10,
            color: Colors.grey.shade100,
          ),
        ),
      ],
    );
  }

  // Gráfico de Pastel: ESTADO DE PROYECTOS
  Widget _buildProjectStatusPieChart() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Estado de Proyectos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        color: Colors.green,
                        value: _completedProjects.toDouble(),
                        title: '${_calculatePercentage(_completedProjects)}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      PieChartSectionData(
                        color: AppColors.primaryOrange,
                        value: _runningProjects.toDouble(),
                        title: '${_calculatePercentage(_runningProjects)}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      PieChartSectionData(
                        color: Colors.redAccent,
                        value: _pendingProjects.toDouble(),
                        title: '${_calculatePercentage(_pendingProjects)}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("$_totalProjects",
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const Text("Total", style: TextStyle(fontSize: 10)),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildLegendItem(Colors.green, "Completados"),
          _buildLegendItem(AppColors.primaryOrange, "En Progreso"),
          _buildLegendItem(Colors.redAccent, "Pendientes"),
        ],
      ),
    );
  }

  // Top Performing Members (Sigue basándose en Tareas, porque los miembros hacen tareas)
  Widget _buildTopPerformersCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Mejores Miembros",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Icon(Icons.star, color: Colors.orange.shade300),
            ],
          ),
          const SizedBox(height: 5),
          Text("Basado en tareas individuales completadas",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 20),
          if (_topUsers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: Text("No hay datos suficientes aún.")),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _topUsers.length,
              separatorBuilder: (c, i) => const Divider(height: 30),
              itemBuilder: (context, index) {
                final user = _topUsers[index];
                final score = _userScores[user.uid] ?? 0;

                return Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: Text(user.nombre.isNotEmpty ? user.nombre[0] : '?',
                          style: const TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.nombre,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(user.email,
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 12),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text("$score",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700)),
                          const SizedBox(width: 4),
                          const Icon(Icons.check_circle,
                              size: 14, color: Colors.green),
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  int _calculatePercentage(int value) {
    if (_totalProjects == 0) return 0;
    return ((value / _totalProjects) * 100).round();
  }
}
