import 'package:flutter/material.dart';

/// Widget de Footer reutilizable 
class SharedFooter extends StatelessWidget {
  final Color primaryOrange;
  final Color accentBlue;

  const SharedFooter({
    super.key,
    this.primaryOrange = const Color(0xFFFF6633),
    this.accentBlue = const Color(0xFF00BFFF),
  });

  // Sección individual del footer 
  Widget _buildFooterSection(String title, List<String> items, bool isMobile,
      {bool isTitleBold = false, bool isContact = false}) {
    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isContact ? accentBlue : Colors.black87,
            fontSize: 18,
            fontWeight: isTitleBold ? FontWeight.bold : FontWeight.w500,
          ),
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
        ),
        const SizedBox(height: 10),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                item,
                style: TextStyle(
                  color: isContact ? Colors.black54 : Colors.black87,
                  fontSize: 14,
                ),
                textAlign: isMobile ? TextAlign.center : TextAlign.left,
              ),
            ))
      ],
    );
  }

  // Footer completo 
  Widget _buildFooter(BuildContext context, bool isMobile) {
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
            top: BorderSide(color: primaryOrange, width: 4)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              mainAxisAlignment: isMobile
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
              crossAxisAlignment: isMobile
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                _buildFooterSection(
                  'ProyectApp',
                  [
                    'Sistema de gestión de proyectos para ingeniería',
                    'en la Universidad Metropolitana'
                  ],
                  isMobile,
                  isTitleBold: true,
                ),
                SizedBox(height: isMobile ? 30 : 0, width: isMobile ? 0 : 50),
                _buildFooterSection(
                  'Funcionalidades',
                  ['Proyectos', 'Calendario', 'Estadísticas'],
                  isMobile,
                ),
                SizedBox(height: isMobile ? 30 : 0, width: isMobile ? 0 : 50),
                _buildFooterSection(
                  'Ayuda',
                  [
                    'Email: ayudalog@proyectapp.unimet.edu.ve',
                    'Contacto: 0202020200202'
                  ],
                  isMobile,
                  isContact: true,
                ),
                SizedBox(height: isMobile ? 30 : 0, width: isMobile ? 0 : 50),
                Column(
                  children: [
                    const Icon(
                      Icons.camera_alt,
                      color: Colors.black87,
                      size: 30,
                    ),
                    const SizedBox(height: 5),
                    const Text('Instagram',
                        style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 800;
        return _buildFooter(context, isMobile);
      },
    );
  }
}