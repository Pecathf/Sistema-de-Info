// Archivo: lib/funcionalidades/Pantallas/tareas/pantalla_crear_tarea.dart
// VERSIÓN MODIFICADA (Para coincidir con la imagen 'image_01c241.png')

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sistem_proyect/central/constantes/modelos/usuario_model.dart';
import 'package:sistem_proyect/central/constantes/servicios/user_data_service.dart';

// --- Importa tus modelos y servicios ---
import 'package:sistem_proyect/central/constantes/modelos/project_model.dart';
import 'package:sistem_proyect/central/constantes/modelos/task_model.dart';
import 'package:sistem_proyect/central/constantes/modelos/recurso_model.dart';
import 'package:sistem_proyect/central/constantes/servicios/task.service.dart';
import 'package:sistem_proyect/central/constantes/colores.dart'; // Asumo que esto contiene tus colores
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart';

// --- Importa tus DIÁLOGOS de selección (REUTILIZADOS) ---
import 'package:sistem_proyect/funcionalidades/Pantallas/proyectos/resource_selection_dialog.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/tareas/taskMemberSelection.dart';

// --- Importa los widgets compartidos (COMO EN 'pantalla_principal.dart') ---
// No necesitamos 'SharedFooter' porque lo recrearemos aquí para que coincida con la imagen
// import 'package:sistem_proyect/funcionalidades/Pantallas/Widgets/shared_footer_widget.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/Widgets/profile_menu_widget.dart';

// ======== INICIO DE MODIFICACIÓN: Constantes de color del diseño ========
// Si ya los tienes en 'colores.dart', puedes borrarlos.
// Los pongo aquí para que el código sea autocontenido.
const Color kAppRed = Color(0xFFE74C3C);
const Color kButtonOrange = Color(0xFFF39C12);
const Color kIconBlue = Color(0xFF3498DB);
const Color kDarkFooter = Color(0xFF343A40);
const Color kLightGrayBg = Color(0xFFF4F4F7);
const Color kDividerColor = Color(0xFFEEEEEE);
// ======== FIN DE MODIFICACIÓN ========

class PantallaCrearTarea extends StatefulWidget {
  final Proyecto proyecto;

  const PantallaCrearTarea({
    Key? key,
    required this.proyecto,
  }) : super(key: key);

  @override
  _PantallaCrearTareaState createState() => _PantallaCrearTareaState();
}

class _PantallaCrearTareaState extends State<PantallaCrearTarea> {
  // Servicios y estado
  final _formKey = GlobalKey<FormState>();
  // MODIFICADO: El formato de la imagen no tiene día, pero 'intl' es mejor
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  // --- Conexión a tus Servicios ---
  final TaskService _taskService = TaskService();
  final UserDataService _userDataService = UserDataService();
  final AuthService _authService = AuthService();
  bool _isAdmin = false;

  // Controladores
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  // --- MODIFICADO: Añadido controlador para fecha de inicio (como en la imagen) ---
  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _fechaLimiteController = TextEditingController();

  // Datos de la tarea
  DateTime? _fechaInicio; // MODIFICADO: Añadido
  DateTime? _fechaLimite;
  String _prioridad =
      'Media'; // Lo mantenemos por lógica, aunque no está en la imagen
  List<Usuario> _selectedMembers = [];
  List<RecursoMaterial> _selectedResources = [];

