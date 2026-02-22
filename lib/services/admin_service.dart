import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../models/task.dart';
import '../models/audit_log.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== GESTION DES UTILISATEURS ====================

  // Récupérer tous les utilisateurs
  Stream<List<AppUser>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      print('getAllUsers: ${snapshot.docs.length} utilisateurs trouvés');
      return snapshot.docs.map((doc) {
        return AppUser.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Ajouter un utilisateur
  Future<void> addUser({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    try {
      print('Ajout utilisateur: $email');
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      AppUser newUser = AppUser(
        uid: result.user!.uid,
        email: email,
        displayName: displayName,
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(newUser.toFirestore());
      
      print('Utilisateur ajouté: ${result.user!.uid}');
    } catch (e) {
      print('Erreur ajout utilisateur: $e');
      throw Exception('Erreur ajout utilisateur: $e');
    }
  }

  // Mettre à jour un utilisateur
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      print('Mise à jour utilisateur: $userId');
      await _firestore.collection('users').doc(userId).update(data);
      print('Utilisateur mis à jour');
    } catch (e) {
      print('Erreur mise à jour: $e');
      throw Exception('Erreur mise à jour: $e');
    }
  }

  // Changer le rôle
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    try {
      print('Changement rôle: $userId -> $newRole');
      await _firestore.collection('users').doc(userId).update({
        'role': newRole.toString().split('.').last,
      });
      print('Rôle mis à jour');
    } catch (e) {
      print('Erreur mise à jour rôle: $e');
      throw Exception('Erreur mise à jour rôle: $e');
    }
  }

  // Supprimer un utilisateur
  Future<void> deleteUser(String userId) async {
    try {
      print('Suppression utilisateur: $userId');
      
      // Supprimer toutes ses tâches
      final tasks = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .get();
      
      print('Tâches à supprimer: ${tasks.docs.length}');
          
      for (var task in tasks.docs) {
        await task.reference.delete();
      }
      
      // Supprimer le document utilisateur
      await _firestore.collection('users').doc(userId).delete();
      
      print('Utilisateur supprimé');
    } catch (e) {
      print('Erreur suppression utilisateur: $e');
      throw Exception('Erreur suppression utilisateur: $e');
    }
  }

  // ==================== GESTION DES TÂCHES ====================

  // Récupérer toutes les tâches (avec anonymisation)
  Stream<List<Map<String, dynamic>>> getAllTasksAnonymized() {
    return _firestore.collectionGroup('tasks').snapshots().map((snapshot) {
      print('getAllTasksAnonymized: ${snapshot.docs.length} tâches trouvées');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? 'Sans titre',
          'status': data['status'] ?? 'todo',
          'priority': data['priority'] ?? 'medium',
          'createdAt': data['createdAt'],
          'userId': _anonymizeUserId(data['userId']),
          'taskPreview': _getTaskPreview(data['title'], data['description']),
        };
      }).toList();
    });
  }

  // Récupérer les tâches signalées
  Stream<List<ReportedTask>> getReportedTasks() {
    return _firestore
        .collection('reports')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          print('getReportedTasks: ${snapshot.docs.length} signalements');
          return snapshot.docs.map((doc) {
            return ReportedTask.fromJson(doc.data(), doc.id);
          }).toList();
        });
  }

  // Signaler une tâche (par les utilisateurs)
  Future<void> reportTask(String taskId, String userId, String reason) async {
    try {
      print('Signalement tâche: $taskId par $userId');
      await _firestore.collection('reports').add({
        'taskId': taskId,
        'reportedBy': userId,
        'reason': reason,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Signalement enregistré');
    } catch (e) {
      print('Erreur signalement: $e');
      throw Exception('Erreur signalement: $e');
    }
  }

  // Supprimer une tâche (modération)
  Future<void> deleteAnyTask(String userId, String taskId, String reason) async {
    try {
      print('Suppression tâche: $taskId de l\'utilisateur $userId');
      print('Raison: $reason');
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .delete();
      
      print('Tâche supprimée');
    } catch (e) {
      print('Erreur suppression tâche: $e');
      throw Exception('Erreur suppression tâche: $e');
    }
  }

  // ==================== STATISTIQUES ====================

  
  Future<Map<String, dynamic>> getGlobalStats() async {
    try {
      print('Récupération des statistiques...');
      print('Timestamp: ${DateTime.now()}');
      
      // Récupérer tous les utilisateurs
      print('Requête Firestore: collection users');
      final usersSnapshot = await _firestore.collection('users').get();
      print('Utilisateurs trouvés: ${usersSnapshot.docs.length}');
      
      if (usersSnapshot.docs.isEmpty) {
        print('Aucun utilisateur trouvé dans Firestore');
      } else {
        print('Premier utilisateur: ${usersSnapshot.docs.first.id}');
      }

      // Récupérer toutes les tâches (collectionGroup)
      print('Requête Firestore: collectionGroup tasks');
      final tasksSnapshot = await _firestore.collectionGroup('tasks').get();
      print('âches trouvées: ${tasksSnapshot.docs.length}');
      
      if (tasksSnapshot.docs.isEmpty) {
        print('Aucune tâche trouvée dans Firestore');
      } else {
        print(' tâche: ${tasksSnapshot.docs.first.id}');
        print('Données: ${tasksSnapshot.docs.first.data()}');
      }

      int totalUsers = usersSnapshot.docs.length;
      int totalTasks = tasksSnapshot.docs.length;
      
      int tasksDone = 0;
      int tasksInProgress = 0;
      int tasksTodo = 0;
      int tasksHigh = 0;
      int tasksMedium = 0;
      int tasksLow = 0;

      // Parcourir toutes les tâches pour les statistiques
      for (var doc in tasksSnapshot.docs) {
        final data = doc.data();
        String status = data['status'] ?? 'todo';
        String priority = data['priority'] ?? 'medium';
        
        if (status == 'done') tasksDone++;
        else if (status == 'inProgress') tasksInProgress++;
        else tasksTodo++;
        
        if (priority == 'high') tasksHigh++;
        else if (priority == 'medium') tasksMedium++;
        else tasksLow++;
      }

      print('Répartition:');
      print('  - Terminées: $tasksDone');
      print('  - En cours: $tasksInProgress');
      print('  - À faire: $tasksTodo');
      print('  - Haute: $tasksHigh');
      print('  - Moyenne: $tasksMedium');
      print('  - Basse: $tasksLow');

      final stats = {
        'totalUsers': totalUsers,
        'totalTasks': totalTasks,
        'tasksDone': tasksDone,
        'tasksInProgress': tasksInProgress,
        'tasksTodo': tasksTodo,
        'tasksHigh': tasksHigh,
        'tasksMedium': tasksMedium,
        'tasksLow': tasksLow,
        'avgTasksPerUser': totalUsers > 0 
            ? (totalTasks / totalUsers).toStringAsFixed(1) 
            : '0',
      };

      print('Statistiques calculées: $stats');
      return stats;
    } catch (e) {
      print('Erreur statistiques: $e');
      print('Stack trace: ${StackTrace.current}');
      throw Exception('Erreur statistiques: $e');
    }
  }

  // ==================== CATÉGORIES ====================

  // Récupérer toutes les catégories uniques
  Future<List<String>> getAllCategories() async {
    try {
      print('Récupération des catégories...');
      final tasksSnapshot = await _firestore.collectionGroup('tasks').get();
      
      Set<String> categories = {};
      for (var doc in tasksSnapshot.docs) {
        String? category = doc.data()['category'];
        if (category != null && category.isNotEmpty) {
          categories.add(category);
        }
      }
      
      print('Catégories trouvées: ${categories.length}');
      return categories.toList();
    } catch (e) {
      print('Erreur catégories: $e');
      throw Exception('Erreur catégories: $e');
    }
  }

  // ==================== UTILITAIRES ====================

  String _anonymizeUserId(String? userId) {
    if (userId == null) return 'Utilisateur inconnu';
    if (userId.length < 8) return 'User***';
    return 'User_${userId.substring(0, 4)}...${userId.substring(userId.length - 4)}';
  }

  String _getTaskPreview(String? title, String? description) {
    if (title != null && title.isNotEmpty) {
      return title.length > 30 ? '${title.substring(0, 30)}...' : title;
    }
    if (description != null && description.isNotEmpty) {
      return description.length > 30 ? '${description.substring(0, 30)}...' : description;
    }
    return 'Tâche sans titre';
  }
}

// Modèle pour les tâches signalées
class ReportedTask {
  final String id;
  final String taskId;
  final String reportedBy;
  final String reason;
  final String status;
  final DateTime createdAt;

  ReportedTask({
    required this.id,
    required this.taskId,
    required this.reportedBy,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory ReportedTask.fromJson(Map<String, dynamic> json, String id) {
    return ReportedTask(
      id: id,
      taskId: json['taskId'] ?? '',
      reportedBy: json['reportedBy'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}