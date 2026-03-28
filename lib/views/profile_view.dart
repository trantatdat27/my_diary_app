import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_diary_app/controllers/diary_controller.dart' show DiaryController;
import 'package:my_diary_app/models/diary_model.dart' show Diary;
import 'package:provider/provider.dart' show Provider;
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _hobbiesController = TextEditingController();

  // --- LOGIC TÌM TÂM TRẠNG XUẤT HIỆN NHIỀU NHẤT ---
  String _calculateMostFrequentMood(List<Diary> diaries) {
    if (diaries.isEmpty) return "Chưa có";

    Map<String, int> moodCounts = {};
    for (var diary in diaries) {
      moodCounts[diary.mood] = (moodCounts[diary.mood] ?? 0) + 1;
    }

    // Tìm tâm trạng có số lần xuất hiện cao nhất
    var sortedMoods = moodCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedMoods.first.key; // Trả về Emoji tâm trạng phổ biến nhất
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Xác nhận", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              FirebaseAuth.instance.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Đăng xuất", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfileToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fullName': _nameController.text,
        'age': _ageController.text,
        'hobbies': _hobbiesController.text,
        'email': user.email,
        'lastUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() => _isEditing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật thông tin thành công! ✅'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu: $e ❌'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final diaryController = Provider.of<DiaryController>(context, listen: false);

    return SafeArea(
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Đã xảy ra lỗi"));

          if (snapshot.hasData && snapshot.data!.exists && !_isEditing) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            _nameController.text = data['fullName'] ?? "";
            _ageController.text = data['age'] ?? "";
            _hobbiesController.text = data['hobbies'] ?? "";
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Hồ sơ cá nhân", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () {
                        if (_isEditing) {
                          _saveProfileToFirestore();
                        } else {
                          setState(() => _isEditing = true);
                        }
                      },
                      icon: Icon(_isEditing ? Icons.cloud_upload : Icons.edit_note, color: const Color(0xFFF06292)),
                      label: Text(_isEditing ? "Lưu lại" : "Chỉnh sửa",
                          style: const TextStyle(color: Color(0xFFF06292), fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(backgroundColor: const Color(0xFFFDE8E8)),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Color(0xFFFFB6C1), shape: BoxShape.circle),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 55, color: Color(0xFFFFB6C1)),
                  ),
                ),
                const SizedBox(height: 10),
                Text(user?.email ?? "", style: const TextStyle(color: Colors.grey)),

                const SizedBox(height: 30),
                _buildField(Icons.badge_outlined, "Họ và tên", _nameController),
                _buildField(Icons.cake_outlined, "Tuổi", _ageController, isNumber: true),
                _buildField(Icons.favorite_border_rounded, "Sở thích", _hobbiesController, maxLines: 2),

                const SizedBox(height: 20),

                // --- PHẦN THỐNG KÊ CẬP NHẬT TÂM TRẠNG THỰC TẾ ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.withOpacity(0.05)),
                  ),
                  child: StreamBuilder<List<Diary>>(
                    stream: diaryController.diariesStream,
                    builder: (context, dSnapshot) {
                      final diaries = dSnapshot.data ?? [];
                      final topMood = _calculateMostFrequentMood(diaries);

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat("Bài viết", "${diaries.length}"),
                          // Đường kẻ dọc phân cách
                          Container(width: 1, height: 30, color: Colors.blue.withOpacity(0.1)),
                          _buildStat("Tâm trạng chính", topMood),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40),

                InkWell(
                  onTap: () => _showLogoutDialog(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
                        SizedBox(width: 12),
                        Text(
                          "Đăng xuất tài khoản",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(IconData icon, String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        enabled: _isEditing,
        maxLines: maxLines,
        style: const TextStyle(fontWeight: FontWeight.w500),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF7B8DFF)),
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14),
          filled: true,
          fillColor: _isEditing ? Colors.white : Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF7B8DFF), width: 1)),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7B8DFF))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }
}