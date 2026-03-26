import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diary_model.dart';

class DiaryController {
  final CollectionReference _db = FirebaseFirestore.instance.collection('diaries');

  // 1. Lấy dữ liệu Stream
  Stream<List<Diary>> get diariesStream {
    return _db.orderBy('date', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Diary.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // 2. Hàm thêm mới
  Future<void> addDiary(Diary diary) async {
    await _db.add(diary.toMap());
  }

  // 3. HÀM XÓA (Thêm hàm này để hết lỗi đỏ)
  Future<void> deleteDiary(String id) async {
    try {
      await _db.doc(id).delete();
      print("Đã xóa bài viết thành công");
    } catch (e) {
      print("Lỗi khi xóa: $e");
    }
  }
}