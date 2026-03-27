import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/diary_controller.dart';
import '../models/diary_model.dart';
// Import trực tiếp từ file home_screen.dart
import 'home_screen.dart';

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({super.key});
  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  // Thêm biến này để quản lý định dạng lịch
  CalendarFormat _calendarFormat = CalendarFormat.month;

  List<Diary> _getDiariesForDay(List<Diary> allDiaries, DateTime day) {
    String formattedDay = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    return allDiaries.where((diary) => diary.date.startsWith(formattedDay)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DiaryController>(context, listen: false);

    return SafeArea(
      child: StreamBuilder<List<Diary>>(
        stream: controller.diariesStream,
        builder: (context, snapshot) {
          final allDiaries = snapshot.data ?? [];
          final selectedDayDiaries = _getDiariesForDay(allDiaries, _selectedDay ?? _focusedDay);

          return Column(
            children: [
              TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                calendarFormat: _calendarFormat, // Gán định dạng
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                // SỬA LỖI EXCEPTION: Thêm hàm xử lý khi đổi định dạng
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false, // Ẩn nút gây lỗi
                  titleCentered: true,
                ),
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(color: Color(0xFFFFB6C1), shape: BoxShape.circle),
                  todayDecoration: BoxDecoration(color: Color(0xFFFDE8E8), shape: BoxShape.circle),
                ),
              ),
              Expanded(
                child: selectedDayDiaries.isEmpty
                    ? const Center(child: Text("Không có nhật ký nào 🐰"))
                    : ListView.builder(
                  itemCount: selectedDayDiaries.length,
                  itemBuilder: (context, index) => DiaryModernCard(diary: selectedDayDiaries[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}