import 'package:flutter/material.dart';
import 'package:sistem_proyect/central/constantes/colores.dart';
import 'package:sistem_proyect/central/constantes/modelos/task_model.dart';
// Asume que tienes un modelo de comentario, si no, usa un Map o crea uno simple.

// Crear un modelo de comentario simple para este ejemplo
class Comentario {
  final String usuario;
  final String texto;
  final DateTime fecha;

  Comentario({required this.usuario, required this.texto, required this.fecha});
}

class ComentariosSection extends StatefulWidget {
  final String taskId;

  const ComentariosSection({super.key, required this.taskId});

  @override
  State<ComentariosSection> createState() => _ComentariosSectionState();
}

class _ComentariosSectionState extends State<ComentariosSection> {
  final TextEditingController _commentController = TextEditingController();
  final List<Comentario> _comentarios = [
    // Datos de ejemplo
    Comentario(
        usuario: 'Admin',
        texto: 'Tarea iniciada con éxito.',
        fecha: DateTime.now().subtract(const Duration(hours: 2))),
    Comentario(
        usuario: 'Usuario Prueba',
        texto: 'Revisando los recursos asignados.',
        fecha: DateTime.now().subtract(const Duration(minutes: 30))),
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Lógica para agregar un nuevo comentario (temporal para UI)
  void _agregarComentario() {
    if (_commentController.text.trim().isNotEmpty) {
      setState(() {
        _comentarios.add(Comentario(
          usuario:
              'Yo (UID: ${widget.taskId.substring(0, 4)})', // Simulación de usuario logeado
          texto: _commentController.text.trim(),
          fecha: DateTime.now(),
        ));
        _commentController.clear();
      });
      // Aquí iría la lógica real para guardar en Firestore o tu servicio.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Campo de texto para agregar un nuevo comentario
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Escribe un comentario...',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _agregarComentario,
                tooltip: 'Enviar comentario',
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 2. Título de la sección de comentarios existentes
        Text(
          'Comentarios (${_comentarios.length})',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),

        const SizedBox(height: 10),

        // 3. Lista de comentarios
        ..._comentarios.reversed.map((comentario) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.accentColor.withOpacity(0.8),
                  child: Text(
                    comentario.usuario[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre de usuario y fecha
                      Row(
                        children: [
                          Text(
                            comentario.usuario,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${comentario.fecha.day}/${comentario.fecha.month} ${comentario.fecha.hour}:${comentario.fecha.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Texto del comentario
                      Text(
                        comentario.texto,
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),

        if (_comentarios.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Aún no hay comentarios. ¡Sé el primero en comentar!',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
          ),
      ],
    );
  }
}
