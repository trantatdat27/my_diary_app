import 'package:flutter/material.dart';
import '../models/diary_model.dart';


class DetailScreen extends StatelessWidget {
  final Diary diary; // Nhận dữ liệu của 1 bài nhật ký

  const DetailScreen({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF0F0), // Nền hồng nhạt cho đồng bộ giao diện
      appBar: AppBar(
        title: const Text("CHI TIẾT"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cảm xúc và Ngày tháng
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    diary.mood,
                    style: const TextStyle(fontSize: 40),
                  ),
                  Text(
                    diary.date,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tiêu đề
              Text(
                diary.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Divider(height: 30, thickness: 1, color: Color(0xFFFDE8E8)),

              // Nội dung
              Text(
                diary.content,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.6, // Khoảng cách dòng cho dễ đọc
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}