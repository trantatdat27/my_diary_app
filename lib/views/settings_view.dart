import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Text("Cài đặt", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            _buildSettingTile("Thông báo", Icons.notifications_none_rounded, true),
            _buildSettingTile("Chế độ tối", Icons.dark_mode_outlined, false),
            _buildSettingTile("Khóa ứng dụng (PIN)", Icons.lock_outline_rounded, false),

            const Divider(height: 40),
            const Text("Ứng dụng", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildSettingTile("Ngôn ngữ (Tiếng Việt)", Icons.language_rounded, null),
            _buildSettingTile("Đánh giá ứng dụng", Icons.star_border_rounded, null),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(String title, IconData icon, bool? switchValue) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(title),
      trailing: switchValue != null
          ? Switch(value: switchValue, onChanged: (v) {}, activeColor: const Color(0xFFF06292))
          : const Icon(Icons.chevron_right, size: 20),
    );
  }
}