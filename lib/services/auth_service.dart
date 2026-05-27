import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

// Talk to Firebase
class AuthService {

  // used for login
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // used for read Firestore data
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserProfile?> login(String email, String password) async {

      final result = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
      );

      final user = result.user;
      if (user == null) return null;

      final doc = await _db.collection('users').doc(user.uid).get();
      if(!doc.exists || doc.data() == null){
        return null;
      }

      return UserProfile.fromMap(user.uid, doc.data()!);
  }
}