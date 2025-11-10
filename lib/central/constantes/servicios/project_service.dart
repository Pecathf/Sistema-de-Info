// Archivo: project_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sistem_proyect/central/constantes/modelos/project_model.dart';
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart'; 

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
      collectionRef = collectionRef
          .where('miembrosUid', arrayContains: currentUserId); 
    }
    
    yield* collectionRef
        .snapshots() 
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            // Usa el modelo actualizado
            return Proyecto.fromFirestore(doc);
          }).toList();
        });
  }
  
  // 2. Crea un nuevo proyecto en Firestore (CREATE)
  // 🎯 Método corregido: 'crearProyecto'
  Future<void> crearProyecto(Proyecto proyecto) async {
    try {
      final proyectoData = proyecto.toFirestore();
      await _firestore.collection('proyectos').add(proyectoData);
      
    } on FirebaseException catch (e) {
      print('Error al crear proyecto: ${e.message}');
      throw Exception('Fallo al crear proyecto: ${e.code}');
    }
  }

  // 3. Obtiene un solo proyecto por ID (READ)
  Future<Proyecto?> getProyectoById(String projectId) async {
    try {
      final doc = await _firestore.collection('proyectos').doc(projectId).get();
      if (doc.exists) {
        return Proyecto.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error al obtener proyecto: $e');
      return null;
    }
  }
}