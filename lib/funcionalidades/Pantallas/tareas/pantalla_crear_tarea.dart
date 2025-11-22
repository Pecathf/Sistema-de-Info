import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sistem_proyect/central/constantes/modelos/usuario_model.dart';
import 'package:sistem_proyect/central/constantes/modelos/recurso_model.dart';
import 'package:sistem_proyect/central/constantes/modelos/task_model.dart';
import 'package:sistem_proyect/central/constantes/servicios/task_service.dart';
import 'package:sistem_proyect/central/constantes/servicios/resource_service.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/tareas/task_member_selection.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/Widgets/widgets_principal.dart';


class PantallaCrearTarea extends StatefulWidget {
  final String projectId;
  final List<Usuario> projectMembers;

  const PantallaCrearTarea({
    super.key,
    required this.projectId,
    required this.projectMembers,
  });

  @override
  State<PantallaCrearTarea> createState() => _PantallaCrearTareaState();
}

class _PantallaCrearTareaState extends State<PantallaCrearTarea> {
  final _formKey = GlobalKey<FormState>();
  final TaskService _taskService = TaskService();
  final ResourceService _resourceService = ResourceService();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  DateTime? _fechaInicio;
  DateTime? _fechaVencimiento;
  String _prioridad = 'Media';
  List<Usuario> _selectedMembers = [];
  Map<String, int> _selectedResources = {};
  List<RecursoMaterial> _availableResources = [];
  bool _isCreating = false;
  bool _isLoadingResources = true;

  final List<String> _priorities = ['Alta', 'Media', 'Baja'];

