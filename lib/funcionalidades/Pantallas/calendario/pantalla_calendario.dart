import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_auth/firebase_auth.dart';

// IMPORTS
import 'package:sistem_proyect/central/constantes/modelos/project_model.dart';
import 'package:sistem_proyect/central/constantes/servicios/project_service.dart';
import 'package:sistem_proyect/central/constantes/colores.dart';
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/Widgets/profile_menu_widget.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/Widgets/shared_footer_widget.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/pantalla_principal.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/proyectos/pantalla_listado_proyectos.dart';
import 'package:sistem_proyect/funcionalidades/estadisticas/pantalla_estadisticas_admin.dart';

class PantallaCalendario extends StatefulWidget {
  const PantallaCalendario({super.key});

  @override
  State<PantallaCalendario> createState() => _PantallaCalendarioState();
}

class _PantallaCalendarioState extends State<PantallaCalendario> {
  final ProjectService _projectService = ProjectService();
  final AuthService _authService = AuthService();

  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Proyecto>> _proyectosPorFecha = {};

  bool _isAdmin = false;
  bool _isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    initializeDateFormatting('es_ES', null);
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

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  List<Proyecto> _getEventosDelDia(DateTime day) {
    final fechaNormalizada = DateTime(day.year, day.month, day.day);
    return _proyectosPorFecha[fechaNormalizada] ?? [];
  }

  void _procesarEventos(List<Proyecto> proyectos) {
    _proyectosPorFecha = {};
    for (var proyecto in proyectos) {
      final fecha = DateTime(
        proyecto.fechaLimite.year,
        proyecto.fechaLimite.month,
        proyecto.fechaLimite.day,
      );

      if (_proyectosPorFecha[fecha] == null) {
        _proyectosPorFecha[fecha] = [];
      }
      _proyectosPorFecha[fecha]!.add(proyecto);
    }
  }

