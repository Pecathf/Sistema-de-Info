import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_proyect/central/constantes/modelos/task_model.dart';
import 'package:sistem_proyect/central/constantes/modelos/recurso_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'tareas';
  final String _projectsCollection = 'proyectos';

  // 1. Crear una nueva tarea
  Future<String?> crearTarea(TaskModel tarea) async {
    try {
      final docRef =
          await _firestore.collection(_collectionName).add(tarea.toMap());

      // IMPORTANTE: Al crear tarea, recalculamos el progreso
      await _recalcularProgresoProyecto(tarea.proyectoId);

      return docRef.id;
    } catch (e) {
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
      throw Exception('Fallo al eliminar tarea');
    }
  }

  // 4. Actualizar estado
  Future<void> updateTaskStatus(
      String taskId, String projectId, String newStatus) async {
    try {
      // Actualizamos el estado de la tarea
      await _firestore.collection(_collectionName).doc(taskId).update({
        'estado': newStatus,
      });

      // Recalculamos el progreso del proyecto inmediatamente
      await _recalcularProgresoProyecto(projectId);
    } catch (e) {
      rethrow;
    }
  }

  // 5. Actualizar una tarea completa
  Future<void> updateTarea(
    String taskId, {
    required String nombre,
    required String descripcion,
    required List<String> miembrosUid,
    required List<RecursoMaterial> recursosAsignados,
    required DateTime? fechaInicio,
    required DateTime? fechaVencimiento,
    required String prioridad,
  }) async {
    try {
      await _firestore.collection(_collectionName).doc(taskId).update({
        'nombre': nombre,
        'descripcion': descripcion,
        'miembrosUid': miembrosUid,
        'recursosAsignados': recursosAsignados.map((r) => r.toMap()).toList(),
        'fechaInicio':
            fechaInicio != null ? Timestamp.fromDate(fechaInicio) : null,
        'fechaVencimiento': fechaVencimiento != null
            ? Timestamp.fromDate(fechaVencimiento)
            : null,
        'prioridad': prioridad,
      });
    } catch (e) {
      throw Exception('Fallo al actualizar tarea: $e');
    }
  }

  // ----------------------------------------------------------------------
  //  MÉTODOS PARA COMENTARIOS
  // ----------------------------------------------------------------------

  // 5. Agregar un comentario
  Future<void> addComment(
      String taskId, String texto, String autorId, String autorNombre) async {
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
      try {
        // Intentar obtener TODAS las tareas del proyecto
        final querySnapshot = await _firestore
            .collection(_collectionName)
            .where('proyectoId', isEqualTo: projectId)
            .get();

        final totalTareas = querySnapshot.docs.length;

        // Total de tareas encontradas: $totalTareas

        // Si no hay tareas, el progreso es 0 y estado Activo
        if (totalTareas == 0) {
          await _firestore
              .collection(_projectsCollection)
              .doc(projectId)
              .update({
            'progreso': 0.0,
            'estado': 'Activo',
          });

          // Proyecto actualizado: Sin tareas - Progreso 0%, Estado Activo
          return;
        }

        // Contamos cuántas dicen 'Completada' y cuántas 'En Progreso'
        final tareasCompletadas = querySnapshot.docs
            .where((doc) => doc['estado'] == 'Completada')
            .length;

        final tareasEnProgreso = querySnapshot.docs
            .where((doc) => doc['estado'] == 'En Progreso')
            .length;

        // Calculamos el decimal
        double nuevoProgreso = tareasCompletadas / totalTareas;

        // DETERMINAR ESTADO DEL PROYECTO
        String nuevoEstado;
        if (tareasCompletadas == totalTareas) {
          nuevoEstado = 'Completado';
        } else if (tareasEnProgreso > 0 || tareasCompletadas > 0) {
          nuevoEstado = 'En Progreso';
        } else {
          nuevoEstado = 'Activo';
        }

        // Calculando actualización de progreso y estado

        // Guardamos el nuevo progreso Y estado
        await _firestore.collection(_projectsCollection).doc(projectId).update({
          'progreso': nuevoProgreso,
          'estado': nuevoEstado,
        });
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          rethrow;
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
