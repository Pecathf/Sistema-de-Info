import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sistem_proyect/central/constantes/colores.dart';
import 'package:sistem_proyect/central/constantes/modelos/usuario_model.dart';
import 'package:sistem_proyect/central/constantes/modelos/recurso_model.dart';
import 'package:sistem_proyect/central/constantes/modelos/task_model.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/tareas/taskMemberSelection.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/proyectos/resource_selection_dialog.dart';
import 'package:intl/intl.dart';

// 1. IMPORTAR EL SERVICIO DE TAREAS
import 'package:sistem_proyect/central/constantes/servicios/task.service.dart';

class TaskCreationDialog extends StatefulWidget {
  final String projectId;
  final List<Usuario> projectMembers;
  final List<RecursoMaterial> projectResources;

  const TaskCreationDialog({
    super.key,
    required this.projectId,
    required this.projectMembers,
    required this.projectResources,
  });

  @override
  State<TaskCreationDialog> createState() => _TaskCreationDialogState();
}

class _TaskCreationDialogState extends State<TaskCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  DateTime? _fechaVencimiento;
  String _prioridad = 'Media';
  List<Usuario> _selectedMembers = [];
  List<RecursoMaterial> _selectedResources = [];
  final List<String> _priorities = ['Alta', 'Media', 'Baja'];

  // 2. AÑADIR ESTADO DE CARGA
  bool _isCreating = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != _fechaVencimiento) {
      setState(() {
        _fechaVencimiento = picked;
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
      setState(() {
        _selectedMembers = result;
      });
    }
  }

  void _selectResources() async {
    final List<RecursoMaterial>? result = await showDialog(
      context: context,
      builder: (context) => ResourceSelectionDialog(
        initialSelectedResources: _selectedResources,
      ),
    );
    if (result != null) {
      setState(() {
        _selectedResources = result;
      });
    }
  }

  TaskModel _createTaskModel() {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    return TaskModel(
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      proyectoId: widget.projectId, // Usa el projectId del widget
      creadorUid: currentUserUid,
      miembrosUid: _selectedMembers.map((m) => m.uid).toList(),
      recursosAsignados: _selectedResources,
      fechaVencimiento: _fechaVencimiento,
      prioridad: _prioridad,
      fechaCreacion: DateTime.now(),
      estado: 'Pendiente',
    );
  }

  // 3. MODIFICAR _onConfirm PARA GUARDAR EN FIREBASE
  void _onConfirm() async {
    // Validar que el formulario sea correcto y no se esté creando ya una tarea
    if (_formKey.currentState!.validate() && !_isCreating) {
      setState(() {
        _isCreating = true;
      });

      try {
        // Crear el modelo
        final newTask = _createTaskModel();

        // Instanciar el servicio
        final taskService = TaskService();

        // Llamar al método para crear la tarea
        final newTaskId = await taskService.crearTarea(newTask);

        if (newTaskId != null && mounted) {
          // Mostrar mensaje de éxito (opcional, pero recomendado)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tarea creada con éxito'),
              backgroundColor: Colors.green,
            ),
          );
          // Cerrar el diálogo y DEVOLVER TRUE para que la pantalla anterior sepa
          Navigator.of(context).pop(true);
        } else {
          throw Exception('No se pudo obtener el ID de la nueva tarea.');
        }
      } catch (e) {
        // Manejar el error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al crear la tarea: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        // Asegurarse de quitar el estado de carga
        if (mounted) {
          setState(() {
            _isCreating = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear Nueva Tarea'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: ListBody(
            children: <Widget>[
              TextFormField(
                controller: _nombreController,
                decoration:
                    const InputDecoration(labelText: 'Nombre de la Tarea'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _descripcionController,
                decoration:
                    const InputDecoration(labelText: 'Descripción (Opcional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Prioridad'),
                value: _prioridad,
                items: _priorities
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _prioridad = value!;
                  });
                },
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Vencimiento (Opcional)',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _fechaVencimiento == null
                        ? 'Seleccionar fecha'
                        : DateFormat('dd/MM/yyyy').format(_fechaVencimiento!),
                    style: TextStyle(
                      color: _fechaVencimiento == null
                          ? Colors.grey
                          : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSelectionChip(
                'Miembros Asignados',
                'Asignar',
                _selectedMembers.length,
                _selectMembers,
              ),
              const SizedBox(height: 5),
              _buildMemberChips(),
              const SizedBox(height: 20),
              _buildSelectionChip(
                'Recursos Materiales',
                'Añadir',
                _selectedResources.length,
                _selectResources,
              ),
              const SizedBox(height: 5),
              _buildResourceChips(),
            ],
          ),
        ),
      ),
      // 4. ACTUALIZAR ACCIONES PARA MOSTRAR CARGA
      actions: <Widget>[
        TextButton(
          // Deshabilitar botón si se está creando
          onPressed:
              _isCreating ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          // Deshabilitar botón si se está creando
          onPressed: _isCreating ? null : _onConfirm,
          child: _isCreating
              // Mostrar un indicador de carga
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Crear Tarea'),
        ),
      ],
    );
  }

  // ... (Los métodos _build... no cambian)
  Widget _buildSelectionChip(
      String title, String actionLabel, int count, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$title ($count)',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ActionChip(
          label: Text(actionLabel, style: const TextStyle(color: Colors.white)),
          avatar: const Icon(Icons.add, color: Colors.white, size: 18),
          backgroundColor: AppColors.accentColor,
          onPressed: onTap,
        ),
      ],
    );
  }

  Widget _buildMemberChips() {
    if (_selectedMembers.isEmpty) {
      return Text('No hay miembros asignados.',
          style: TextStyle(color: Colors.grey.shade600));
    }
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: _selectedMembers
          .map((member) => Chip(
                label: Text(
                    member.nombre.isNotEmpty ? member.nombre : member.email),
                onDeleted: () {
                  setState(() {
                    _selectedMembers.removeWhere((m) => m.uid == member.uid);
                  });
                },
              ))
          .toList(),
    );
  }

  Widget _buildResourceChips() {
    if (_selectedResources.isEmpty) {
      return Text('No hay recursos asignados.',
          style: TextStyle(color: Colors.grey.shade600));
    }
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: _selectedResources
          .map((resource) => Chip(
                avatar: Text(resource.icono),
                label: Text('${resource.nombre} (${resource.cantidad})'),
                onDeleted: () {
                  setState(() {
                    _selectedResources.removeWhere((r) => r.id == resource.id);
                  });
                },
              ))
          .toList(),
    );
  }
}
