import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient supabase;
  User? currentUser;
  bool isLoading = true;

  AuthService(this.supabase) {
    _restore();
    supabase.auth.onAuthStateChange.listen((event) {
      currentUser = supabase.auth.currentUser;
      if (currentUser != null) {
        _saveProfile(currentUser!);
      }
      notifyListeners();
    });
  }

  void _restore() {
    currentUser = supabase.auth.currentUser;
    isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.example.todothis://login-callback/',
      );
    } catch (e) {
      // Handle authentication errors
      print('Google sign in error: $e');
      rethrow; // Re-throw the error so calling code can handle it
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    currentUser = null;
    notifyListeners();
  }

  Future<void> _saveProfile(User user) async {
    try {
      final name = user.userMetadata?['name'] ?? user.email;
      final avatar = user.userMetadata?['picture'];
      await supabase.from('profiles').upsert({
        'id': user.id,
        'full_name': name,
        'avatar_url': avatar,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Handle profile saving errors
      print('Error saving profile: $e');
      rethrow; // Re-throw the error so calling code can handle it
    }
  }
}
