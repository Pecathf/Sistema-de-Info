import 'package:flutter/material.dart';
// Ajusta las rutas según donde tengas estos archivos
import 'package:sistem_proyect/central/constantes/servicios/user_data_service.dart'; 
import 'package:sistem_proyect/central/constantes/modelos/project_model.dart'; 
import 'pantalla_crear_proyecto.dart'; // Importación de la pantalla de creación
// Asumo que AppColors se encuentra aquí
import 'package:sistem_proyect/central/constantes/colores.dart'; 

class PantallaListadoProyectos extends StatefulWidget {
  const PantallaListadoProyectos({super.key});

  @override
  State<PantallaListadoProyectos> createState() => _PantallaListadoProyectosState();
}

class _PantallaListadoProyectosState extends State<PantallaListadoProyectos> {
  // Instanciamos el servicio para la interacción con los datos
  // **RECUERDA:** UserDataService debe obtener el ID del usuario real para funcionar correctamente.
  final UserDataService _userDataService = UserDataService(); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Listado de Proyectos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryOrange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      
      // StreamBuilder para escuchar los cambios en los proyectos desde Firestore
      body: StreamBuilder<List<Proyecto>>(
        stream: _userDataService.getProyectosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            // Muestra el error de Firebase/Firestore si ocurre
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error al cargar los proyectos: ${snapshot.error.toString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final proyectos = snapshot.data;

          if (proyectos == null || proyectos.isEmpty) {
            // Estado si no hay proyectos
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('Aún no tienes proyectos creados.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 20),
                ],
              ),
            );
          }

          // Si hay datos, mostramos la lista
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: proyectos.length,
            itemBuilder: (context, index) {
              final proyecto = proyectos[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.workspaces_filled, color: AppColors.primaryOrange),
                  title: Text(proyecto.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  // Mostramos la descripción y la fecha de creación formateada
                  subtitle: Text(
                    '${proyecto.descripcion}\nEstado: ${proyecto.estado} - Creado: ${_formatDate(proyecto.fechaCreacion)}',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  isThreeLine: true,
                  onTap: () {
                    // TODO: Implementar navegación a la Pantalla de Detalle del Proyecto
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaDetalleProyecto(proyecto: proyecto)));
                  },
                ),
              );
            },
          );
        },
      ),

      // Botón flotante para crear un nuevo proyecto
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 🚀 NAVEGACIÓN ACTIVA a la PantallaCrearProyecto
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PantallaCrearProyecto(),
            ),
          );
        },
        backgroundColor: AppColors.primaryOrange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Función auxiliar para formatear la fecha
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}