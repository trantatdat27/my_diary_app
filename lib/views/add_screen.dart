import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:convert';
import '../controllers/diary_controller.dart';
import '../models/diary_model.dart';


class AddScreen extends StatefulWidget {
  final Diary? diary;
  const AddScreen({super.key, this.diary});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedMood = '😊';

  // 3. Khai báo biến lưu ảnh đã chọn
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final List<String> _moods = ['😊', '🤩', '🥳', '😢', '😡', '😴'];

  @override
  void initState() {
    super.initState();
    if (widget.diary != null) {
      _titleController.text = widget.diary!.title;
      _contentController.text = widget.diary!.content;
      _selectedMood = widget.diary!.mood;
      // Nếu có ảnh cũ thì load ở đây (tùy thuộc vào model của bạn)
    }
  }

  // 4. Hàm chọn ảnh từ điện thoại
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Nén ảnh cho nhẹ
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _submitData() async { // Phải có async
    if (_formKey.currentState!.validate()) {
      final diaryController = Provider.of<DiaryController>(context, listen: false);

      String? base64Image;
      // 1. Nếu có file ảnh mới được chọn từ máy, chuyển nó sang Base64
      if (_imageFile != null) {
        List<int> imageBytes = await _imageFile!.readAsBytes();
        base64Image = base64Encode(imageBytes);
      }

      if (widget.diary == null) {
        // --- CHẾ ĐỘ THÊM MỚI ---
        String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
        await diaryController.addDiary(
          title: _titleController.text,
          content: _contentController.text,
          date: formattedDate,
          mood: _selectedMood,
          imagePath: base64Image, // Truyền chuỗi Base64 đã xử lý
        );
      } else {
        // --- CHẾ ĐỘ CẬP NHẬT ---
        await diaryController.updateDiary(
          id: widget.diary!.id!,
          title: _titleController.text,
          content: _contentController.text,
          date: widget.diary!.date,
          mood: _selectedMood,
          imagePath: base64Image, // Truyền chuỗi Base64 đã xử lý
        );
      }
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.diary == null ? "TẠO BÀI MỚI" : "CHỈNH SỬA"),
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
              // --- PHẦN CHỌN ẢNH THỰC TẾ ---
              Text("Ảnh đính kèm", style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(_imageFile!, fit: BoxFit.cover), // Hiện ảnh VỪA CHỌN ngay lập tức
                  )
                      : (widget.diary != null && widget.diary!.images.isNotEmpty)
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.memory(
                      base64Decode(widget.diary!.images[0]), // Hiện ảnh CŨ từ database
                      fit: BoxFit.cover,
                    ),
                  )
                      : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                      Text("Chọn ảnh từ điện thoại", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // --- PHẦN CHỌN MOOD (Giữ nguyên của bạn) ---
              Text("Hôm nay bạn thấy thế nào?", style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 10),
              // --- MOOD PICKER: Danh sách Emoji chọn cảm xúc
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _moods.map((mood) => Expanded(
                  child: FittedBox(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMood = mood),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _selectedMood == mood ? const Color(0xFFFDE8E8) : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(mood, style: const TextStyle(fontSize: 35)),
                      ),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 25),

              // --- TIÊU ĐỀ & NỘI DUNG ---
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Tiêu đề",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Hãy nhập tiêu đề' : null,
              ),
              const SizedBox(height: 15),
              // --- INPUT: Ô nhập nội dung hỗ trợ nhiều dòng (maxLines: 10) ---
              TextFormField(
                controller: _contentController,
                maxLines: 10,
                decoration: InputDecoration(
                  labelText: "Nội dung",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  alignLabelWithHint: true,
                ),
                validator: (val) => val == null || val.isEmpty ? 'Hãy viết gì đó' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}