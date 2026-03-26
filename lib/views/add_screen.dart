import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controllers/diary_controller.dart';
import '../models/diary_model.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedMood = '😊'; // Mặc định là vui vẻ

  final List<String> _moods = ['😊', '🤩', '🥳', '😢', '😡', '😴'];

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      // Ép kiểu ngày giờ thành chuỗi (ví dụ: 2023-10-25 14:30) để lưu lên firebase
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(_selectedDate);

      Provider.of<DiaryController>(context, listen: false).addDiary(
        _titleController.text,
        _contentController.text,
        formattedDate, // Chuyền chuỗi ngày tháng vào đây
        _selectedMood,
      );
      Navigator.pop(context); // Quay lại màn hình chính
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TẠO BÀI MỚI"),
        actions: [
          IconButton(onPressed: _submitData, icon: const Icon(Icons.check_outlined)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Phông tiêu đề nhỏ
              Text(
                "Hôm nay bạn thấy thế nào?",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),

              // 2. PHẦN CHỌN CẢM XÚC - SỬA LỖI TRÀN VIỀN Ở ĐÂY
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _moods.map((mood) => Expanded( // Bọc Expanded để chia đều không gian ngang
                  child: FittedBox( // Bọc FittedBox để tự động thu nhỏ nội dung
                    fit: BoxFit.scaleDown, // Tự động scale xuống nếu icon quá lớn
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMood = mood),
                      child: Container(
                        padding: const EdgeInsets.all(8), // Giữ padding cho dễ thương
                        decoration: BoxDecoration(
                          color: _selectedMood == mood
                              ? const Color(0xFFFDE8E8) // Màu nền hồng pastel khi chọn
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          mood,
                          style: const TextStyle(fontSize: 35), // Kích thước chữ gốc (35)
                          textAlign: TextAlign.center, // Đảm bảo căn giữa
                        ),
                      ),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 25),

              // 3. Ngày giờ (Hiện tại chưa có picker, tạm thời hiển thị)
              Text(
                "Ngày: ${DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate)}",
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 15),

              // 4. Nhập tiêu đề
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Tiêu đề",
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                style: Theme.of(context).textTheme.titleLarge,
                validator: (val) => val == null || val.isEmpty ? 'Hãy nhập tiêu đề nhé' : null,
              ),
              const SizedBox(height: 15),

              // 5. Nhập nội dung
              TextFormField(
                controller: _contentController,
                maxLines: 15, // Cho phép nhập nhiều dòng
                decoration: InputDecoration(
                  labelText: "Hôm nay của bạn thế nào? Chia sẻ câu chuyện của bạn...",
                  labelStyle: const TextStyle(color: Colors.grey),
                  alignLabelWithHint: true, // Căn label lên đầu ô nhập
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Hãy viết gì đó nhé...' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}