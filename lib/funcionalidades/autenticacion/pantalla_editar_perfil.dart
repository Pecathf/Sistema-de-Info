import 'package:flutter/material.dart';
import '../../central/constantes/colores.dart';
import '../../central/constantes/servicio_usuario.dart';

class PantallaEditarPerfil extends StatefulWidget {
  const PantallaEditarPerfil({Key? key}) : super(key: key);

  @override
  State<PantallaEditarPerfil> createState() => _PantallaEditarPerfilState();
}

class _PantallaEditarPerfilState extends State<PantallaEditarPerfil> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _controladorNombre;
  late TextEditingController _controladorCorreo;
  late TextEditingController _controladorTelefono;
  late TextEditingController _controladorBiografia;

  bool _cargando = false;
  String? _imagenPerfil;

  @override
  void initState() {
    super.initState();
    final usuario = ServicioUsuario.usuarioActual;
    _controladorNombre = TextEditingController(text: usuario.nombre);
    _controladorCorreo = TextEditingController(text: usuario.correo);
    _controladorTelefono = TextEditingController(text: usuario.telefono);
    _controladorBiografia = TextEditingController(text: usuario.biografia);
    _imagenPerfil = usuario.imagenPerfil;
  }

  @override
  void dispose() {
    _controladorNombre.dispose();
    _controladorCorreo.dispose();
    _controladorTelefono.dispose();
    _controladorBiografia.dispose();
    super.dispose();
  }

  Future<void> _guardarPerfil() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _cargando = true;
      });

      try {
        final usuarioActualizado = ServicioUsuario.usuarioActual.copyWith(
          nombre: _controladorNombre.text,
          correo: _controladorCorreo.text,
          telefono: _controladorTelefono.text,
          biografia: _controladorBiografia.text,
          imagenPerfil: _imagenPerfil,
        );

        final exito =
            await ServicioUsuario.actualizarPerfil(usuarioActualizado);

        if (exito) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perfil actualizado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _cargando = false;
          });
        }
      }
    }
  }

  Future<void> _seleccionarImagen() async {
    setState(() {
      _imagenPerfil = 'https://via.placeholder.com/150';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: AppColors.primaryOrange, // Usando tu color naranja
        actions: [
          if (_cargando)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.white),
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _seleccionarImagen,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _imagenPerfil != null
                          ? NetworkImage(_imagenPerfil!)
                          : null,
                      child: _imagenPerfil == null
                          ? const Icon(Icons.person,
                              size: 60, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Toca para cambiar foto',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _controladorNombre,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controladorCorreo,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (valor) {
                  if (valor == null || valor.isEmpty) {
                    return 'Por favor ingresa tu correo';
                  }
                  if (!valor.contains('@')) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controladorTelefono,
                decoration: const InputDecoration(
                  labelText: 'Teléfono (opcional)',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controladorBiografia,
                decoration: const InputDecoration(
                  labelText: 'Biografía (opcional)',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _guardarPerfil,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primaryOrange, // Tu color naranja
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _cargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'GUARDAR CAMBIOS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
