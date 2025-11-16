// Archivo: funcionalidades/Pantallas/proyectos/task_member_selection_dialog.dart

import 'package:flutter/material.dart';
import 'package:sistem_proyect/central/constantes/modelos/usuario_model.dart';

class TaskMemberSelectionDialog extends StatefulWidget {
  final List<Usuario> initialSelectedMembers;
  // ✅ NUEVO: La lista de usuarios disponibles (los miembros del proyecto)
  final List<Usuario> availableUsers;

  const TaskMemberSelectionDialog({
    super.key,
    required this.initialSelectedMembers,
    required this.availableUsers,
  });

  @override
  State<TaskMemberSelectionDialog> createState() =>
      _TaskMemberSelectionDialogState();
}

class _TaskMemberSelectionDialogState extends State<TaskMemberSelectionDialog> {
  late List<Usuario> _selectedMembers;

  @override
  void initState() {
    super.initState();
    _selectedMembers = List.from(widget.initialSelectedMembers);
  }

  void _toggleMemberSelection(Usuario user) {
    setState(() {
      if (_selectedMembers.any((m) => m.uid == user.uid)) {
        _selectedMembers.removeWhere((m) => m.uid == user.uid);
      } else {
        _selectedMembers.add(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final users = widget.availableUsers;

    return AlertDialog(
      title: const Text('Seleccionar Miembros de Tarea'),
      content: SizedBox(
        width: double.maxFinite,
        child: users.isEmpty
            ? const Center(child: Text('No hay miembros en el proyecto.'))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final isSelected =
                      _selectedMembers.any((m) => m.uid == user.uid);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected ? Colors.orange : Colors.grey,
                      child: Text(
                        user.nombre.isNotEmpty
                            ? user.nombre[0].toUpperCase()
                            : (user.email.isNotEmpty
                                ? user.email[0].toUpperCase()
                                : '?'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title:
                        Text(user.nombre.isNotEmpty ? user.nombre : user.email),
                    subtitle: Text(user.email),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.circle_outlined, color: Colors.grey),
                    onTap: () => _toggleMemberSelection(user),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedMembers);
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
