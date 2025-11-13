// Archivo: user_data_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
// 🚨 Asegúrate de que esta ruta sea correcta para tu modelo de usuario
import 'package:sistem_proyect/central/constantes/modelos/usuario_model.dart';
import 'dart:developer' as developer;

class UserDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Stream para obtener TODOS los usuarios
  // Utilizado comúnmente en formularios de asignación de proyectos.
  Stream<List<Usuario>> getAllUsuariosStream() {
    return _firestore
        .collection('usuarios')
        .orderBy('nombre') // Ordenar por nombre para mejor usabilidad
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // Asume que tienes un factory 'fromFirestore' en tu modelo Usuario
        return Usuario.fromFirestore(doc);
      }).toList();
    });
  }

  // 2. 🎯 FUNCIÓN CLAVE: Obtener usuarios por una lista de UIDs
  // Esta función es la que requiere el ProjectCardWidget para mostrar los avatares
  Future<List<Usuario>> getUsuariosByIds(List<String> uids) async {
    // Si la lista de UIDs está vacía, devuelve una lista vacía de inmediato.
    if (uids.isEmpty) return [];

    try {
      // Usar FieldPath.documentId para consultar los documentos por su UID
      final snapshot = await _firestore
          .collection('usuarios')
          .where(FieldPath.documentId, whereIn: uids)
          .get();

      // Mapear los documentos obtenidos a objetos Usuario
      return snapshot.docs.map((doc) {
        return Usuario.fromFirestore(doc);
      }).toList();
    } catch (e, st) {
      // Manejo básico de errores (es importante que no falle la UI si la data falla)
      developer.log(
        'Error al obtener usuarios por UIDs: $e',
        error: e,
        stackTrace: st,
        name: 'UserDataService.getUsuariosByIds',
      );
      return [];
    }
  }

  // Puedes añadir otras funciones de manipulación de usuarios aquí (ej: editar perfil)

  Future<Usuario?> getUsuarioById(String uid) async {
    try {
      final doc = await _firestore.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        return Usuario.fromFirestore(doc);
      }
      return null;
    } catch (e, st) {
      developer.log(
        'Error al obtener usuario: $e',
        error: e,
        stackTrace: st,
        name: 'UserDataService.getUsuarioById',
      );
      return null;
    }
  }
}
