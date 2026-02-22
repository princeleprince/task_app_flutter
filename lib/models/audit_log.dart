import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuditLog {
  final String id;
  final String adminId;
  final String adminEmail;
  final String action;
  final String targetType;
  final String? targetId;
  final Map<String, dynamic> details;
  final DateTime timestamp;

  AuditLog({
    required this.id,
    required this.adminId,
    required this.adminEmail,
    required this.action,
    required this.targetType,
    this.targetId,
    required this.details,
    required this.timestamp,
  });

  // Constructeur depuis Firestore
  factory AuditLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuditLog(
      id: doc.id,
      adminId: data['adminId'] ?? '',
      adminEmail: data['adminEmail'] ?? '',
      action: data['action'] ?? '',
      targetType: data['targetType'] ?? '',
      targetId: data['targetId'],
      details: Map<String, dynamic>.from(data['details'] ?? {}),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Constructeur depuis JSON (pour compatibilité)
  factory AuditLog.fromJson(Map<String, dynamic> json, String id) {
    return AuditLog(
      id: id,
      adminId: json['adminId'] ?? '',
      adminEmail: json['adminEmail'] ?? '',
      action: json['action'] ?? '',
      targetType: json['targetType'] ?? '',
      targetId: json['targetId'],
      details: json['details'] ?? {},
      timestamp: json['timestamp'] is Timestamp 
          ? (json['timestamp'] as Timestamp).toDate()
          : (json['timestamp'] is DateTime 
              ? json['timestamp'] 
              : DateTime.now()),
    );
  }

  // Convertir pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'adminId': adminId,
      'adminEmail': adminEmail,
      'action': action,
      'targetType': targetType,
      'targetId': targetId,
      'details': details,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Convertir pour JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adminId': adminId,
      'adminEmail': adminEmail,
      'action': action,
      'targetType': targetType,
      'targetId': targetId,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Types d'actions possibles
  static const String ACTION_CREATE_USER = 'create_user';
  static const String ACTION_UPDATE_USER = 'update_user';
  static const String ACTION_DELETE_USER = 'delete_user';
  static const String ACTION_CHANGE_ROLE = 'change_role';
  static const String ACTION_DELETE_TASK = 'delete_task';
  static const String ACTION_BULK_OPERATION = 'bulk_operation';
  static const String ACTION_LOGIN = 'login';
  static const String ACTION_LOGOUT = 'logout';
  static const String ACTION_EXPORT_DATA = 'export_data';
  static const String ACTION_IMPORT_DATA = 'import_data';

  // Types de cibles possibles
  static const String TARGET_USER = 'user';
  static const String TARGET_TASK = 'task';
  static const String TARGET_CATEGORY = 'category';
  static const String TARGET_SETTING = 'setting';
  static const String TARGET_SYSTEM = 'system';

  // Obtenir un libellé lisible pour l'action
  String get actionLabel {
    switch (action) {
      case ACTION_CREATE_USER:
        return 'Création d\'utilisateur';
      case ACTION_UPDATE_USER:
        return 'Modification d\'utilisateur';
      case ACTION_DELETE_USER:
        return 'Suppression d\'utilisateur';
      case ACTION_CHANGE_ROLE:
        return 'Changement de rôle';
      case ACTION_DELETE_TASK:
        return 'Suppression de tâche';
      case ACTION_BULK_OPERATION:
        return 'Opération groupée';
      case ACTION_LOGIN:
        return 'Connexion';
      case ACTION_LOGOUT:
        return 'Déconnexion';
      case ACTION_EXPORT_DATA:
        return 'Export de données';
      case ACTION_IMPORT_DATA:
        return 'Import de données';
      default:
        return action;
    }
  }

  // Couleur associée à l'action
  Color get actionColor {
    switch (action) {
      case ACTION_CREATE_USER:
        return Colors.green;
      case ACTION_UPDATE_USER:
        return Colors.blue;
      case ACTION_DELETE_USER:
        return Colors.red;
      case ACTION_CHANGE_ROLE:
        return Colors.amber;
      case ACTION_DELETE_TASK:
        return Colors.orange;
      case ACTION_LOGIN:
        return Colors.teal;
      case ACTION_LOGOUT:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Icône associée à l'action
  IconData get actionIcon {
    switch (action) {
      case ACTION_CREATE_USER:
        return Icons.person_add;
      case ACTION_UPDATE_USER:
        return Icons.person_outline;
      case ACTION_DELETE_USER:
        return Icons.person_remove;
      case ACTION_CHANGE_ROLE:
        return Icons.admin_panel_settings;
      case ACTION_DELETE_TASK:
        return Icons.task;
      case ACTION_LOGIN:
        return Icons.login;
      case ACTION_LOGOUT:
        return Icons.logout;
      default:
        return Icons.history;
    }
  }

  // Formatage de la date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} j';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  // Description détaillée
  String get description {
    final buffer = StringBuffer();
    buffer.write('$actionLabel par $adminEmail');
    
    if (targetId != null) {
      buffer.write(' sur $targetType: $targetId');
    }
    
    if (details.isNotEmpty) {
      buffer.write(' - ${details.toString()}');
    }
    
    return buffer.toString();
  }
}


