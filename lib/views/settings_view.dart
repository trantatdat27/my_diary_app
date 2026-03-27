import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 80, color: Color(0xFFFFB6C1)),
            SizedBox(height: 20),
            Text("Cài Đặt", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Tính năng này đang được phát triển... 🛠️", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}