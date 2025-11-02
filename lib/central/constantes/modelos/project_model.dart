// Archivo: project_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Proyecto {
  final String? id; 
  final String nombre;
  final String descripcion;
  final String estado;
  final DateTime fechaCreacion;
  final List<String> miembrosUid; 
  final List<String> recursos;   

  Proyecto({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.estado,
    required this.fechaCreacion,
    required this.miembrosUid,
    required this.recursos,
  });

  factory Proyecto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('Documento de proyecto no contiene datos.');
    }
    final timestamp = data['fechaCreacion'] as Timestamp?;

    return Proyecto(
      id: doc.id,
      nombre: data['nombre'] ?? 'Proyecto sin nombre',
      descripcion: data['descripcion'] ?? 'Sin descripción.',
      estado: data['estado'] ?? 'Pendiente',
      fechaCreacion: timestamp?.toDate() ?? DateTime.now(),
      miembrosUid: List<String>.from(data['miembrosUid'] ?? []), 
      recursos: List<String>.from(data['recursos'] ?? []), 
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'estado': estado,
      'fechaCreacion': FieldValue.serverTimestamp(), 
      'miembrosUid': miembrosUid,
      'recursos': recursos,
    };
  }
}