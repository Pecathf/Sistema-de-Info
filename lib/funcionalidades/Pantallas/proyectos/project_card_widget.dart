import 'package:flutter/material.dart';
import 'package:sistem_proyect/central/constantes/modelos/project_model.dart';
import 'package:sistem_proyect/central/constantes/modelos/usuario_model.dart'; 
import 'package:sistem_proyect/central/constantes/servicios/user_data_service.dart';
import 'package:sistem_proyect/central/constantes/colores.dart';
import 'package:intl/intl.dart';

class ProjectCardWidget extends StatelessWidget {
  final Proyecto proyecto;
  final VoidCallback? onTapView; 
  final VoidCallback? onTapDelete; 
  
  final UserDataService _userDataService = UserDataService(); 

  ProjectCardWidget({
    required this.proyecto,
    this.onTapView,
    this.onTapDelete,
    super.key,
  });

  Color _getStatusColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'activo': return Colors.green.shade700;
      case 'completado': return Colors.blue.shade700;
      case 'en pausa': return Colors.orange.shade700;
      case 'pendiente': default: return Colors.red.shade700;
    }
  }

  String _getUserInitial(Usuario user) {
      if (user.nombre.isNotEmpty) {
          return user.nombre[0].toUpperCase();
      }
      if (user.email.isNotEmpty) {
          return user.email[0].toUpperCase();
      }
      return '?';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date); // Formato actualizado
  }

  Widget _buildMetaRow(IconData icon, String text, {Color? iconColor}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor ?? Colors.grey.shade500),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text, 
            style: TextStyle(
              fontSize: 13, 
              color: Colors.grey.shade700
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.15),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3), 
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sección Superior: Título y Descripción
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre del Proyecto
              Text(
                proyecto.nombre,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBackground,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Descripción corta
              Text(
                proyecto.descripcion,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 15),
            ],
          ),

          // Sección Media: Metadata
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fecha de inicio
              _buildMetaRow(
                Icons.date_range,
                'Fecha de inicio: ${_formatDate(proyecto.fechaInicio)}',
              ),
              const SizedBox(height: 5),
              // Fecha límite
              _buildMetaRow(
                Icons.calendar_today,
                'Fecha límite: ${_formatDate(proyecto.fechaLimite)}',
              ),
              const SizedBox(height: 5),
              // Progreso
              _buildMetaRow(
                Icons.trending_up,
                'Progreso: ${proyecto.progreso}%',
              ),
              const SizedBox(height: 10),
              
              // Barra de progreso
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: proyecto.progreso / 100,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 10),
              
              // Tareas completadas (placeholder - se actualizará cuando implementes tareas)
              _buildMetaRow(
                Icons.task_alt,
                'Tareas completadas: 8/12', // 🎯 Placeholder
              ),
              const SizedBox(height: 15),
            ],
          ),

          // Sección de Miembros
          _buildMembersStack(),
          
          const SizedBox(height: 15),
          
          // Estado Badge
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(proyecto.estado).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getStatusColor(proyecto.estado), width: 1),
              ),
              child: Text(
                proyecto.estado.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(proyecto.estado),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 15),
          
          // BOTONES DE ACCIÓN
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onTapView,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentColor,
                    side: BorderSide(color: AppColors.accentColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Ver',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onTapDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Eliminar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMembersStack() {
    return FutureBuilder<List<Usuario>>(
        future: _userDataService.getUsuariosByIds(proyecto.miembrosUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 24,
              child: Center(
                child: LinearProgressIndicator(color: AppColors.primaryOrange),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Text('Error al cargar miembros.', 
              style: TextStyle(color: Colors.red.shade400, fontSize: 12));
          }

          final List<Usuario> members = snapshot.data!;
          final visibleMembers = members.take(4).toList(); 

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Miembros (${members.length})', 
                style: TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.w600, 
                  color: Colors.grey.shade700
                )
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Stack(
                    children: List.generate(
                      visibleMembers.length,
                      (index) {
                        final member = visibleMembers[index];
                        return Padding(
                          padding: EdgeInsets.only(left: index * 20.0), 
                          child: Tooltip(
                            message: member.nombre.isNotEmpty ? member.nombre : member.email,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.accentColor, 
                              child: Text(
                                _getUserInitial(member),
                                style: const TextStyle(
                                  color: Colors.white, 
                                  fontSize: 12, 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  if (members.length > 4)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Center(
                            child: Text(
                              '+${members.length - 4}', 
                              style: TextStyle(
                                color: Colors.grey.shade700, 
                                fontSize: 13
                              )
                            ),
                        ),
                      ),
              ],
            ),
          ],
        );
    });
  }
}