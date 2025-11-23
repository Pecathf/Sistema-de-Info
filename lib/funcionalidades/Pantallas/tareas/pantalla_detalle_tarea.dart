import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_proyect/central/constantes/modelos/task_model.dart';
import 'package:sistem_proyect/central/constantes/modelos/usuario_model.dart';
import 'package:sistem_proyect/central/constantes/servicios/user_data_service.dart';
import 'package:sistem_proyect/central/constantes/servicios/task_service.dart';
import 'package:sistem_proyect/central/constantes/colores.dart';
import 'package:intl/intl.dart';
import 'package:sistem_proyect/central/constantes/servicios/project_service.dart';

class PantallaDetalleTarea extends StatefulWidget {
  final TaskModel tarea;

  const PantallaDetalleTarea({
    super.key,
    required this.tarea,
  });

  @override
  State<PantallaDetalleTarea> createState() => _PantallaDetalleTareaState();
}

class _PantallaDetalleTareaState extends State<PantallaDetalleTarea> {
  final UserDataService _userDataService = UserDataService();
  final TaskService _taskService = TaskService();
  final ProjectService _projectService = ProjectService();
  // Controlador para escribir comentarios
  final TextEditingController _commentController = TextEditingController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  List<Usuario> _miembros = [];
  bool _isLoading = true;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.tarea.estado;
    _cargarMiembros();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _cargarMiembros() async {
    setState(() => _isLoading = true);
    try {
      final miembrosUids =
          widget.tarea.miembrosUid.where((uid) => uid.isNotEmpty).toList();
      final miembros = await _userDataService.getUsuariosByIds(miembrosUids);
      if (mounted) {
        setState(() {
          _miembros = miembros;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _miembros = [];
          _isLoading = false;
        });
      }
    }
  }

