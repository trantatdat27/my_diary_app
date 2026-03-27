import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
        // CHẾ ĐỘ ĐĂNG NHẬP
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        // CHẾ ĐỘ ĐĂNG KÝ
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email, password: password);
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = "Lỗi: ${e.message}";
      if (e.code == 'email-already-in-use') errorMsg = "Tài khoản này đã có rồi, hãy bấm Đăng nhập nhé!";
      if (e.code == 'user-not-found') errorMsg = "Email này chưa đăng ký bạn ơi!";
      if (e.code == 'wrong-password') errorMsg = "Mật khẩu chưa đúng rồi!";
      if (e.code == 'invalid-email') errorMsg = "Email sai định dạng (thiếu @...)";
      if (e.code == 'weak-password') errorMsg = "Mật khẩu phải có ít nhất 6 ký tự.";

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
                _isLogin ? "CHÀO MỪNG TRỞ LẠI 🌸" : "THÀNH VIÊN MỚI 🎀",
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD3A3A3)
                ),
              ),
              const SizedBox(height: 30),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    labelText: "Email",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _passController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Mật khẩu",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
                ),
              ),
              const SizedBox(height: 30),

              // NÚT BẤM CHÍNH
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB6C1),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  _isLogin ? "ĐĂNG NHẬP" : "VÀO NHẬT KÝ",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ), // Đã thêm dấu đóng ngoặc ở đây

              const SizedBox(height: 15),

              // NÚT CHUYỂN ĐỔI
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                    _emailController.clear();
                    _passController.clear();
                  });
                },
                child: Text(
                  _isLogin ? "Chưa có tài khoản? Đăng ký ngay" : "Đã có tài khoản? Đăng nhập",
                  style: const TextStyle(color: Color(0xFFD3A3A3), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}