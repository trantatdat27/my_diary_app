import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/diary_model.dart';
import 'dart:convert';
import 'dart:io';

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

// Trong DiaryController, tìm hàm thêm nhật ký của bạn và sửa như sau:
  Future<void> addDiary({
    required String title,
    required String content,
    required String date,
    required String mood,
    String? imagePath, // Bây giờ nó nhận chuỗi Base64 trực tiếp
  }) async {
    try {
      await _db.add({
        'title': title,
        'content': content,
        'date': date,
        'mood': mood,
        'userId': _currentUserId,
        'images': (imagePath != null && imagePath.isNotEmpty) ? [imagePath] : [],
        'timestamp': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      print("Lỗi lưu nhật ký: $e");
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

      // Nếu có ảnh mới (Base64), cập nhật lại mảng images
      if (imagePath != null && imagePath.isNotEmpty) {
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