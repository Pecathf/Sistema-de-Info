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
        // ✅ CORRECCIÓN: Usar fromMap en lugar de fromFirestore
        return Proyecto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // 2. Crea un nuevo proyecto en Firestore
  Future<void> crearProyecto(Proyecto proyecto) async {
    try {
      // ✅ CORRECCIÓN: Usar toMap en lugar de toFirestore
      final proyectoData = proyecto.toMap();
      await _firestore.collection('proyectos').add(proyectoData);
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

      // Usa .update() para actualizar solo los campos modificados
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

  // 5. Eliminar un proyecto
  Future<bool> eliminarProyecto(String projectId) async {
    try {
      await _firestore.collection('proyectos').doc(projectId).delete();
      return true;
    } on FirebaseException catch (e, st) {
      developer.log(
        'Error al eliminar proyecto: ${e.message}',
        error: e,
        stackTrace: st,
        name: 'ProjectService.eliminarProyecto',
      );
      return false;
    }
  }
}
