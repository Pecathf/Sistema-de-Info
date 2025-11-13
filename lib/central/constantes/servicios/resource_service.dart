import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_proyect/central/constantes/modelos/recurso_model.dart';
import 'dart:developer' as developer;

class ResourceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'recursos_materiales';

  // Crear un nuevo recurso
  Future<String?> crearRecurso(RecursoMaterial recurso) async {
    try {
      final docRef = await _firestore.collection(_collectionName).add(recurso.toMap());
      return docRef.id;
    } catch (e, st) {
      developer.log(
        'Error al crear recurso: $e',
        error: e,
        stackTrace: st,
        name: 'ResourceService.crearRecurso',
      );
      return null;
    }
  }

  // Obtener todos los recursos como Stream
  Stream<List<RecursoMaterial>> getRecursosStream() {
    return _firestore
        .collection(_collectionName)
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RecursoMaterial.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Obtener recursos por lista de IDs
  Future<List<RecursoMaterial>> getRecursosByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where(FieldPath.documentId, whereIn: ids)
          .get();

      return querySnapshot.docs
          .map((doc) => RecursoMaterial.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e, st) {
      developer.log(
        'Error al obtener recursos por IDs: $e',
        error: e,
        stackTrace: st,
        name: 'ResourceService.getRecursosByIds',
      );
      return [];
    }
  }

  // Obtener un recurso por ID
  Future<RecursoMaterial?> getRecursoById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return RecursoMaterial.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e, st) {
      developer.log(
        'Error al obtener recurso: $e',
        error: e,
        stackTrace: st,
        name: 'ResourceService.getRecursoById',
      );
      return null;
    }
  }

  // Eliminar un recurso
  Future<bool> eliminarRecurso(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
      return true;
    } catch (e, st) {
      developer.log(
        'Error al eliminar recurso: $e',
        error: e,
        stackTrace: st,
        name: 'ResourceService.eliminarRecurso',
      );
      return false;
    }
  }

  // Actualizar un recurso
  Future<bool> actualizarRecurso(RecursoMaterial recurso) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(recurso.id)
          .update(recurso.toMap());
      return true;
    } catch (e, st) {
      developer.log(
        'Error al actualizar recurso: $e',
        error: e,
        stackTrace: st,
        name: 'ResourceService.actualizarRecurso',
      );
      return false;
    }
  }
}