  @override
  void initState() {
    super.initState();
    _cargarRecursos();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _cargarRecursos() async {
    setState(() => _isLoadingResources = true);

    try {
      final recursos =
          await _resourceService.getRecursosByProject(widget.projectId);

      if (mounted) {
        setState(() {
          _availableResources = recursos;
          _isLoadingResources = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _availableResources = [];
          _isLoadingResources = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar recursos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isFechaInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isFechaInicio ? _fechaInicio : _fechaVencimiento) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        final ThemeData base = Theme.of(context);
        return Theme(
          data: base.copyWith(
            colorScheme: base.colorScheme.copyWith(
              primary: AppColors.primaryOrange,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFechaInicio) {
          _fechaInicio = picked;
        } else {
          _fechaVencimiento = picked;
        }
      });
    }
  }

  void _selectMembers() async {
    final List<Usuario>? result = await showDialog(
      context: context,
      builder: (context) => TaskMemberSelectionDialog(
        initialSelectedMembers: _selectedMembers,
        availableUsers: widget.projectMembers,
      ),
    );

    if (result != null) {
      setState(() => _selectedMembers = result);
    }
  }

  void _showResourceSelector() {
    if (_availableResources.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sin Recursos'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Este proyecto no tiene recursos materiales disponibles.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Los recursos deben ser creados al momento de crear el proyecto.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _ResourceAssignmentDialog(
        availableResources: _availableResources,
        currentAssignments: Map.from(_selectedResources),
        onConfirm: (assignments) {
          setState(() => _selectedResources = assignments);
        },
      ),
    );
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fechaInicio == null || _fechaVencimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona las fechas de inicio y vencimiento.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

      // Preparar recursos asignados
      List<RecursoMaterial> recursosAsignados = [];
      for (var entry in _selectedResources.entries) {
        final recurso =
            _availableResources.firstWhere((r) => r.id == entry.key);
        recursosAsignados.add(recurso.copyWith(cantidad: entry.value));
      }

      final newTask = TaskModel(
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        proyectoId: widget.projectId,
        creadorUid: currentUserUid,
        miembrosUid: _selectedMembers.map((m) => m.uid).toList(),
        recursosAsignados: recursosAsignados,
        fechaInicio: _fechaInicio,
        fechaVencimiento: _fechaVencimiento,
        prioridad: _prioridad,
        fechaCreacion: DateTime.now(),
        estado: 'Pendiente',
      );

      final taskId = await _taskService.crearTarea(newTask);

      if (taskId != null) {
        // Actualizar cantidades disponibles de recursos
        for (var entry in _selectedResources.entries) {
          final recurso =
              _availableResources.firstWhere((r) => r.id == entry.key);
          final nuevaCantidadDisponible =
              recurso.cantidadDisponible - entry.value;
          await _resourceService.actualizarCantidadDisponible(
            entry.key,
            nuevaCantidadDisponible,
          );
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarea creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear la tarea: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 800;
        final double horizontalPadding = isDesktop ? 40.0 : 20.0;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Crear Nueva Tarea',
              style:
                  TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 30.0,
            ),
            child: Column(
              children: [
                isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _isCreating ? null : _createTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 3,
                    ),
                    child: _isCreating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Crear',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: OutlinedButton(
                    onPressed: _isCreating ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryOrange,
                      side: BorderSide(color: AppColors.primaryOrange),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Volver',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildTaskForm()),
        const SizedBox(width: 40),
        Expanded(child: _buildResourcesPanel()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildTaskForm(),
        const SizedBox(height: 30),
        _buildResourcesPanel(),
      ],
    );
  }

  Widget _buildTaskForm() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crear Tarea',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Nombre
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la Tarea',
                  hintText: 'Ingresa el nombre',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: AppColors.primaryOrange, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Descripción
              TextFormField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Describe la tarea',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: AppColors.primaryOrange, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La descripcion no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Prioridad
              DropdownButtonFormField<String>(
                initialValue: _prioridad,
                decoration: InputDecoration(
                  labelText: 'Prioridad',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: AppColors.primaryOrange, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                items: _priorities
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _prioridad = value!);
                },
              ),
              const SizedBox(height: 15),

              // Fecha de Inicio
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fecha de Inicio',
                    suffixIcon: Icon(Icons.calendar_today,
                        color: AppColors.primaryOrange),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: AppColors.primaryOrange, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Text(
                    _fechaInicio == null
                        ? 'Seleccionar fecha'
                        : _formatDate(_fechaInicio),
                    style: TextStyle(
                      color: _fechaInicio == null
                          ? Colors.grey
                          : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Fecha Límite
              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fecha Límite',
                    suffixIcon: Icon(Icons.calendar_today,
                        color: AppColors.primaryOrange),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: AppColors.primaryOrange, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Text(
                    _fechaVencimiento == null
                        ? 'Seleccionar fecha'
                        : _formatDate(_fechaVencimiento),
                    style: TextStyle(
                      color: _fechaVencimiento == null
                          ? Colors.grey
                          : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourcesPanel() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recursos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Recursos Humanos
            Text(
              'Recursos Humanos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${_selectedMembers.length}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryOrange,
              ),
            ),
            const SizedBox(height: 15),

            if (_selectedMembers.isNotEmpty)
              Column(
                children: _selectedMembers.map((member) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: member.uid.hashCode.isEven
                              ? AppColors.accentColor
                              : AppColors.primaryOrange,
                          child: Text(
                            member.nombre.isNotEmpty
                                ? member.nombre[0].toUpperCase()
                                : (member.email.isNotEmpty
                                    ? member.email[0].toUpperCase()
                                    : '?'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            member.nombre.isNotEmpty
                                ? member.nombre
                                : member.email,
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey.shade800),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )
            else
              Text(
                'No se han asignado miembros.',
                style: TextStyle(color: Colors.grey.shade600),
              ),

            const SizedBox(height: 20),

            // Botón Agregar miembros
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectMembers,
                icon: const Icon(Icons.person_add, color: Colors.white, size: 20),
                label: const Text('Agregar miembros',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Recursos Materiales
            Text(
              'Recursos Materiales',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${_selectedResources.length}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryOrange,
              ),
            ),
            if (!_isLoadingResources && _availableResources.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '${_availableResources.where((r) => r.cantidadDisponible > 0).length} disponibles en el proyecto',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade600),
                ),
              ),
            const SizedBox(height: 15),

            if (_isLoadingResources)
              const Center(child: CircularProgressIndicator())
            else if (_availableResources.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'No hay recursos en este proyecto',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else if (_availableResources.every((r) => r.cantidadDisponible == 0))
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 48, color: Colors.orange.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'Todos los recursos están agotados',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No hay cantidad disponible para asignar',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            else if (_selectedResources.isNotEmpty)
              Column(
                children: _selectedResources.entries.map((entry) {
                  final recurso =
                      _availableResources.firstWhere((r) => r.id == entry.key);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              AppColors.accentColor.withValues(alpha: 0.2),
                          child: Text(recurso.icono,
                              style: const TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${recurso.nombre} (${entry.value} unidades)',
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey.shade800),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )
            else
              Text(
                'No se han asignado recursos materiales.',
                style: TextStyle(color: Colors.grey.shade600),
              ),

            const SizedBox(height: 20),

            // Botón Agregar recursos
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_isLoadingResources || 
                           _availableResources.isEmpty || 
                           _availableResources.every((r) => r.cantidadDisponible == 0))
                    ? null 
                    : _showResourceSelector,
                icon:
                    const Icon(Icons.inventory_2, color: Colors.white, size: 20),
                label: const Text('Agregar recursos',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Diálogo para asignar recursos
class _ResourceAssignmentDialog extends StatefulWidget {
  final List<RecursoMaterial> availableResources;
  final Map<String, int> currentAssignments;
  final Function(Map<String, int>) onConfirm;

  const _ResourceAssignmentDialog({
    required this.availableResources,
    required this.currentAssignments,
    required this.onConfirm,
  });

  @override
  State<_ResourceAssignmentDialog> createState() =>
      _ResourceAssignmentDialogState();
}

class _ResourceAssignmentDialogState extends State<_ResourceAssignmentDialog> {
  late Map<String, int> _assignments;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _errors = {};

  @override
  void initState() {
    super.initState();
    _assignments = Map.from(widget.currentAssignments);

    for (var recurso in widget.availableResources) {
      final currentValue = _assignments[recurso.id] ?? 0;
      _controllers[recurso.id] = TextEditingController(
        text: currentValue > 0 ? currentValue.toString() : '',
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _validateAndUpdateAssignment(RecursoMaterial recurso, String value) {
    setState(() {
      if (value.isEmpty) {
        _assignments.remove(recurso.id);
        _errors[recurso.id] = null;
        return;
      }

      final cantidad = int.tryParse(value);

      if (cantidad == null) {
        _errors[recurso.id] = 'Ingresa un número válido';
        return;
      }

      if (cantidad <= 0) {
        _errors[recurso.id] = 'Debe ser mayor a 0';
        _assignments.remove(recurso.id);
        return;
      }

      if (cantidad > recurso.cantidadDisponible) {
        _errors[recurso.id] =
            'Solo hay ${recurso.cantidadDisponible} disponibles';
        return;
      }

      _errors[recurso.id] = null;
      _assignments[recurso.id] = cantidad;
    });
  }

  bool _hasErrors() {
    return _errors.values.any((error) => error != null);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Asignar Recursos'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6,
        child: widget.availableResources.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No hay recursos disponibles en este proyecto',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: widget.availableResources.length,
                itemBuilder: (context, index) {
                  final recurso = widget.availableResources[index];
                  final controller = _controllers[recurso.id]!;
                  final error = _errors[recurso.id];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.accentColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  recurso.icono,
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recurso.nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 14,
                                          color: Colors.green.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${recurso.cantidadDisponible} disponibles',
                                          style: TextStyle(
                                            color: Colors.green.shade700,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'de ${recurso.cantidad} totales',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Cantidad a asignar',
                              hintText: 'Ej: ${recurso.cantidadDisponible}',
                              errorText: error,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.edit),
                              helperText:
                                  'Máximo: ${recurso.cantidadDisponible}',
                              helperStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                            ),
                            onChanged: (value) =>
                                _validateAndUpdateAssignment(recurso, value),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: _hasErrors()
              ? null
              : () {
                  widget.onConfirm(_assignments);
                  Navigator.of(context).pop();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryOrange,
          ),
          child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}