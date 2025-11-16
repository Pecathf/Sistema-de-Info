// Archivo: central/constantes/servicios/task_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_proyect/central/constantes/modelos/task_model.dart';
import 'dart:developer' as developer;

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'tareas';

  // 1. Crear una nueva tarea
  Future<String?> crearTarea(TaskModel tarea) async {
    try {
      final docRef =
          await _firestore.collection(_collectionName).add(tarea.toMap());
      return docRef.id;
    } catch (e, st) {
      developer.log(
        'Error al crear tarea: $e',
        error: e,
        stackTrace: st,
        name: 'TaskService.crearTarea',
      );
      throw Exception('Fallo al crear tarea');
    }
  }

  // 2. Obtener un Stream de tareas por proyectoId
  Stream<List<TaskModel>> getTasksStreamByProject(String proyectoId) {
    return _firestore
        .collection(_collectionName)
        .where('proyectoId', isEqualTo: proyectoId)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> eliminarTarea(String taskId) async {}

  // 3. (Opcional) Implementar más métodos (update, delete, getById) si es necesario
}
