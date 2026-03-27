import 'package:firebase_auth/firebase_auth.dart'; // Thêm thư viện Auth
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/diary_controller.dart';
import 'views/home_screen.dart';
import 'views/auth_screen.dart'; // Giả sử bạn đặt tên file đăng nhập là auth_screen.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    // Sử dụng MultiProvider để dễ dàng mở rộng thêm các Controller khác sau này
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
      // Logic kiểm tra trạng thái đăng nhập ngay tại đây
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Nếu đang kiểm tra kết nối
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // Nếu đã đăng nhập thành công (snapshot có dữ liệu User)
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          // Nếu chưa đăng nhập
          return const AuthScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}