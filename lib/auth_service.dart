import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      
      // Update last login timestamp in Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
      
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // register with email and password
  Future registerWithEmailAndPassword(String email, String password, {String? displayName}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      
      // Create comprehensive user document in Firestore using FirestoreService
      if (user != null) {
        await _firestoreService.createUserDocument(user.uid, email, displayName: displayName);
      }
      
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // auth change user stream
  Stream<User?> get user {
    return _auth.authStateChanges();
  }
}
