import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/diary_controller.dart';
import 'notification_service.dart';
import 'views/home_screen.dart';
import 'views/auth_screen.dart';
import 'views/pin_lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DiaryController()),
      ],
      child: const CuteDiaryApp(),
    ),
  );
}

class CuteDiaryApp extends StatelessWidget {
  const CuteDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cute Diary App',
      theme: ThemeData(
        primaryColor: const Color(0xFFFDE8E8),
        scaffoldBackgroundColor: const Color(0xFFFDF0F0),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFFFB6C1),
          secondary: const Color(0xFFD3A3A3),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            // Nếu đã đăng nhập, dùng AuthWrapper để kiểm tra mã PIN
            return const AuthWrapper();
          }
          return const AuthScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        bool isPinEnabled = false;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          isPinEnabled = data['isPinLockEnabled'] ?? false;
        }

        if (isPinEnabled) {
          return const PinLockScreen(nextScreen: HomeScreen());
        }
        return const HomeScreen();
      },
    );
  }
}