// Archivo: lib/funcionalidades/Pantallas/tareas/pantalla_crear_tarea.dart
// VERSIÓN MODIFICADA (Para coincidir con la imagen 'image_01c241.png')

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sistem_proyect/central/constantes/modelos/project_model.dart';
import 'package:sistem_proyect/central/constantes/modelos/usuario_model.dart';
import 'package:sistem_proyect/central/constantes/modelos/recurso_model.dart';
import 'package:sistem_proyect/central/constantes/modelos/task_model.dart';
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart';
import 'package:sistem_proyect/central/constantes/servicios/task_service.dart';
import 'package:sistem_proyect/central/constantes/servicios/user_data_service.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/Widgets/profile_menu_widget.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/proyectos/resource_selection_dialog.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/tareas/task_member_selection.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/Widgets/widgets_principal.dart';

class PantallaCrearTarea extends StatefulWidget {
  final String projectId;
  final List<Usuario> projectMembers;
  final TaskModel? tareaExistente;

  const PantallaCrearTarea({
    super.key,
    required this.projectId,
    required this.projectMembers,
    this.tareaExistente,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PantallaCrearTareaState createState() => _PantallaCrearTareaState();
}

class _PantallaCrearTareaState extends State<PantallaCrearTarea> {
  // Servicios y estado
  final _formKey = GlobalKey<FormState>();
  // MODIFICADO: El formato de la imagen no tiene día, pero 'intl' es mejor
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  // --- Conexión a tus Servicios ---
  final TaskService _taskService = TaskService();
  final UserDataService _userDataService = UserDataService();
  final AuthService _authService = AuthService();
  bool _isAdmin = false;

  // Controladores
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  // --- MODIFICADO: Añadido controlador para fecha de inicio (como en la imagen) ---
  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _fechaLimiteController = TextEditingController();

  // Datos de la tarea
  DateTime? _fechaInicio; // MODIFICADO: Añadido
  DateTime? _fechaLimite;
  final String _prioridad =
      'Media'; // Lo mantenemos por lógica, aunque no está en la imagen
  List<Usuario> _selectedMembers = [];
  Map<String, int> _selectedResources = {};
  final Map<String, int> _recursosOriginales = {};
  List<RecursoMaterial> _availableResources = [];
  bool _isCreating = false;
  bool _isLoadingResources = true;

  final List<String> _priorities = ['Alta', 'Media', 'Baja'];

  bool get _isEditMode => widget.tareaExistente != null;

  @override
  void initState() {
    super.initState();

    // Primero cargamos los recursos disponibles
    _cargarRecursos().then((_) {
      // Después de cargar recursos, si estamos en modo edición, cargamos los datos
      if (_isEditMode && mounted) {
        _cargarDatosExistentes();
      }
    });
  }

  void _cargarDatosExistentes() {
    final tarea = widget.tareaExistente!;

    setState(() {
      _nombreController.text = tarea.nombre;
      _descripcionController.text = tarea.descripcion;
      _fechaInicio = tarea.fechaInicio;
      _fechaVencimiento = tarea.fechaVencimiento;
      _prioridad = tarea.prioridad;

      // Cargar miembros seleccionados
      _selectedMembers = widget.projectMembers
          .where((m) => tarea.miembrosUid.contains(m.uid))
          .toList();

      // Cargar recursos asignados
      for (var recurso in tarea.recursosAsignados) {
        // Verificar que el recurso todavía existe en el proyecto
        final existe = _availableResources.any((r) => r.id == recurso.id);
        if (existe) {
          _selectedResources[recurso.id] = recurso.cantidad;
          _recursosOriginales[recurso.id] = recurso.cantidad;
        }
      }
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _checkIfAdmin() async {
    final isAdmin = await _authService.isAdmin();
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _fechaInicioController.dispose(); // MODIFICADO
    _fechaLimiteController.dispose(); // MODIFICADO
    super.dispose();
  }

  // --- LÓGICA DE FUNCIONAMIENTO (Sin cambios) ---

  // --- MODIFICADO: Función genérica para seleccionar fecha ---
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          (isFechaInicio ? _fechaInicio : _fechaVencimiento) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      // Puedes añadir el 'builder' de estilo que tenías en mi otra respuesta si quieres
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() {
        final formattedDate = _dateFormat.format(picked);
        if (isStartDate) {
          _fechaInicio = picked;
          _fechaInicioController.text = formattedDate;
        } else {
          _fechaLimite = picked;
          _fechaLimiteController.text = formattedDate;
        }
      });
    }
  }

  void _selectMembers() async {
    final availableUsers = await _miembrosDelProyecto;

    final List<Usuario>? result = await showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (_) => TaskMemberSelectionDialog(
        initialSelectedMembers: _selectedMembers,
        availableUsers: availableUsers,
      ),
    );

    if (!mounted) return;
    if (result != null) {
      setState(() {
        _selectedMembers = result;
      });
    }
  }

  void _selectResources() async {
    final List<RecursoMaterial>? result = await showDialog(
      context: context,
      builder: (_) => ResourceSelectionDialog(
        initialSelectedResources: _selectedResources,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedResources = result;
      });
    }
  }

