// Archivo: pantalla_crear_proyecto.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
// Ajusta las rutas según donde tengas estos archivos
import 'package:sistem_proyect/central/constantes/colores.dart'; 
import 'package:sistem_proyect/central/constantes/servicios/user_data_service.dart'; 
import 'package:sistem_proyect/central/constantes/modelos/usuario_model.dart';
import 'package:sistem_proyect/central/constantes/servicios/project_service.dart';
import 'package:sistem_proyect/central/constantes/modelos/project_model.dart'; 


class PantallaCrearProyecto extends StatefulWidget {
  const PantallaCrearProyecto({super.key});

  @override
  State<PantallaCrearProyecto> createState() => _PantallaCrearProyectoState();
}

class _PantallaCrearProyectoState extends State<PantallaCrearProyecto> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  
  // 🎯 NUEVO CONTROLADOR PARA RECURSOS
  final TextEditingController _recursosController = TextEditingController();
  
  String _estadoSeleccionado = 'Pendiente';

  final List<String> _estadosDisponibles = ['Pendiente', 'Activo', 'Completado', 'En Pausa'];
  
  // Servicios necesarios
  final UserDataService _userDataService = UserDataService();
  final ProjectService _projectService = ProjectService(); 
  
  // 🎯 CAMBIO CLAVE: Lista de UIDs seleccionados para multi-miembro
  List<String> _miembrosSeleccionadosUid = []; 
  
  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _recursosController.dispose();
    super.dispose();
  }

  Future<void> _guardarProyecto() async {
    if (!_formKey.currentState!.validate()) return;
      
    try {
        // 1. Prepara la lista de recursos (limpiando espacios)
        final recursosList = _recursosController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        // 2. Crea el objeto Proyecto con el modelo actualizado
        final nuevoProyecto = Proyecto(
            nombre: _nombreController.text.trim(),
            descripcion: _descripcionController.text.trim(),
            estado: _estadoSeleccionado,
            fechaCreacion: DateTime.now(), 
            miembrosUid: _miembrosSeleccionadosUid, 
            recursos: recursosList,
        );
        
        // 3. Usa el servicio de proyectos (solo el Admin podrá hacerlo por la regla de seguridad)
        await _projectService.crearProyecto(nuevoProyecto);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proyecto creado y asignado con éxito!')),
        );
        Navigator.of(context).pop();
    } on Exception catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear el proyecto: ${e.toString()}. (Si no eres Admin, este es el error esperado)')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Nuevo Proyecto')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  _nombreController, 
                  'Nombre del Proyecto', 
                  'Ingrese un nombre para el proyecto'
                ),
                const SizedBox(height: 15),
                _buildTextArea(
                  _descripcionController, 
                  'Descripción', 
                  'Detalles del proyecto', 
                  maxLines: 4
                ),
                const SizedBox(height: 15),

                // 🎯 CAMPO DE RECURSOS
                _buildRecursosField(),
                const SizedBox(height: 30),
                
                // 🎯 CAMPO DE SELECCIÓN MÚLTIPLE DE MIEMBROS (RESOLVIENDO ERROR)
                const Text(
                  'Miembros Asignados', 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
                const SizedBox(height: 10),
                _buildUserAssignmentField(), // ⬅️ Este método ahora está definido
                
                const SizedBox(height: 30),

                _buildEstadoDropdown(),

                const SizedBox(height: 40),

                // Botón Guardar Proyecto
                ElevatedButton(
                  onPressed: _guardarProyecto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF6633), // AppColors.primaryOrange
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Guardar Proyecto', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // =========================================================
  // ✅ WIDGETS AUXILIARES (DEFINIDOS DENTRO DE LA CLASE)
  // =========================================================
  
  // 1. Función para el campo de asignación de miembros
  Widget _buildUserAssignmentField() {
    return StreamBuilder<List<Usuario>>(
      stream: _userDataService.getAllUsuariosStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error al cargar usuarios: ${snapshot.error}', 
                      style: const TextStyle(color: Colors.red));
        }
        final usuarios = snapshot.data ?? [];
        final usuarioMap = {for (var user in usuarios) user.uid: user.nombre};
        
        return FormField<List<String>>(
          initialValue: _miembrosSeleccionadosUid,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Debe asignar al menos un miembro al proyecto.';
            }
            return null;
          },
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputDecorator(
                  decoration: _buildInputDecoration('Seleccionar Miembros'),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _miembrosSeleccionadosUid.isEmpty
                            ? 'Seleccionar Miembros'
                            : 'Seleccionados: ${_miembrosSeleccionadosUid.length}',
                          style: TextStyle(color: _miembrosSeleccionadosUid.isEmpty ? Colors.grey : Colors.black),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.group_add),
                        onPressed: () async {
                          final List<String>? selected = await showDialog<List<String>>(
                            context: context,
                            builder: (context) => _buildMultiSelectDialog(usuarios),
                          );

                          if (selected != null) {
                            setState(() {
                              _miembrosSeleccionadosUid = selected;
                              field.didChange(selected);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                if (_miembrosSeleccionadosUid.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Miembros: ${_miembrosSeleccionadosUid.map((uid) => usuarioMap[uid] ?? 'Desconocido').join(', ')}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                if (field.hasError) 
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      field.errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
  
  // 2. Función para el diálogo Multi-Select
  Widget _buildMultiSelectDialog(List<Usuario> usuarios) {
    final Set<String> tempSelected = Set.from(_miembrosSeleccionadosUid);
    
    return AlertDialog(
      title: const Text('Seleccionar Miembros'),
      content: SingleChildScrollView(
        child: Column(
          children: usuarios.map((user) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return CheckboxListTile(
                  title: Text(user.nombre),
                  subtitle: Text(user.email),
                  value: tempSelected.contains(user.uid),
                  onChanged: (bool? isSelected) {
                    setState(() {
                      if (isSelected ?? false) {
                        tempSelected.add(user.uid);
                      } else {
                        tempSelected.remove(user.uid);
                      }
                    });
                  },
                );
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), 
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(tempSelected.toList()),
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  // 3. Función para el campo de Recursos
  Widget _buildRecursosField() {
    return TextFormField(
      controller: _recursosController,
      decoration: _buildInputDecoration('Recursos (URLs, documentos)').copyWith(
        hintText: 'Separe los recursos con comas (Ej: url1, url2, nombre_doc3)',
      ),
      maxLines: 3,
    );
  }
  
  // 4. Función para campo de texto simple
  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return TextFormField(
      controller: controller,
      decoration: _buildInputDecoration(hint),
      validator: (value) {
        if (value == null || value.isEmpty) return 'El campo $label es obligatorio.';
        return null;
      },
    );
  }
  
  // 5. Función para campo de área de texto
  Widget _buildTextArea(TextEditingController controller, String label, String hint, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: _buildInputDecoration(hint),
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) return 'El campo $label es obligatorio.';
        return null;
      },
    );
  }

  // 6. Función para el Dropdown de Estado
  Widget _buildEstadoDropdown() {
    return DropdownButtonFormField<String>(
      value: _estadoSeleccionado,
      decoration: _buildInputDecoration('Estado'),
      isExpanded: true,
      items: _estadosDisponibles.map((estado) {
        return DropdownMenuItem<String>(
          value: estado,
          child: Text(estado),
        );
      }).toList(),
      onChanged: (String? nuevoEstado) {
        setState(() {
          _estadoSeleccionado = nuevoEstado ?? 'Pendiente';
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) return 'Debe seleccionar un estado.';
        return null;
      },
    );
  }
  
  // 7. Función para la decoración de Input
  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFF6633), width: 2), // AppColors.primaryOrange
      ),
    );
  }
}