  // Función para enviar comentario
  Future<void> _enviarComentario() async {
    final texto = _commentController.text.trim();
    if (texto.isEmpty) return;

    try {
      String nombreAutor =
          _currentUser?.displayName ?? _currentUser?.email ?? 'Usuario';

      await _taskService.addComment(
          widget.tarea.id, texto, _currentUser?.uid ?? '', nombreAutor);

      if (!mounted) return;

      _commentController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al enviar: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      await _taskService.updateTaskStatus(
          widget.tarea.id, widget.tarea.proyectoId, newStatus);
      final user = FirebaseAuth.instance.currentUser;
      final userName = user?.displayName ?? user?.email ?? 'Usuario';
      await _projectService.registrarHistorial(widget.tarea.proyectoId,
          'Cambió estado de "${widget.tarea.nombre}" a $newStatus', userName);

      if (mounted) {
        setState(() {
          _currentStatus = newStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado actualizado a $newStatus'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al actualizar: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No definida';
    return DateFormat('d MMM, y').format(date);
  }

  // Formato para fecha de comentario
  String _formatCommentDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Ahora';
    return DateFormat('d MMM HH:mm').format(timestamp.toDate());
  }

  Color _getPriorityColor(String prioridad) {
    switch (prioridad.toLowerCase()) {
      case 'alta':
        return AppColors.prioridadAlta;
      case 'media':
        return AppColors.prioridadMedia;
      case 'baja':
        return AppColors.prioridadBaja;
      default:
        return Colors.grey.shade400;
    }
  }

  Color _getStatusColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'completada':
        return AppColors.estadoCompletado;
      case 'en progreso':
        return AppColors.estadoEnProgreso;
      case 'pendiente':
        return AppColors.estadoActivo;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cargando...'),
          backgroundColor: Colors.white,
          elevation: 0.5,
        ),
        body: const Center(
            child: CircularProgressIndicator(color: AppColors.primaryOrange)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkBackground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.tarea.nombre,
          style: const TextStyle(
              color: AppColors.darkBackground,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.tarea.nombre,
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBackground),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(_currentStatus)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _getStatusColor(_currentStatus), width: 1),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _currentStatus,
                        icon: Icon(Icons.arrow_drop_down,
                            color: _getStatusColor(_currentStatus)),
                        isDense: true,
                        style: TextStyle(
                            color: _getStatusColor(_currentStatus),
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                        dropdownColor: Colors.white,
                        items: [
                          DropdownMenuItem(
                            value: 'Pendiente',
                            child: Text(
                              'PENDIENTE',
                              style: TextStyle(
                                color: AppColors.estadoActivo,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'En Progreso',
                            child: Text(
                              'EN PROGRESO',
                              style: TextStyle(
                                color: AppColors.estadoEnProgreso,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Completada',
                            child: Text(
                              'COMPLETADA',
                              style: TextStyle(
                                color: AppColors.estadoCompletado,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (v) => (v != null && v != _currentStatus)
                            ? _updateStatus(v)
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.tarea.descripcion.isNotEmpty
                    ? widget.tarea.descripcion
                    : 'Sin descripción',
                style: TextStyle(
                    fontSize: 15, color: Colors.grey.shade700, height: 1.5),
              ),
              const SizedBox(height: 30),
              _buildInfoCards(),
              const SizedBox(height: 30),
              _buildDatesAndPriority(),
              const SizedBox(height: 30),
              _buildResourcesSection(),
              const SizedBox(height: 30),
              _buildMembersSection(),
              const SizedBox(height: 30),
              _buildCommentsSection(),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                  child: const Text('Volver',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- COMENTARIOS ---
  Widget _buildCommentsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.comment, size: 22, color: AppColors.primaryOrange),
              const SizedBox(width: 8),
              const Text(
                'Comentarios',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBackground),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Lista de comentarios en tiempo real
          StreamBuilder<QuerySnapshot>(
            stream: _taskService.getCommentsStream(widget.tarea.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Text('Error al cargar.');
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'No hay comentarios. ¡Sé el primero!',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final autor = data['autorNombre'] ?? 'Usuario';
                  final texto = data['texto'] ?? '';
                  final fecha = data['fecha'] as Timestamp?;
                  final esMio = data['autorId'] == _currentUser?.uid;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: esMio
                            ? AppColors.primaryOrange
                            : Colors.grey.shade300,
                        child: Text(
                          autor.isNotEmpty ? autor[0].toUpperCase() : '?',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(esMio ? 'Tú' : autor,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                                Text(_formatCommentDate(fecha),
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(texto,
                                style: TextStyle(
                                    color: Colors.grey.shade800, fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),

          // Input para escribir
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Escribe un comentario...',
                    hintStyle:
                        TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  minLines: 1,
                  maxLines: 3,
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: AppColors.primaryOrange,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  onPressed: _enviarComentario,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE INFORMACIÓN ---

  Widget _buildInfoCards() {
    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth > 800;
      List<Widget> cards = [
        _buildInfoCard(
            label: 'PRIORIDAD',
            value: widget.tarea.prioridad,
            color: _getPriorityColor(widget.tarea.prioridad)),
        _buildInfoCard(
            label: 'MIEMBROS',
            value: _miembros.length.toString(),
            color: AppColors.accentColor),
        _buildInfoCard(
            label: 'RECURSOS',
            value: widget.tarea.recursosAsignados.length.toString(),
            color: AppColors.primaryOrange),
      ];
      if (isDesktop) {
        return Row(
            children: cards
                .map((c) => Expanded(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: c)))
                .toList());
      } else {
        return Column(
            children: cards
                .map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 15), child: c))
                .toList());
      }
    });
  }

  Widget _buildInfoCard(
      {required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300, width: 1)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
                letterSpacing: 0.3)),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }

  Widget _buildDatesAndPriority() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Información de Fechas',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBackground)),
        const SizedBox(height: 20),
        _buildDateRow(
            icon: Icons.event,
            label: 'Fecha de Creación',
            date: _formatDate(widget.tarea.fechaCreacion)),
        const Divider(height: 24),
        _buildDateRow(
            icon: Icons.play_circle_outline,
            label: 'Fecha de Inicio',
            date: _formatDate(widget.tarea.fechaInicio)),
        const Divider(height: 24),
        _buildDateRow(
            icon: Icons.calendar_today,
            label: 'Fecha de Vencimiento',
            date: _formatDate(widget.tarea.fechaVencimiento),
            isOverdue: widget.tarea.fechaVencimiento != null &&
                widget.tarea.fechaVencimiento!.isBefore(DateTime.now()) &&
                _currentStatus != 'Completada'),
      ]),
    );
  }

  Widget _buildDateRow(
      {required IconData icon,
      required String label,
      required String date,
      bool isOverdue = false}) {
    return Row(children: [
      Icon(icon, size: 20, color: AppColors.primaryOrange),
      const SizedBox(width: 12),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(date,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isOverdue ? Colors.red : AppColors.darkBackground)),
      ])),
      if (isOverdue)
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12)),
            child: Text('VENCIDA',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700))),
    ]);
  }

  Widget _buildResourcesSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.inventory_2, size: 22, color: AppColors.accentColor),
          const SizedBox(width: 8),
          const Text('Recursos Asignados',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBackground))
        ]),
        const SizedBox(height: 20),
        widget.tarea.recursosAsignados.isEmpty
            ? Center(
                child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text('No hay recursos asignados a esta tarea',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 14))
                    ])))
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.tarea.recursosAsignados.length,
                separatorBuilder: (context, index) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final recurso = widget.tarea.recursosAsignados[index];
                  return Row(children: [
                    Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: AppColors.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(recurso.icono,
                            style: const TextStyle(fontSize: 28))),
                    const SizedBox(width: 16),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(recurso.nombre,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkBackground)),
                          const SizedBox(height: 4),
                          Text('Cantidad: ${recurso.cantidad} unidades',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade600))
                        ])),
                  ]);
                }),
      ]),
    );
  }

  Widget _buildMembersSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.people, size: 22, color: AppColors.primaryOrange),
          const SizedBox(width: 8),
          const Text('Miembros Asignados',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBackground))
        ]),
        const SizedBox(height: 20),
        _miembros.isEmpty
            ? Center(
                child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(children: [
                      Icon(Icons.people_outline,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text('No hay miembros asignados a esta tarea',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 14))
                    ])))
            : Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: _miembros.map((miembro) {
                  return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.accentColor,
                            child: Text(
                                miembro.nombre.isNotEmpty
                                    ? miembro.nombre[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold))),
                        const SizedBox(width: 12),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  miembro.nombre.isNotEmpty
                                      ? miembro.nombre
                                      : 'Sin nombre',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkBackground)),
                              Text(miembro.email,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600))
                            ]),
                      ]));
                }).toList()),
      ]),
    );
  }
}
