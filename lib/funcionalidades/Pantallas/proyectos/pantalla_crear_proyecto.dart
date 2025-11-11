import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sistem_proyect/central/constantes/modelos/project_model.dart';
import 'package:sistem_proyect/central/constantes/modelos/usuario_model.dart';
import 'package:sistem_proyect/central/constantes/servicios/auth_service.dart';
import 'package:sistem_proyect/central/constantes/servicios/project_service.dart';
import 'package:sistem_proyect/central/constantes/servicios/user_data_service.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/proyectos/pantalla_listado_proyectos.dart'; 
import 'package:sistem_proyect/funcionalidades/Pantallas/proyectos/member_selection_dialog.dart'; 
import 'package:sistem_proyect/funcionalidades/Pantallas/pantalla_principal.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/Widgets/widgets_principal.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/Widgets/shared_footer_widget.dart';
import 'package:sistem_proyect/funcionalidades/Pantallas/Widgets/profile_menu_widget.dart';


class PantallaCrearProyecto extends StatefulWidget {
  const PantallaCrearProyecto({super.key});

  @override
  State<PantallaCrearProyecto> createState() => _PantallaCrearProyectoState();
}

class _PantallaCrearProyectoState extends State<PantallaCrearProyecto> {
  final _formKey = GlobalKey<FormState>();
  final ProjectService _projectService = ProjectService();
  final AuthService _authService = AuthService();
  final UserDataService _userDataService = UserDataService(); 
  
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _recursosMaterialesController = TextEditingController();
  
  DateTime? _fechaInicio;
  DateTime? _fechaLimite;
  List<Usuario> _selectedMembers = []; 

  bool _isAdmin = false;
  bool _isLoadingRole = true;


