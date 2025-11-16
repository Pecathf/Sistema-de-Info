import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_proyect/central/constantes/modelos/recurso_model.dart';
import 'dart:developer' as developer;

class ResourceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'recursos_materiales';

  // Crear un nuevo recurso asociado a un proyecto
  Future<String?> crearRecurso(RecursoMaterial recurso, String projectId) async {
    try {
      final recursoData = recurso.toMap();
      recursoData['proyectoId'] = projectId; // Asociar al proyecto
      recursoData['cantidadDisponible'] = recurso.cantidad; // Cantidad inicial disponible
      
      final docRef = await _firestore.collection(_collectionName).add(recursoData);
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

  // Obtener recursos de un proyecto específico como Stream (para actualizaciones en tiempo real)
  Stream<List<RecursoMaterial>> getRecursosStreamByProject(String projectId) {
    return _firestore
        .collection(_collectionName)
        .where('proyectoId', isEqualTo: projectId)
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RecursoMaterial.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Obtener recursos de un proyecto específico como Future (para carga única)
  Future<List<RecursoMaterial>> getRecursosByProject(String projectId) async {
    try {
      developer.log(
        'Consultando recursos para proyecto: $projectId',
        name: 'ResourceService.getRecursosByProject',
      );
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('proyectoId', isEqualTo: projectId)
          .get();

      final recursos = querySnapshot.docs
          .map((doc) {
            developer.log(
              'Recurso encontrado: ${doc.data()['nombre']} (ID: ${doc.id})',
              name: 'ResourceService.getRecursosByProject',
            );
            return RecursoMaterial.fromMap(doc.data(), doc.id);
          })
          .toList();

      // Ordenar manualmente por nombre en lugar de en la consulta
      recursos.sort((a, b) => a.nombre.compareTo(b.nombre));

      developer.log(
        'Total recursos encontrados: ${recursos.length}',
        name: 'ResourceService.getRecursosByProject',
      );

      return recursos;
    } catch (e, st) {
      developer.log(
        'Error al obtener recursos del proyecto: $e',
        error: e,
        stackTrace: st,
        name: 'ResourceService.getRecursosByProject',
      );
      return [];
    }
  }

  // Obtener todos los recursos como Stream (para admin global si es necesario)
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

  // Actualizar cantidad disponible de un recurso
  Future<bool> actualizarCantidadDisponible(String id, int nuevaCantidad) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(id)
          .update({'cantidadDisponible': nuevaCantidad});
      return true;
    } catch (e, st) {
      developer.log(
        'Error al actualizar cantidad disponible: $e',
        error: e,
        stackTrace: st,
        name: 'ResourceService.actualizarCantidadDisponible',
      );
      return false;
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

  // Actualizar un recurso completo
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