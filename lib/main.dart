import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Firebase
import 'firebase_options.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/task_provider.dart';
import 'providers/admin_provider.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';

// Utils & Services
import 'utils/theme.dart';
import 'services/cache_service.dart';
import 'services/task_service.dart';
import 'services/auth_service.dart';
import 'services/sync_service.dart';

// Models
import 'models/task.dart';

// Widgets
import 'widgets/loading_widget.dart';
import 'widgets/error_widget.dart';
import 'widgets/task_card.dart';
import 'widgets/priority_badge.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print('Initialisation Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialisé');
    
    print('Initialisation Cache...');
    final cacheService = CacheService();
    await cacheService.init();
    print('Cache initialisé');
    
    runApp(MyApp());
  } catch (e) {
    print('Erreur initialisation: $e');
    runApp(MyApp());
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Gestion de Tâches',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                print('Auth state: ${authProvider.currentUser?.email ?? 'Aucun'}');
                
                if (authProvider.isLoading) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                if (authProvider.currentUser != null) {
                  print('Affichage HomeScreen');
                  
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                    taskProvider.initialize(authProvider.currentUser!.uid);
                  });
                  
                  return const HomeScreen();
                }
                
                print('Affichage LoginScreen');
                return const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}