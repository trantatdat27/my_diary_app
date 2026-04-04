import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/diary_model.dart';
import '../controllers/diary_controller.dart';
import 'add_screen.dart';
import 'dart:io'; // Quan trọng để đọc file ảnh từ máy

class DetailScreen extends StatelessWidget {
  final Diary diary;

  const DetailScreen({super.key, required this.diary});

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
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDE8E8),
                      shape: BoxShape.circle,
                    ),
                    child: Text(diary.mood, style: const TextStyle(fontSize: 35)),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Thời gian viết", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(diary.date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(thickness: 0.8, color: Color(0xFFFDE8E8)),
              ),

              // --- PHẦN HIỂN THỊ ẢNH ĐÃ THÊM ---
              // Kiểm tra nếu trong model có chứa đường dẫn ảnh
              if (diary.images.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(diary.images[0]), // Lấy đường dẫn ảnh đầu tiên
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      // Xử lý nếu ảnh bị xóa khỏi bộ nhớ máy
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image_outlined, color: Colors.grey),
                            Text("Ảnh không còn tồn tại trên máy", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              Text(
                diary.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
              ),
              const SizedBox(height: 15),
              Text(
                diary.content,
                style: TextStyle(fontSize: 17, height: 1.8, color: Colors.grey[800]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}