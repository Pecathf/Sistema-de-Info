import 'package:flutter/material.dart';
import 'package:sistem_proyect/central/constantes/modelos/usuario_model.dart';
import 'package:sistem_proyect/central/constantes/servicios/user_data_service.dart';

class MemberSelectionDialog extends StatefulWidget {
  final UserDataService userDataService;
  final List<Usuario> initialSelectedMembers;

  const MemberSelectionDialog({
    super.key,
    required this.userDataService,
    required this.initialSelectedMembers,
  });

  @override
  State<MemberSelectionDialog> createState() => _MemberSelectionDialogState();
}

class _MemberSelectionDialogState extends State<MemberSelectionDialog> {
  late List<Usuario> _selectedMembers;

  @override
  void initState() {
    super.initState();
    // Inicializa la lista de miembros seleccionados con la lista inicial
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
    return AlertDialog(
      title: const Text('Seleccionar Miembros'),
      content: SizedBox(
        width: double.maxFinite,
        // Escucha el stream de todos los usuarios
        child: StreamBuilder<List<Usuario>>(
          stream: widget.userDataService.getAllUsuariosStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No hay usuarios registrados.'));
            }

            final users = snapshot.data!;

            return ListView.builder(
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
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Cierra el diálogo sin guardar cambios (retorna null)
            Navigator.of(context).pop(null);
          },
          child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: () {
            // Cierra el diálogo y retorna la lista de miembros seleccionados
            Navigator.of(context).pop(_selectedMembers);
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
