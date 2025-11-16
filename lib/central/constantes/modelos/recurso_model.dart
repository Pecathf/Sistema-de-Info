class RecursoMaterial {
  final String id;
  final String nombre;
  final int cantidad; 
  final int cantidadDisponible; 
  final String icono;
  final String? proyectoId; 

  RecursoMaterial({
    required this.id,
    required this.nombre,
    required this.cantidad,
    int? cantidadDisponible,
    this.icono = '📦',
    this.proyectoId,
  }) : cantidadDisponible = cantidadDisponible ?? cantidad;

  // Convertir de Firestore a Modelo
  factory RecursoMaterial.fromMap(Map<String, dynamic> map, String id) {
    final cantidad = map['cantidad'] ?? 0;
    return RecursoMaterial(
      id: id,
      nombre: map['nombre'] ?? '',
      cantidad: cantidad,
      cantidadDisponible: map['cantidadDisponible'] ?? cantidad,
      icono: map['icono'] ?? '📦',
      proyectoId: map['proyectoId'],
    );
  }

  // Convertir de Modelo a Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'cantidad': cantidad,
      'cantidadDisponible': cantidadDisponible,
      'icono': icono,
      if (proyectoId != null) 'proyectoId': proyectoId,
    };
  }

  // Método para crear una copia con campos modificados
  RecursoMaterial copyWith({
    String? id,
    String? nombre,
    int? cantidad,
    int? cantidadDisponible,
    String? icono,
    String? proyectoId,
  }) {
    return RecursoMaterial(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      cantidad: cantidad ?? this.cantidad,
      cantidadDisponible: cantidadDisponible ?? this.cantidadDisponible,
      icono: icono ?? this.icono,
      proyectoId: proyectoId ?? this.proyectoId,
    );
  }

  // Calcular cuántos recursos están siendo usados
  int get cantidadUsada => cantidad - cantidadDisponible;

  // Verificar si hay cantidad suficiente disponible
  bool tieneDisponible(int cantidadSolicitada) {
    return cantidadDisponible >= cantidadSolicitada;
  }
}