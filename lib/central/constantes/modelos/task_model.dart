import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_proyect/central/constantes/modelos/recurso_model.dart';

class TaskModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String proyectoId;
  final String creadorUid; 
  final List<String> miembrosUid; 
  final List<RecursoMaterial> recursosAsignados;
  final DateTime? fechaInicio; 
  final DateTime? fechaVencimiento;
  final String prioridad; 
  final String estado; 
  final DateTime fechaCreacion;

  TaskModel({
    this.id = '',
    required this.nombre,
    this.descripcion = '',
    required this.proyectoId,
    required this.creadorUid,
    required this.miembrosUid,
    required this.recursosAsignados,
    this.fechaInicio, 
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
      'recursosAsignados': recursosAsignados
          .map((recurso) =>
              recurso.toMapWithId()) 
          .toList(),
      'fechaInicio':
          fechaInicio != null ? Timestamp.fromDate(fechaInicio!) : null,
      'fechaVencimiento': fechaVencimiento != null
          ? Timestamp.fromDate(fechaVencimiento!)
          : null,
      'prioridad': prioridad,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'estado': estado,
    };
  }

  // Crear TaskModel desde un Map de Firestore
  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      proyectoId: map['proyectoId'] ?? '',
      creadorUid: map['creadorUid'] ?? '',
      miembrosUid: List<String>.from(map['miembrosUid'] ?? []),
      recursosAsignados: (map['recursosAsignados'] as List<dynamic>?)
              ?.map((item) =>
                  RecursoMaterial.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      fechaInicio: map['fechaInicio'] != null
          ? (map['fechaInicio'] as Timestamp).toDate()
          : null,
      fechaVencimiento: map['fechaVencimiento'] != null
          ? (map['fechaVencimiento'] as Timestamp).toDate()
          : null,
      prioridad: map['prioridad'] ?? 'Media',
      fechaCreacion: (map['fechaCreacion'] as Timestamp).toDate(),
      estado: map['estado'] ?? 'Pendiente',
    );
  }
}
