import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'theme/theme_provider.dart';
import 'services/notification_service.dart';
import 'services/task_service.dart';
import 'services/auth_service.dart';
import 'providers/task_provider.dart';

import 'screens/home_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<TaskService>(create: (_) => TaskService()),
        ChangeNotifierProxyProvider<TaskService, TaskProvider>(
          create: (context) =>
              TaskProvider(service: context.read<TaskService>()),
          update: (context, service, previous) =>
              previous ?? TaskProvider(service: service),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'To Do App with Flutter',
            theme: theme.lightTheme,
            darkTheme: theme.darkTheme,
            themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData) {
                  return const HomeScreen();
                } else {
                  return const LoginScreen();
                }
              },
            ),
            routes: {
              '/home': (_) => const HomeScreen(),
              '/add': (_) => const AddTaskScreen(),
              '/settings': (_) => const SettingsScreen(),
              '/profile': (_) => const ProfileScreen(),
              '/login': (_) => const LoginScreen(),
              '/signup': (_) => const SignupScreen(),
            },
          );
        },
      ),
    );
  }
}
