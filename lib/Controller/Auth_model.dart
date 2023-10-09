import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  Future signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      print("User signed in with UID: ${_user?.uid}");

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      // Ném ra ngoại lệ để bắt và xử lý ở bên ngoài
      throw e;
    }
  }


// You can add more methods like signOut, signUp, etc.
}
