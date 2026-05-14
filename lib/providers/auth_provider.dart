import 'package:flutter/foundation.dart';
import '../models/app_user.dart';

class AuthProvider with ChangeNotifier {
  AppUser? _user;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  String get displayName => _user?.name ?? 'Guest';
  String get email => _user?.email ?? '';

  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _user = AppUser(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameFromEmail(email),
      email: email,
    );
    notifyListeners(); // Atelier 7 pattern
  }

  Future<void> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _user = AppUser(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
    );
    notifyListeners(); // Atelier 7 pattern
  }

  void logout() {
    _user = null;
    notifyListeners(); // Atelier 7 pattern
  }

  String _nameFromEmail(String email) {
    final local = email.split('@').first;
    if (local.isEmpty) return 'User';
    return local[0].toUpperCase() + local.substring(1);
  }
}
