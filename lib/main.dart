import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';

import 'home_screen.dart';

import 'login_screen.dart';

import 'notification_service.dart';

import 'todo_service.dart';

const SUPABASE_URL = "https://xrfdahjcuzrekkxvotsh.supabase.co";

const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhyZmRhaGpjdXpyZWtreHZvdHNoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcyNDg1ODEsImV4cCI6MjA3MjgyNDU4MX0.j8DK70q93QFmi_CpHmU1_7Gn6dbRm00aNaV0oBAmWEU";

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
  );

  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(Supabase.instance.client),
        ),
        ChangeNotifierProvider<TodoService>(
          create: (_) => TodoService(Supabase.instance.client),
        ),
      ],
      child: MaterialApp(
        title: 'Todo Reminder',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: Colors.grey[100],
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
        home: const Root(),
      ),
    );
  }
}

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return auth.currentUser == null ? const LoginScreen() : const TodoListScreen();
  }
}
