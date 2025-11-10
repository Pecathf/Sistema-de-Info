// Archivo: project_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Proyecto {
  final String id;
  final String nombre;
  final String descripcion;
  final DateTime fechaCreacion;
  final DateTime fechaInicio;      // 🎯 NUEVO CAMPO
  final DateTime fechaLimite;      // 🎯 NUEVO CAMPO
  final int progreso;
  final String estado;
  final String creadorUid;
  final List<String> miembrosUid;
  final List<String> recursosMateriales;

  Proyecto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.fechaCreacion,
    required this.fechaInicio,     // Requerido
    required this.fechaLimite,     // Requerido
    required this.progreso,
    required this.estado,
    required this.creadorUid,
    required this.miembrosUid,
    required this.recursosMateriales,
  });

  // Factory para crear un objeto Proyecto desde Firestore
  factory Proyecto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final Timestamp? tsCreacion = data['fechaCreacion'] as Timestamp?;
    final Timestamp? tsInicio = data['fechaInicio'] as Timestamp?;
    final Timestamp? tsLimite = data['fechaLimite'] as Timestamp?;

    return Proyecto(
      id: doc.id,
      nombre: data['nombre'] ?? 'Proyecto sin nombre',
      descripcion: data['descripcion'] ?? 'Sin descripción',
      fechaCreacion: tsCreacion?.toDate() ?? DateTime.now(),
      fechaInicio: tsInicio?.toDate() ?? DateTime.now(),         // ✅ ACTUALIZADO
      fechaLimite: tsLimite?.toDate() ?? DateTime(2101),         // ✅ ACTUALIZADO
      progreso: data['progreso'] ?? 0,
      estado: data['estado'] ?? 'Pendiente',
      creadorUid: data['creadorUid'] ?? '',
      miembrosUid: List<String>.from(data['miembrosUid'] ?? []),
      recursosMateriales: List<String>.from(data['recursosMateriales'] ?? []),
    );
  }

  // Método para convertir el objeto Proyecto a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaInicio': Timestamp.fromDate(fechaInicio),        // ✅ ACTUALIZADO
      'fechaLimite': Timestamp.fromDate(fechaLimite),        // ✅ ACTUALIZADO
      'progreso': progreso,
      'estado': estado,
      'creadorUid': creadorUid,
      'miembrosUid': miembrosUid,
      'recursosMateriales': recursosMateriales,
    };
  }
}