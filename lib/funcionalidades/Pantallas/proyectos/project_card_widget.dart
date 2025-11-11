// Archivo: project_card_widget.dart

import 'package:flutter/material.dart';
// 🚨 Revisa estas rutas según tu estructura
import 'package:sistem_proyect/central/constantes/modelos/project_model.dart';
import 'package:sistem_proyect/central/constantes/modelos/usuario_model.dart'; 
import 'package:sistem_proyect/central/constantes/servicios/user_data_service.dart';

class ProjectCardWidget extends StatelessWidget {
  final Proyecto proyecto;
  final VoidCallback? onTap;
  
  // Servicio para obtener los datos del usuario (asumimos que existe)
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
      return user.email.isNotEmpty ? user.email[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. Título y Estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      proyecto.nombre, 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)
                    )
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(proyecto.estado), 
                      borderRadius: BorderRadius.circular(16)
                    ),
                    child: Text(
                      proyecto.estado, 
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)
                    )
                  ),
                ],
              ),
              
              const SizedBox(height: 10),
              
              // 2. Descripción
              Text(
                proyecto.descripcion,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 15),

              // 3. Metadata (Fecha y Avatares de Miembros)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetaRow(Icons.calendar_today, 'Creado: ${_formatDate(proyecto.fechaCreacion)}'),
                  const SizedBox(height: 15),
                  
                  // 🎯 Widget de Avatares
                  _buildMemberAvatars(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 🎯 Widget que usa FutureBuilder para obtener y apilar los avatares
  Widget _buildMemberAvatars() {
      if (proyecto.miembrosUid.isEmpty) {
          return _buildMetaRow(Icons.group, 'Miembros: 0');
      }

      return FutureBuilder<List<Usuario>>(
          // ASUMIMOS que esta función existe en tu UserDataService
          future: _userDataService.getUsuariosByIds(proyecto.miembrosUid), 
          builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildMetaRow(Icons.group, 'Cargando miembros...');
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildMetaRow(Icons.group, 'Miembros: ${proyecto.miembrosUid.length}');
              }

              final members = snapshot.data!;
              const double avatarSize = 30.0;
              const double overlap = 15.0; // Espacio de solapamiento

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const Icon(Icons.group, size: 16, color: Color.fromARGB(255, 117, 117, 117)),
                    const SizedBox(width: 15),
                    SizedBox(
                      height: avatarSize,
                      width: members.length * (avatarSize - overlap) + overlap,
                      child: Stack(
                        children: List.generate(
                          members.length > 4 ? 4 : members.length, // Máximo 4 avatares
                          (index) {
                            final member = members[index];
                            return Positioned(
                              left: index * overlap,
                              child: Tooltip(
                                message: member.nombre.isNotEmpty ? member.nombre : member.email,
                                child: CircleAvatar(
                                  radius: avatarSize / 2,
                                  backgroundColor: index.isEven ? const Color(0xFF00BFFF) : const Color(0xFFFF6633), // Azul o Naranja
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
              );
          },
      );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildMetaRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
      ],
    );
  }
}