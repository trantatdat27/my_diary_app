import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/diary_controller.dart';
import '../models/diary_model.dart';
import 'add_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _views = const [TimelineView(), CalendarViewScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? "NHẬT KÝ CỦA TÔI" : "LỊCH",
          style: const TextStyle(letterSpacing: 1.2),
        ),
      ),
      body: _views[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddScreen()),
        ),
        child: const Icon(Icons.add_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.history_edu_outlined), label: 'Dòng thời gian'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Lịch'),
        ],
      ),
    );
  }
}

// ==========================================
// 1. GIAO DIỆN DÒNG THỜI GIAN (TAB 1)
// ==========================================
class TimelineView extends StatelessWidget {
  const TimelineView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DiaryController>(context, listen: false);

    return StreamBuilder<List<Diary>>(
      stream: controller.diariesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Chưa có nhật kí nào...'));
        }

        final diaries = snapshot.data!;
        final totalEntries = diaries.length;

        return ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            Card(
              margin: const EdgeInsets.all(15),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    const Text('🐰', style: TextStyle(fontSize: 40)),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("NHẬT KÝ CỦA BẠN", style: Theme.of(context).textTheme.titleLarge),
                        Text("Tổng số: $totalEntries nhật kí", style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ...diaries.map((diary) => DiaryEntryCard(diary: diary)).toList(),
          ],
        );
      },
    );
  }
}

// ==========================================
// 2. GIAO DIỆN XEM THEO LỊCH (TAB 2)
// ==========================================
class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({super.key});
  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  // Hàm hỗ trợ: Lọc danh sách nhật ký theo một ngày cụ thể
  List<Diary> _getDiariesForDay(List<Diary> allDiaries, DateTime day) {
    // Ép kiểu ngày của TableCalendar về định dạng chuỗi "yyyy-MM-dd" để so sánh
    String formattedDay =
        "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

    return allDiaries.where((diary) {
      // Vì diary.date lưu cả giờ (VD: "2023-10-25 14:30"), ta chỉ cần check phần đầu
      return diary.date.startsWith(formattedDay);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DiaryController>(context, listen: false);

    return StreamBuilder<List<Diary>>(
      stream: controller.diariesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Lấy danh sách toàn bộ nhật ký (nếu chưa có thì trả về mảng rỗng)
        final allDiaries = snapshot.data ?? [];

        // Lọc ra các nhật ký thuộc ngày đang được chọn
        final selectedDayDiaries = _getDiariesForDay(allDiaries, _selectedDay ?? _focusedDay);

        return Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              // HIỂN THỊ DẤU CHẤM: TableCalendar sẽ dùng hàm này để biết ngày nào có bài viết
              eventLoader: (day) => _getDiariesForDay(allDiaries, day),

              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(color: Color(0xFFFFB6C1), shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: Color(0xFFFDE8E8), shape: BoxShape.circle),
                markerDecoration: BoxDecoration(color: Color(0xFFFFB6C1), shape: BoxShape.circle),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: Theme.of(context).textTheme.titleLarge!,
              ),
            ),
            const Divider(),

            // DANH SÁCH BÀI VIẾT TRONG NGÀY BÊN DƯỚI LỊCH
            Expanded(
              child: selectedDayDiaries.isEmpty
                  ? const Center(
                  child: Text(
                    "Không có nhật ký nào trong ngày này 🐰",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ))
                  : ListView.builder(
                itemCount: selectedDayDiaries.length,
                itemBuilder: (context, index) {
                  return DiaryEntryCard(diary: selectedDayDiaries[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ==========================================
// 3. WIDGET THẺ HIỂN THỊ 1 BÀI NHẬT KÝ
// ==========================================
class DiaryEntryCard extends StatelessWidget {
  final Diary diary;
  const DiaryEntryCard({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(diary: diary),
            ),
          );
        },
        leading: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: const Color(0xFFFDF0F0)),
          child: Center(child: Text(diary.mood, style: const TextStyle(fontSize: 25))),
        ),
        title: Text(diary.title, style: Theme.of(context).textTheme.titleLarge, overflow: TextOverflow.ellipsis),
        subtitle: Text(diary.date),
        trailing: Text(diary.mood, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}