import 'package:flutter/material.dart';
import '../controllers/diary_controller.dart';
import '../models/diary_model.dart';
import 'add_screen.dart'; // ĐẢM BẢO FILE NÀY TỒN TẠI TRONG THƯ MỤC LIB/VIEWS

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo controller bên trong build để đảm bảo context hợp lệ
    final DiaryController controller = DiaryController();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Màu nền sáng chuyên nghiệp
      appBar: AppBar(
        title: const Text(
            "NHẬT KÝ ĐÁM MÂY",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Diary>>(
        stream: controller.diariesStream,
        builder: (context, snapshot) {
          // 1. Trạng thái đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }

          // 2. Trạng thái lỗi
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }

          // 3. Trạng thái trống
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  const Text("Chưa có kỷ niệm nào trên Cloud.",
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          // 4. Hiển thị danh sách
          final diaries = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: diaries.length,
            itemBuilder: (context, index) {
              final item = diaries[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.withOpacity(0.1),
                    child: Text(item.mood, style: const TextStyle(fontSize: 22)),
                  ),
                  title: Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(item.date, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _showDeleteDialog(context, controller, item.id!),
                  ),
                  onTap: () {
                    // Sau này bạn có thể thêm chức năng xem chi tiết ở đây
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddScreen()),
        ),
        label: const Text("Viết mới"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }

  // Hàm hỗ trợ hiển thị hộp thoại xác nhận xóa
  void _showDeleteDialog(BuildContext context, DiaryController controller, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xóa nhật ký?"),
        content: const Text("Bạn có chắc chắn muốn xóa kỷ niệm này trên Cloud không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("HỦY")),
          TextButton(
              onPressed: () {
                controller.deleteDiary(id);
                Navigator.pop(context);
              },
              child: const Text("XÓA", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}