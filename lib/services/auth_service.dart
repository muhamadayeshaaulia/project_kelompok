import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (!userDoc.exists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'uid': user.uid,
                'nama': user.displayName,
                'email': user.email,
                'photo_url': user.photoURL,
                'keterangan': 'Halo! Saya menggunakan MyPhotoBooth',
                'search_keywords': _createSearchKeywords(
                  user.displayName ?? "User",
                ),
              });
        }
      }
      return user;
    } catch (e) {
      print("Error Google Sign-In: $e");
      return null;
    }
  }

  List<String> _createSearchKeywords(String name) {
    List<String> keywords = [];
    String lowerName = name.toLowerCase().trim();
    String temp = "";
    for (var i = 0; i < lowerName.length; i++) {
      temp += lowerName[i];
      keywords.add(temp);
    }
    return keywords;
  }
}
