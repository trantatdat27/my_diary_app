import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/diary_model.dart';
import '../controllers/diary_controller.dart';
import 'add_screen.dart';

class DetailScreen extends StatelessWidget {
  final Diary diary;

  const DetailScreen({super.key, required this.diary});

  // Hàm hiển thị hộp thoại xác nhận xóa
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa nhật ký?"),
        content: const Text("Dữ liệu đã xóa sẽ không thể khôi phục lại."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("HỦY")),
          TextButton(
            onPressed: () {
              Provider.of<DiaryController>(context, listen: false).deleteDiary(diary.id!);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("XÓA", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF0F0),
      appBar: AppBar(
        title: const Text("CHI TIẾT"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddScreen(diary: diary)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(diary.mood, style: const TextStyle(fontSize: 40)),
                  Text(diary.date, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                diary.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 30, thickness: 1, color: Color(0xFFFDE8E8)),
              Text(
                diary.content,
                style: const TextStyle(fontSize: 18, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}