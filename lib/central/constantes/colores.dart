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
  static const Color softOrange =
      Color(0xFFFF8C66); // Un tono más suave para el botón de Iniciar Sesión

  // Estados de Proyectos y Tareas
  static const Color estadoActivo = Color(
      0xFFF57C00); // Naranja para Activo/Pendiente (Colors.orange.shade700)
  static const Color estadoEnProgreso =
      Color(0xFF1976D2); // Azul para En Progreso (Colors.blue.shade700)
  static const Color estadoCompletado = Color(
      0xFF388E3C); // Verde para Completado/Completada (Colors.green.shade700)
  static const Color estadoPausado =
      Color(0xFFF57C00); // Naranja para En Pausa (Colors.orange.shade700)

  // Prioridades de Tareas
  static const Color prioridadAlta = Color(0xFFEF5350); // Colors.red.shade400
  static const Color prioridadMedia =
      Color(0xFFFF9800); // Colors.orange.shade400
  static const Color prioridadBaja = Color(0xFF42A5F5); // Colors.blue.shade400
}
