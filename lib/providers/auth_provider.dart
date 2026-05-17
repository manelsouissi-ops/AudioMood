import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  AppUser? _user;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  String get displayName => _user?.name ?? 'Guest';
  String get email => _user?.email ?? '';
  String? get userId => _user?.id;

  /// Check if already signed in; initialize Google Sign-In (v7 requirement).
  /// Called from splash screen before navigating.
  Future<void> initialize() async {
    await _googleSignIn.initialize();
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      _user = _userFromFirebase(firebaseUser);
      notifyListeners(); // Atelier 7 pattern
    }
  }

  Stream<AppUser?> get authChanges => _auth.authStateChanges().map(
        (u) => u == null ? null : _userFromFirebase(u),
      );

  Future<void> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    _user = _userFromFirebase(cred.user!);
    notifyListeners(); // Atelier 7 pattern
  }

  Future<void> signup(String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user!.updateDisplayName(name);
    await cred.user!.reload();
    _user = AppUser(
      id: cred.user!.uid,
      name: name,
      email: email.trim(),
    );
    // Save profile to Firestore for future profile features (Atelier 9 pattern)
    await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    notifyListeners(); // Atelier 7 pattern
  }

  Future<void> loginWithGoogle() async {
    // google_sign_in v7: use authenticate() instead of signIn()
    final googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    _user = _userFromFirebase(cred.user!);
    // Save/merge user profile in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(cred.user!.uid)
        .set({
      'name': cred.user!.displayName ?? 'User',
      'email': cred.user!.email ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    notifyListeners(); // Atelier 7 pattern
  }

  Future<void> forgotPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
    _user = null;
    notifyListeners(); // Atelier 7 pattern
  }

  AppUser _userFromFirebase(User u) => AppUser(
        id: u.uid,
        name: u.displayName ?? (u.email?.split('@').first ?? 'User'),
        email: u.email ?? '',
        avatarUrl: u.photoURL,
      );
}