  Future<void> _crearTarea() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaLimite == null || _fechaInicio == null) {
      // MODIFICADO
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Por favor, selecciona las fechas de inicio y vencimiento.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

      if (_isEditMode) {
        // ============================================
        // MODO EDICIÓN
        // ============================================

        // 1. Liberar recursos que se quitaron
        for (var entry in _recursosOriginales.entries) {
          final recursoId = entry.key;
          final cantidadOriginal = entry.value;
          final cantidadNueva = _selectedResources[recursoId] ?? 0;

          // Verificar que el recurso todavía existe
          final recursoIndex =
              _availableResources.indexWhere((r) => r.id == recursoId);
          if (recursoIndex == -1) {
            // El recurso ya no existe, saltarlo
            continue;
          }

          if (cantidadNueva < cantidadOriginal) {
            // Se liberaron recursos
            final recurso = _availableResources[recursoIndex];
            final cantidadALiberar = cantidadOriginal - cantidadNueva;
            final nuevaCantidadDisponible =
                recurso.cantidadDisponible + cantidadALiberar;

            await _resourceService.actualizarCantidadDisponible(
              recursoId,
              nuevaCantidadDisponible,
            );
          }
        }

        // 2. Asignar nuevos recursos o aumentar cantidad
        for (var entry in _selectedResources.entries) {
          final recursoId = entry.key;
          final cantidadNueva = entry.value;
          final cantidadOriginal = _recursosOriginales[recursoId] ?? 0;

          // Verificar que el recurso existe
          final recursoIndex =
              _availableResources.indexWhere((r) => r.id == recursoId);
          if (recursoIndex == -1) {
            // El recurso no existe, mostrar advertencia y continuar
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Advertencia: El recurso con ID $recursoId ya no existe'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            continue;
          }

          if (cantidadNueva > cantidadOriginal) {
            // Se agregaron más recursos
            final recurso = _availableResources[recursoIndex];
            final cantidadAAgregar = cantidadNueva - cantidadOriginal;
            final nuevaCantidadDisponible =
                recurso.cantidadDisponible - cantidadAAgregar;

            await _resourceService.actualizarCantidadDisponible(
              recursoId,
              nuevaCantidadDisponible,
            );
          }
        }

        // 3. Preparar recursos asignados actualizados (solo los que existen)
        List<RecursoMaterial> recursosAsignados = [];
        for (var entry in _selectedResources.entries) {
          final recursoIndex =
              _availableResources.indexWhere((r) => r.id == entry.key);
          if (recursoIndex != -1) {
            final recurso = _availableResources[recursoIndex];
            recursosAsignados.add(
              RecursoMaterial(
                id: recurso.id,
                nombre: recurso.nombre,
                cantidad: entry.value,
                icono: recurso.icono,
                proyectoId: recurso.proyectoId,
                cantidadDisponible: recurso.cantidadDisponible,
              ),
            );
          }
        }

        // 4. Actualizar la tarea
        await _taskService.updateTarea(
          widget.tareaExistente!.id,
          nombre: _nombreController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          miembrosUid: _selectedMembers.map((m) => m.uid).toList(),
          recursosAsignados: recursosAsignados,
          fechaInicio: _fechaInicio,
          fechaVencimiento: _fechaVencimiento,
          prioridad: _prioridad,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarea actualizada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // ============================================
        // MODO CREACIÓN (código original)
        // ============================================

        // Preparar recursos asignados
        List<RecursoMaterial> recursosAsignados = [];
        for (var entry in _selectedResources.entries) {
          final recursoIndex =
              _availableResources.indexWhere((r) => r.id == entry.key);
          if (recursoIndex != -1) {
            final recurso = _availableResources[recursoIndex];
            recursosAsignados.add(
              RecursoMaterial(
                id: recurso.id,
                nombre: recurso.nombre,
                cantidad: entry.value,
                icono: recurso.icono,
                proyectoId: recurso.proyectoId,
                cantidadDisponible: recurso.cantidadDisponible,
              ),
            );
          }
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
            final recursoIndex =
                _availableResources.indexWhere((r) => r.id == entry.key);
            if (recursoIndex != -1) {
              final recurso = _availableResources[recursoIndex];
              final nuevaCantidadDisponible =
                  recurso.cantidadDisponible - entry.value;
              await _resourceService.actualizarCantidadDisponible(
                entry.key,
                nuevaCantidadDisponible,
              );
            }
          }

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tarea creada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ---
  // PANTALLA COMPLETA (build) - MODIFICADO
  // ---
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String userInitial = (user?.email?[0] ?? 'U').toUpperCase();
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    // Usamos el NUEVO AppBar que coincide con la imagen
    final appBar = _buildCustomAppBar(userInitial, isDesktop);

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              _isEditMode ? 'Editar Tarea' : 'Crear Nueva Tarea',
              style: const TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.bold),
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
                        : Text(
                            _isEditMode ? 'Guardar Cambios' : 'Crear',
                            style: const TextStyle(
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
                    onPressed:
                        _isCreating ? null : () => Navigator.pop(context),
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

  /// MODIFICADO: Formulario (Panel Izquierdo)
  /// Limpiado para que solo tenga los campos de la imagen
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
              Text(
                _isEditMode ? 'Editar Tarea' : 'Crear Tarea',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      color: _fechaInicio == null ? Colors.grey : Colors.black,
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

  /// MODIFICADO: Panel de Recursos (Panel Derecho)
  /// Ahora contiene la lógica de selección, como en la imagen
  Widget _buildResourcesPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recursos',
            style: TextStyle(
                fontSize: 28,
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
                icon:
                    const Icon(Icons.person_add, color: Colors.white, size: 20),
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
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
            else if (_availableResources
                .every((r) => r.cantidadDisponible == 0))
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
                        _availableResources
                            .every((r) => r.cantidadDisponible == 0))
                    ? null
                    : _showResourceSelector,
                icon: const Icon(Icons.inventory_2,
                    color: Colors.white, size: 20),
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
} // Fin de _PantallaCrearTareaState

// ---
// WIDGET COPIADO (y corregido de tu código original)
// ---
class HoverableProfileAvatar extends StatefulWidget {
  final AuthService authService;
  final bool isAdmin;
  final String userInitial;
  final bool isDesktop;
  final Color avatarColor;

  const HoverableProfileAvatar({
    super.key,
    required this.authService,
    required this.isAdmin,
    required this.userInitial,
    required this.isDesktop,
    required this.avatarColor,
  });

  @override
  State<HoverableProfileAvatar> createState() => _HoverableProfileAvatarState();
}

class _HoverableProfileAvatarState extends State<HoverableProfileAvatar> {
  bool _isHovered = false;

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