  @override
  void initState() {
    super.initState();
    _checkIfAdmin(); 
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _recursosMaterialesController.dispose();
    super.dispose();
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

  Future<DateTime?> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary:  AppColors.primaryOrange,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    return picked;
  }
  
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _createProject() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_fechaInicio == null || _fechaLimite == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona las fechas de inicio y límite.')),
        );
        return;
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes iniciar sesión para crear un proyecto.')),
        );
        return;
      }

      try {
        final Proyecto newProject = Proyecto(
          id: '', 
          nombre: _nombreController.text,
          descripcion: _descripcionController.text,
          fechaCreacion: DateTime.now(),
          fechaInicio: _fechaInicio!,
          fechaLimite: _fechaLimite!,
          progreso: 0,
          estado: 'Pendiente',
          creadorUid: currentUser.uid,
          miembrosUid: _selectedMembers.map((e) => e.uid).toList(),
          recursosMateriales: _recursosMaterialesController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
        );

        await _projectService.crearProyecto(newProject); 

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proyecto creado exitosamente!')),
        );
        
      
        Navigator.of(context).pop();

      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear proyecto: $e')),
        );
      }
    }
  }

  String _getUserInitial(String? userName) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    return userEmail?.isNotEmpty == true ? userEmail![0].toUpperCase() : 'U';
  }

  

 PreferredSizeWidget _buildAppBar(String userInitial, bool isDesktop) {
  final Color avatarColor = _isAdmin ? AppColors.accentColor : AppColors.primaryOrange; 
  
   final profileWidget = HoverableProfileAvatar(
    userInitial: userInitial,
    avatarColor: avatarColor,
    isDesktop: isDesktop,
  );

  if (isDesktop) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 60,
      title: Text(
        'ProyectApp',
        style: TextStyle(
          color: AppColors.primaryOrange,
          fontWeight: FontWeight.bold,
          fontSize: 20
        )
      ),
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
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const PantallaListadoProyectos()),
                    (Route<dynamic> route) => false,
                  );
                }, 
                child: Text(
                  'Proyecto',
                  style: TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.bold
                  )
                ),
              ), 
              TextButton(
                onPressed: () {},
                child: const Text('Calendario', style: TextStyle(color: Colors.black87))
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Estadísticas', style: TextStyle(color: Colors.black87))
              ),
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
      title: const Text(
        'Crear Nuevo Proyecto',
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)
      ),
      actions: [
        profileWidget,
      ],
    );
  }
}
  
  // FOOTER REUTILIZABLE 
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
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),

                      isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),

                      const SizedBox(height: 30),

                      Center(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); 
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryOrange, 
                            side: BorderSide(color: AppColors.primaryOrange),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Volver', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),            
                
                SharedFooter(primaryOrange: AppColors.primaryOrange,
                    accentBlue: AppColors.accentColor),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildProjectForm()),
        const SizedBox(width: 40), 
        Expanded(child: _buildResourcesPanel()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildProjectForm(),
        const SizedBox(height: 30), 
        _buildResourcesPanel(),
      ],
    );
  }

  Widget _buildProjectForm() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Crear Proyecto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              _buildTextField(_nombreController, 'Nombre del Proyecto', validator: (value) {
                if (value == null || value.isEmpty) return 'Por favor ingresa un nombre.';
                return null;
              }),
              const SizedBox(height: 15),
              _buildTextField(_descripcionController, 'Descripción', maxLines: 3, validator: (value) {
                if (value == null || value.isEmpty) return 'Por favor ingresa una descripción.';
                return null;
              }),
              const SizedBox(height: 15),
              
              _buildDateField(context, 'Fecha de Inicio', _fechaInicio, (date) => setState(() => _fechaInicio = date), isStartDate: true),
              const SizedBox(height: 15),
              _buildDateField(context, 'Fecha Límite', _fechaLimite, (date) => setState(() => _fechaLimite = date), isStartDate: false),
              const SizedBox(height: 15),

              _buildTextField(_recursosMaterialesController, 'Recursos Materiales (separados por coma)', maxLines: 2, isOptional: true),
              const SizedBox(height: 20),
              
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final List<Usuario>? result = await showDialog<List<Usuario>>(
                      context: context,
                      builder: (context) => MemberSelectionDialog(
                        userDataService: _userDataService,
                        initialSelectedMembers: _selectedMembers,
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        _selectedMembers = result;
                      });
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: const Text('Agregar miembros', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: _createProject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 3,
                  ),
                  child: const Text('Crear', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, String? Function(String?)? validator, bool isOptional = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryOrange, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      validator: isOptional ? null : validator,
    );
  }

  Widget _buildDateField(BuildContext context, String label, DateTime? date, Function(DateTime) onDateSelected, {required bool isStartDate}) {
    return InkWell(
      onTap: () async {
        final picked = await _selectDate(context, isStartDate);
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Seleccionar fecha',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primaryOrange, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          suffixIcon: Icon(Icons.calendar_today, color: AppColors.primaryOrange),
        ),
        child: Text(
          _formatDate(date),
          style: TextStyle(
            color: date == null ? Colors.grey : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildResourcesPanel() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recursos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            Text('Recursos Humanos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            const SizedBox(height: 10),
            Text('${_selectedMembers.length}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryOrange)),
            const SizedBox(height: 15),
            
            if (_selectedMembers.isNotEmpty)
              Column(
                children: _selectedMembers.map((member) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: member.uid.hashCode.isEven ? AppColors.accentColor : AppColors.primaryOrange, 
                        child: Text(
                          member.nombre.isNotEmpty ? member.nombre[0].toUpperCase() : (member.email.isNotEmpty ? member.email[0].toUpperCase() : '?'),
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          member.nombre.isNotEmpty ? member.nombre : member.email,
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              )
            else
              Text('No se han asignado miembros.', style: TextStyle(color: Colors.grey.shade600)),

            const SizedBox(height: 30),

            Text('Recursos Materiales', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  _recursosMaterialesController.text.split(',').where((s) => s.trim().isNotEmpty).length.toString(), 
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryOrange)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}