import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_proyect/central/constantes/modelos/recurso_model.dart';

class Proyecto {
  final String id;
  final String nombre;
  final String descripcion;
  final DateTime fechaCreacion;
  final DateTime fechaInicio;
  final DateTime fechaLimite;
  final double progreso; // <--- CAMBIO IMPORTANTE: de int a double
  final String estado;
  final String creadorUid;
  final List<String> miembrosUid;
  final List<RecursoMaterial> recursosMateriales;

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

  factory Proyecto.fromMap(Map<String, dynamic> map, String id) {
    List<RecursoMaterial> recursos = [];
    if (map['recursosMateriales'] != null) {
      recursos = (map['recursosMateriales'] as List)
          .map((recursoMap) => RecursoMaterial.fromMap(
              recursoMap as Map<String, dynamic>, 
              recursoMap['id'] ?? ''
          ))
          .toList();
    }

    return Proyecto(
      id: id,
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      fechaCreacion: (map['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaInicio: (map['fechaInicio'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaLimite: (map['fechaLimite'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // CAMBIO AQUI: .toDouble() asegura que lea 0.5 correctamente en lugar de redondear a 0
      progreso: (map['progreso'] ?? 0).toDouble(), 
      estado: map['estado'] ?? 'Activo',
      creadorUid: map['creadorUid'] ?? '',
      miembrosUid: List<String>.from(map['miembrosUid'] ?? []),
      recursosMateriales: recursos,
    );
  }

  Map<String, dynamic> toMap() {
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
      'recursosMateriales': recursosMateriales.map((r) => r.toMap()).toList(),
    };
  }

  Proyecto copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    DateTime? fechaCreacion,
    DateTime? fechaInicio,
    DateTime? fechaLimite,
    double? progreso, // <--- CAMBIO AQUI TAMBIÉN
    String? estado,
    String? creadorUid,
    List<String>? miembrosUid,
    List<RecursoMaterial>? recursosMateriales,
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
}