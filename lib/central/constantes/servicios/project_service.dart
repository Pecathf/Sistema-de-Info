import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sistem_proyect/central/constantes/modelos/project_model.dart';
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart';
import 'dart:developer' as developer;

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  // 1. Obtiene un Stream de proyectos (Administrador ve todos, Usuario solo los suyos)
  Stream<List<Proyecto>> getProyectosStream() async* {
    final String? currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) {
      yield [];
      return;
    }

    final isAdmin = await _authService.isAdmin();

    Query collectionRef = _firestore
        .collection('proyectos')
        .orderBy('fechaCreacion', descending: true);

    if (!isAdmin) {
      // Si NO es admin, solo proyectos donde es miembro o creador
      collectionRef =
          collectionRef.where('miembrosUid', arrayContains: currentUserId);
    }

    yield* collectionRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Proyecto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // 2. Crea un nuevo proyecto en Firestore y devuelve el ID
  Future<String> crearProyecto(Proyecto proyecto) async {
    try {
      final proyectoData = proyecto.toMap();
      final docRef = await _firestore.collection('proyectos').add(proyectoData);
      return docRef.id;
    } on FirebaseException catch (e, st) {
      developer.log(
        'Error al crear proyecto: ${e.message}',
        error: e,
        stackTrace: st,
        name: 'ProjectService.crearProyecto',
      );
      throw Exception('Fallo al crear proyecto: ${e.code}');
    }
  }

  // 3. Obtiene un solo proyecto por ID
  Future<Proyecto?> getProyectoById(String projectId) async {
    try {
      final doc = await _firestore.collection('proyectos').doc(projectId).get();
      if (doc.exists) {
        return Proyecto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e, st) {
      developer.log(
        'Error al obtener proyecto: $e',
        error: e,
        stackTrace: st,
        name: 'ProjectService.getProyectoById',
      );
      return null;
    }
  }

  // 4. Actualiza un proyecto existente
  Future<void> updateProyecto(Proyecto proyecto) async {
    try {
      final proyectoRef = _firestore.collection('proyectos').doc(proyecto.id);

      final data = proyecto.toMap();

      await proyectoRef.update(data);
    } on FirebaseException catch (e, st) {
      developer.log(
        'Error al actualizar proyecto: ${e.message}',
        error: e,
        stackTrace: st,
        name: 'ProjectService.updateProyecto',
      );
      throw Exception('Fallo al actualizar proyecto: ${e.code}');
    }
  }

  // 5. Eliminar un proyecto y todos sus recursos asociados
  Future<bool> eliminarProyecto(String projectId) async {
    try {
      // 1️. VALIDAR: Verificar si hay tareas en progreso o completadas
      final tareasSnapshot = await _firestore
          .collection('tareas')
          .where('proyectoId', isEqualTo: projectId)
          .get();

      final hayTareasIniciadas = tareasSnapshot.docs.any((doc) {
        final estado = doc['estado'] as String?;
        return estado == 'En Progreso' || estado == 'Completada';
      });

      if (hayTareasIniciadas) {
        developer.log(
          'No se puede eliminar: proyecto con tareas iniciadas',
          name: 'ProjectService.eliminarProyecto',
        );
        throw Exception(
            'No se puede eliminar un proyecto que ya tiene tareas en progreso o completadas');
      }

      // 2️. Eliminar todos los recursos asociados al proyecto
      final recursosSnapshot = await _firestore
          .collection('recursos_materiales')
          .where('proyectoId', isEqualTo: projectId)
          .get();

      // Eliminar cada recurso en un batch
      final batch = _firestore.batch();
      for (var doc in recursosSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // 3️. Eliminar todas las tareas asociadas (solo pendientes llegarían aquí)
      final batchTareas = _firestore.batch();
      for (var doc in tareasSnapshot.docs) {
        batchTareas.delete(doc.reference);
      }
      await batchTareas.commit();

      // 4️. Finalmente eliminar el proyecto
      await _firestore.collection('proyectos').doc(projectId).delete();

      developer.log(
        'Proyecto eliminado exitosamente junto con sus recursos y tareas',
        name: 'ProjectService.eliminarProyecto',
      );

      return true;
    } on FirebaseException catch (e, st) {
      developer.log(
        'Error al eliminar proyecto: ${e.message}',
        error: e,
        stackTrace: st,
        name: 'ProjectService.eliminarProyecto',
      );
      return false;
    } catch (e, st) {
      developer.log(
        'Error al eliminar proyecto: $e',
        error: e,
        stackTrace: st,
        name: 'ProjectService.eliminarProyecto',
      );
      rethrow;
    }
  }

  Future<void> registrarHistorial(
      String projectId, String accion, String usuarioNombre) async {
    await _firestore
        .collection('proyectos')
        .doc(projectId)
        .collection('historial')
        .add({
      'accion': accion,
      'usuarioNombre': usuarioNombre,
      'fecha': FieldValue.serverTimestamp(),
    });
  }
}
