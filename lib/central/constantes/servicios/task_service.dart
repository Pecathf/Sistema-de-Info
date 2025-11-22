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

      // Recalculamos el progreso del proyecto
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

  // 3. Eliminar tarea con validación y liberación de recursos
  Future<Map<String, dynamic>> eliminarTareaConValidacion(
    String taskId,
    String projectId,
  ) async {
    try {
      // 1. Obtener la tarea
      final tareaDoc =
          await _firestore.collection(_collectionName).doc(taskId).get();

      if (!tareaDoc.exists) {
        return {
          'success': false,
          'message': 'La tarea no existe',
        };
      }

      final tareaData = tareaDoc.data() as Map<String, dynamic>;
      final estado = tareaData['estado'] as String;

      // 2. Validar estado: solo se pueden eliminar tareas 'Pendiente'
      if (estado != 'Pendiente') {
        return {
          'success': false,
          'message':
              'Solo se pueden eliminar tareas en estado Pendiente.\nEsta tarea está en estado: $estado',
        };
      }

      // 3. Liberar recursos
      final recursosAsignados =
          tareaData['recursosAsignados'] as List<dynamic>? ?? [];
      int recursosLiberados = 0;

      for (var recursoMap in recursosAsignados) {
        final recursoData = recursoMap as Map<String, dynamic>;
        final recursoId = recursoData['id'] as String?;
        final cantidadAsignada = recursoData['cantidad'] as int? ?? 0;

        if (recursoId == null || cantidadAsignada <= 0) {
          continue;
        }

        try {
          // Obtener recurso actual
          final recursoDoc = await _firestore
              .collection('recursos_materiales')
              .doc(recursoId)
              .get();

          if (!recursoDoc.exists) {
            continue;
          }

          final recursoActual = recursoDoc.data() as Map<String, dynamic>;
          final cantidadDisponibleActual =
              recursoActual['cantidadDisponible'] as int? ?? 0;

          // CALCULAR nueva cantidad disponible
          final nuevaCantidadDisponible =
              cantidadDisponibleActual + cantidadAsignada;

          // ACTUALIZAR en Firestore
          await _firestore
              .collection('recursos_materiales')
              .doc(recursoId)
              .update({
            'cantidadDisponible': nuevaCantidadDisponible,
          });

          recursosLiberados++;
        } catch (e) {
          // Omitimos el logging aquí, si hay un error en un recurso,
          // se intenta liberar el siguiente.
        }
      }

      // 4. Eliminar la tarea
      await _firestore.collection(_collectionName).doc(taskId).delete();

      // 5. Recalcular progreso
      await _recalcularProgresoProyecto(projectId);

      return {
        'success': true,
        'message':
            'Tarea eliminada exitosamente.\n$recursosLiberados recursos liberados.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al eliminar tarea: $e',
      };
    }
  }

  // Método para diagnóstico de recursos (manteniendo solo la funcionalidad de Firestore)
  Future<void> diagnosticarRecursos(String projectId) async {
    try {
      // 1. Ver recursos del proyecto (funcionalidad no alterada)
      await _firestore
          .collection('recursos_materiales')
          .where('proyectoId', isEqualTo: projectId)
          .get();

      // 2. Ver tareas del proyecto (funcionalidad no alterada)
      await _firestore
          .collection('tareas')
          .where('proyectoId', isEqualTo: projectId)
          .get();
    } catch (e) {
      // Manejo de errores simplificado.
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
        'recursosAsignados':
            recursosAsignados.map((r) => r.toMapWithId()).toList(),
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
  //  MÉTODOS PARA COMENTARIOS
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
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('proyectoId', isEqualTo: projectId)
          .get();

      final totalTareas = querySnapshot.docs.length;

      // Si no hay tareas, el progreso es 0 y estado Activo
      if (totalTareas == 0) {
        await _firestore.collection(_projectsCollection).doc(projectId).update({
          'progreso': 0.0,
          'estado': 'Activo',
        });
        return;
      }

      // Contamos cuántas tareas están 'Completada'
      final tareasCompletadas = querySnapshot.docs
          .where((doc) => doc['estado'] == 'Completada')
          .length;

      // Contamos cuántas tareas están 'En Progreso'
      final tareasEnProgreso = querySnapshot.docs
          .where((doc) => doc['estado'] == 'En Progreso')
          .length;

      // Calculamos el decimal del progreso
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

      // Guardamos el nuevo progreso Y estado
      await _firestore.collection(_projectsCollection).doc(projectId).update({
        'progreso': nuevoProgreso,
        'estado': nuevoEstado,
      });
    } on FirebaseException {
      rethrow; // Re-lanza la excepción de Firebase
    } catch (e) {
      rethrow; // Re-lanza cualquier otra excepción
    }
  }
}
