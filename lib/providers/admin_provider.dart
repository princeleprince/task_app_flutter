import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/task.dart';
import '../models/audit_log.dart';
import '../services/admin_service.dart';
import '../services/audit_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();
  final AuditService _auditService = AuditService();
  
  List<AppUser> _users = [];
  List<Map<String, dynamic>> _anonymizedTasks = [];
  List<AuditLog> _auditLogs = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _globalStats = {};

  // Getters
  List<AppUser> get users => _users;
  List<Map<String, dynamic>> get anonymizedTasks => _anonymizedTasks;
  List<AuditLog> get auditLogs => _auditLogs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get globalStats => _globalStats;

  // ==================== CHARGEMENT DES DONNÉES ====================

  void loadUsers() {
    _isLoading = true;
    notifyListeners();

    _adminService.getAllUsers().listen(
      (users) {
        _users = users;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void loadAnonymizedTasks() {
    _adminService.getAllTasksAnonymized().listen(
      (tasks) {
        _anonymizedTasks = tasks;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  void loadAuditLogs() {
    _auditService.getLogs().listen(
      (logs) {
        _auditLogs = logs;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  Future<void> loadGlobalStats() async {
    try {
      _globalStats = await _adminService.getGlobalStats();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // MÉTHODE de récupération de toutes les catégories
  Future<List<String>> getAllCategories() async {
    try {
      return await _adminService.getAllCategories();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // ==================== ACTIONS SUR LES UTILISATEURS ====================

  Future<bool> addUser({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    required String adminId,
    required String adminEmail,
  }) async {
    try {
      await _adminService.addUser(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
      );

      // Journaliser l'action
      await _auditService.addLog(
        AuditLog(
          id: '',
          adminId: adminId,
          adminEmail: adminEmail,
          action: AuditLog.ACTION_CREATE_USER,
          targetType: 'user',
          details: {'email': email, 'role': role.toString()},
          timestamp: DateTime.now(),
        ),
      );

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(
    String userId,
    Map<String, dynamic> data,
    String adminId,
    String adminEmail,
  ) async {
    try {
      await _adminService.updateUser(userId, data);

      // Journaliser
      await _auditService.addLog(
        AuditLog(
          id: '',
          adminId: adminId,
          adminEmail: adminEmail,
          action: AuditLog.ACTION_UPDATE_USER,
          targetType: 'user',
          targetId: userId,
          details: data,
          timestamp: DateTime.now(),
        ),
      );

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUserRole(
    String userId,
    UserRole newRole,
    String adminId,
    String adminEmail,
  ) async {
    try {
      await _adminService.updateUserRole(userId, newRole);

      // Journaliser
      await _auditService.addLog(
        AuditLog(
          id: '',
          adminId: adminId,
          adminEmail: adminEmail,
          action: AuditLog.ACTION_CHANGE_ROLE,
          targetType: 'user',
          targetId: userId,
          details: {'newRole': newRole.toString()},
          timestamp: DateTime.now(),
        ),
      );

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String userId, String adminId, String adminEmail) async {
    try {
      await _adminService.deleteUser(userId);

      // Journaliser
      await _auditService.addLog(
        AuditLog(
          id: '',
          adminId: adminId,
          adminEmail: adminEmail,
          action: AuditLog.ACTION_DELETE_USER,
          targetType: 'user',
          targetId: userId,
          details: {'deletedAt': DateTime.now().toIso8601String()},
          timestamp: DateTime.now(),
        ),
      );

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== TÂCHES ====================

  Future<bool> deleteAnyTask(
    String userId,
    String taskId,
    String reason,
    String adminId,
    String adminEmail,
  ) async {
    try {
      await _adminService.deleteAnyTask(userId, taskId, reason);

      // Journaliser
      await _auditService.addLog(
        AuditLog(
          id: '',
          adminId: adminId,
          adminEmail: adminEmail,
          action: AuditLog.ACTION_DELETE_TASK,
          targetType: 'task',
          targetId: taskId,
          details: {'reason': reason, 'userId': userId},
          timestamp: DateTime.now(),
        ),
      );

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== UTILITAIRES ====================

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void refreshAll() {
    loadUsers();
    loadAnonymizedTasks();
    loadAuditLogs();
    loadGlobalStats();
  }
}