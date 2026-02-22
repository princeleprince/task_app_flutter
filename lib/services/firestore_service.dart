import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection références
  CollectionReference _getUserTasksRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  // Ajouter une tâche
  Future<void> addTask(Task task) async {
    try {
      await _getUserTasksRef(task.userId).doc(task.id).set({
        'id': task.id,
        'title': task.title,
        'description': task.description,
        'status': task.status.toString().split('.').last,
        'priority': task.priority.toString().split('.').last,
        'createdAt': Timestamp.fromDate(task.createdAt),
        'dueDate': task.dueDate != null ? Timestamp.fromDate(task.dueDate!) : null,
        'category': task.category,
        'userId': task.userId,
      });
      print('Tâche ajoutée: ${task.id}');
    } catch (e) {
      print('Erreur ajout: $e');
      throw Exception('Erreur lors de l\'ajout de la tâche: $e');
    }
  }

  // Mettre à jour une tâche
  Future<void> updateTask(Task task) async {
    try {
      await _getUserTasksRef(task.userId).doc(task.id).update({
        'title': task.title,
        'description': task.description,
        'status': task.status.toString().split('.').last,
        'priority': task.priority.toString().split('.').last,
        'dueDate': task.dueDate != null ? Timestamp.fromDate(task.dueDate!) : null,
        'category': task.category,
      });
      print('Tâche mise à jour: ${task.id}');
    } catch (e) {
      print('Erreur mise à jour: $e');
      throw Exception('Erreur lors de la mise à jour de la tâche: $e');
    }
  }

  // Supprimer une tâche
  Future<void> deleteTask(String userId, String taskId) async {
    try {
      await _getUserTasksRef(userId).doc(taskId).delete();
      print('Tâche supprimée: $taskId');
    } catch (e) {
      print('Erreur suppression: $e');
      throw Exception('Erreur lors de la suppression de la tâche: $e');
    }
  }

  // Récupérer les tâches d'un utilisateur
  Stream<List<Task>> getUserTasks(String userId) {
    return _getUserTasksRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            
            // Convertir les timestamps en DateTime
            DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
            DateTime? dueDate = data['dueDate'] != null 
                ? (data['dueDate'] as Timestamp).toDate() 
                : null;

            // Convertir les strings en enum
            TaskStatus status = TaskStatus.values.firstWhere(
              (e) => e.toString() == 'TaskStatus.${data['status']}',
              orElse: () => TaskStatus.todo,
            );

            Priority priority = Priority.values.firstWhere(
              (e) => e.toString() == 'Priority.${data['priority']}',
              orElse: () => Priority.medium,
            );

            return Task(
              id: doc.id,
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              status: status,
              priority: priority,
              createdAt: createdAt,
              dueDate: dueDate,
              category: data['category'],
              userId: data['userId'] ?? '',
            );
          }).toList();
        });
  }

  // Récupérer une tâche spécifique
  Future<Task?> getTask(String userId, String taskId) async {
    try {
      DocumentSnapshot doc = await _getUserTasksRef(userId).doc(taskId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        
        DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
        DateTime? dueDate = data['dueDate'] != null 
            ? (data['dueDate'] as Timestamp).toDate() 
            : null;

        TaskStatus status = TaskStatus.values.firstWhere(
          (e) => e.toString() == 'TaskStatus.${data['status']}',
          orElse: () => TaskStatus.todo,
        );

        Priority priority = Priority.values.firstWhere(
          (e) => e.toString() == 'Priority.${data['priority']}',
          orElse: () => Priority.medium,
        );

        return Task(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          status: status,
          priority: priority,
          createdAt: createdAt,
          dueDate: dueDate,
          category: data['category'],
          userId: data['userId'] ?? '',
        );
      }
      return null;
    } catch (e) {
      print('Erreur récupération: $e');
      throw Exception('Erreur lors de la récupération de la tâche: $e');
    }
  }

  // Synchronisation en temps réel
  Stream<List<Task>> syncTasks(String userId) {
    return _getUserTasksRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            
            DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
            DateTime? dueDate = data['dueDate'] != null 
                ? (data['dueDate'] as Timestamp).toDate() 
                : null;

            TaskStatus status = TaskStatus.values.firstWhere(
              (e) => e.toString() == 'TaskStatus.${data['status']}',
              orElse: () => TaskStatus.todo,
            );

            Priority priority = Priority.values.firstWhere(
              (e) => e.toString() == 'Priority.${data['priority']}',
              orElse: () => Priority.medium,
            );

            return Task(
              id: doc.id,
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              status: status,
              priority: priority,
              createdAt: createdAt,
              dueDate: dueDate,
              category: data['category'],
              userId: data['userId'] ?? '',
            );
          }).toList();
        });
  }

  // Mettre à jour le profil utilisateur
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
      print('Profil mis à jour');
    } catch (e) {
      print('Erreur mise à jour profil: $e');
      throw Exception('Erreur lors de la mise à jour du profil: $e');
    }
  }

  // Récupérer les statistiques d'un utilisateur
  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      QuerySnapshot tasks = await _getUserTasksRef(userId).get();

      int total = tasks.docs.length;
      int todo = 0;
      int inProgress = 0;
      int done = 0;
      int high = 0;
      int medium = 0;
      int low = 0;

      for (var doc in tasks.docs) {
        final data = doc.data() as Map<String, dynamic>;
        String status = data['status'] ?? 'todo';
        String priority = data['priority'] ?? 'medium';

        if (status == 'todo') todo++;
        else if (status == 'inProgress') inProgress++;
        else if (status == 'done') done++;

        if (priority == 'high') high++;
        else if (priority == 'medium') medium++;
        else if (priority == 'low') low++;
      }

      return {
        'total': total,
        'todo': todo,
        'inProgress': inProgress,
        'done': done,
        'high': high,
        'medium': medium,
        'low': low,
      };
    } catch (e) {
      print('Erreur stats: $e');
      throw Exception('Erreur lors de la récupération des statistiques: $e');
    }
  }
}

