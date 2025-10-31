// Archivo: servicios/user_data_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/project_model.dart'; // Importamos el modelo

class UserDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Colección principal para los proyectos
  late final CollectionReference _proyectosRef;

  UserDataService() {
    // Apunta a una subcolección de 'usuarios/{userId}/proyectos'
    // Deberías obtener el ID del usuario actualmente logueado.
    // Por simplicidad, aquí usamos un ID de placeholder. 
    // Asegúrate de reemplazar 'current_user_id' con el ID de FirebaseAuth.
    String userId = 'current_user_id_placeholder'; 
    
    // **NOTA IMPORTANTE:** Reemplaza 'current_user_id_placeholder' por el ID del usuario real
    // (ej: FirebaseAuth.instance.currentUser?.uid) en tu aplicación.
    _proyectosRef = _db.collection('usuarios').doc(userId).collection('proyectos');
  }

  // Obtiene un stream de todos los proyectos del usuario
  Stream<List<Proyecto>> getProyectosStream() {
    return _proyectosRef
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Proyecto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Método para añadir un nuevo proyecto (ejemplo)
  Future<void> addProyecto(Proyecto proyecto) {
    // Usamos el toMap del modelo para subir a Firestore
    return _proyectosRef.add(proyecto.toMap());
  }
}