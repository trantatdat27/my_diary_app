import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/diary_controller.dart';
import '../models/diary_model.dart';
import 'add_screen.dart';
import 'detail_screen.dart';
import 'calendar_view.dart';
import 'profile_view.dart';
import 'settings_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Danh sách các màn hình
  final List<Widget> _views = const [
    HomeModernView(),     // Nội dung nằm ngay bên dưới file này
    CalendarViewScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    return IconButton(
      icon: Icon(
        icon,
        size: 28,
        color: isSelected ? const Color(0xFFF06292) : Colors.grey[400],
      ),
      onPressed: () => _onItemTapped(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: _views[_currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddScreen()),
          );
        },
        backgroundColor: const Color(0xFF7B8DFF),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 36),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 10,
        height: 70,
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, 0),
            _buildNavItem(Icons.calendar_today_outlined, 1),
            const SizedBox(width: 48),
            _buildNavItem(Icons.person_outline_rounded, 2),
            _buildNavItem(Icons.settings_outlined, 3),
          ],
        ),
      ),
    );
  }
}

// --- NỘI DUNG TAB TRANG CHỦ (Gộp chung vào đây) ---
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
                  Text("Chào buổi sáng! ✨", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                  const SizedBox(height: 8),
                  Text("Hôm nay của bạn thế nào rồi?", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
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
          StreamBuilder<List<Diary>>(
            stream: controller.diariesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
              if (!snapshot.hasData || snapshot.data!.isEmpty) return const SliverToBoxAdapter(child: Center(child: Text('Chưa có nhật kí nào...🐰')));

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => DiaryModernCard(diary: snapshot.data![index]),
                  childCount: snapshot.data!.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// Các Widget phụ bổ trợ (Components)
class MoodItem extends StatelessWidget {
  final String emoji, label;
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
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
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(diary: diary))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(diary.date, style: const TextStyle(color: Color(0xFFF06292), fontSize: 13, fontWeight: FontWeight.bold)),
                Text(diary.mood, style: const TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 12),
            Text(diary.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            Text(diary.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], height: 1.6, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}