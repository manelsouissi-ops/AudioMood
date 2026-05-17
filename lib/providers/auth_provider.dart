import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/app_user.dart';
import 'favorites_provider.dart';
import 'mood_provider.dart';
import 'player_provider.dart';

// ── State ────────────────────────────────────────────────────────────────────

class AuthState {
  final AppUser? user;
  const AuthState({this.user});

  bool get isLoggedIn => user != null;
  String get displayName => user?.name ?? 'Guest';
  String get email => user?.email ?? '';
  String? get userId => user?.id;
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class AuthNotifier extends Notifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  @override
  AuthState build() => const AuthState();

  Future<void> initialize() async {
    await _googleSignIn.initialize();
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      state = AuthState(user: _userFromFirebase(firebaseUser));
    }
  }

  /// Wipe all per-user Riverpod state before switching accounts.
  /// Called at the start of every login path and inside logout().
  void _clearUserState() {
    ref.invalidate(favoritesProvider);
    ref.invalidate(moodProvider);
    ref.invalidate(playerProvider);
  }

  Future<void> login(String email, String password) async {
    _clearUserState();
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    state = AuthState(user: _userFromFirebase(cred.user!));
  }

  Future<void> signup(String name, String email, String password) async {
    _clearUserState();
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user!.updateDisplayName(name);
    await cred.user!.reload();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(cred.user!.uid)
        .set({
      'name': name,
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    state = AuthState(
      user: AppUser(id: cred.user!.uid, name: name, email: email.trim()),
    );
  }

  Future<void> loginWithGoogle() async {
    _clearUserState();
    final googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(cred.user!.uid)
        .set({
      'name': cred.user!.displayName ?? 'User',
      'email': cred.user!.email ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    state = AuthState(user: _userFromFirebase(cred.user!));
  }

  Future<void> forgotPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
    // Reset all per-user state — covers every logout path (drawer, profile, etc.)
    _clearUserState();
    state = const AuthState();
  }

  AppUser _userFromFirebase(User u) => AppUser(
        id: u.uid,
        name: u.displayName ?? (u.email?.split('@').first ?? 'User'),
        email: u.email ?? '',
        avatarUrl: u.photoURL,
      );
}

// ── Provider ─────────────────────────────────────────────────────────────────

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
