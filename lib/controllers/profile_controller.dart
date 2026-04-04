import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:my_diary_app/models/diary_model.dart';
import '../models/profile_model.dart';
import 'package:flutter/material.dart';

class ProfileController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // Luồng dữ liệu profile từ Firestore
  Stream<DocumentSnapshot> get profileStream {
    return _firestore.collection('users').doc(currentUser?.uid).snapshots();
  }

  // Lưu thông tin profile
  Future<void> saveProfile(ProfileModel profile) async {
    if (currentUser == null) return;
    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Logic lọc nhật ký 7 ngày gần nhất
  List<Diary> getRecentDiaries(List<Diary> allDiaries) {
    final now = DateTime.now();
    final sevenDaysAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));

    return allDiaries.where((diary) {
      try {
        DateTime diaryDate = DateFormat('yyyy-MM-dd HH:mm').parse(diary.date);
        return diaryDate.isAfter(sevenDaysAgo);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // Logic tính tâm trạng phổ biến nhất
  String calculateMostFrequentMood(List<Diary> diaries) {
    if (diaries.isEmpty) return "Chưa có";

    Map<String, int> moodCounts = {};
    for (var diary in diaries) {
      moodCounts[diary.mood] = (moodCounts[diary.mood] ?? 0) + 1;
    }

    var sortedMoods = moodCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedMoods.first.key;
  }
}