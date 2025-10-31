import 'package:flutter/material.dart';
// Asumo que AppColors está aquí, ajusta la importación si es necesario
import 'package:sistem_proyect/central/constantes/colores.dart'; 
// import 'servicios/user_data_service.dart'; 
// import 'modelos/proyectos_model.dart'; 

class PantallaCrearProyecto extends StatefulWidget {
  const PantallaCrearProyecto({super.key});

  @override
  State<PantallaCrearProyecto> createState() => _PantallaCrearProyectoState();
}

class _PantallaCrearProyectoState extends State<PantallaCrearProyecto> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  String _estadoSeleccionado = 'Pendiente';

  final List<String> _estadosDisponibles = ['Pendiente', 'Activo', 'Completado', 'En Pausa'];
  
  void _guardarProyecto() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implementar la lógica de guardado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guardando nuevo proyecto... (Lógica pendiente)')),
      );
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final padding = isDesktop ? 60.0 : 20.0;
    final formWidth = isDesktop ? 600.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crear Nuevo Proyecto',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryOrange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 30),
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: formWidth),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nombre del Proyecto', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 8),
                  // Campo Nombre
                  TextFormField(
                    controller: _nombreController,
                    decoration: _buildInputDecoration('Ej: Sistema de Gestión V2'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese el nombre del proyecto.';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),

                  const Text('Descripción', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 8),
                  // Campo Descripción
                  TextFormField(
                    controller: _descripcionController,
                    maxLines: 4,
                    decoration: _buildInputDecoration('Detalles, objetivos, y requisitos...'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La descripción es obligatoria.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),
                  
                  // ❌ ELIMINAMOS LA ETIQUETA 'Estado Inicial'

                  // ✅ INICIO: Selector de Estado con estilo de campo de texto
                  Container(
                    // Aquí usamos el estilo que se asemeja al TextFormField
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _estadoSeleccionado,
                      // Usamos un InputDecoration simplificado para que parezca un TextFormField
                      decoration: _buildInputDecoration('Estado Inicial'), // Usamos la misma función auxiliar
                      isExpanded: true,
                      items: _estadosDisponibles.map((String estado) {
                        return DropdownMenuItem<String>(
                          value: estado,
                          child: Text(estado),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _estadoSeleccionado = newValue!;
                        });
                      },
                    ),
                  ),
                  // ✅ FIN: Selector de Estado

                  // TODO: Agregar campos adicionales como 'Asignar Miembros' si es necesario.
                  
                  const SizedBox(height: 40),

                  // Botón Guardar Proyecto
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _guardarProyecto,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Guardar Proyecto',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Función auxiliar para el estilo de los campos de texto y Dropdown
  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: AppColors.lightBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.transparent), // Transparente para usar el Container border
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryOrange, width: 2),
      ),
    );
  }
}