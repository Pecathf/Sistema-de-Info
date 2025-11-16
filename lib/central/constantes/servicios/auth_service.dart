import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signIn(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUpAndSaveUser(
      String nombre, String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'nombre': nombre,
        // 💡 CORREGIDO: Ahora se guarda como 'rol' (con 'l')
        'rol': 'usuario', 
        'timestamp': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Obtener el rol del usuario actual desde Firestore
  Future<String?> getUserRole() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      final userDoc =
          await _firestore.collection('usuarios').doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data();
        // ✅ ESTO AHORA ES CORRECTO: Lee 'rol' (con 'l')
        final rol = data?['rol'] as String?; 
        return rol?.trim();
      }
      return null;
    } catch (e) {
      print("Error obteniendo el rol del usuario: $e"); // Para debugging
      return null;
    }
  }

  // Verificar si el usuario actual es admin
  Future<bool> isAdmin() async {
    final rol = await getUserRole();
    return rol == 'admin';
  }
}