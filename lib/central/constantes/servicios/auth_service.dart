import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // REGISTRO de un nuevo usuario
  Future<User?> signUp(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('La contraseña es muy débil.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Ya existe una cuenta con ese correo.');
      }
      throw Exception(e.message ?? 'Ocurrió un error al registrar.');
    }
  }

  // INICIO DE SESIÓN (Login)
  Future<User?> signIn(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Usuario no encontrado.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Contraseña incorrecta.');
      }
      throw Exception(e.message ?? 'Ocurrió un error al iniciar sesión.');
    }
  }

  // CERRAR SESIÓN
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

