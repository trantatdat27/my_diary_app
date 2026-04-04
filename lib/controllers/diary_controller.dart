import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/diary_model.dart';

class DiaryController with ChangeNotifier {
  final CollectionReference _db = FirebaseFirestore.instance.collection('diaries');

  // Lấy UID của người dùng hiện tại
  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Stream<List<Diary>> get diariesStream {
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

  // Cập nhật hàm addDiary dùng tham số có tên {}
  Future<void> addDiary({
    required String title,
    required String content,
    required String date,
    required String mood,
    String? imagePath, // Tham số ảnh từ điện thoại
  }) async {
    try {
      await _db.add({
        'title': title,
        'content': content,
        'date': date,
        'mood': mood,
        'userId': _currentUserId,
        'thumbnailImageUrl': 'https://cdn-icons-png.flaticon.com/512/1000/1000957.png',
        'images': imagePath != null ? [imagePath] : [],
      });
      notifyListeners();
    } catch (e) {
      print("Lỗi khi thêm: $e");
    }
  }

  // Hàm Cập nhật
  Future<void> updateDiary({
    required String id,
    required String title,
    required String content,
    required String date,
    required String mood,
    String? imagePath,
  }) async {
    try {
      Map<String, dynamic> data = {
        'title': title,
        'content': content,
        'date': date,
        'mood': mood,
      };
      if (imagePath != null) {
        data['images'] = [imagePath];
      }
      await _db.doc(id).update(data);
      notifyListeners();
    } catch (e) {
      print("Lỗi cập nhật: $e");
    }
  }

  Future<void> deleteDiary(String id) async {
    try {
      await _db.doc(id).delete();
      notifyListeners();
    } catch (e) {
      print("Lỗi khi xóa: $e");
    }
  }
}