import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_proyect/central/constantes/modelos/recurso_model.dart';

class TaskModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String proyectoId;
  final String creadorUid; // Quién creó la tarea
  final List<String> miembrosUid; // UIDs de los miembros asignados
  final List<RecursoMaterial> recursosAsignados; // Lista de recursos
  final DateTime? fechaInicio; // NUEVO CAMPO
  final DateTime? fechaVencimiento;
  final String prioridad; // 'Alta', 'Media', 'Baja'
  final String estado; // 'Pendiente', 'En Progreso', 'Completada'
  final DateTime fechaCreacion;

  TaskModel({
    this.id = '',
    required this.nombre,
    this.descripcion = '',
    required this.proyectoId,
    required this.creadorUid,
    required this.miembrosUid,
    required this.recursosAsignados,
    this.fechaInicio, // NUEVO CAMPO
    this.fechaVencimiento,
    this.prioridad = 'Media',
    this.estado = 'Pendiente',
    required this.fechaCreacion,
  });

  // Convertir TaskModel a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'proyectoId': proyectoId,
      'creadorUid': creadorUid,
      'miembrosUid': miembrosUid,
      'recursosAsignados': recursosAsignados.map((r) => r.toMap()).toList(),
      'fechaInicio': fechaInicio != null
          ? Timestamp.fromDate(fechaInicio!)
          : null, // NUEVO CAMPO
      'fechaVencimiento': fechaVencimiento != null
          ? Timestamp.fromDate(fechaVencimiento!)
          : null,
      'prioridad': prioridad,
      'estado': estado,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }

  // Crear TaskModel desde un Map de Firestore
  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      nombre: map['nombre'] as String? ?? '',
      descripcion: map['descripcion'] as String? ?? '',
      proyectoId: map['proyectoId'] as String? ?? '',
      creadorUid: map['creadorUid'] as String? ?? '',
      miembrosUid:
          List<String>.from(map['miembrosUid'] as List<dynamic>? ?? []),
      recursosAsignados: (map['recursosAsignados'] as List<dynamic>? ?? [])
          .map((r) => RecursoMaterial.fromMap(
              r as Map<String, dynamic>, r['id'] as String? ?? ''))
          .toList(),
      fechaInicio: (map['fechaInicio'] as Timestamp?)?.toDate(), // NUEVO CAMPO
      fechaVencimiento: (map['fechaVencimiento'] as Timestamp?)?.toDate(),
      prioridad: map['prioridad'] as String? ?? 'Media',
      estado: map['estado'] as String? ?? 'Pendiente',
      fechaCreacion: (map['fechaCreacion'] as Timestamp).toDate(),
    );
  }
}
