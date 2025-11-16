class RecursoMaterial {
  final String id;
  final String nombre;
  final int cantidad;
  final String icono; 

  RecursoMaterial({
    required this.id,
    required this.nombre,
    required this.cantidad,
    this.icono = '📦', 
  });

  // Convertir de Firestore a Modelo
  factory RecursoMaterial.fromMap(Map<String, dynamic> map, String id) {
    return RecursoMaterial(
      id: id,
      nombre: map['nombre'] ?? '',
      cantidad: map['cantidad'] ?? 0,
      icono: map['icono'] ?? '📦',
    );
  }

  // Convertir de Modelo a Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'cantidad': cantidad,
      'icono': icono,
    };
  }

  // Método para crear una copia con campos modificados
  RecursoMaterial copyWith({
    String? id,
    String? nombre,
    int? cantidad,
    String? icono,
  }) {
    return RecursoMaterial(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      cantidad: cantidad ?? this.cantidad,
      icono: icono ?? this.icono,
    );
  }
}