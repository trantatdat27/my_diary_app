import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controllers/diary_controller.dart';
import '../models/diary_model.dart';

class AddScreen extends StatefulWidget {
  final Diary? diary; // Thêm tham số để nhận dữ liệu khi sửa
  const AddScreen({super.key, this.diary});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedMood = '😊';

  final List<String> _moods = ['😊', '🤩', '🥳', '😢', '😡', '😴'];

  @override
  void initState() {
    super.initState();
    // Nếu là chế độ chỉnh sửa, đổ dữ liệu cũ vào form
    if (widget.diary != null) {
      _titleController.text = widget.diary!.title;
      _contentController.text = widget.diary!.content;
      _selectedMood = widget.diary!.mood;
      // Lưu ý: Có thể cần parse widget.diary!.date thành DateTime nếu muốn giữ nguyên ngày cũ
    }
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(_selectedDate);
      final diaryController = Provider.of<DiaryController>(context, listen: false);

      if (widget.diary == null) {
        // Chế độ THÊM MỚI
        diaryController.addDiary(
          _titleController.text,
          _contentController.text,
          formattedDate,
          _selectedMood,
        );
        Navigator.pop(context);
      } else {
        // Chế độ CẬP NHẬT
        diaryController.updateDiary(
          widget.diary!.id!,
          _titleController.text,
          _contentController.text,
          formattedDate,
          _selectedMood,
        );
        // Quay về màn hình chính sau khi sửa
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
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
              Text("Hôm nay bạn thấy thế nào?", style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 10),
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
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Tiêu đề", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                validator: (val) => val == null || val.isEmpty ? 'Hãy nhập tiêu đề' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _contentController,
                maxLines: 15,
                decoration: InputDecoration(labelText: "Nội dung", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                validator: (val) => val == null || val.isEmpty ? 'Hãy viết gì đó' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}