import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PinLockScreen extends StatefulWidget {
  final Widget nextScreen;
  const PinLockScreen({super.key, required this.nextScreen});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final TextEditingController _pinController = TextEditingController();
  String _correctPin = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPinFromFirestore();
  }

  // Tải mã PIN từ Firestore
  Future<void> _loadPinFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        var doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          _correctPin = doc.data()?['pinCode'] ?? "";
        }
      } catch (e) {
        debugPrint("Lỗi tải PIN: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  void _verifyPin(String enteredPin) {
    if (enteredPin == _correctPin) {
      // Chuyển vào màn hình kế tiếp nếu đúng
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => widget.nextScreen),
      );
    } else {
      _pinController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Mã PIN không chính xác!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFDF0F0),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFF06292))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDF0F0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              const Icon(Icons.lock_outline_rounded, size: 80, color: Color(0xFFF06292)),
              const SizedBox(height: 20),
              const Text(
                "NHẬP MÃ PIN",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 10),
              const Text("Vui lòng nhập mã khóa để tiếp tục",
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: TextField(
                  controller: _pinController,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  autofocus: true, // Tự động mở bàn phím
                  style: const TextStyle(
                      fontSize: 32, letterSpacing: 20, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    counterText: "",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFF06292), width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.length == 4) _verifyPin(value);
                  },
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text("Đăng xuất tài khoản",
                    style: TextStyle(color: Color(0xFFF06292))),
              )
            ],
          ),
        ),
      ),
    );
  }
}