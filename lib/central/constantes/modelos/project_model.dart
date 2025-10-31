import 'package:cloud_firestore/cloud_firestore.dart';

class Proyecto {
  final String id;
  final String nombre;
  final String descripcion;
  final String estado; // Ejemplo: "Activo", "Completado", "Pendiente"
  final DateTime fechaCreacion;
  final List<String> miembros;
  
  // Constructor principal
  Proyecto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.estado,
    required this.fechaCreacion,
    required this.miembros,
  });

  // Método Factory para crear una instancia de Proyecto desde un mapa de Firestore
  factory Proyecto.fromMap(Map<String, dynamic> data, String id) {
    // 1. Intentamos obtener el campo 'fechaCreacion' como un objeto Timestamp opcional (Timestamp?).
    final timestamp = data['fechaCreacion'] as Timestamp?; 

    // 2. Si el timestamp es nulo (por si el campo no existe o está corrupto), 
    //    usamos DateTime.now() como valor predeterminado (fallback).
    //    Si NO es nulo, llamamos con seguridad a .toDate().
    final DateTime fecha = timestamp?.toDate() ?? DateTime.now();

    return Proyecto(
      id: id,
      nombre: data['nombre'] ?? 'Proyecto Sin Nombre',
      descripcion: data['descripcion'] ?? '',
      estado: data['estado'] ?? 'Pendiente',
      fechaCreacion: fecha, // Usamos la fecha ya validada
      miembros: List<String>.from(data['miembros'] ?? []),
    );
  }
  
  // Método para convertir la instancia de Proyecto a un mapa (para subir a Firestore)
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'estado': estado,
      // Al guardar, se recomienda usar FieldValue.serverTimestamp() o el DateTime convertido
      'fechaCreacion': Timestamp.fromDate(fechaCreacion), 
      'miembros': miembros,
    };
  }
}