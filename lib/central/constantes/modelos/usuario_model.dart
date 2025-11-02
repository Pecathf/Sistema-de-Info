// Archivo: usuario_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String uid;
  final String email;
  final String nombre;
  final String cedula;
  final String rol;

  Usuario({
    required this.uid,
    required this.email,
    required this.nombre,
    required this.cedula,
    required this.rol,
  });

  // 🛠️ Factory Constructor: Mapea DocumentSnapshot a Usuario
  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw StateError('Documento de usuario no contiene datos.');
    }

    return Usuario(
      uid: doc.id,
      email: data['email'] ?? 'sin_correo@app.com',
      nombre: data['nombre'] ?? 'Usuario Desconocido',
      cedula: data['cedula'] ?? 'N/A',
      // Asumo que tu colección de usuarios tiene un campo 'rol'
      rol: data['rol'] ?? 'usuario', 
    );
  }
}