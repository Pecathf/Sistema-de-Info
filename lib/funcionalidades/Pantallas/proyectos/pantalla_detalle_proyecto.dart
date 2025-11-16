import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sistem_proyect/central/constantes/modelos/project_model.dart';
import 'package:sistem_proyect/central/constantes/modelos/usuario_model.dart';
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart';
import 'package:sistem_proyect/central/constantes/servicios/project_service.dart';
import 'package:sistem_proyect/central/constantes/servicios/user_data_service.dart';
import 'package:sistem_proyect/central/constantes/servicios/resource_service.dart';
import 'package:sistem_proyect/central/constantes/colores.dart';
import 'package:sistem_proyect/central/constantes/modelos/recurso_model.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import 'package:sistem_proyect/funcionalidades/Pantallas/Widgets/shared_footer_widget.dart';

import 'package:sistem_proyect/central/constantes/modelos/task_model.dart';
import 'package:sistem_proyect/central/constantes/servicios/task.service.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/tareas/pantalla_crear_tarea.dart';

class PantallaDetalleProyecto extends StatefulWidget {
  final String projectId;

  const PantallaDetalleProyecto({
    super.key,
    required this.projectId,
  });

  @override
  State<PantallaDetalleProyecto> createState() =>
      _PantallaDetalleProyectoState();
}

class _PantallaDetalleProyectoState extends State<PantallaDetalleProyecto> {
  final ProjectService _projectService = ProjectService();
  final UserDataService _userDataService = UserDataService();
  final AuthService _authService = AuthService();
  final TaskService _taskService = TaskService();
  final ResourceService _resourceService = ResourceService();

  Proyecto? _proyecto;
  List<Usuario> _miembros = [];
  List<TaskModel> _tareas = [];
  List<RecursoMaterial> _recursos = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  bool _isLoadingRole = true;
  String? _errorMessage;
  String _selectedFilter = 'Todas';

