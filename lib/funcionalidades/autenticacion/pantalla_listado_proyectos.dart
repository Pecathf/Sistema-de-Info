// Archivo: pantalla_listado_proyectos.dart

import 'package:flutter/material.dart';
// Asegúrate de que todas estas rutas sean correctas
import 'package:sistem_proyect/central/constantes/modelos/project_model.dart'; 
import 'pantalla_crear_proyecto.dart'; 
import 'package:sistem_proyect/central/constantes/colores.dart'; // Asumiendo que AppColors está aquí
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart'; 
import 'package:sistem_proyect/central/constantes/servicios/project_service.dart'; 


class PantallaListadoProyectos extends StatefulWidget {
  const PantallaListadoProyectos({super.key});

  @override
  State<PantallaListadoProyectos> createState() => _PantallaListadoProyectosState();
}

class _PantallaListadoProyectosState extends State<PantallaListadoProyectos> {
  final ProjectService _projectService = ProjectService();
  final AuthService _authService = AuthService();
  
  bool _isAdmin = false;
  bool _isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    _checkIfAdmin(); 
  }

  // Función para verificar el rol
  Future<void> _checkIfAdmin() async {
    final isAdmin = await _authService.isAdmin();
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
        _isLoadingRole = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de Proyectos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        // Usando AppColors de tu archivo widgets_principal.dart
        backgroundColor: Color(0xFFFF6633), 
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      
      body: _isLoadingRole
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Proyecto>>(
              // 🎯 Usa ProjectService, que ya incluye el filtro de admin
              stream: _projectService.getProyectosStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Error al cargar proyectos: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
                final proyectos = snapshot.data ?? [];
                
                if (proyectos.isEmpty && !_isAdmin) {
                    return const Center(
                        child: Text('Solo el Administrador tiene permiso para ver y crear proyectos.', style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center,),
                    );
                }
                if (proyectos.isEmpty && _isAdmin) {
                    return const Center(
                        child: Text('No hay proyectos creados.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    );
                }

                return ListView.builder(
                  itemCount: proyectos.length,
                  itemBuilder: (context, index) {
                    final proyecto = proyectos[index];
                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                      child: ListTile(
                        title: Text(proyecto.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${proyecto.descripcion}\nEstado: ${proyecto.estado} - Creado: ${_formatDate(proyecto.fechaCreacion)}',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        isThreeLine: true,
                        onTap: () {
                          // Implementar navegación a detalle (solo el admin podrá leer)
                        },
                      ),
                    );
                  },
                );
              },
            ),

      // 🎯 Botón flotante CONDICIONAL
      floatingActionButton: _isLoadingRole
          ? null
          : _isAdmin
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PantallaCrearProyecto(),
                      ),
                    );
                  },
                  backgroundColor: Color(0xFFFF6633), // AppColors.primaryOrange
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null, 
    );
  }
}