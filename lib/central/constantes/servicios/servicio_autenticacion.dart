import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ServicioAutenticacion {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Propiedad para obtener el correo del usuario actual (útil para el perfil)
  String? get currentUserEmail => _auth.currentUser?.email;

  Stream<User?> get authStateChanges => _auth.authStateChanges();


  Future<void> _guardarDatosUsuario(String userId, String nombre, String rol, String correo) async {
    await _firestore.collection('usuarios').doc(userId).set({
      'nombre': nombre,
      'rol': rol,
      'correo': correo,
      'fechaCreacion': FieldValue.serverTimestamp(),
    });
  }


  Future<Map<String, dynamic>?> obtenerDatosUsuario() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('usuarios').doc(user.uid).get();
      return doc.data();
    }
    return null;
  }


  // FUNCIÓN PARA REGISTRAR MUCHACHSO
  Future<User?> registrar(String email, String password, String name, String role) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        
        await _guardarDatosUsuario(credential.user!.uid, name, role, email);
        return credential.user;
      }
    } catch (e) {
    
      debugPrint('Error de registro (VERSIÓN SENCILLA): $e');
      rethrow;
    }
    return null;
  }

  // FUNCIÓN PARA INICIAR SESIÓN 
  Future<User?> iniciarSesion(String email, String password) async {
    try {
     
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
    
      debugPrint('Error de inicio de sesión (VERSIÓN SENCILLA): $e');
      rethrow;
    }
  }

  // FUNCIÓN PARA CERRAR SESIÓN
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
}