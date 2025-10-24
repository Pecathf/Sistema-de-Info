class Usuario {
  final String id;
  String nombre;
  String correo;
  String? telefono;
  String? imagenPerfil;
  String? biografia;

  Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    this.telefono,
    this.imagenPerfil,
    this.biografia,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'imagenPerfil': imagenPerfil,
      'biografia': biografia,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      correo: map['correo'] ?? '',
      telefono: map['telefono'],
      imagenPerfil: map['imagenPerfil'],
      biografia: map['biografia'],
    );
  }

  Usuario copyWith({
    String? nombre,
    String? correo,
    String? telefono,
    String? imagenPerfil,
    String? biografia,
  }) {
    return Usuario(
      id: id,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      imagenPerfil: imagenPerfil ?? this.imagenPerfil,
      biografia: biografia ?? this.biografia,
    );
  }
}
