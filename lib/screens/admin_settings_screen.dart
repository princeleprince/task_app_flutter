import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _autoSync = true;
  bool _notificationsEnabled = true;
  bool _allowUserRegistration = true;
  String _selectedLanguage = 'fr';
  String _selectedTheme = 'system';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Paramètres généraux
          const Text(
            'Général',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Synchronisation automatique'),
                  subtitle: const Text('Synchroniser les données en temps réel'),
                  value: _autoSync,
                  onChanged: (value) {
                    setState(() {
                      _autoSync = value;
                    });
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Notifications admin'),
                  subtitle: const Text('Recevoir des alertes pour les signalements'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Inscription libre'),
                  subtitle: const Text('Permettre aux nouveaux utilisateurs de s\'inscrire'),
                  value: _allowUserRegistration,
                  onChanged: (value) {
                    setState(() {
                      _allowUserRegistration = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Langue
          const Text(
            'Langue',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Column(
              children: [
                RadioListTile(
                  title: const Text('Français'),
                  value: 'fr',
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value.toString();
                    });
                  },
                ),
                RadioListTile(
                  title: const Text('English'),
                  value: 'en',
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value.toString();
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Thème
          const Text(
            'Thème',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Column(
              children: [
                RadioListTile(
                  title: const Text('Clair'),
                  value: 'light',
                  groupValue: _selectedTheme,
                  onChanged: (value) {
                    setState(() {
                      _selectedTheme = value.toString();
                    });
                  },
                ),
                RadioListTile(
                  title: const Text('Sombre'),
                  value: 'dark',
                  groupValue: _selectedTheme,
                  onChanged: (value) {
                    setState(() {
                      _selectedTheme = value.toString();
                    });
                  },
                ),
                RadioListTile(
                  title: const Text('Système'),
                  value: 'system',
                  groupValue: _selectedTheme,
                  onChanged: (value) {
                    setState(() {
                      _selectedTheme = value.toString();
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Actions de maintenance
          const Text(
            'Maintenance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup, color: Colors.blue),
                  title: const Text('Sauvegarder les données'),
                  subtitle: const Text('Exporter toutes les données'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sauvegarde démarrée...'),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.restore, color: Colors.green),
                  title: const Text('Restaurer les données'),
                  subtitle: const Text('Importer une sauvegarde'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fonction à implémenter'),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.cleaning_services, color: Colors.orange),
                  title: const Text('Nettoyer le cache'),
                  subtitle: const Text('Supprimer les données temporaires'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cache nettoyé'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Bouton de sauvegarde
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Paramètres sauvegardés'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Enregistrer les paramètres'),
            ),
          ),
        ],
      ),
    );
  }
}