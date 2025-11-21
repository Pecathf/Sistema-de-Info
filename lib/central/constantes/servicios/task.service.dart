import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_proyect/central/constantes/modelos/task_model.dart';
import 'dart:developer' as developer;

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'tareas';
  final String _projectsCollection = 'proyectos';

  // 1. Crear una nueva tarea
  Future<String?> crearTarea(TaskModel tarea) async {
    try {
      final docRef = await _firestore.collection(_collectionName).add(tarea.toMap());
      
      // IMPORTANTE: Al crear tarea, recalculamos el progreso 
      await _recalcularProgresoProyecto(tarea.proyectoId);
      
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

  // 3. Eliminar tarea
  Future<void> eliminarTarea(String taskId, String projectId) async {
    try {
      await _firestore.collection(_collectionName).doc(taskId).delete();
      // Al eliminar, recalculamos el progreso
      await _recalcularProgresoProyecto(projectId);
    } catch (e) {
      developer.log('Error al eliminar tarea: $e', name: 'TaskService');
      throw Exception('Fallo al eliminar tarea');
    }
  }

  // 4. Actualizar estado
  Future<void> updateTaskStatus(String taskId, String projectId, String newStatus) async {
    try {
      // A. Actualizamos el estado de la tarea
      await _firestore.collection(_collectionName).doc(taskId).update({
        'estado': newStatus,
      });

      // B. Recalculamos el progreso del proyecto inmediatamente
      await _recalcularProgresoProyecto(projectId);

    } catch (e) {
      developer.log('Error al actualizar estado y progreso: $e', name: 'TaskService');
      rethrow;
    }
  }

  // ----------------------------------------------------------------------
  //  MÉTODOS PARA COMENTARIOS
  // ----------------------------------------------------------------------

  // 5. Agregar un comentario
  Future<void> addComment(String taskId, String texto, String autorId, String autorNombre) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(taskId)
          .collection('comentarios')
          .add({
        'texto': texto,
        'autorId': autorId,
        'autorNombre': autorNombre,
        'fecha': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log('Error al agregar comentario: $e', name: 'TaskService');
      rethrow;
    }
  }

  // 6. Leer comentarios en tiempo real
  Stream<QuerySnapshot> getCommentsStream(String taskId) {
    return _firestore
        .collection(_collectionName)
        .doc(taskId)
        .collection('comentarios')
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  // ----------------------------------------------------------------------
  // MÉTODO PRIVADO: CÁLCULO DE PROGRESO
  // ----------------------------------------------------------------------
  Future<void> _recalcularProgresoProyecto(String projectId) async {
    try {
      // 1. Obtenemos TODAS las tareas de este proyecto
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('proyectoId', isEqualTo: projectId)
          .get();

      final totalTareas = querySnapshot.docs.length;
      
      // Si no hay tareas, el progreso es 0
      if (totalTareas == 0) {
        await _firestore.collection(_projectsCollection).doc(projectId).update({
          'progreso': 0.0,
        });
        return;
      }

      // 2. Contamos cuántas dicen 'Completada'
      final tareasCompletadas = querySnapshot.docs
          .where((doc) => doc['estado'] == 'Completada')
          .length;

      // 3. Calculamos el decimal (Ej: 5/10 = 0.5)
      double nuevoProgreso = tareasCompletadas / totalTareas;

      // 4. Guardamos el nuevo progreso en el documento del PROYECTO
      await _firestore.collection(_projectsCollection).doc(projectId).update({
        'progreso': nuevoProgreso,
      });
      
      developer.log('Progreso actualizado: ${(nuevoProgreso * 100).toStringAsFixed(1)}%', name: 'TaskService');
      
    } catch (e) {
      developer.log('Error crítico recalculando el porcentaje del proyecto: $e', name: 'TaskService');
    }
  }
}