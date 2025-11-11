import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sistem_proyect/central/constantes/modelos/project_model.dart'; 
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart'; 
import 'package:sistem_proyect/central/constantes/servicios/project_service.dart'; 
import 'package:sistem_proyect/funcionalidades/Pantallas/proyectos/pantalla_crear_proyecto.dart'; 
import 'package:sistem_proyect/funcionalidades/Pantallas/Autenticacion/pantalla_editar_perfil.dart'; 
import 'package:sistem_proyect/funcionalidades/Pantallas/Autenticacion/pantalla_inicio_sesion.dart'; 
import 'package:sistem_proyect/funcionalidades/Pantallas/proyectos/project_card_widget.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/pantalla_principal.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/Widgets/widgets_principal.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/widgets/shared_footer_widget.dart';

class PantallaListadoProyectos extends StatefulWidget {
  const PantallaListadoProyectos({super.key});

  @override
  State<PantallaListadoProyectos> createState() => _PantallaListadoProyectosState();
}

class _PantallaListadoProyectosState extends State<PantallaListadoProyectos> {
  final ProjectService _projectService = ProjectService();
  final AuthService _authService = AuthService();
  
  bool _isAdmin = false;
  bool _isLoadingRole = true;
  String _searchQuery = '';
  // ELIMINAMOS: bool _isProfileHovered = false; 

  @override
  void initState() {
    super.initState();
    _checkIfAdmin(); 
  }

  Future<void> _checkIfAdmin() async {
    final roleResult = await _authService.getUserRole();
    if (mounted) {
      setState(() {
        _isAdmin = (roleResult == 'admin');
        _isLoadingRole = false;
      });
    }
  }

  String _getUserInitial(String? userName) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    return userEmail?.isNotEmpty == true ? userEmail![0].toUpperCase() : 'U';
  }

  Future<void> _cerrarSesion() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const PantallaInicioSesion()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _editarPerfil() {
    Navigator.of(context).pop(); 
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PantallaEditarPerfil()),
    );
  }

  void _mostrarMenuPerfil(BuildContext context, Offset offset) {
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        offset & const Size(40, 40), 
        Offset.zero & MediaQuery.of(context).size,
      ),
      items: const [
        PopupMenuItem<String>(value: 'perfil', child: Text('Editar Perfil')),
        PopupMenuItem<String>(value: 'cerrar', child: Text('Cerrar Sesión')),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value == 'perfil') {
        _editarPerfil();
      } else if (value == 'cerrar') {
        _cerrarSesion();
      }
    });
  }

  PreferredSizeWidget _buildAppBar(String userInitial, bool isDesktop) {
    final Color avatarColor = _isAdmin ? AppColors.accentColor : AppColors.primaryOrange; 
    
    // Usamos un StatefulWidget local para el avatar con hover
    final profileWidget = _HoverableAvatar(
      userInitial: userInitial,
      avatarColor: avatarColor,
      isDesktop: isDesktop,
      onTapDown: (details) => _mostrarMenuPerfil(context, details.globalPosition),
    );

    if (isDesktop) {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 60,
        title: Text('ProyectApp', style: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: false,
        actions: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const PantallaPrincipal()),
                      (Route<dynamic> route) => false,
                    );
                  }, 
                  child: const Text('Menú', style: TextStyle(color: Colors.black87)),
                ), 
                TextButton(onPressed: () {}, child: Text('Proyectos', style: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold))), 
                TextButton(onPressed: () {}, child: const Text('Calendario', style: TextStyle(color: Colors.black87))),
                TextButton(onPressed: () {}, child: const Text('Estadísticas', style: TextStyle(color: Colors.black87))),
              ],
            ),
          ),
          profileWidget,
        ],
      );
    } else {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Gestión de Proyectos', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black54), onPressed: () {}),
          profileWidget,
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userInitial = _getUserInitial(FirebaseAuth.instance.currentUser?.email);

    if (_isLoadingRole) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 800;
        final double horizontalPadding = isDesktop ? 40.0 : 20.0;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: _buildAppBar(userInitial, isDesktop), 
          
          body: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding, vertical: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, _isAdmin),
                      const SizedBox(height: 20),
                      
                      _buildSearchBar(),
                      const SizedBox(height: 40),
                      
                      _buildProjectList(isDesktop),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),

                SharedFooter(primaryOrange: AppColors.primaryOrange,
                    accentBlue: AppColors.accentColor),
              ],
            ),
          ),
          
          floatingActionButton: !_isAdmin || isDesktop 
              ? null
              : FloatingActionButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaCrearProyecto()));
                  },
                  backgroundColor:AppColors.primaryOrange, 
                  child: const Icon(Icons.add, color: Colors.white),
                ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isAdmin) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Gestión de Proyectos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
        if (isAdmin) 
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaCrearProyecto()));
            },
            icon: const Icon(Icons.add, color: Colors.white, size: 20),
            label: const Text('Nuevo Proyecto',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange, 
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 3,
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha:0.1), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value); 
              },
              decoration: const InputDecoration(
                hintText: 'Buscar proyectos por nombre...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange, 
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 14),
            ),
            child: const Text('Buscar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProjectList(bool isDesktop) {
    return StreamBuilder<List<Proyecto>>(
      stream: _projectService.getProyectosStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error al cargar proyectos: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
          );
        }
        
        List<Proyecto> proyectos = snapshot.data ?? [];
        
        if (_searchQuery.isNotEmpty) {
          proyectos = proyectos.where((p) => 
            p.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) || 
            p.descripcion.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
        }

        if (proyectos.isEmpty) {
            return const Center(
                child: Text('No hay proyectos creados o que coincidan con la búsqueda.', style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
            );
        }

        return GridView.builder(
          shrinkWrap: true, 
          physics: const NeverScrollableScrollPhysics(), 
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 3 : 1, 
            childAspectRatio: isDesktop ? 1.2 : 2.5, 
            crossAxisSpacing: 20.0,
            mainAxisSpacing: 20.0,
          ),
          itemCount: proyectos.length,
          itemBuilder: (context, index) {
            final proyecto = proyectos[index];
            return ProjectCardWidget(
              proyecto: proyecto,
              onTap: () {
                // Navegación a la pantalla de detalle/edición
              },
            );
          },
        );
      },
    );
  }
}

// Widget independiente para el avatar con hover
class _HoverableAvatar extends StatefulWidget {
  final String userInitial;
  final Color avatarColor;
  final bool isDesktop;
  final Function(TapDownDetails) onTapDown;

  const _HoverableAvatar({
    required this.userInitial,
    required this.avatarColor,
    required this.isDesktop,
    required this.onTapDown,
  });

  @override
  State<_HoverableAvatar> createState() => _HoverableAvatarState();
}

class _HoverableAvatarState extends State<_HoverableAvatar> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: widget.onTapDown,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          margin: EdgeInsets.only(right: widget.isDesktop ? 20 : 16),
          decoration: BoxDecoration(
            color: widget.avatarColor,
            shape: BoxShape.circle,
            boxShadow: _isHovered ? [
              BoxShadow(
                color: widget.avatarColor.withValues(alpha: 0.5),
                blurRadius: 12,
                offset: const Offset(0, 4)
              )
            ] : [],
          ),
          transform: Matrix4.diagonal3Values(
            _isHovered ? 1.05 : 1.0,
            _isHovered ? 1.05 : 1.0,
            1.0
          ),
          child: Text(
            widget.userInitial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }
}