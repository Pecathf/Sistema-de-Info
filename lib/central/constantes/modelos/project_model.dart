// Archivo: project_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Proyecto {
  final String id;
  final String nombre;
  final String descripcion;
  final DateTime fechaCreacion;
  final DateTime fechaInicio;      
  final DateTime fechaLimite;      
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
    required this.fechaInicio,     
    required this.fechaLimite,     
    required this.progreso,
    required this.estado,
    required this.creadorUid,
    required this.miembrosUid,
    required this.recursosMateriales,
  });

  // 🎯 IMPLEMENTACIÓN DEL MÉTODO copyWith para resolver el error
  Proyecto copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    DateTime? fechaCreacion,
    DateTime? fechaInicio,
    DateTime? fechaLimite,
    int? progreso,
    String? estado,
    String? creadorUid,
    List<String>? miembrosUid,
    List<String>? recursosMateriales,
  }) {
    return Proyecto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaLimite: fechaLimite ?? this.fechaLimite,
      progreso: progreso ?? this.progreso,
      estado: estado ?? this.estado,
      creadorUid: creadorUid ?? this.creadorUid,
      miembrosUid: miembrosUid ?? this.miembrosUid,
      recursosMateriales: recursosMateriales ?? this.recursosMateriales,
    );
  }

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
      fechaInicio: tsInicio?.toDate() ?? DateTime.now(),        
      fechaLimite: tsLimite?.toDate() ?? DateTime(2101),        
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
      'fechaInicio': Timestamp.fromDate(fechaInicio),        
      'fechaLimite': Timestamp.fromDate(fechaLimite),        
      'progreso': progreso,
      'estado': estado,
      'creadorUid': creadorUid,
      'miembrosUid': miembrosUid,
      'recursosMateriales': recursosMateriales,
    };
  }
}