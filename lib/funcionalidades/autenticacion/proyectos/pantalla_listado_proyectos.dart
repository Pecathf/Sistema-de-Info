// Archivo: pantalla_listado_proyectos.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// 🚨 Revisa estas rutas según tu estructura
import 'package:sistem_proyect/central/constantes/modelos/project_model.dart'; 
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart'; 
import 'package:sistem_proyect/central/constantes/servicios/project_service.dart'; 
import 'package:sistem_proyect/funcionalidades/autenticacion/proyectos/pantalla_crear_proyecto.dart'; 
import 'package:sistem_proyect/funcionalidades/autenticacion/pantalla_editar_perfil.dart'; 
import 'package:sistem_proyect/funcionalidades/autenticacion/pantalla_inicio_sesion.dart'; 
import 'package:sistem_proyect/funcionalidades/autenticacion/proyectos/project_card_widget.dart'; 
// Importaciones adicionales que podrías necesitar para navegación (ejemplo)
// import 'package:sistem_proyect/funcionalidades/principal/pantalla_principal.dart'; 

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
  bool _isProfileHovered = false; 

  // Colores simulados para consistencia con tu diseño (Naranja y Azul)
  final Color _primaryOrange = const Color(0xFFFF6633); 
  final Color _accentBlue = const Color(0xFF00BFFF); 

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

  // ============== FUNCIONES DE PERFIL/AUTENTICACIÓN (COPIADAS) ==============
  
  String _getUserInitial(String? userName) {
    // Intenta obtener la inicial del email si el nombre no está disponible
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

  // 🎯 WIDGET DEL APPBAR COMPLETO
  PreferredSizeWidget _buildAppBar(String userInitial, bool isDesktop) {
    final Color avatarColor = _isAdmin ? _accentBlue : _primaryOrange; 
    
    final profileWidget = MouseRegion(
      onEnter: (_) => setState(() => _isProfileHovered = true),
      onExit: (_) => setState(() => _isProfileHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (details) => _mostrarMenuPerfil(context, details.globalPosition),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          margin: EdgeInsets.only(right: isDesktop ? 20 : 16),
          decoration: BoxDecoration(
            color: avatarColor,
            shape: BoxShape.circle,
            boxShadow: _isProfileHovered ? [BoxShadow(color: avatarColor.withOpacity(0.5), blurRadius: 12, offset: const Offset(0, 4))] : [],
          ),
          transform: Matrix4.diagonal3Values(_isProfileHovered ? 1.05 : 1.0, _isProfileHovered ? 1.05 : 1.0, 1.0),
          child: Text(userInitial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );

    if (isDesktop) {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 60,
        title: Text('ProyectApp', style: TextStyle(color: _primaryOrange, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: false,
        actions: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: () {}, child: const Text('Menú', style: TextStyle(color: Colors.black87))), 
                TextButton(onPressed: () {}, child: Text('Proyectos', style: TextStyle(color: _primaryOrange, fontWeight: FontWeight.bold))), 
                TextButton(onPressed: () {}, child: const Text('Calendario', style: TextStyle(color: Colors.black87))),
                TextButton(onPressed: () {}, child: const Text('Estadísticas', style: TextStyle(color: Colors.black87))),
              ],
            ),
          ),
          profileWidget,
        ],
      );
    } else {
      // Versión Móvil
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Gestión de Proyectos', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black54), onPressed: () {}),
          profileWidget,
        ],
      );
    }
  }
  
  // 🎯 WIDGET AUXILIAR DEL FOOTER (Sección de columna)
  Widget _buildFooterSection(BuildContext context, String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
        const SizedBox(height: 15),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {},
                  child: Text(link, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                ),
              ),
            )),
      ],
    );
  }

  // 🎯 WIDGET DEL FOOTER COMPLETO (Estructura de secciones)
  Widget _buildFooter(BuildContext context, bool isMobile) {
    final linksAcerca = ['Nosotros', 'Equipo','Carreras'];
    final linksServicios = ['Gestión de Proyectos', 'Asignación de Tareas'];
    final linksContacto = ['Soporte','Blog', 'Preguntas Frecuentes'];

    return Container(
      padding: EdgeInsets.only(top: 40, bottom: isMobile ? 80 : 20, left: 40, right: 40),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: _primaryOrange, width: 4)), 
      ),
      child: Column(
        children: [
          if (!isMobile) 
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFooterSection(context, 'Acerca de', linksAcerca),
                  _buildFooterSection(context, 'Servicios', linksServicios),
                  _buildFooterSection(context, 'Contacto', linksContacto),
                ],
              ),
            )
          else 
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFooterSection(context, 'Acerca de', linksAcerca),
                  const SizedBox(height: 20),
                  _buildFooterSection(context, 'Servicios', linksServicios),
                  const SizedBox(height: 20),
                  _buildFooterSection(context, 'Contacto', linksContacto),
                ],
              ),
            ),
          
          Divider(color: Colors.grey[300]),
          const Text(
            '2025 ProyectApp UNIMET. Derechos Reservados.',
            style: TextStyle(color: Colors.black54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  // =========================================================================

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
                      // 1. Encabezado (Título + Botón Nuevo Proyecto)
                      _buildHeader(context, _isAdmin),
                      const SizedBox(height: 20),
                      
                      // 2. Barra de Búsqueda
                      _buildSearchBar(),
                      const SizedBox(height: 40),
                      
                      // 3. Listado de Proyectos en Grid
                      _buildProjectList(isDesktop),
                      
                      const SizedBox(height: 30),
                      // 4. Barra de Estadísticas
                      // Si tienes un widget de estadísticas, agrégalo aquí (ej: const PendingTasksCard())
                    ],
                  ),
                ),
                
                // Footer
                _buildFooter(context, !isDesktop), 
              ],
            ),
          ),
          
          // Botón flotante
          floatingActionButton: !_isAdmin || isDesktop 
              ? null
              : FloatingActionButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaCrearProyecto()));
                  },
                  backgroundColor: _primaryOrange, 
                  child: const Icon(Icons.add, color: Colors.white),
                ),
        );
      },
    );
  }

  // ---------------- WIDGETS DE CONTENIDO (Cuerpo) ----------------

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
              backgroundColor: _primaryOrange, 
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
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 1)),
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
              backgroundColor: _primaryOrange, 
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
            return Center(
                child: Text('No hay proyectos creados o que coincidan con la búsqueda.', style: const TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
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