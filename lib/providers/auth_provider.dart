import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  AppUser? _currentUser;
  bool _isLoading = false;
  FirebaseAuthException? _authError;  // Stocke l'erreur complète

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  FirebaseAuthException? get authError => _authError;
  bool get isAuthenticated => _currentUser != null;
  String? get userId => _currentUser?.uid;

  // Message d'erreur formaté pour l'affichage
  String? get errorMessage => _authError?.message;

  // Code d'erreur pour traitement spécifique
  String? get errorCode => _authError?.code;

  AuthProvider() {
    _authService.user.listen((firebaseUser) {
      if (firebaseUser == null) {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _authError = null;
    
    try {
      _currentUser = await _authService.signInWithEmail(email, password);
      return _currentUser != null;
    } on FirebaseAuthException catch (e) {
      _authError = e;  // Stocke l'erreur avec message personnalisé
      return false;
    } catch (e) {
      _authError = FirebaseAuthException(
        code: 'unknown',
        message: 'Une erreur inattendue est survenue. Veuillez réessayer.',
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp(String email, String password, String? displayName) async {
    _setLoading(true);
    _authError = null;
    
    try {
      _currentUser = await _authService.signUpWithEmail(email, password, displayName);
      return _currentUser != null;
    } on FirebaseAuthException catch (e) {
      _authError = e;
      return false;
    } catch (e) {
      _authError = FirebaseAuthException(
        code: 'unknown',
        message: 'Une erreur inattendue est survenue. Veuillez réessayer.',
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _currentUser = null;
      _authError = null;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _authError = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}