  // Datos del Proyecto (para el panel derecho)
  late Future<Usuario?> _creadorDelProyecto;
  late Future<List<Usuario>> _miembrosDelProyecto;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProjectData();
    _checkIfAdmin();
  }

  void _loadProjectData() {
    _creadorDelProyecto =
        _userDataService.getUsuarioById(widget.proyecto.creadorUid);
    _miembrosDelProyecto =
        _userDataService.getUsuariosByIds(widget.proyecto.miembrosUid);
  }

  Future<void> _checkIfAdmin() async {
    final isAdmin = await _authService.isAdmin();
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _fechaInicioController.dispose(); // MODIFICADO
    _fechaLimiteController.dispose(); // MODIFICADO
    super.dispose();
  }

  // --- LÓGICA DE FUNCIONAMIENTO (Sin cambios) ---

  // --- MODIFICADO: Función genérica para seleccionar fecha ---
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      // Puedes añadir el 'builder' de estilo que tenías en mi otra respuesta si quieres
    );
    if (picked != null) {
      setState(() {
        final formattedDate = _dateFormat.format(picked);
        if (isStartDate) {
          _fechaInicio = picked;
          _fechaInicioController.text = formattedDate;
        } else {
          _fechaLimite = picked;
          _fechaLimiteController.text = formattedDate;
        }
      });
    }
  }

  void _selectMembers() async {
    final availableUsers = await _miembrosDelProyecto;

    final List<Usuario>? result = await showDialog(
      context: context,
      builder: (_) => TaskMemberSelectionDialog(
        initialSelectedMembers: _selectedMembers,
        availableUsers: availableUsers,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedMembers = result;
      });
    }
  }

  void _selectResources() async {
    final List<RecursoMaterial>? result = await showDialog(
      context: context,
      builder: (_) => ResourceSelectionDialog(
        initialSelectedResources: _selectedResources,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedResources = result;
      });
    }
  }

  Future<void> _crearTarea() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaLimite == null || _fechaInicio == null) {
      // MODIFICADO
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona ambas fechas.')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error: No se pudo encontrar el usuario.')));
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final nuevaTarea = TaskModel(
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      proyectoId: widget.proyecto.id,
      creadorUid: user.uid,
      miembrosUid: _selectedMembers.map((m) => m.uid).toList(),
      recursosAsignados: _selectedResources,
      fechaVencimiento: _fechaLimite,
      // NOTA: El campo 'fechaInicio' no está en tu 'TaskModel' del código original.
      // Si lo necesitas, debes añadirlo al modelo.
      prioridad: _prioridad, // Tu lógica lo usa
      estado: 'Pendiente',
      fechaCreacion: DateTime.now(),
    );

    try {
      await _taskService.crearTarea(nuevaTarea);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarea creada exitosamente')));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al crear la tarea: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ---
  // PANTALLA COMPLETA (build) - MODIFICADO
  // ---
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String userInitial = (user?.email?[0] ?? 'U').toUpperCase();
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    // Usamos el NUEVO AppBar que coincide con la imagen
    final appBar = _buildCustomAppBar(userInitial, isDesktop);

    return Scaffold(
      appBar: appBar, // AppBar blanco con links
      backgroundColor: kLightGrayBg, // Fondo gris claro
      body: SingleChildScrollView(
        child: Center(
          // Centra el contenido
          child: Column(
            children: [
              // Panel principal (UNA TARJETA)
              Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 24.0),
                child: _buildTaskPanel(
                    context), // Widget que contiene las 2 columnas
              ),
              const SizedBox(height: 20),

              // Botón "Volver" (AÑADIDO)
              _buildBackButton(),
              const SizedBox(height: 30),

              // Footer (AÑADIDO)
              _buildCustomFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  // ---
  // WIDGETS DE LA PANTALLA (MODIFICADOS)
  // ---

  /// MODIFICADO: Este es el AppBar blanco de tu imagen
  PreferredSizeWidget _buildCustomAppBar(String userInitial, bool isDesktop) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      automaticallyImplyLeading: false, // La imagen no tiene flecha de "atrás"
      toolbarHeight: 70,
      title: RichText(
        text: const TextSpan(
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'Poppins'), // Asegúrate de tener la fuente Poppins
          children: [
            TextSpan(text: "Proyect"),
            TextSpan(text: "App", style: TextStyle(color: kAppRed)),
          ],
        ),
      ),
      actions: [
        if (isDesktop) ...[
          _navLink("Menú"),
          _navLink("Proyectos"),
          _navLink("Calendario"),
          _navLink("Estadísticas"),
        ],
        // Reutilizamos el 'HoverableProfileAvatar' de tu código original
        HoverableProfileAvatar(
          authService: _authService,
          isAdmin: _isAdmin,
          userInitial: userInitial,
          isDesktop: isDesktop,
          // Usa el color de tu app, asumo que 'accentColor' es el azul
          avatarColor: AppColors.accentColor,
        ),
      ],
    );
  }

  // AÑADIDO: Helper para los links del AppBar
  Widget _navLink(String title) {
    return TextButton(
      onPressed: () {},
      child: Text(
        title,
        style: const TextStyle(color: Colors.black54, fontSize: 16),
      ),
    );
  }

  /// AÑADIDO: Widget que crea la tarjeta blanca con 2 columnas
  Widget _buildTaskPanel(BuildContext context) {
    bool isWideScreen = MediaQuery.of(context).size.width > 800;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: isWideScreen
            ? Row(
                // Versión ancha (Web/Tablet)
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildTaskForm()), // Formulario
                  const SizedBox(width: 28),
                  Container(
                      width: 1, height: 450, color: kDividerColor), // Divisor
                  const SizedBox(width: 28),
                  Expanded(flex: 1, child: _buildResourcesPanel()), // Recursos
                ],
              )
            : Column(
                // Versión estrecha (Móvil)
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTaskForm(),
                  const Divider(height: 40, thickness: 1, color: kDividerColor),
                  _buildResourcesPanel(),
                ],
              ),
      ),
    );
  }

  /// MODIFICADO: Formulario (Panel Izquierdo)
  /// Limpiado para que solo tenga los campos de la imagen
  Widget _buildTaskForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Crear Tarea',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          const SizedBox(height: 24),

          _buildFormTextField(
            label: "Nombre de la Tarea",
            controller: _nombreController,
            validator: (value) => (value == null || value.isEmpty)
                ? 'El nombre es obligatorio'
                : null,
          ),
          const SizedBox(height: 16),

          _buildFormTextField(
            label: "Descripción",
            controller: _descripcionController,
            maxLines: 3, // Ajustado
          ),
          const SizedBox(height: 16),

          // Campo "Fecha de inicio" (de la imagen)
          _buildFormDateField(
            context: context,
            label: "Fecha de inicio",
            controller: _fechaInicioController,
            onTap: () => _selectDate(context, true), // true para isStartDate
          ),
          const SizedBox(height: 16),

          // Campo "Fecha límite" (de la imagen)
          _buildFormDateField(
            context: context,
            label: "Fecha límite",
            controller: _fechaLimiteController,
            onTap: () => _selectDate(context, false), // false para isStartDate
          ),
          const SizedBox(height: 16),

          // --- CAMPO "AGREGAR MIEMBROS" (de la imagen) ---
          // La lógica de selección se movió al panel derecho,
          // pero el campo del form está en la imagen.
          _buildFormTextField(
            label: "Agregar miembros",
            readOnly: true, // Este campo solo muestra
            hintText: '${_selectedMembers.length} miembros asignados',
            onTap: _selectMembers, // Tocarlo abre el selector
            suffixIcon: Icon(Icons.add_circle, color: kIconBlue),
          ),
          const SizedBox(height: 24),

          Center(
            child: _isLoading
                ? CircularProgressIndicator(color: AppColors.primaryOrange)
                : ElevatedButton(
                    child: Text('Crear'), // Texto de la imagen
                    onPressed: _crearTarea,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      minimumSize:
                          const Size(double.infinity, 52), // Full width
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// MODIFICADO: Panel de Recursos (Panel Derecho)
  /// Ahora contiene la lógica de selección, como en la imagen
  Widget _buildResourcesPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recursos',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        const SizedBox(height: 24),

        // 1. Observador (del código original)
        Text('Observador (Creador)',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Colors.grey[600])),
        FutureBuilder<Usuario?>(
          future: _creadorDelProyecto,
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const ListTile(title: Text('Cargando...'));
            final creador = snapshot.data!;
            String initial = creador.nombre.isNotEmpty
                ? creador.nombre.substring(0, 2).toUpperCase()
                : "U";
            // Estilizado como en la imagen
            return _ResourceInfoTile(
              title: "Observador",
              subtitle: creador.nombre,
              avatarContent: CircleAvatar(
                  backgroundColor: kIconBlue,
                  radius: 18,
                  child: Text(initial,
                      style: TextStyle(color: Colors.white, fontSize: 12))),
            );
          },
        ),
        const SizedBox(height: 16),

        // 2. Recursos Humanos (MODIFICADO con lógica de selección)
        _ResourceInfoTile(
          title: "Recursos Humanos",
          subtitle:
              "${_selectedMembers.length} miembro(s)\n${_selectedMembers.map((e) => e.nombre).join(', ')}",
          avatarContent: CircleAvatar(
              backgroundColor: kIconBlue,
              radius: 18,
              child: Text(_selectedMembers.length.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 12))),
          trailing: IconButton(
            icon: Icon(Icons.add_circle, color: kIconBlue, size: 28),
            onPressed: _selectMembers, // La lógica ya existe
          ),
        ),
        const SizedBox(height: 16),

        // 3. Recursos Materiales (MODIFICADO con lógica de selección)
        _ResourceInfoTile(
          title: "Recursos Materiales",
          subtitle:
              "${_selectedResources.length} recurso(s)\n${_selectedResources.map((e) => e.nombre).join(', ')}",
          // Puedes poner un icono si quieres
          // avatarContent: CircleAvatar(backgroundColor: kIconBlue, ...),
          trailing: IconButton(
            icon: Icon(Icons.add_circle, color: kIconBlue, size: 28),
            onPressed: _selectResources, // La lógica ya existe
          ),
        ),
      ],
    );
  }

  /// AÑADIDO: Botón "Volver"
  Widget _buildBackButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kButtonOrange,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
        child: const Text("Volver",
            style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  /// AÑADIDO: Footer de dos partes (como en la imagen)
  Widget _buildCustomFooter(BuildContext context) {
    // Reemplaza 'SharedFooter' para que coincida con la imagen
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: kDarkFooter,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Builder(
                builder: (context) {
                  bool isWideScreen = MediaQuery.of(context).size.width > 800;
                  // Contenido del footer (Brand, Links, Ayuda)
                  Widget brand = _buildFooterBrand();
                  Widget links = _buildFooterLinks();
                  Widget help = _buildFooterHelp();

                  if (isWideScreen) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [brand, links, help],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        brand,
                        const SizedBox(height: 24),
                        links,
                        const SizedBox(height: 24),
                        help,
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ),
        // Barra naranja inferior
        Container(
          width: double.infinity,
          color: kButtonOrange,
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Center(
            child: Text("2025 ProyectApp. UNIMET. Derechos Reservados.",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 13)),
          ),
        ),
      ],
    );
  }

  // --- Helpers para el Footer (Añadidos) ---
  Widget _buildFooterBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins'),
            children: [
              TextSpan(text: "Proyect"),
              TextSpan(text: "App", style: TextStyle(color: kAppRed)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
            "Sistema de Gestión de proyectos para Ingeniería\nen la Universidad Metropolitana",
            style: TextStyle(color: Colors.grey[400], fontSize: 13)),
      ],
    );
  }

  Widget _buildFooterLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Links",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Iniciar Sesión",
            style: TextStyle(color: Colors.grey[400], fontSize: 13)),
        const SizedBox(height: 4),
        Text("Registro",
            style: TextStyle(color: Colors.grey[400], fontSize: 13)),
      ],
    );
  }

  Widget _buildFooterHelp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Ayuda",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Email: ayuda@proyectapp.unimet.edu.ve",
            style: TextStyle(color: Colors.grey[400], fontSize: 13)),
        const SizedBox(height: 4),
        Text("Contacto: 02120000000",
            style: TextStyle(color: Colors.grey[400], fontSize: 13)),
        const SizedBox(height: 8),
        const Icon(Icons.camera_alt,
            color: Colors.white, size: 24), // Icono de Instagram
      ],
    );
  }

  // --- Helpers para el Formulario (Añadidos) ---
  Widget _buildFormTextField({
    required String label,
    TextEditingController? controller,
    String? hintText,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool readOnly = false,
    Widget? suffixIcon,
    void Function()? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.black87, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hintText,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey[400]!)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey[400]!)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildFormDateField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required void Function() onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.black87, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'yyyy-mm-dd',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey[400]!)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey[400]!)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon:
                const Icon(Icons.calendar_today_outlined, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  // --- Helper para los items de Recursos (Añadido) ---
  Widget _ResourceInfoTile({
    required String title,
    required String subtitle,
    Widget? avatarContent,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (avatarContent != null) ...[
                  avatarContent,
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style:
                              TextStyle(fontSize: 15, color: Colors.grey[600])),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: const TextStyle(
                              fontSize: 16, // Ajustado
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing,
          ]
        ],
      ),
    );
  }
} // Fin de _PantallaCrearTareaState

// ---
// WIDGET COPIADO (y corregido de tu código original)
// ---
class HoverableProfileAvatar extends StatefulWidget {
  final AuthService authService;
  final bool isAdmin;
  final String userInitial;
  final bool isDesktop;
  final Color avatarColor;

  const HoverableProfileAvatar({
    super.key,
    required this.authService,
    required this.isAdmin,
    required this.userInitial,
    required this.isDesktop,
    required this.avatarColor,
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
        onTapDown: (details) {
          // Asumo que 'ProfileMenuHelper' existe en tu 'profile_menu_widget.dart'
          ProfileMenuHelper.mostrarMenuPerfil(context, details.globalPosition);
        },
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
                      color: widget.avatarColor.withOpacity(0.5),
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
