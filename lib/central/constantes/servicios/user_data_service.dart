// Archivo: user_data_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
// Asegúrate de que tu modelo de usuario sea correcto
import 'package:sistem_proyect/central/constantes/modelos/usuario_model.dart'; 

class UserDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream para obtener TODOS los usuarios (necesario para la asignación de proyectos)
  Stream<List<Usuario>> getAllUsuariosStream() {
    return _firestore
        .collection('usuarios')
        .orderBy('nombre') 
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            // Asume que tienes un factory 'fromFirestore' en tu modelo Usuario
            return Usuario.fromFirestore(doc); 
          }).toList();
        });
  }
  
  // Si tu código antiguo usaba addProject, ignora esta función, ahora usamos ProjectService.
  // Future<void> addProject(Map<String, dynamic> data) async { ... }
}

// Modelado base para 'usuario_model.dart' (Necesario para el Stream)
// Debes asegurar que este modelo existe en la ruta correcta.
/*
class Usuario {
  final String uid;
  final String nombre;
  final String email;

  Usuario({required this.uid, required this.nombre, required this.email});

  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Usuario(
      uid: doc.id,
      nombre: data['nombre'] ?? '',
      email: data['email'] ?? '',
    );
  }
}
*/