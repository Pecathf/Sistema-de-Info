import '/funcionalidades/autenticacion/modelo_usuario.dart';

class ServicioUsuario {
  static Usuario _usuarioActual = Usuario(
    id: '1',
    nombre: 'Usuario Ejemplo',
    correo: 'usuario@example.com',
    telefono: '+1234567890',
    biografia: 'Biografía del usuario',
  );

  static Usuario get usuarioActual => _usuarioActual;

  static Future<bool> actualizarPerfil(Usuario usuarioActualizado) async {
    await Future.delayed(const Duration(seconds: 1));
    _usuarioActual = usuarioActualizado;
    return true;
  }

  static Future<bool> actualizarImagenPerfil(String rutaImagen) async {
    await Future.delayed(const Duration(seconds: 1));
    _usuarioActual = _usuarioActual.copyWith(imagenPerfil: rutaImagen);
    return true;
  }
}
