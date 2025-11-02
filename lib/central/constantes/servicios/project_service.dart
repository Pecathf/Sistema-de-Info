// Archivo: project_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sistem_proyect/central/constantes/modelos/project_model.dart';
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart'; 

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; 
  final AuthService _authService = AuthService(); 

  // 1. Obtiene un Stream de proyectos (Solo Admin ejecuta la consulta)
  Stream<List<Proyecto>> getProyectosStream() async* {
    final String? currentUserId = _auth.currentUser?.uid;
    
    if (currentUserId == null) {
      yield []; 
      return;
    }

    final isAdmin = await _authService.isAdmin(); 
    
    if (!isAdmin) {
      // Si no es admin, retorna un stream vacío
      yield []; 
      return;
    }
    
    // Si es admin, ejecuta la consulta.
    yield* _firestore
        .collection('proyectos')
        // Puedes quitar el .where() si quieres que el admin vea *TODOS* los proyectos.
        .orderBy('fechaCreacion', descending: true) 
        .snapshots() 
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Proyecto.fromFirestore(doc);
          }).toList();
        });
  }
  
  // 2. Crea un nuevo proyecto en Firestore (CREATE)
  Future<void> crearProyecto(Proyecto proyecto) async {
    try {
      final proyectoData = proyecto.toFirestore();
      await _firestore.collection('proyectos').add(proyectoData);
      
    } on FirebaseException catch (e) {
      // Esto capturará la excepción de 'Permiso Denegado' si alguien que no es admin lo intenta
      throw Exception('Error al guardar el proyecto en Firestore: ${e.message}');
    }
  }
}