  String _getUserInitial(String? userName) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    return userEmail?.isNotEmpty == true ? userEmail![0].toUpperCase() : 'U';
  }

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
        automaticallyImplyLeading: false,
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
                // Botón Menú
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const PantallaPrincipal(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text(
                    'Menú',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),

                // Botón Proyectos
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const PantallaListadoProyectos(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text(
                    'Proyectos',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),

                // Botón Calendario
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Calendario',
                    style: TextStyle(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Botón Estadísticas
                if (_isAdmin)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const PantallaEstadisticasAdmin(),
                        ),
                      );
                    },
                    child: const Text(
                      'Estadísticas',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
              ],
            ),
          ),
          profileWidget,
          const SizedBox(width: 20),
        ],
      );
    } else {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Calendario',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isAdmin)
            IconButton(
              tooltip: "Ver Estadísticas",
              icon: const Icon(Icons.bar_chart, color: AppColors.primaryOrange),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaEstadisticasAdmin(),
                  ),
                );
              },
            ),
          profileWidget,
          const SizedBox(width: 10),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userInitial =
        _getUserInitial(FirebaseAuth.instance.currentUser?.email);

    if (_isLoadingRole) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(userInitial, isDesktop),
          body: Column(
            children: [
              // LEYENDA FIJA
              _buildLegend(),
              const Divider(height: 1),

              // CONTENIDO SCROLLABLE
              Expanded(
                child: StreamBuilder<List<Proyecto>>(
                  stream: _projectService.getProyectosStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      _procesarEventos(snapshot.data!);
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          TableCalendar<Proyecto>(
                            locale: 'es_ES',
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: _focusedDay,
                            calendarFormat: _calendarFormat,
                            rowHeight: 120,
                            daysOfWeekHeight: 40,
                            headerStyle: HeaderStyle(
                              titleCentered: true,
                              formatButtonVisible: false,
                              titleTextStyle: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                              titleTextFormatter: (date, locale) => _capitalize(
                                  DateFormat.yMMMM(locale).format(date)),
                              leftChevronIcon:
                                  const Icon(Icons.chevron_left, size: 30),
                              rightChevronIcon:
                                  const Icon(Icons.chevron_right, size: 30),
                            ),
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, day, focusedDay) =>
                                  _buildCustomCell(day,
                                      isToday: false, isSelected: false),
                              todayBuilder: (context, day, focusedDay) =>
                                  _buildCustomCell(day,
                                      isToday: true, isSelected: false),
                              selectedBuilder: (context, day, focusedDay) =>
                                  _buildCustomCell(day,
                                      isToday: isSameDay(day, DateTime.now()),
                                      isSelected: true),
                              outsideBuilder: (context, day, focusedDay) {
                                return Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade100),
                                    color: Colors.grey.shade50,
                                  ),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Text('${day.day}',
                                          style: TextStyle(
                                              color: Colors.grey.shade300,
                                              fontSize: 14)),
                                    ),
                                  ),
                                );
                              },
                              markerBuilder: (context, day, events) {
                                if (events.isEmpty) return null;
                                return Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle),
                                  ),
                                );
                              },
                            ),
                            selectedDayPredicate: (day) =>
                                isSameDay(_selectedDay, day),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            },
                            onPageChanged: (focusedDay) =>
                                _focusedDay = focusedDay,
                            eventLoader: _getEventosDelDia,
                          ),

                          const SizedBox(height: 40),

                          // FOOTER
                          SharedFooter(
                            primaryOrange: AppColors.primaryOrange,
                            accentBlue: AppColors.accentColor,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomCell(DateTime day,
      {required bool isToday, required bool isSelected}) {
    final eventos = _getEventosDelDia(day);
    Color borderColor =
        isSelected ? AppColors.primaryOrange : Colors.grey.shade300;
    double borderWidth = isSelected ? 2.5 : 0.5;
    Color? bgColor = isToday
        ? AppColors.primaryOrange.withValues(alpha: 0.05)
        : Colors.white;

    return Container(
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: isToday
                    ? BoxDecoration(
                        color: AppColors.primaryOrange,
                        borderRadius: BorderRadius.circular(4))
                    : null,
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isToday ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: eventos.length > 3 ? 3 : eventos.length,
              itemBuilder: (context, index) {
                final proyecto = eventos[index];
                final config = _obtenerConfiguracionVisual(proyecto, day);

                return Container(
                  margin: const EdgeInsets.only(bottom: 3),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: config['colorFondo'],
                    borderRadius: BorderRadius.circular(3),
                    border: Border(
                        left:
                            BorderSide(color: config['colorBorde'], width: 3)),
                  ),
                  child: Text(
                    proyecto.nombre,
                    style: TextStyle(
                      fontSize: 11,
                      color: config['colorTexto'],
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _obtenerConfiguracionVisual(
      Proyecto proyecto, DateTime fechaEvento) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final fechaEventoNorm =
        DateTime(fechaEvento.year, fechaEvento.month, fechaEvento.day);

    if (proyecto.estado.toLowerCase().contains('completad')) {
      return {
        'colorFondo': Colors.green.shade50,
        'colorBorde': Colors.green,
        'colorTexto': Colors.green.shade800
      };
    }
    if (fechaEventoNorm.isBefore(today)) {
      return {
        'colorFondo': Colors.red.shade50,
        'colorBorde': Colors.red,
        'colorTexto': Colors.red.shade800
      };
    }
    return {
      'colorFondo': Colors.blue.shade50,
      'colorBorde': Colors.blue,
      'colorTexto': Colors.blue.shade800
    };
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Wrap(
        spacing: 20,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          _legendItem("Completada", Colors.green),
          _legendItem("Vencida", Colors.red),
          _legendItem("Normal", Colors.blue),
          _legendItem("Día Actual", AppColors.primaryOrange, isCircle: true),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color, {bool isCircle = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: isCircle ? color : color.withValues(alpha: 0.2),
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle ? null : BorderRadius.circular(3),
            border: isCircle ? null : Border.all(color: color, width: 1.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
