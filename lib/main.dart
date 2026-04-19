import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/theme.dart';
import 'features/authentication/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thingual',
      debugShowCheckedModeBanner: false,
      theme: ThingualTheme.lightTheme(),
      darkTheme: ThingualTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
    );
  }
}