  @override
  void initState() {
    super.initState();
    _checkIfAdmin();
    _cargarDatosProyecto();
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

  Future<void> _cargarDatosProyecto() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final proyecto = await _projectService.getProyectoById(widget.projectId);

      if (proyecto != null) {
        final miembrosUids =
            proyecto.miembrosUid.where((uid) => uid.isNotEmpty).toList();
        final miembros = await _userDataService.getUsuariosByIds(miembrosUids);
        
        // Obtener todas las tareas del proyecto
        final todasLasTareas =
            await _taskService.getTasksStreamByProject(widget.projectId).first;
        
        // FILTRAR tareas según el rol del usuario
        List<TaskModel> tareasFiltradas;
        final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
        
        if (_isAdmin) {
          // Admin ve todas las tareas
          tareasFiltradas = todasLasTareas;
        } else {
          // Miembro solo ve tareas donde está asignado
          tareasFiltradas = todasLasTareas.where((tarea) {
            return tarea.miembrosUid.contains(currentUserUid);
          }).toList();
        }
        
        // Cargar recursos del proyecto
        final recursos = await _resourceService
            .getRecursosStreamByProject(widget.projectId)
            .first;

        setState(() {
          _proyecto = proyecto;
          _miembros = miembros;
          _tareas = tareasFiltradas;
          _recursos = recursos;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'El proyecto no fue encontrado.';
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log("Error en _cargarDatosProyecto: $e");
      setState(() {
        _errorMessage = 'Error al cargar los datos: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _abrirPantallaCrearTarea() async {
    if (!_isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes permisos para crear tareas.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_proyecto == null) return;

    final bool? exito = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaCrearTarea(
          projectId: widget.projectId,
          projectMembers: _miembros,
        ),
      ),
    );

    if (exito == true && mounted) {
      _cargarDatosProyecto();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarea creada exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM, y').format(date);
  }

  Widget _buildMetricsRow() {
    final tareasTotales = _tareas.length;
    final tareasCompletadas =
        _tareas.where((t) => t.estado == 'Completada').length;
    final tareasPendientes =
        _tareas.where((t) => t.estado == 'Pendiente').length;
    final miembrosCount = _miembros.length;

    // Texto descriptivo según el rol
    final String tareasLabel = _isAdmin 
        ? 'TAREAS TOTALES' 
        : 'MIS TAREAS';

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            label: tareasLabel,
            value: tareasTotales.toString(),
            color: AppColors.primaryOrange,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildMetricCard(
            label: 'COMPLETADAS',
            value: tareasCompletadas.toString(),
            color: AppColors.primaryOrange,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildMetricCard(
            label: 'PENDIENTES',
            value: tareasPendientes.toString(),
            color: AppColors.primaryOrange,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildMetricCard(
            label: 'MIEMBROS',
            value: miembrosCount.toString(),
            color: AppColors.primaryOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
              letterSpacing: 0.3,
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
        ],
      ),
    );
  }

  Widget _buildProgressBar({
    required String label,
    required String percentage,
    required String subtitle,
    required Color color,
  }) {
    final progress = int.parse(percentage.replaceAll('%', '')) / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.darkBackground,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskManagementSection() {
    // Título dinámico según el rol
    final String tituloSeccion = _isAdmin 
        ? 'Tareas del Proyecto' 
        : 'Mis Tareas Asignadas';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tituloSeccion,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBackground,
              ),
            ),
            if (_isAdmin)
              ElevatedButton.icon(
                onPressed: _abrirPantallaCrearTarea,
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text(
                  'Nueva Tarea',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),

        _buildTaskFilters(),

        const SizedBox(height: 20),

        _buildTasksDataTable(),
      ],
    );
  }

  Widget _buildTaskFilters() {
    final filters = ['Todas', 'Pendientes', 'Completadas', 'Vencidas'];

    return Row(
      children: filters.map((filter) {
        final isSelected = _selectedFilter == filter;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryOrange : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryOrange
                      : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTasksDataTable() {
    final tareasFiltradas = _tareas;

    if (tareasFiltradas.isEmpty) {
      // Mensaje diferente según el rol
      final String mensaje = _isAdmin 
          ? 'Este proyecto aún no tiene tareas.' 
          : 'No tienes tareas asignadas en este proyecto.';
      
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(30),
        child: Center(
          child: Text(
            mensaje,
            style: const TextStyle(fontSize: 15, color: Colors.grey),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Determinar si estamos en móvil o desktop
        final isDesktop = constraints.maxWidth > 900;

        if (isDesktop) {
          // Vista de tabla para desktop
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                  ),
                  child: DataTable(
                    headingRowColor: WidgetStatePropertyAll(Colors.grey.shade50),
                    dataRowMinHeight: 60.0,
                    dataRowMaxHeight: 80.0,
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(label: Text('')),
                      DataColumn(label: Text('TAREA')),
                      DataColumn(label: Text('ASIGNADO')),
                      DataColumn(label: Text('VENCIMIENTO')),
                      DataColumn(label: Text('PRIORIDAD')),
                      DataColumn(label: Text('ACCIONES')),
                    ],
                    rows: tareasFiltradas
                        .map((tarea) => _buildTaskDataRow(tarea))
                        .toList(),
                  ),
                ),
              ),
            ),
          );
        } else {
          // Vista de cards para móvil
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: tareasFiltradas
                  .map((tarea) => _buildTaskCard(tarea))
                  .toList(),
            ),
          );
        }
      },
    );
  }

  // Nuevo widget para vista móvil
  Widget _buildTaskCard(TaskModel tarea) {
    final isCompletada = tarea.estado == 'Completada';

    Usuario? asignado;
    String iniciales = 'S/A';
    if (tarea.miembrosUid.isNotEmpty) {
      asignado = _miembros.firstWhere(
        (m) => m.uid == tarea.miembrosUid.first,
        orElse: () => Usuario(uid: '', nombre: 'N/A', email: ''),
      );
      if (asignado.nombre.isNotEmpty) {
        iniciales = asignado.nombre.substring(0, 1).toUpperCase();
      }
    }

    String fechaStr = 'Sin fecha';
    if (tarea.fechaVencimiento != null) {
      fechaStr = DateFormat('d MMM, y').format(tarea.fechaVencimiento!);
    }

    final Color prioridadColor = tarea.prioridad == 'Alta'
        ? Colors.red.shade400
        : tarea.prioridad == 'Media'
            ? Colors.orange.shade400
            : Colors.blue.shade400;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompletada ? Colors.green.shade600 : Colors.transparent,
                    border: Border.all(
                      color: isCompletada ? Colors.green.shade600 : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isCompletada
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
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: isCompletada ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      Text(
                        'Creada: ${_formatDate(tarea.fechaCreacion)}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: prioridadColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tarea.prioridad,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: prioridadColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.accentColor,
                  child: Text(
                    iniciales,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    asignado?.nombre ?? 'Sin Asignar',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  fechaStr,
                  style: TextStyle(
                    fontSize: 13,
                    color: (tarea.fechaVencimiento != null &&
                            tarea.fechaVencimiento!.isBefore(DateTime.now()) &&
                            !isCompletada)
                        ? Colors.red
                        : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, size: 20),
                  color: AppColors.accentColor,
                  onPressed: () {
                    developer.log('Ver tarea: ${tarea.nombre}', name: 'TaskAction');
                  },
                  tooltip: 'Ver',
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: Colors.blueGrey,
                  onPressed: () {
                    developer.log('Editar tarea: ${tarea.nombre}', name: 'TaskAction');
                  },
                  tooltip: 'Editar',
                ),
                if (_isAdmin)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: Colors.red,
                    onPressed: () {
                      developer.log('Eliminar tarea: ${tarea.nombre}', name: 'TaskAction');
                    },
                    tooltip: 'Eliminar',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildTaskDataRow(TaskModel tarea) {
    final isCompletada = tarea.estado == 'Completada';

    Usuario? asignado;
    String iniciales = 'S/A';
    if (tarea.miembrosUid.isNotEmpty) {
      asignado = _miembros.firstWhere(
        (m) => m.uid == tarea.miembrosUid.first,
        orElse: () => Usuario(uid: '', nombre: 'N/A', email: ''),
      );
      if (asignado.nombre.isNotEmpty) {
        iniciales = asignado.nombre.substring(0, 1).toUpperCase();
      }
    }

    String fechaStr = 'Sin fecha';
    if (tarea.fechaVencimiento != null) {
      fechaStr = DateFormat('d MMM, y').format(tarea.fechaVencimiento!);
    }

    final Color prioridadColor = tarea.prioridad == 'Alta'
        ? Colors.red.shade400
        : tarea.prioridad == 'Media'
            ? Colors.orange.shade400
            : Colors.blue.shade400;

    return DataRow(
      cells: [
        DataCell(Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompletada ? Colors.green.shade600 : Colors.transparent,
            border: Border.all(
              color:
                  isCompletada ? Colors.green.shade600 : Colors.grey.shade400,
              width: 2,
            ),
          ),
          child: isCompletada
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : null,
        )),

        DataCell(SizedBox(
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tarea.nombre,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  decoration: isCompletada ? TextDecoration.lineThrough : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Creada: ${_formatDate(tarea.fechaCreacion)}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        )),

        DataCell(Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.accentColor,
              child: Text(
                iniciales,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
            const SizedBox(width: 8),
            Text(asignado?.nombre ?? 'Sin Asignar'),
          ],
        )),

        DataCell(Text(
          fechaStr,
          style: TextStyle(
            color: (tarea.fechaVencimiento != null &&
                    tarea.fechaVencimiento!.isBefore(DateTime.now()) &&
                    !isCompletada)
                ? Colors.red
                : Colors.grey.shade700,
          ),
        )),

        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: prioridadColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            tarea.prioridad,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: prioridadColor,
            ),
          ),
        )),

        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility_outlined, size: 18),
              color: AppColors.accentColor,
              onPressed: () {
                developer.log('Ver tarea: ${tarea.nombre}', name: 'TaskAction');
              },
              tooltip: 'Ver',
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              color: Colors.blueGrey,
              onPressed: () {
                developer.log('Editar tarea: ${tarea.nombre}',
                    name: 'TaskAction');
              },
              tooltip: 'Editar',
            ),
            if (_isAdmin)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                color: Colors.red,
                onPressed: () {
                  developer.log('Eliminar tarea: ${tarea.nombre}',
                      name: 'TaskAction');
                },
                tooltip: 'Eliminar',
              ),
          ],
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _isLoadingRole) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cargando Proyecto...')),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryOrange),
        ),
      );
    }

    if (_errorMessage != null || _proyecto == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              _errorMessage ?? 'El proyecto solicitado no existe.',
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final proyecto = _proyecto!;
    
    // Calcular progreso de tareas
    final tareasTotales = _tareas.length;
    final tareasCompletadas = _tareas.where((t) => t.estado == 'Completada').length;
    final progresoTareas = tareasTotales > 0 
        ? (tareasCompletadas / tareasTotales * 100).round() 
        : 0;
    
    // Calcular progreso de recursos
    int totalRecursos = 0;
    int recursosDisponibles = 0;
    for (var recurso in _recursos) {
      totalRecursos += recurso.cantidad;
      recursosDisponibles += recurso.cantidadDisponible;
    }
    final progresoRecursos = totalRecursos > 0 
        ? (recursosDisponibles / totalRecursos * 100).round() 
        : 100;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkBackground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Text(
              'Proyectos',
              style: TextStyle(
                color: AppColors.primaryOrange,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Flexible(
              child: Text(
                ' > ${proyecto.nombre} > ',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Text(
              'Tareas',
              style: TextStyle(
                color: AppColors.darkBackground,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.history,
                      color: AppColors.darkBackground),
                  tooltip: 'HISTORIAL',
                  onPressed: () {
                    developer.log('Ver historial', name: 'ProjectAction');
                  },
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.insert_drive_file_outlined,
                          size: 16, color: Colors.grey.shade700),
                      const SizedBox(width: 6),
                      Text(
                        'HISTORIAL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                proyecto.nombre,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBackground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                proyecto.descripcion,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              _buildMetricsRow(),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildProgressBar(
                      label: 'Progreso del Proyecto',
                      percentage: '$progresoTareas%',
                      subtitle: '$progresoTareas% completado - $tareasCompletadas de $tareasTotales tareas finalizadas',
                      color: AppColors.primaryOrange,
                    ),
                    const SizedBox(height: 24),
                    _buildProgressBar(
                      label: 'Recursos',
                      percentage: '$progresoRecursos%',
                      subtitle: '$progresoRecursos% de recursos disponibles ($recursosDisponibles de $totalRecursos)',
                      color: AppColors.primaryOrange,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: _buildTaskManagementSection(),
              ),

              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Volver',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              SharedFooter(
                primaryOrange: AppColors.primaryOrange,
                accentBlue: AppColors.accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}