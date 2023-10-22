// import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  Future<User?> signInWithGoogle() async {
    try {
      // Start Google Sign-In
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a credential for Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Return the signed-in user
      print(credential);
      return authResult.user;
    } catch (e) {
      // Handle any errors
      print("Error signing in with Google: $e");
      return null;
    }
  }
}