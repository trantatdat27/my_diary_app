import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String fullName;
  final String age;
  final String hobbies;
  final String email;

  ProfileModel({
    required this.fullName,
    required this.age,
    required this.hobbies,
    required this.email,
  });

  // Chuyển đổi từ Map (Firestore) sang Object
  factory ProfileModel.fromMap(Map<String, dynamic> data) {
    return ProfileModel(
      fullName: data['fullName'] ?? "",
      age: data['age'] ?? "",
      hobbies: data['hobbies'] ?? "",
      email: data['email'] ?? "",
    );
  }

  // Chuyển đổi từ Object sang Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'age': age,
      'hobbies': hobbies,
      'email': email,
      'lastUpdate': FieldValue.serverTimestamp(),
    };
  }
}