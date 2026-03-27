import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diary_model.dart';

class DiaryController with ChangeNotifier {
  // Trỏ tới collection 'diaries' trên Firestore
  final CollectionReference _db = FirebaseFirestore.instance.collection('diaries');

  // 1. Cung cấp Stream để HomeScreen lắng nghe realtime
  Stream<List<Diary>> get diariesStream {
    return _db.orderBy('date', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Diary.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // 2. Hàm Thêm mới lên Firestore
  Future<void> addDiary(String title, String content, String date, String mood) async {
    try {
      final newDiary = Diary(
        title: title,
        content: content,
        date: date,
        mood: mood,
        thumbnailImageUrl: 'https://cdn-icons-png.flaticon.com/512/1000/1000957.png',
      );
      await _db.add(newDiary.toMap());
      notifyListeners();
    } catch (e) {
      print("Lỗi khi thêm bài viết: $e");
    }
  }

  // 3. Hàm Xóa trên Firestore
  Future<void> deleteDiary(String id) async {
    try {
      await _db.doc(id).delete();
      notifyListeners();
    } catch (e) {
      print("Lỗi khi xóa: $e");
    }
  }

  // 4. Hàm Cập nhật trên Firestore
  Future<void> updateDiary(String id, String title, String content, String date, String mood) async {
    try {
      await _db.doc(id).update({
        'title': title,
        'content': content,
        'date': date,
        'mood': mood,
      });
      notifyListeners();
    } catch (e) {
      print("Lỗi khi cập nhật: $e");
    }
  }
}