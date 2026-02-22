import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Stream<User?> get user => _auth.authStateChanges();

  Future<AppUser?> signUpWithEmail(String email, String password, String? displayName) async {
    try {
      print('Création du compte...');
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        print('Utilisateur Firebase créé: ${user.uid}');
        
        AppUser appUser = AppUser(
          uid: user.uid,
          email: email,
          displayName: displayName,
          role: UserRole.user,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(appUser.toFirestore());
        print('Profil Firestore créé');
        
        await _saveUserSession(user.uid);
        return appUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('Erreur Firebase Auth: ${e.code}');
      throw _handleAuthException(e);
    }
  }

  Future<AppUser?> signInWithEmail(String email, String password) async {
    try {
      print('Connexion de: $email');
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        print('Utilisateur connecté: ${user.uid}');
        
        var userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        if (userDoc.exists) {
          print('Document Firestore trouvé');
          await _saveUserSession(user.uid);
          return AppUser.fromFirestore(userDoc.data()!, user.uid);
        } else {
          print('Création du document Firestore manquant');
          AppUser newUser = AppUser(
            uid: user.uid,
            email: email,
            displayName: user.displayName,
            role: UserRole.user,
            createdAt: DateTime.now(),
          );
          await _firestore.collection('users').doc(user.uid).set(newUser.toFirestore());
          await _saveUserSession(user.uid);
          return newUser;
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('Erreur Firebase Auth: ${e.code}');
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    print('Déconnexion...');
    await _auth.signOut();
    await _secureStorage.delete(key: 'user_session');
    print('Déconnecté');
  }

  Future<bool> checkAutoLogin() async {
    try {
      String? session = await _secureStorage.read(key: 'user_session');
      if (session != null) {
        User? currentUser = _auth.currentUser;
        return currentUser != null;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveUserSession(String uid) async {
    await _secureStorage.write(key: 'user_session', value: uid);
  }

  // Gestion des erreurs avec messages personnalisés
  FirebaseAuthException _handleAuthException(FirebaseAuthException e) {
    String message;
    
    switch (e.code) {
      // Inscription
      case 'email-already-in-use':
        message = 'Cet email est déjà utilisé. Veuillez en choisir un autre ou vous connecter.';
        break;
      case 'invalid-email':
        message = 'L\'adresse email n\'est pas valide. Vérifiez le format (ex: nom@domaine.com).';
        break;
      case 'weak-password':
        message = 'Le mot de passe est trop faible. Utilisez au moins 6 caractères avec des chiffres et lettres.';
        break;
      
      // Connexion
      case 'user-not-found':
        message = 'Aucun compte trouvé avec cet email. Voulez-vous créer un compte ?';
        break;
      case 'wrong-password':
        message = 'Mot de passe incorrect. Vérifiez votre mot de passe et réessayez.';
        break;
      case 'too-many-requests':
        message = 'Trop de tentatives de connexion. Compte temporairement bloqué. Réessayez dans quelques minutes.';
        break;
      case 'user-disabled':
        message = 'Ce compte a été désactivé. Contactez l\'administrateur pour plus d\'informations.';
        break;
      
      // Réseau
      case 'network-request-failed':
        message = 'Problème de connexion internet. Vérifiez votre réseau et réessayez.';
        break;
      
      // Autres
      default:
        message = 'Erreur de connexion: ${e.message}';
    }
    
    // On retourne l'exception avec le message personnalisé
    return FirebaseAuthException(
      code: e.code,
      message: message,
    );
  }
}