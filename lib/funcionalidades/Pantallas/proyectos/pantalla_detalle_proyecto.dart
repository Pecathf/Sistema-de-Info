// Archivo: pantalla_detalle_proyecto.dart

import 'package:flutter/material.dart';
import 'package:sistem_proyect/central/constantes/modelos/project_model.dart';
import 'package:sistem_proyect/central/constantes/modelos/usuario_model.dart';
import 'package:sistem_proyect/central/constantes/servicios/project_service.dart';
import 'package:sistem_proyect/central/constantes/servicios/user_data_service.dart';
import 'package:sistem_proyect/central/constantes/colores.dart';
import 'package:intl/intl.dart'; // Para el formato de fecha
import 'package:sistem_proyect/funcionalidades/Pantallas/widgets/shared_footer_widget.dart'; 

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
  
  Proyecto? _proyecto;
  List<Usuario> _miembros = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarDatosProyecto();
  }

  // 1. Carga el proyecto y sus miembros
  Future<void> _cargarDatosProyecto() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final proyecto =
          await _projectService.getProyectoById(widget.projectId);

      if (proyecto != null) {
        final miembrosUids = proyecto.miembrosUid.where((uid) => uid.isNotEmpty).toList(); 

        final miembros =
            await _userDataService.getUsuariosByIds(miembrosUids);
        
        setState(() {
          _proyecto = proyecto;
          _miembros = miembros;
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

  // 2. Formato de fecha
  String _formatDate(DateTime date) {
    return DateFormat('d MMM, y').format(date);
  }

  // 3. Etiqueta de Estado (Badge)
  Widget _buildStatusBadge(String estado) {
    Color color;
    switch (estado.toLowerCase()) {
      case 'activo': color = Colors.blue.shade700; break;
      case 'completado': color = Colors.green.shade700; break;
      case 'en pausa': color = Colors.orange.shade700; break;
      case 'pendiente': default: color = Colors.red.shade700; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        estado.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  // 4. Barra de Progreso Detallada
  Widget _buildDetailedProgressBar(int progreso) {
    const Color primaryColor = AppColors.primaryOrange;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso del Proyecto',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              '$progreso%',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progreso / 100,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
            minHeight: 12,
          ),
        ),
      ],
    );
  }

  // 5. Botones de Acción (Editar/Eliminar)
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Botón Eliminar
        OutlinedButton.icon(
          icon: const Icon(Icons.delete, color: Colors.red),
          label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          onPressed: () {
            // TODO: Implementar lógica de eliminación con confirmación
            print('Eliminar proyecto ${_proyecto!.nombre}');
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
        const SizedBox(width: 15),
        // Botón Editar
        ElevatedButton.icon(
          icon: const Icon(Icons.edit, color: Colors.white),
          label: const Text('Editar Proyecto', style: TextStyle(color: Colors.white)),
          onPressed: () {
            // TODO: Navegar a la pantalla de edición, posiblemente reutilizando PantallaCrearProyecto
            print('Editar proyecto ${_proyecto!.nombre}');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryOrange,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  // 6. Sección de Miembros
  Widget _buildMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Miembros del Equipo (${_miembros.length})'),
        const SizedBox(height: 15),
        Wrap(
          spacing: 15.0, 
          runSpacing: 15.0,
          children: _miembros.map((member) {
            String initial = member.nombre.isNotEmpty ? member.nombre[0].toUpperCase() : (member.email.isNotEmpty ? member.email[0].toUpperCase() : '?');

            return Tooltip(
              message: member.nombre.isNotEmpty ? member.nombre : member.email,
              child: Row(
                mainAxisSize: MainAxisSize.min, 
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.accentColor,
                    child: Text(
                      initial,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    member.nombre.isNotEmpty ? member.nombre : member.email,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 7. Sección de Gestión de Tareas (Única columna para el diseño)
  Widget _buildTaskManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Tareas del Proyecto'),
            // BOTÓN DE CREAR TAREA
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navegar a PantallaCrearTarea
                print('Navegar a crear tarea para ${_proyecto!.id}');
              },
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              label: const Text('Crear Tarea',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor, 
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // BARRA DE PROGRESO RELACIONADA CON LAS TAREAS
        _buildDetailedProgressBar(_proyecto!.progreso), 
        
        const SizedBox(height: 30),
        
        // TODO: Aquí irá el Widget de Listado de Tareas
        Text(
          'Aquí se mostrará el listado de tareas que determinan el progreso...',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // 8. Contenido de la Columna Izquierda (Descripción, Fechas, Recursos)
  Widget _buildLeftColumnContent(Proyecto proyecto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sección de Descripción
        _buildSectionTitle('Descripción del Proyecto'),
        const SizedBox(height: 10),
        Text(
          proyecto.descripcion,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Colors.grey.shade700,
          ),
        ),
        
        const SizedBox(height: 30),
        const Divider(height: 1, color: AppColors.lightGrey),
        const SizedBox(height: 30),

        // Sección de Fechas
        _buildSectionTitle('Fechas Clave'),
        const SizedBox(height: 10),
        Wrap( 
          spacing: 50.0,
          runSpacing: 20.0,
          children: [
            _buildInfoItem(Icons.date_range, 'Fecha de Inicio', _formatDate(proyecto.fechaInicio)),
            _buildInfoItem(Icons.calendar_today, 'Fecha Límite', _formatDate(proyecto.fechaLimite)),
          ],
        ),

        const SizedBox(height: 30),
        const Divider(height: 1, color: AppColors.lightGrey),
        const SizedBox(height: 30),

        // Sección de Recursos
        _buildSectionTitle('Recursos Materiales'),
        const SizedBox(height: 10),
        ...proyecto.recursosMateriales.where((r) => r.trim().isNotEmpty).map((recurso) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              const Icon(Icons.check_box, size: 18, color: AppColors.accentColor),
              const SizedBox(width: 10),
              Flexible(child: Text(recurso, style: TextStyle(fontSize: 15, color: Colors.grey.shade700))),
            ],
          ),
        )).toList(),
        
        if (proyecto.recursosMateriales.isEmpty)
          Text('No hay recursos materiales asignados.', style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }

  // 9. Estructura principal
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
          child: Text(_errorMessage ?? 'El proyecto solicitado no existe.', 
              style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    final proyecto = _proyecto!; 

    return LayoutBuilder(
      builder: (context, constraints) {
        // Se considera desktop o tablet si el ancho es >= 800
        final bool isDesktop = constraints.maxWidth > 800; 

        return Scaffold(
          backgroundColor: Colors.grey[50], 
          appBar: AppBar(
            title: Text(proyecto.nombre, style: const TextStyle(color: AppColors.darkBackground)),
            backgroundColor: Colors.white,
            elevation: 1,
            iconTheme: const IconThemeData(color: AppColors.darkBackground),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.zero, 
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(isDesktop ? 40.0 : 20.0),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Fila superior: Título y Botones (Siempre)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  proyecto.nombre,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkBackground,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              _buildActionButtons(),
                            ],
                          ),
                          
                          const SizedBox(height: 10),
                          
                          // 2. Subtítulo/Estado (Siempre)
                          _buildStatusBadge(proyecto.estado),
                          
                          const Divider(height: 40, color: AppColors.lightGrey),

                          // 3. Sección de Tareas (Siempre, ocupa todo el ancho)
                          _buildTaskManagementSection(),
                          
                          const Divider(height: 40, color: AppColors.lightGrey),
                          
                          // 4. Contenido Principal: Columna simple (Móvil) o Row de dos columnas (Desktop)
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Columna Izquierda: Descripción, Fechas, Recursos
                                Expanded(
                                  flex: 2, 
                                  child: _buildLeftColumnContent(proyecto),
                                ),
                                const SizedBox(width: 40),
                                // Columna Derecha: Miembros
                                Expanded(
                                  flex: 1,
                                  child: _buildMembersSection(),
                                ),
                              ],
                            )
                          else
                            // Diseño de una sola columna para móvil
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLeftColumnContent(proyecto),
                                const SizedBox(height: 30),
                                _buildMembersSection(),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // FOOTER COMPARTIDO
                SharedFooter(
                    primaryOrange: AppColors.primaryOrange,
                    accentBlue: AppColors.accentColor),
              ],
            ),
          ),
        );
      }
    );
  }
  
  // Widget auxiliar para títulos de sección
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.darkBackground,
      ),
    );
  }

  // Widget auxiliar para elementos de información clave
  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primaryOrange),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkBackground,
          ),
        ),
      ],
    );
  }
}