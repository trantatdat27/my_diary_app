import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/diary_controller.dart';
import '../models/diary_model.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final DiaryController _diaryController = DiaryController();

  // Biến lưu cảm xúc đang chọn
  String _selectedMood = "😊";
  final List<String> _moods = ["😊", "🤩", "🥳", "😢", "😡", "😴"];

  void _saveDiary() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ tiêu đề và nội dung!")),
      );
      return;
    }

    // Hiển thị vòng xoay đang tải
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final newDiary = Diary(
        title: _titleController.text,
        content: _contentController.text,
        date: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
        mood: _selectedMood,
      );

      // Gọi Controller để lưu lên Firebase
      await _diaryController.addDiary(newDiary);

      if (mounted) {
        Navigator.pop(context); // Đóng vòng xoay
        Navigator.pop(context); // Quay lại trang chủ
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Đóng vòng xoay nếu lỗi
      print("Lỗi lưu bài viết: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("VIẾT NHẬT KÝ"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _saveDiary,
            icon: const Icon(Icons.check, size: 30),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Hôm nay bạn thấy thế nào?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 15),

            // Bộ chọn cảm xúc (Mood Selector)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _moods.map((mood) => GestureDetector(
                onTap: () => setState(() => _selectedMood = mood),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedMood == mood ? Colors.teal.withOpacity(0.2) : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: _selectedMood == mood ? Colors.teal : Colors.transparent,
                        width: 2
                    ),
                  ),
                  child: Text(mood, style: const TextStyle(fontSize: 30)),
                ),
              )).toList(),
            ),

            const SizedBox(height: 30),

            // Ô nhập tiêu đề
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: "Tiêu đề bài viết...",
                border: InputBorder.none,
              ),
            ),
            const Divider(height: 30),

            // Ô nhập nội dung
            TextField(
              controller: _contentController,
              maxLines: null, // Tự động xuống dòng
              keyboardType: TextInputType.multiline,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                hintText: "Kể cho mình nghe về ngày hôm nay của bạn...",
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
      // Nút lưu dưới cùng (Option 2 nếu không bấm trên AppBar)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton.icon(
          onPressed: _saveDiary,
          icon: const Icon(Icons.cloud_upload),
          label: const Text("LƯU LÊN ĐÁM MÂY", style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}