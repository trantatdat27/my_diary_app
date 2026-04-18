import 'package:cloud_firestore/cloud_firestore.dart'; // Thêm import này
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'pin_lock_screen.dart'; // Import màn hình PIN của bạn
import 'home_screen.dart';    // Import màn hình chính của bạn

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLogin = true;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMsg("Vui lòng điền đủ Email và Mật khẩu nhé! ✨");
      return;
    }

    try {
      if (_isLogin) {
        // --- CHẾ ĐỘ ĐĂNG NHẬP ---
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        final user = userCredential.user;
        if (user != null) {
          // Kiểm tra cài đặt PIN trong Firestore
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          bool isPinEnabled = false;
          if (userDoc.exists) {
            final data = userDoc.data() as Map<String, dynamic>;
            isPinEnabled = data['isPinLockEnabled'] ?? false;
          }

          if (!mounted) return;

          if (isPinEnabled) {
            // Nếu có bật PIN -> Chuyển đến màn hình nhập PIN
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PinLockScreen(nextScreen: HomeScreen()),
              ),
            );
          } else {
            // Nếu không bật PIN -> Vào thẳng trang chủ
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      } else {
        // --- CHẾ ĐỘ ĐĂNG KÝ ---
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email, password: password);

        // Sau khi đăng ký xong thường vào thẳng HomeScreen (vì chưa có mã PIN)
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = "Lỗi: ${e.message}";
      if (e.code == 'email-already-in-use') errorMsg = "Tài khoản này đã có rồi!";
      if (e.code == 'user-not-found') errorMsg = "Email này chưa đăng ký!";
      if (e.code == 'wrong-password') errorMsg = "Mật khẩu chưa đúng!";

      _showMsg(errorMsg);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF0F0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("📔", style: TextStyle(fontSize: 80)),
              const SizedBox(height: 10),
              Text(
                // --- HEADER: Tiêu đề động thay đổi theo chế độ Đăng nhập/Đăng ký ---
                _isLogin ? "CHÀO MỪNG TRỞ LẠI 🌸" : "THÀNH VIÊN MỚI 🎀",
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD3A3A3)),
              ),
              const SizedBox(height: 30),
              // --- INPUT FIELD: Ô nhập Email với icon chỉ dẫn ---
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    labelText: "Email",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 15),
              // --- INPUT FIELD: Ô nhập Mật khẩu có chức năng ẩn/hiện (obscureText) ---
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Mật khẩu",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 30),
              // --- BUTTON: Nút hành động chính (Full-width, màu hồng pastel) ---
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB6C1),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  _isLogin ? "ĐĂNG NHẬP" : "VÀO NHẬT KÝ",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                    _emailController.clear();
                    _passController.clear();
                  });
                },
                child: Text(
                  _isLogin
                      ? "Chưa có tài khoản? Đăng ký ngay"
                      : "Đã có tài khoản? Đăng nhập",
                  style: const TextStyle(
                      color: Color(0xFFD3A3A3), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}