import 'package:flutter/material.dart';

class ErrorDialog {
  // Affiche une boîte de dialogue d'erreur élégante
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            message,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          if (onAction != null && actionLabel != null)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                onAction();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // Affiche un snackbar d'erreur (plus discret)
  static void showSnackBar({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  // Gestion spécialisée des erreurs d'authentification
  static Future<void> handleAuthError(
    BuildContext context,
    String? errorCode,
    String? errorMessage,
  ) {
    String title = 'Erreur de connexion';
    String message = errorMessage ?? 'Une erreur est survenue.';
    String? actionLabel;
    VoidCallback? onAction;

    switch (errorCode) {
      case 'wrong-password':
        message = 'Le mot de passe que vous avez saisi est incorrect.\n\nVérifiez votre mot de passe ou utilisez "Mot de passe oublié" pour le réinitialiser.';
        actionLabel = 'Réessayer';
        onAction = () => Navigator.pop(context);
        break;

      case 'user-not-found':
        message = 'Aucun compte n\'existe avec cette adresse email.\n\nVoulez-vous créer un nouveau compte ?';
        actionLabel = 'Créer un compte';
        onAction = () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/register');
        };
        break;

      case 'invalid-email':
        message = 'Le format de l\'adresse email n\'est pas valide.\n\nExemple attendu : nom@domaine.com';
        actionLabel = 'Corriger';
        onAction = () => Navigator.pop(context);
        break;

      case 'email-already-in-use':
        title = 'Email déjà utilisé';
        message = 'Cette adresse email est déjà associée à un compte.\n\nSouhaitez-vous vous connecter ?';
        actionLabel = 'Se connecter';
        onAction = () {
          Navigator.pop(context);
          // Rester sur l'écran de connexion
        };
        break;

      case 'weak-password':
        message = 'Le mot de passe est trop faible.\n\nUtilisez au moins 6 caractères avec des chiffres et des lettres.';
        actionLabel = 'Modifier';
        onAction = () => Navigator.pop(context);
        break;

      case 'too-many-requests':
        title = 'Trop de tentatives';
        message = 'Vous avez effectué trop de tentatives de connexion.\n\nVeuillez réessayer dans quelques minutes.';
        break;

      case 'network-request-failed':
        title = 'Problème de connexion';
        message = 'Impossible de se connecter au serveur.\n\nVérifiez votre connexion internet et réessayez.';
        actionLabel = 'Réessayer';
        onAction = () => Navigator.pop(context);
        break;

      default:
        // Garder le message par défaut
        break;
    }

    return show(
      context: context,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}