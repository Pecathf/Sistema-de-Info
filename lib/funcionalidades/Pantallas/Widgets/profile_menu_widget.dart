import 'package:flutter/material.dart';
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/Autenticacion/pantalla_inicio_sesion.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/Autenticacion/pantalla_editar_perfil.dart';

/// Helper class para mostrar el menú de perfil reutilizable en todas las pantallas
class ProfileMenuHelper {
  static final AuthService _authService = AuthService();


  static void mostrarMenuPerfil(BuildContext context, Offset offset) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx - 150,
        offset.dy + 50,
        offset.dx,
        offset.dy,
      ),
      items: [
        PopupMenuItem(
          onTap: () => Future.delayed(Duration.zero, () => _editarPerfil(context)),
          child: const Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 12),
              Text('Editar Perfil'),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () => Future.delayed(Duration.zero, () => _cerrarSesion(context)),
          child: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red, size: 20),
              SizedBox(width: 12),
              Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  static void _editarPerfil(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PantallaEditarPerfil()),
    );
  }

  static Future<void> _cerrarSesion(BuildContext context) async {
    try {
      await _authService.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const PantallaInicioSesion()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }
}

/// Widget del avatar con hover que muestra el menú de perfil al hacer clic
/// Este widget es reutilizable en todas las pantallas
class HoverableProfileAvatar extends StatefulWidget {
  final String userInitial;
  final Color avatarColor;
  final bool isDesktop;

  const HoverableProfileAvatar({
    super.key,
    required this.userInitial,
    required this.avatarColor,
    required this.isDesktop,
  });

  @override
  State<HoverableProfileAvatar> createState() => _HoverableProfileAvatarState();
}

class _HoverableProfileAvatarState extends State<HoverableProfileAvatar> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (details) => ProfileMenuHelper.mostrarMenuPerfil(context, details.globalPosition),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          margin: EdgeInsets.only(right: widget.isDesktop ? 20 : 16),
          decoration: BoxDecoration(
            color: widget.avatarColor,
            shape: BoxShape.circle,
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.avatarColor.withValues(alpha: 0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          transform: Matrix4.diagonal3Values(
            _isHovered ? 1.05 : 1.0,
            _isHovered ? 1.05 : 1.0,
            1.0,
          ),
          child: Text(
            widget.userInitial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}