import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/profile_controller.dart';
import '../controllers/diary_controller.dart';
import '../models/diary_model.dart';
import '../models/profile_model.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController _controller = ProfileController();
  bool _isEditing = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _hobbiesController = TextEditingController();
  String? _currentAvatarBase64;

  void _handleSave() async {
    try {
      final updatedProfile = ProfileModel(
        fullName: _nameController.text,
        age: _ageController.text,
        hobbies: _hobbiesController.text,
        email: _controller.currentUser?.email ?? "",
        avatarUrl: _currentAvatarBase64,
      );
      await _controller.saveProfile(updatedProfile);
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thành công! ✅'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận đăng xuất"),
        content: const Text("Bạn có chắc chắn muốn rời khỏi ứng dụng không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              await _controller.signOut();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthScreen()), (route) => false,
              );
            },
            child: const Text("Đăng xuất"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diaryController = Provider.of<DiaryController>(context, listen: false);

    return SafeArea(
      child: StreamBuilder<DocumentSnapshot>(
        stream: _controller.profileStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists && !_isEditing) {
            final data = ProfileModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);
            _nameController.text = data.fullName;
            _ageController.text = data.age;
            _hobbiesController.text = data.hobbies;
            _currentAvatarBase64 = data.avatarUrl; // Lấy ảnh từ Firebase
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 30),
                _buildAvatar(_currentAvatarBase64), // Truyền chuỗi ảnh vào widget
                const SizedBox(height: 10),
                Text(_controller.currentUser?.email ?? "", style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 30),
                _buildField(Icons.badge_outlined, "Họ và tên", _nameController),
                _buildField(Icons.cake_outlined, "Tuổi", _ageController, isNumber: true),
                _buildField(Icons.favorite_border_rounded, "Sở thích", _hobbiesController, maxLines: 2),
                const SizedBox(height: 20),
                _buildStatistics(diaryController),
                const SizedBox(height: 40),
                _buildLogoutButton(),
                const SizedBox(height: 120),
              ],
            ),
          );
        },
      ),
    );
  }

  // Các Widget thành phần nhỏ (Helper Widgets)
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Hồ sơ cá nhân", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        TextButton.icon(
          onPressed: () => _isEditing ? _handleSave() : setState(() => _isEditing = true),
          icon: Icon(_isEditing ? Icons.cloud_upload : Icons.edit_note),
          label: Text(_isEditing ? "Lưu lại" : "Chỉnh sửa"),
        ),
      ],
    );
  }

  Widget _buildStatistics(DiaryController diaryController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Căn lề trái cho tiêu đề
      children: [
        // 1. Tiêu đề bên trên
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            "Thống kê 7 ngày qua",
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A)
            ),
          ),
        ),

        // 2. Bảng thống kê bên dưới
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6FF), // Màu nền xanh nhạt
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.withOpacity(0.05)),
          ),
          child: StreamBuilder<List<Diary>>(
            stream: diaryController.diariesStream,
            builder: (context, dSnapshot) {
              // Lấy dữ liệu và tính toán
              final allDiaries = dSnapshot.data ?? [];
              final recent = _controller.getRecentDiaries(allDiaries);
              final mood = _controller.calculateMostFrequentMood(recent);

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Cột 1: Bài viết mới
                  _buildStatItem("Bài viết mới", "${recent.length}"),

                  // Vạch ngăn cách giữa
                  Container(width: 1, height: 30, color: Colors.blue.withOpacity(0.1)),

                  // Cột 2: Tâm trạng chính
                  _buildStatItem("Tâm trạng chính", mood),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildField(IconData icon, String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        enabled: _isEditing,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF7B8DFF)),
          labelText: label,
          filled: true,
          fillColor: _isEditing ? Colors.white : Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7B8DFF))),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAvatar(String? base64String) {
    return GestureDetector(
      onTap: _isEditing ? () async {
        String? result = await _controller.pickAndConvertImage();
        if (result != null) {
          setState(() => _currentAvatarBase64 = result);
        }
      } : null,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(color: Color(0xFFFFB6C1), shape: BoxShape.circle),
        child: CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          backgroundImage: (base64String != null && base64String.isNotEmpty)
              ? MemoryImage(base64Decode(base64String))
              : null,
          child: (base64String == null || base64String.isEmpty)
              ? const Icon(Icons.person, size: 55, color: Colors.grey)
              : null,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: _showLogoutDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withOpacity(0.1)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent),
            SizedBox(width: 12),
            Text("Đăng xuất tài khoản", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}