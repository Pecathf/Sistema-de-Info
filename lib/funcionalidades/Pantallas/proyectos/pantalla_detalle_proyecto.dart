// Archivo: PantallaDetalleProyecto.dart
import 'package:flutter/material.dart';
import 'package:sistem_proyect/central/constantes/modelos/project_model.dart';
import 'package:sistem_proyect/central/constantes/modelos/usuario_model.dart';
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart';
import 'package:sistem_proyect/central/constantes/servicios/project_service.dart';
import 'package:sistem_proyect/central/constantes/servicios/user_data_service.dart';
import 'package:sistem_proyect/central/constantes/colores.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import 'package:sistem_proyect/funcionalidades/Pantallas/Widgets/shared_footer_widget.dart';

// 1. IMPORTACIONES DE TAREAS (Completando TODOs)
// ⚠ Asegúrate que estas rutas sean correctas
import 'package:sistem_proyect/central/constantes/modelos/task_model.dart';
import 'package:sistem_proyect/central/constantes/servicios/task.service.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/tareas/task_creation_dialog.dart';
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

  Proyecto? _proyecto;
  List<Usuario> _miembros = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  bool _isLoadingRole = true;
  String? _errorMessage;
  String _selectedFilter = 'Todas';

  // 2. INSTANCIAR SERVICIO Y LISTA DE TAREAS (Completando TODOs)
  final TaskService _taskService = TaskService();
  List<TaskModel> _tareas = [];

  @override
  void initState() {
    super.initState();
    // 💡 NOTA: _checkIfAdmin() ahora funcionará correctamente
    _checkIfAdmin();
    _cargarDatosProyecto();
  }

  Future<void> _checkIfAdmin() async {
    // 💡 NOTA: _authService.isAdmin() ahora devolverá 'true'
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
      // Obtenemos el proyecto
      final proyecto = await _projectService.getProyectoById(widget.projectId);

      if (proyecto != null) {
        // Obtenemos los miembros (necesarios para la tabla de tareas)
        final miembrosUids =
            proyecto.miembrosUid.where((uid) => uid.isNotEmpty).toList();
        final miembros = await _userDataService.getUsuariosByIds(miembrosUids);

        // 3. CARGAR TAREAS (Completando TODOs)
        final tareas =
            await _taskService.getTasksStreamByProject(widget.projectId).first;

        setState(() {
          _proyecto = proyecto;
          _miembros = miembros; // <-- Miembros cargados
          _tareas = tareas; // <-- Tareas cargadas
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'El proyecto no fue encontrado.';
          _isLoading = false;
        });
      }
    } catch (e) {
      // ⚠ Si las reglas de Firestore o el Índice fallan, esto se activará
      developer.log("Error en _cargarDatosProyecto: $e");
      setState(() {
        _errorMessage = 'Error al cargar los datos: $e';
        _isLoading = false;
      });
    }
  }

  // 4. IMPLEMENTAR DIÁLOGO REAL (Completando TODOs)
  Future<void> _abrirDialogoCrearTarea() async {
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

    // Llamar al diálogo
    final bool? exito = await showDialog<bool>(
      context: context,
      builder: (context) => TaskCreationDialog(
        projectId: widget.projectId,
        projectMembers: _miembros,
        projectResources: _proyecto!.recursosMateriales,
      ),
    );

    // Si el diálogo devuelve 'true', recargar los datos
    if (exito == true && mounted) {
      _cargarDatosProyecto(); // Recargar la lista de tareas

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

  // Métricas superiores tipo Figma
  Widget _buildMetricsRow() {
    // 5. USAR DATOS REALES (Completando TODOs)
    final tareasTotales = _tareas.length;
    final tareasCompletadas =
        _tareas.where((t) => t.estado == 'Completada').length;
    final tareasPendientes =
        _tareas.where((t) => t.estado == 'Pendiente').length;
    final miembrosCount = _miembros.length;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            label: 'TAREAS TOTALES',
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
    // ... (Este widget está bien, no hay cambios)
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
    // ... (Este widget está bien, no hay cambios)
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
    // Este Column está bien, porque sus hijos (Row, Row, _buildTasksDataTable)
    // tienen alturas finitas y conocidas.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tareas del Proyecto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBackground,
              ),
            ),
            // Solo mostrar botón si es admin
            if (_isAdmin)
              ElevatedButton.icon(
                onPressed: () {
                  // 1. Validar que el proyecto esté cargado
                  if (_proyecto == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Error: No se ha podido cargar el proyecto.')),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PantallaCrearTarea(
                        proyecto: _proyecto!,
                      ),
                    ),
                  ).then((_) {
                    _cargarDatosProyecto();
                  });
                },
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

        // Filtros de tareas (como en Figma)
        _buildTaskFilters(),

        const SizedBox(height: 20),

        // 💡 6. ÁREA DE TAREAS REEMPLAZADA
        // Reemplazamos el _buildTasksList() original por _buildTasksDataTable()
        _buildTasksDataTable(),
      ],
    );
  }

  Widget _buildTaskFilters() {
    // ... (Este widget está bien, no hay cambios)
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
              // 🎯 TODO: Implementar filtrado de tareas
              developer.log('Filtro seleccionado: $filter', name: 'TaskFilter');
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

  // 💡 7. NUEVO WIDGET: _buildTasksDataTable
  // Esta es la solución. Reemplaza _buildTasksList y _buildTaskItem
  Widget _buildTasksDataTable() {
    // 🎯 TODO: Filtrar _tareas basado en _selectedFilter
    final tareasFiltradas = _tareas; // Por ahora, usa todas las tareas

    if (tareasFiltradas.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(30),
        child: const Center(
          child: Text(
            'Este proyecto aún no tiene tareas.',
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
        ),
      );
    }

    // El SingleChildScrollView horizontal es la clave para arreglar
    // el desbordamiento y hacer que los botones funcionen.
    return Container(
      width: double.infinity, // Ocupa todo el ancho del Container padre
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      // ClipRRect para que el borde redondeado corte el scroll
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
            dataRowMinHeight: 60.0, // Damos un poco más de altura a las filas
            dataRowMaxHeight: 80.0,
            columns: const [
              DataColumn(label: Text('')), // Checkbox
              DataColumn(label: Text('TAREA')),
              DataColumn(label: Text('ASIGNADO')),
              DataColumn(label: Text('VENCIMIENTO')),
              DataColumn(label: Text('PRIORIDAD')),
              DataColumn(label: Text('ACCIONES')),
            ],
            // Usamos las tareas reales (_tareas) en lugar de 'tareasEjemplo'
            rows: tareasFiltradas
                .map((tarea) => _buildTaskDataRow(tarea))
                .toList(),
          ),
        ),
      ),
    );
  }

  // 💡 8. NUEVO WIDGET: _buildTaskDataRow
  // Este es el "ayudante" que construye cada fila de la tabla
  DataRow _buildTaskDataRow(TaskModel tarea) {
    final isCompletada = tarea.estado == 'Completada';

    // Lógica para buscar el primer miembro asignado (si existe)
    Usuario? asignado;
    String iniciales = 'S/A';
    if (tarea.miembrosUid.isNotEmpty) {
      // Usamos .firstWhere, pero con un 'orElse' para evitar errores si no se encuentra
      asignado = _miembros.firstWhere(
        (m) => m.uid == tarea.miembrosUid.first,
        orElse: () => Usuario(uid: '', nombre: 'N/A', email: ''),
      );
      if (asignado.nombre.isNotEmpty) {
        iniciales = asignado.nombre.substring(0, 1).toUpperCase();
      }
    }

    // Lógica para formatear la fecha
    String fechaStr = 'Sin fecha';
    if (tarea.fechaVencimiento != null) {
      fechaStr = DateFormat('d MMM, y').format(tarea.fechaVencimiento!);
    }

    // Lógica para el color de prioridad
    final Color prioridadColor = tarea.prioridad == 'Alta'
        ? Colors.red.shade400
        : tarea.prioridad == 'Media'
            ? Colors.orange.shade400
            : Colors.blue.shade400;

    return DataRow(
      cells: [
        // Celda 1: Checkbox
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

        // Celda 2: Tarea y Fecha de Creación
        DataCell(Container(
          width: 200, // Ancho fijo para el nombre
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

        // Celda 3: Asignados (Avatar e Iniciales)
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

        // Celda 4: Vencimiento
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

        // Celda 5: Prioridad
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: prioridadColor.withOpacity(0.15),
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

        // Celda 6: Acciones (¡Ahora funcionarán!)
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

    // 💡 Si los permisos (rol/role) fallan, verás esto
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
            // Flexible para que el nombre del proyecto no desborde el AppBar
            Flexible(
              child: Text(
                ' > ${proyecto.nombre} > ', // Título dinámico
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
                    // 🎯 TODO: Implementar historial del proyecto
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
          // La Columna principal es segura
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con título y descripción
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

              // Métricas superiores
              _buildMetricsRow(),

              const SizedBox(height: 30),

              // Barras de progreso
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
                      percentage: '67%', // 🎯 TODO: Conectar a datos reales
                      subtitle: '67% completado - 8 de 12 tareas finalizadas',
                      color: AppColors.primaryOrange,
                    ),
                    const SizedBox(height: 24),
                    _buildProgressBar(
                      label: 'Recursos',
                      percentage: '98%', // 🎯 TODO: Conectar a datos reales
                      subtitle: '98% de recursos disponibles',
                      color: AppColors.primaryOrange,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Sección de Tareas
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

              // Botón Volver
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

              // Footer
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
