import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isNotificationEnabled = true;
  bool _isPinLockEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 21, minute: 0);
  String _currentPin = "";

  @override
  void initState() {
    super.initState();
    _loadSettingsFromFirestore();
  }

  // Tải cài đặt từ Firestore khi vào màn hình
  Future<void> _loadSettingsFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _isPinLockEnabled = data?['isPinLockEnabled'] ?? false;
          _isNotificationEnabled = data?['isNotificationEnabled'] ?? true;
          _currentPin = data?['pinCode'] ?? "";
          if (data?['reminderTime'] != null) {
            final parts = data!['reminderTime'].split(':');
            _reminderTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          }
        });
      }
    }
  }

  // Hàm cập nhật dữ liệu lên Firestore
  Future<void> _updateSettings(Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(data, SetOptions(merge: true));
    }
  }

  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && picked != _reminderTime) {
      setState(() => _reminderTime = picked);
      await _updateSettings({'reminderTime': "${picked.hour}:${picked.minute}"});
      _showSnackBar("🔔 Đã đặt lịch nhắc nhở vào ${picked.format(context)}", Colors.green);
    }
  }

  void _showPinDialog({bool isChanging = false}) {
    final TextEditingController pinController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isChanging ? "Thay đổi mã PIN" : "Thiết lập mã PIN mới"),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Nhập 4 số"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (!isChanging && _currentPin.isEmpty) {
                setState(() => _isPinLockEnabled = false);
              }
              Navigator.pop(context);
            },
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (pinController.text.length == 4) {
                await _updateSettings({
                  'pinCode': pinController.text,
                  'isPinLockEnabled': true,
                });
                setState(() {
                  _currentPin = pinController.text;
                  _isPinLockEnabled = true;
                });
                if (!mounted) return;
                Navigator.pop(context);
                _showSnackBar("✅ Mã PIN đã được cập nhật!", Colors.green);
              }
            },
            child: const Text("Xác nhận"),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordWithPin() {
    final TextEditingController pinVerifyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Xác thực mã PIN"),
        content: TextField(
          controller: pinVerifyController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(hintText: "Nhập mã PIN để tiếp tục"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              if (pinVerifyController.text == _currentPin) {
                Navigator.pop(context);
                _handleFirebaseResetPassword();
              } else {
                _showSnackBar("❌ Mã PIN không chính xác", Colors.red);
              }
            },
            child: const Text("Tiếp tục"),
          ),
        ],
      ),
    );
  }

  Future<void> _handleFirebaseResetPassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email != null) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
      _showSnackBar("📧 Link đổi mật khẩu đã gửi tới email", Colors.blue);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 30),
            const Text("Cài đặt", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),
            _buildSectionTitle("Nhắc nhở"),
            _buildSettingTile(
              "Thông báo hàng ngày",
              Icons.notifications_active_outlined,
              switchValue: _isNotificationEnabled,
              onChanged: (val) {
                setState(() => _isNotificationEnabled = val);
                _updateSettings({'isNotificationEnabled': val});
              },
            ),
            if (_isNotificationEnabled)
              ListTile(
                title: const Text("Giờ nhắc nhở"),
                trailing: Text(_reminderTime.format(context),
                    style: const TextStyle(color: Color(0xFFF06292), fontWeight: FontWeight.bold)),
                onTap: _selectReminderTime,
              ),
            const Divider(height: 30),
            _buildSectionTitle("Bảo mật"),
            _buildSettingTile(
              "Sử dụng khóa PIN",
              Icons.lock_person_outlined,
              switchValue: _isPinLockEnabled,
              onChanged: (val) async {
                if (val && _currentPin.isEmpty) {
                  _showPinDialog();
                } else {
                  setState(() => _isPinLockEnabled = val);
                  await _updateSettings({'isPinLockEnabled': val});
                }
              },
            ),
            if (_isPinLockEnabled)
              _buildSettingTile("Thay đổi mã PIN", Icons.pin_outlined,
                  onTap: () => _showPinDialog(isChanging: true)),
            _buildSettingTile("Đổi mật khẩu", Icons.password_rounded,
                onTap: _showChangePasswordWithPin),
            const Divider(height: 30),
            _buildSectionTitle("Hệ thống"),
            _buildSettingTile("Ngôn ngữ", Icons.language_rounded, onTap: () {}),
            const Center(
                child: Text("Phiên bản 1.0.5", style: TextStyle(color: Colors.grey, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title,
          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildSettingTile(String title, IconData icon,
      {bool? switchValue, ValueChanged<bool>? onChanged, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: const Color(0xFFFDE8E8), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: const Color(0xFFF06292), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: switchValue != null
          ? Switch(value: switchValue, onChanged: onChanged, activeColor: const Color(0xFFF06292))
          : const Icon(Icons.chevron_right, size: 20),
    );
  }
}