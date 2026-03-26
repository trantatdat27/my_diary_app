import 'package:firebase_core/firebase_core.dart'; // Thêm dòng này
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/diary_controller.dart';
import 'views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Bắt buộc phải có để kết nối Firebase

  runApp(
    ChangeNotifierProvider(
      create: (context) => DiaryController(),
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
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}