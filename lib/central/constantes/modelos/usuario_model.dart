import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String uid;
  final String nombre;
  final String email;

  Usuario({
    required this.uid,
    required this.nombre,
    required this.email,
  });

  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    // 🎯 CORRECCIÓN CLAVE: Usar ?? para proporcionar valores por defecto
    // '??' se asegura de que si el valor es nulo, se use una cadena vacía ('') en su lugar.
    return Usuario(
      uid: doc.id, // El ID siempre existe en el DocumentSnapshot
      nombre: data?['nombre'] ?? '', // Usa '' si 'nombre' es null
      email: data?['email'] ?? 'Sin email', // Usa 'Sin email' si 'email' es null
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'email': email,
    };
  }
}