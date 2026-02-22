enum UserRole { admin, user }

class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final UserRole role;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.role = UserRole.user,
    required this.createdAt,
  });

  factory AppUser.fromFirestore(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${data['role']}',
        orElse: () => UserRole.user,
      ),
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role.toString().split('.').last,
      'createdAt': createdAt,
    };
  }

  bool get isAdmin => role == UserRole.admin;
}