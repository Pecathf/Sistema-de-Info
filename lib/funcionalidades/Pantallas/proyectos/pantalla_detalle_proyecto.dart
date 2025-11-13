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

// 🎯 TODO: Crear archivo task_creation_dialog.dart
// Este diálogo debe permitir:
// - Seleccionar nombre de la tarea
// - Asignar miembros del proyecto existentes
// - Asignar recursos materiales del proyecto existentes
// - Definir fecha de vencimiento
// - Establecer prioridad (Alta, Media, Baja)
// - Agregar descripción
// Similar a member_selection_dialog.dart y resource_selection_dialog.dart

// 🎯 TODO: Crear modelo task_model.dart en central/constantes/modelos/
// Debe contener:
// - id, nombre, descripcion
// - proyectoId (referencia al proyecto)
// - miembrosAsignadosUid (lista de UIDs)
// - recursosAsignados (lista de RecursoMaterial)
// - fechaVencimiento, prioridad, estado (pendiente/en progreso/completada)
// - fechaCreacion

// 🎯 TODO: Crear servicio task_service.dart en central/constantes/servicios/
// Debe permitir:
// - Crear tarea
// - Obtener tareas de un proyecto (stream)
// - Actualizar estado de tarea
// - Eliminar tarea
// - Calcular progreso del proyecto basado en tareas completadas

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

  // 🎯 TODO: Descomentar cuando TaskService esté implementado
  // final TaskService _taskService = TaskService();
  // List<Task> _tareas = [];

  @override
  void initState() {
    super.initState();
    _checkIfAdmin();
    _cargarDatosProyecto();
  }

  Future<void> _checkIfAdmin() async {
    final roleResult = await _authService.getUserRole();
    if (mounted) {
      setState(() {
        _isAdmin = (roleResult == 'admin');
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

        // 🎯 TODO: Descomentar para cargar tareas cuando TaskService esté listo
        // final tareas = await _taskService.getTareasDeProyecto(widget.projectId);

        setState(() {
          _proyecto = proyecto;
          _miembros = miembros;
          // _tareas = tareas;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'El proyecto no fue encontrado.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los datos: $e';
        _isLoading = false;
      });
    }
  }

  // 🎯 TODO: Implementar este método cuando TaskCreationDialog esté listo
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

    // 🎯 TODO: Descomentar cuando TaskCreationDialog esté implementado
    /*
    final Task? nuevaTarea = await showDialog<Task>(
      context: context,
      builder: (context) => TaskCreationDialog(
        projectId: widget.projectId,
        availableMembers: _miembros,
        availableResources: _proyecto!.recursosMateriales,
      ),
    );

    if (nuevaTarea != null) {
      // Guardar la tarea en Firestore usando TaskService
      await _taskService.crearTarea(nuevaTarea);
      
      // Recargar tareas
      _cargarDatosProyecto();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarea creada exitosamente!')),
        );
      }
    }
    */

    // Temporal: mensaje de desarrollo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad en desarrollo. Ver comentarios TODO en el código.'),
        backgroundColor: Colors.orange,
      ),
    );

    developer.log(
      'Botón crear tarea presionado. Implementar TaskCreationDialog.',
      name: 'PantallaDetalleProyecto.action',
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM, y').format(date);
  }

  // Métricas superiores tipo Figma
  Widget _buildMetricsRow() {
    // 🎯 TODO: Calcular valores reales desde las tareas
    // final tareasCompletadas = _tareas.where((t) => t.estado == 'completada').length;
    // final tareasPendientes = _tareas.where((t) => t.estado == 'pendiente').length;
    
    // Valores temporales de ejemplo
    final tareasTotales = 12;
    final tareasCompletadas = 8;
    final tareasPendientes = 4;
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
                onPressed: _abrirDialogoCrearTarea,
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

        // Área scrolleable de tareas
        _buildTasksList(),
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
              // 🎯 TODO: Implementar filtrado de tareas
              developer.log('Filtro seleccionado: $filter', name: 'TaskFilter');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryOrange : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primaryOrange : Colors.grey.shade300,
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

  Widget _buildTasksList() {
    // 🎯 TODO: Reemplazar con datos reales cuando TaskService esté implementado
    
    // Tareas de ejemplo (temporal)
    final tareasEjemplo = [
      {
        'nombre': 'Diseño de wireframes',
        'estado': 'completada',
        'fechaCompleta': 'Completada el 18 Sep 2025',
        'asignado': 'María García',
        'prioridad': 'Alta',
        'iniciales': 'MG',
      },
      {
        'nombre': 'Desarrollo del frontend',
        'estado': 'en progreso',
        'fechaCompleta': 'Asignada el 19 Sep 2025',
        'fecha': 'Vence: 25 Sep',
        'asignado': 'Juan Pérez',
        'prioridad': 'Media',
        'iniciales': 'JP',
      },
      {
        'nombre': 'Configuración del servidor',
        'estado': 'completada',
        'fechaCompleta': 'Completada el 16 Sep 2025',
        'asignado': 'Carlos López',
        'prioridad': 'Media',
        'iniciales': 'CL',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tareasEjemplo.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          final tarea = tareasEjemplo[index];
          return _buildTaskItem(
            nombre: tarea['nombre']!,
            estado: tarea['estado']!,
            fechaCompleta: tarea['fechaCompleta']!,
            fecha: tarea['fecha'],
            asignado: tarea['asignado']!,
            prioridad: tarea['prioridad']!,
            iniciales: tarea['iniciales']!,
          );
        },
      ),
    );
  }

  Widget _buildTaskItem({
    required String nombre,
    required String estado,
    required String fechaCompleta,
    String? fecha,
    required String asignado,
    required String prioridad,
    required String iniciales,
  }) {
    final isCompletada = estado == 'completada';
    final Color prioridadColor = prioridad == 'Alta' 
        ? Colors.red.shade400 
        : prioridad == 'Media' 
            ? Colors.orange.shade400 
            : Colors.blue.shade400;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Checkbox de completado
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompletada ? Colors.green.shade600 : Colors.transparent,
              border: Border.all(
                color: isCompletada ? Colors.green.shade600 : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: isCompletada
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
          const SizedBox(width: 16),

          // Información de la tarea
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkBackground,
                    decoration: isCompletada ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  fechaCompleta,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // Avatares de miembros asignados
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.accentColor,
                child: Text(
                  iniciales,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade300,
                child: Text(
                  iniciales,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Nombre del asignado y fecha
          SizedBox(
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asignado,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkBackground,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (fecha != null)
                  Text(
                    fecha,
                    style: TextStyle(
                      fontSize: 12,
                      color: fecha.contains('Vence') 
                          ? Colors.red.shade600 
                          : Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Prioridad badge
          Container(
            width: 60,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: prioridadColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              prioridad,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: prioridadColor,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Botones de acción
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón ver/comentar
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 18),
                color: AppColors.accentColor,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  developer.log('Ver tarea: $nombre', name: 'TaskAction');
                },
                tooltip: 'Ver',
              ),
              const SizedBox(width: 8),
              // 🎯 TODO: Implementar edición de tarea
              TextButton(
                onPressed: () {
                  developer.log('Editar tarea: $nombre', name: 'TaskAction');
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Editar',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // 🎯 TODO: Implementar eliminación de tarea (solo admin)
              if (_isAdmin)
                TextButton(
                  onPressed: () {
                    developer.log('Eliminar tarea: $nombre', name: 'TaskAction');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Eliminar',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
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
          child: Text(
            _errorMessage ?? 'El proyecto solicitado no existe.',
            style: const TextStyle(color: Colors.red),
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
            Text(
              ' > Sitio Web Corporativo > ',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
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
                  icon: const Icon(Icons.history, color: AppColors.darkBackground),
                  tooltip: 'HISTORIAL',
                  onPressed: () {
                    // 🎯 TODO: Implementar historial del proyecto
                    developer.log('Ver historial', name: 'ProjectAction');
                  },
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.insert_drive_file_outlined, 
                        size: 16, 
                        color: Colors.grey.shade700
                      ),
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
                      percentage: '67%',
                      subtitle: '67% completado - 8 de 12 tareas finalizadas',
                      color: AppColors.primaryOrange,
                    ),
                    const SizedBox(height: 24),
                    _buildProgressBar(
                      label: 'Recursos',
                      percentage: '98%',
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