import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sistem_proyect/central/constantes/colores.dart';
import 'package:sistem_proyect/central/constantes/modelos/task_model.dart';
import 'package:sistem_proyect/central/constantes/modelos/usuario_model.dart';
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart';
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
  final TaskService _taskService = TaskService();
  final UserDataService _userDataService = UserDataService();
  // final AuthService _authService = AuthService(); // Ya no se usa aquí directamente porque lo maneja el widget del perfil

  List<TaskModel> _allTasks = [];
  bool _isLoading = true;

  // Variables para contadores
  int _total = 0;
  int _completed = 0;
  int _inProgress = 0;
  int _pending = 0;

  // Variables para Top Performers
  List<Usuario> _topUsers = [];
  Map<String, int> _userScores = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final tasks = await _taskService.getAllTasksGlobal();
    
    // Calcular Top Performers
    Map<String, int> scores = {};
    for (var task in tasks) {
      if (task.estado == 'Completada') {
        for (var memberUid in task.miembrosUid) {
          scores[memberUid] = (scores[memberUid] ?? 0) + 1;
        }
      }
    }

    // Ordenar usuarios por puntaje (descendente) y tomar los top 5
    var sortedKeys = scores.keys.toList(growable: false)
      ..sort((k1, k2) => scores[k2]!.compareTo(scores[k1]!));
    
    List<String> topUids = sortedKeys.take(5).toList();
    List<Usuario> topUsersList = [];

    if (topUids.isNotEmpty) {
      topUsersList = await _userDataService.getUsuariosByIds(topUids);
    }

    if (mounted) {
      setState(() {
        _allTasks = tasks;
        _total = tasks.length;
        _completed = tasks.where((t) => t.estado == 'Completada').length;
        _inProgress = tasks.where((t) => t.estado == 'En Progreso').length;
        _pending = tasks.where((t) => t.estado == 'Pendiente').length;
        
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
    final userInitial = _getUserInitial(FirebaseAuth.instance.currentUser?.email);
    
    // CORRECCIÓN: Quitamos el parámetro onLogout porque HoverableProfileAvatar no lo tiene
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
                      onPressed: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const PantallaPrincipal())),
                      child: const Text('Menú', style: TextStyle(color: Colors.black87))),
                  const SizedBox(width: 30),
                  TextButton(
                      onPressed: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const PantallaListadoProyectos())),
                      child: const Text('Proyectos', style: TextStyle(color: Colors.black87))),
                  const SizedBox(width: 30),
                  TextButton(
                      onPressed: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const PantallaCalendario())),
                      child: const Text('Calendario', style: TextStyle(color: Colors.black87))),
                  const SizedBox(width: 30),
                  // Botón Activo
                  TextButton(
                      onPressed: () {},
                      child: const Text('Estadísticas',
                          style: TextStyle(
                              color: AppColors.primaryOrange, fontWeight: FontWeight.bold))),
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
        title: const Text('Dashboard',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
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
                          const Text("Resumen General", 
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          
                          // 1. SECCIÓN DE TARJETAS (KPIs)
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              _buildKpiCard("Total Tareas", "$_total",
                                  Icons.folder_copy_outlined, Colors.blueAccent, constraints.maxWidth),
                              _buildKpiCard("Completadas", "$_completed",
                                  Icons.check_circle_outline, Colors.green, constraints.maxWidth),
                              _buildKpiCard("En Progreso", "$_inProgress",
                                  Icons.trending_up, AppColors.primaryOrange, constraints.maxWidth),
                              _buildKpiCard("Pendientes", "$_pending",
                                  Icons.access_time, Colors.redAccent, constraints.maxWidth),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // 2. SECCIÓN DE GRÁFICOS + TOP PERFORMERS
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Columna Izquierda: Gráficos
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      _buildActivityChart(),
                                      const SizedBox(height: 24),
                                      _buildTopPerformersCard(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                // Columna Derecha: Dona
                                Expanded(
                                  flex: 1,
                                  child: _buildStatusPieChart(),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _buildActivityChart(),
                                const SizedBox(height: 24),
                                _buildStatusPieChart(),
                                const SizedBox(height: 24),
                                _buildTopPerformersCard(),
                              ],
                            ),
                        ],
                      ),
                    ),
                    
                    // 3. FOOTER
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

  // 1. Tarjeta KPI
  Widget _buildKpiCard(String title, String value, IconData icon, Color color,
      double parentWidth) {
    double cardWidth =
        (parentWidth > 600) ? (parentWidth - 72) / 4 : (parentWidth - 48) / 2;

    return Container(
      width: cardWidth,
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

  // 2. Gráfico de Barras (Activity)
  Widget _buildActivityChart() {
    Map<int, int> tasksPerDay = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    for (var task in _allTasks) {
      int weekday = task.fechaCreacion.weekday;
      tasksPerDay[weekday] = (tasksPerDay[weekday] ?? 0) + 1;
    }

    int maxY = 5;
    tasksPerDay.forEach((_, v) { if (v > maxY) maxY = v; });

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
          const Text("Actividad Semanal",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("Nuevas tareas creadas",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
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
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        );
                        String text;
                        switch (value.toInt()) {
                          case 1: text = 'Lun'; break;
                          case 2: text = 'Mar'; break;
                          case 3: text = 'Mié'; break;
                          case 4: text = 'Jue'; break;
                          case 5: text = 'Vie'; break;
                          case 6: text = 'Sáb'; break;
                          case 7: text = 'Dom'; break;
                          default: text = '';
                        }
                        return SideTitleWidget(
                            axisSide: meta.axisSide, child: Text(text, style: style));
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  for (int i = 1; i <= 7; i++)
                    _makeBarGroup(i, tasksPerDay[i]?.toDouble() ?? 0),
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
          // Si te da error aqui, borra estas lineas hasta la coma
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 10,
            color: Colors.grey.shade100,
          ),
        ),
      ],
    );
  }

  // 3. Gráfico de Pastel
  Widget _buildStatusPieChart() {
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
          const Text("Estado de Tareas",
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
                        value: _completed.toDouble(),
                        title: '${_calculatePercentage(_completed)}%',
                        radius: 50,
                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      PieChartSectionData(
                        color: AppColors.primaryOrange,
                        value: _inProgress.toDouble(),
                        title: '${_calculatePercentage(_inProgress)}%',
                        radius: 50,
                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      PieChartSectionData(
                        color: Colors.redAccent,
                        value: _pending.toDouble(),
                        title: '${_calculatePercentage(_pending)}%',
                        radius: 50,
                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("$_total",
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const Text("Total", style: TextStyle(fontSize: 10)),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildLegendItem(Colors.green, "Completadas"),
          _buildLegendItem(AppColors.primaryOrange, "En Progreso"),
          _buildLegendItem(Colors.redAccent, "Pendientes"),
        ],
      ),
    );
  }
  
  // 4. Sección "Top Performing Members"
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
          Text("Basado en tareas completadas",
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
                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.nombre,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(user.email,
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text("$score",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                          const SizedBox(width: 4),
                          const Icon(Icons.check_circle, size: 14, color: Colors.green),
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
    if (_total == 0) return 0;
    return ((value / _total) * 100).round();
  }
}