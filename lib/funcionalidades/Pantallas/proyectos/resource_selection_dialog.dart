import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importar para usar FilteringTextInputFormatter
import 'package:sistem_proyect/central/constantes/modelos/recurso_model.dart';

class ResourceSelectionDialog extends StatefulWidget {
  final List<RecursoMaterial> initialSelectedResources;

  const ResourceSelectionDialog({
    super.key,
    required this.initialSelectedResources,
  });

  @override
  State<ResourceSelectionDialog> createState() => _ResourceSelectionDialogState();
}

class _ResourceSelectionDialogState extends State<ResourceSelectionDialog> {
  late List<RecursoMaterial> _recursos;
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  String _selectedIcon = '📦';

  // Lista de íconos disponibles
  final List<String> _iconosDisponibles = [
    '💻', '📱', '🖨️', '📊', '📈', '📉', '📁', '📂', 
    '📋', '📌', '📍', '🔧', '🔨', '⚙️', '🛠️', '📦',
    '📚', '📝', '✏️', '🖊️', '📐', '📏', '📎', '🔖',
  ];

  @override
  void initState() {
    super.initState();
    _recursos = List.from(widget.initialSelectedResources);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  void _agregarRecurso() {
    if (_nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un nombre para el recurso.')),
      );
      return;
    }

    final cantidad = int.tryParse(_cantidadController.text.trim()) ?? 0;
    if (cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa una cantidad válida mayor a 0.')),
      );
      return;
    }

    setState(() {
      _recursos.add(RecursoMaterial(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // ID temporal
        nombre: _nombreController.text.trim(),
        cantidad: cantidad,
        icono: _selectedIcon,
      ));
      _nombreController.clear();
      _cantidadController.clear();
      _selectedIcon = '📦';
    });
  }

  void _eliminarRecurso(int index) {
    setState(() {
      _recursos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Gestionar Recursos del Proyecto'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Formulario para agregar nuevo recurso
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Agregar Nuevo Recurso',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Selector de ícono
                    const Text('Selecciona un ícono:', 
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _iconosDisponibles.length,
                        itemBuilder: (context, index) {
                          final icono = _iconosDisponibles[index];
                          final isSelected = icono == _selectedIcon;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIcon = icono;
                              });
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.orange : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? Colors.orange.shade700 : Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  icono,
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Campo Nombre
                    TextField(
                      controller: _nombreController,
                      // **VALIDACIÓN: SOLO LETRAS Y ESPACIOS**
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Nombre del recurso *',
                        hintText: 'Ej: Laptop, Proyector, etc.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        prefixIcon: const Icon(Icons.label),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Campo Cantidad
                    TextField(
                      controller: _cantidadController,
                      keyboardType: TextInputType.number,
                      // **VALIDACIÓN: SOLO NÚMEROS**
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: 'Cantidad disponible *',
                        hintText: 'Ej: 5',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        prefixIcon: const Icon(Icons.numbers),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Botón Agregar
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _agregarRecurso,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Agregar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            
            // Lista de recursos agregados
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recursos del Proyecto (${_recursos.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            Expanded(
              child: _recursos.isEmpty
                  ? Center(
                      child: Text(
                        'No hay recursos agregados. Agrega uno arriba.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _recursos.length,
                      itemBuilder: (context, index) {
                        final recurso = _recursos[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange.shade100,
                              child: Text(
                                recurso.icono,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            title: Text(recurso.nombre),
                            subtitle: Text('Cantidad: ${recurso.cantidad}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _eliminarRecurso(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(_recursos);
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}