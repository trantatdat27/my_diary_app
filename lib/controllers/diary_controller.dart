import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Thêm import này
import '../models/diary_model.dart';

class DiaryController with ChangeNotifier {
  final CollectionReference _db = FirebaseFirestore.instance.collection('diaries');

  // Lấy UID của người dùng hiện tại
  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Stream<List<Diary>> get diariesStream {
    // Thêm điều kiện where để lọc theo userId
    return _db
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Diary.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> addDiary(String title, String content, String date, String mood) async {
    try {
      await _db.add({
        'title': title,
        'content': content,
        'date': date,
        'mood': mood,
        'userId': _currentUserId, // Lưu thêm ID người dùng
        'thumbnailImageUrl': 'https://cdn-icons-png.flaticon.com/512/1000/1000957.png',
      });
      notifyListeners();
    } catch (e) {
      print("Lỗi: $e");
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