// Archivo: project_card_widget.dart

import 'package:flutter/material.dart';
import 'package:sistem_proyect/central/constantes/modelos/project_model.dart';
import 'package:sistem_proyect/central/constantes/modelos/usuario_model.dart'; 
import 'package:sistem_proyect/central/constantes/servicios/user_data_service.dart';
import 'package:sistem_proyect/central/constantes/colores.dart'; // Asumiendo que AppColors está aquí
import 'package:intl/intl.dart'; // Necesario para formatear fechas

class ProjectCardWidget extends StatelessWidget {
  final Proyecto proyecto;
  // 🎯 1. PROPIEDAD DE ACCIÓN: Se requiere un callback para la acción de clic
  final VoidCallback? onTap; 
  
  // Servicio para obtener los datos del usuario
  final UserDataService _userDataService = UserDataService(); 

  ProjectCardWidget({
    required this.proyecto,
    this.onTap,
    super.key,
  });

  // Define los colores de estado
  Color _getStatusColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'activo': return Colors.blue.shade700;
      case 'completado': return Colors.green.shade700;
      case 'en pausa': return Colors.orange.shade700;
      case 'pendiente': default: return Colors.red.shade700;
    }
  }

  // Función auxiliar para obtener la inicial
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
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Widget _buildMetaRow(IconData icon, String text, {Color? iconColor}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor ?? Colors.grey.shade500),
        const SizedBox(width: 8),
        Text(
          text, 
          style: TextStyle(
            fontSize: 13, 
            color: Colors.grey.shade700
          )
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 2. WRAPPER CLICKEABLE: Usar InkWell para habilitar el clic y dar feedback visual
    return InkWell( 
      onTap: onTap, 
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
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

            // Sección Media: Metadata y Estado
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progreso (Opcional, si usas Slider o indicador)
                // LinearProgressIndicator(value: proyecto.progreso / 100),

                // Metadatos (Fechas y Estado)
                _buildMetaRow(
                  Icons.calendar_today,
                  'Fecha Límite: ${_formatDate(proyecto.fechaLimite)}',
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    _buildMetaRow(
                      Icons.info_outline,
                      'Estado: ${proyecto.estado}',
                      iconColor: _getStatusColor(proyecto.estado),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
              ],
            ),

            // Sección Inferior: Miembros
            _buildMembersStack(),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersStack() {
    // 3. 🎯 LÓGICA DE MIEMBROS: FutureBuilder para obtener la data de usuarios
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
            return Text('Error al cargar miembros.', style: TextStyle(color: Colors.red.shade400, fontSize: 12));
          }

          final List<Usuario> members = snapshot.data!;
          // Limita a mostrar solo los primeros 4 avatares
          final visibleMembers = members.take(4).toList(); 

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Miembros (${members.length})', 
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)
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
                          // Offset para solapar los avatares
                          padding: EdgeInsets.only(left: index * 20.0), 
                          child: Tooltip(
                            message: member.nombre.isNotEmpty ? member.nombre : member.email,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.accentColor, 
                              child: Text(
                                _getUserInitial(member),
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Contador para miembros ocultos
                  if (members.length > 4)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Center(
                            child: Text('+${members.length - 4}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                        ),
                      ),
              ],
            ),
          ],
        );
    });
  }
}