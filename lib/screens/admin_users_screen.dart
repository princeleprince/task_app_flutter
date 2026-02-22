import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/admin_user_card.dart';
import 'admin_add_user_screen.dart';
import 'admin_user_detail_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<AppUser> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterUsers);
  }

  void _filterUsers() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    setState(() {
      _filteredUsers = adminProvider.users.where((user) {
        return user.email.toLowerCase().contains(_searchController.text.toLowerCase()) ||
               (user.displayName?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false);
      }).toList();
    });
  }

  void _showPromoteDialog(AppUser user) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Promouvoir en admin'),
        content: Text(
          'Voulez-vous promouvoir ${user.displayName ?? user.email} en administrateur ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await adminProvider.updateUserRole(
                user.uid,
                UserRole.admin,
                authProvider.currentUser!.uid,
                authProvider.currentUser!.email,
              );
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Utilisateur promu admin'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text('Promouvoir'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(AppUser user) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'utilisateur'),
        content: Text(
          'Voulez-vous vraiment supprimer ${user.displayName ?? user.email} ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await adminProvider.deleteUser(
                user.uid,
                authProvider.currentUser!.uid,
                authProvider.currentUser!.email,
              );
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Utilisateur supprimé'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final users = _searchController.text.isEmpty 
        ? adminProvider.users 
        : _filteredUsers;

    return Scaffold(
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un utilisateur...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Statistiques
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Total: ${adminProvider.users.length}',
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Admins: ${adminProvider.users.where((u) => u.isAdmin).length}',
                    style: const TextStyle(color: Colors.amber),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Liste des utilisateurs
          Expanded(
            child: adminProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : users.isEmpty
                    ? const Center(
                        child: Text('Aucun utilisateur trouvé'),
                      )
                    : ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return AdminUserCard(
                            user: user,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminUserDetailScreen(user: user),
                                ),
                              );
                            },
                            onEdit: () {
                              
                            },
                            onPromote: user.isAdmin ? null : () => _showPromoteDialog(user),
                            onDelete: () => _showDeleteDialog(user),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminAddUserScreen()),
          );
          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Utilisateur ajouté'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}