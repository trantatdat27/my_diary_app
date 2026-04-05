import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String fullName;
  final String age;
  final String hobbies;
  final String email;
  final String? avatarUrl;

  ProfileModel({
    required this.fullName,
    required this.age,
    required this.hobbies,
    required this.email,
    this.avatarUrl,
  });

  // Chuyển đổi từ Map (Firestore) sang Object
  factory ProfileModel.fromMap(Map<String, dynamic> data) {
    return ProfileModel(
      fullName: data['fullName'] ?? "",
      age: data['age'] ?? "",
      hobbies: data['hobbies'] ?? "",
      email: data['email'] ?? "",
      avatarUrl: data['avatarUrl'],
    );
  }

  // Chuyển đổi từ Object sang Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'age': age,
      'hobbies': hobbies,
      'email': email,
      'avatarUrl': avatarUrl,
      'lastUpdate': FieldValue.serverTimestamp(),
    };
  }
}