import 'package:firebase_auth/firebase_auth.dart';
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

  // Danh sách 4 màn hình tương ứng với 4 nút trên thanh điều hướng
  final List<Widget> _views = const [
    HomeModernView(),     // Tab 0: Home
    CalendarViewScreen(), // Tab 1: Lịch
    ProfileScreen(),      // Tab 2: Hồ sơ (Cá nhân)
    SettingsScreen(),     // Tab 3: Cài đặt
  ];

  // Hàm chuyển tab
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Widget hỗ trợ vẽ từng nút bấm trên BottomAppBar
  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    return IconButton(
      icon: Icon(
        icon,
        size: 28,
        color: isSelected ? const Color(0xFFF06292) : Colors.grey[400], // Màu hồng khi chọn, xám khi bỏ chọn
      ),
      onPressed: () => _onItemTapped(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Màu nền sáng mặc định
      body: _views[_currentIndex],

      // Nút Thêm (Floating Action Button) đặt ở giữa
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddScreen()),
          );
        },
        backgroundColor: const Color(0xFF7B8DFF), // Đổi sang màu xanh tím (giống màu trong hình ảnh mẫu bạn vừa gửi)
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 36),
      ),

      // Thanh điều hướng có vết lõm (Notch)
      bottomNavigationBar: BottomAppBar(
        elevation: 10,
        height: 70,
        color: Colors.white,
        shape: const CircularNotchedRectangle(), // Tạo vết lõm cho nút Thêm
        notchMargin: 8.0, // Khoảng cách từ lõm đến nút
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Nhóm bên trái
            _buildNavItem(Icons.home_filled, 0),
            _buildNavItem(Icons.calendar_today_outlined, 1),

            // Khoảng trống ở giữa để nhường chỗ cho Nút Thêm
            const SizedBox(width: 48),

            // Nhóm bên phải
            _buildNavItem(Icons.insert_chart_outlined, 2), // Icon Hồ sơ / Thống kê như hình
            _buildNavItem(Icons.settings_outlined, 3),     // Icon Cài đặt
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 1. GIAO DIỆN HOME HIỆN ĐẠI (TAB 0)
// ==========================================
class HomeModernView extends StatelessWidget {
  const HomeModernView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DiaryController>(context, listen: false);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Chào buổi sáng! ✨",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Hôm nay của bạn thế nào rồi?",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              height: 100,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                children: const [
                  MoodItem(emoji: "😊", label: "Vui", color: Color(0xFFE8F5E9)),
                  MoodItem(emoji: "😐", label: "Ổn", color: Color(0xFFE3F2FD)),
                  MoodItem(emoji: "😔", label: "Buồn", color: Color(0xFFFFF3E0)),
                  MoodItem(emoji: "😴", label: "Mệt", color: Color(0xFFF3E5F5)),
                  MoodItem(emoji: "🔥", label: "Cháy", color: Color(0xFFFFEBEE)),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                "Nhật ký gần đây",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),

          StreamBuilder<List<Diary>>(
            stream: controller.diariesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Color(0xFFFFB6C1)),
                  )),
                );
              }
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text('Lỗi: ${snapshot.error}')),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Center(child: Text('Chưa có nhật kí nào...🐰')),
                  ),
                );
              }

              final diaries = snapshot.data!;

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => DiaryModernCard(diary: diaries[index]),
                  childCount: diaries.length,
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Thêm khoảng trống tránh bị FAB đè lên nhật ký cuối
        ],
      ),
    );
  }
}

// ==========================================
// 2. GIAO DIỆN LỊCH (TAB 1)
// ==========================================
class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({super.key});
  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  List<Diary> _getDiariesForDay(List<Diary> allDiaries, DateTime day) {
    String formattedDay =
        "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    return allDiaries.where((diary) => diary.date.startsWith(formattedDay)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DiaryController>(context, listen: false);

    return SafeArea(
      child: StreamBuilder<List<Diary>>(
        stream: controller.diariesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFB6C1)));
          }

          final allDiaries = snapshot.data ?? [];
          final selectedDayDiaries = _getDiariesForDay(allDiaries, _selectedDay ?? _focusedDay);

          return Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(bottom: 10),
                child: TableCalendar(
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
                  eventLoader: (day) => _getDiariesForDay(allDiaries, day),

                  // Style màu hồng
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
              ),
              const SizedBox(height: 10),
              Expanded(
                child: selectedDayDiaries.isEmpty
                    ? const Center(
                    child: Text(
                      "Không có nhật ký nào trong ngày này 🐰",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ))
                    : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100), // Padding cuối list
                  itemCount: selectedDayDiaries.length,
                  itemBuilder: (context, index) {
                    return DiaryModernCard(diary: selectedDayDiaries[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ==========================================
// 3. GIAO DIỆN HỒ SƠ (TAB 2)
// ==========================================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFFFB6C1), // Màu avatar tone hồng
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              user?.email ?? "Người dùng ẩn danh",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => FirebaseAuth.instance.signOut(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              icon: const Icon(Icons.logout),
              label: const Text("Đăng xuất"),
            )
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. GIAO DIỆN CÀI ĐẶT (TAB 3)
// ==========================================
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 80, color: Color(0xFFFFB6C1)),
            SizedBox(height: 20),
            Text(
              "Cài Đặt",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Tính năng này đang được phát triển... 🛠️",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET HỖ TRỢ (COMPONENTS)
// ==========================================

class MoodItem extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const MoodItem({super.key, required this.emoji, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54)),
        ],
      ),
    );
  }
}

class DiaryModernCard extends StatelessWidget {
  final Diary diary;

  const DiaryModernCard({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(diary: diary),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04), // Shadow trung tính
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  diary.date,
                  // Màu chữ ngày tháng tone hồng
                  style: const TextStyle(color: Color(0xFFF06292), fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(diary.mood, style: const TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              diary.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            Text(
              diary.content, // Nội dung xem trước
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600], height: 1.6, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}