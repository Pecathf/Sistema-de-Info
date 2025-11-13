import 'package:flutter/material.dart';
import 'package:sistem_proyect/central/constantes/modelos/project_model.dart';
import 'package:sistem_proyect/central/constantes/modelos/usuario_model.dart';
import 'package:sistem_proyect/central/constantes/servicios/project_service.dart';
import 'package:sistem_proyect/central/constantes/servicios/user_data_service.dart';
import 'package:sistem_proyect/central/constantes/colores.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
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

  // Carga el proyecto y sus miembros
  Future<void> _cargarDatosProyecto() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final proyecto = await _projectService.getProyectoById(widget.projectId);

      if (proyecto != null) {
        final miembrosUids =
            proyecto.miembrosUid.where((uid) => uid.isNotEmpty).toList();

        final miembros = await _userDataService.getUsuariosByIds(miembrosUids);

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

  String _formatDate(DateTime date) {
    return DateFormat('d MMM, y').format(date);
  }

  Widget _buildStatusBadge(String estado) {
    Color color;
    switch (estado.toLowerCase()) {
      case 'activo':
        color = Colors.green.shade700;
        break;
      case 'completado':
        color = Colors.blue.shade700;
        break;
      case 'pendiente':
      default:
        color = Colors.red.shade700;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
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
            String initial = member.nombre.isNotEmpty
                ? member.nombre[0].toUpperCase()
                : (member.email.isNotEmpty
                    ? member.email[0].toUpperCase()
                    : '?');

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
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
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

  Widget _buildTaskManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Tareas del Proyecto'),
            ElevatedButton.icon(
              onPressed: () {
                developer.log('Navegar a crear tarea para ${_proyecto!.id}',
                    name: 'PantallaDetalleProyecto.action');
              },
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              label: const Text('Crear Tarea',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildDetailedProgressBar(_proyecto!.progreso),

        const SizedBox(height: 30),

        Text(
          'Aquí se mostrará el listado de tareas que determinan el progreso...',
          style: TextStyle(
              fontStyle: FontStyle.italic, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildLeftColumnContent(Proyecto proyecto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

        _buildSectionTitle('Fechas Clave'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 50.0,
          runSpacing: 20.0,
          children: [
            _buildInfoItem(Icons.date_range, 'Fecha de Inicio',
                _formatDate(proyecto.fechaInicio)),
            _buildInfoItem(Icons.calendar_today, 'Fecha Límite',
                _formatDate(proyecto.fechaLimite)),
          ],
        ),

        const SizedBox(height: 30),
        const Divider(height: 1, color: AppColors.lightGrey),
        const SizedBox(height: 30),

        // SECCIÓN DE RECURSOS MATERIALES
        _buildSectionTitle('Recursos Materiales (${proyecto.recursosMateriales.length})'),
        const SizedBox(height: 15),
        
        if (proyecto.recursosMateriales.isNotEmpty)
          ...proyecto.recursosMateriales.map((recurso) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  // Emoticon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        recurso.icono,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Información del recurso
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recurso.nombre,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.inventory, 
                              size: 16, 
                              color: Colors.grey.shade600
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Cantidad disponible: ${recurso.cantidad}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ))
        else
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey.shade500),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No hay recursos materiales asignados a este proyecto.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

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

    return LayoutBuilder(builder: (context, constraints) {
      final bool isDesktop = constraints.maxWidth > 800;

      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(proyecto.nombre,
              style: const TextStyle(color: AppColors.darkBackground)),
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
                          color: Colors.grey.withValues(alpha: 0.15),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título y estado
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
                            _buildStatusBadge(proyecto.estado),
                          ],
                        ),

                        const Divider(height: 40, color: AppColors.lightGrey),

                        _buildTaskManagementSection(),

                        const Divider(height: 40, color: AppColors.lightGrey),

                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildLeftColumnContent(proyecto),
                              ),
                              const SizedBox(width: 40),
                              Expanded(
                                flex: 1,
                                child: _buildMembersSection(),
                              ),
                            ],
                          )
                        else
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

              SharedFooter(
                  primaryOrange: AppColors.primaryOrange,
                  accentBlue: AppColors.accentColor),
            ],
          ),
        ),
      );
    });
  }

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