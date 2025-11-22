import 'package:flutter/material.dart';

class AppColors {
  // Color Naranja Principal (El color de los botones y el panel lateral)
  static const Color primaryOrange = Color(0xFFFF6633);
  // Color de fondo oscuro (Para texto principal y fondos oscuros)
  static const Color darkBackground = Color(0xFF2E2E2E);
  // Color de Fondo claro para los formularios
  static const Color lightBackground = Colors.white;
  // Color del texto de la marca y enlaces
  static const Color accentColor = Color(0xFF3366FF);
  // Color para campos de texto/bordes grises suaves
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color softOrange = Color(0xFFFF8C66); // Un tono más suave para el botón de Iniciar Sesión
  
  // Estados de Proyectos y Tareas
  static final Color estadoActivo = Colors.orange.shade700;        // Naranja para Activo/Pendiente
  static final Color estadoEnProgreso = Colors.blue.shade700;      // Azul para En Progreso
  static final Color estadoCompletado = Colors.green.shade700;     // Verde para Completado/Completada
  static final Color estadoPausado = Colors.orange.shade700;       // Naranja para En Pausa
  
  // Prioridades de Tareas
  static final Color prioridadAlta = Colors.red.shade400;
  static final Color prioridadMedia = Colors.orange.shade400;
  static final Color prioridadBaja = Colors.blue.shade400;
}