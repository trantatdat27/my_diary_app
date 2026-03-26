class Diary {
  final String? id;
  final String title;
  final String content;
  final String date;
  final String mood;
  final String? thumbnailImageUrl;

  Diary({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    this.thumbnailImageUrl,
  });

  // Chuyển dữ liệu thành Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'date': date,
      'mood': mood,
      'thumbnailImageUrl': thumbnailImageUrl,
    };
  }

  // Lấy dữ liệu từ Firestore (Map) và chuyển thành đối tượng Diary
  factory Diary.fromMap(Map<String, dynamic> map, String documentId) {
    return Diary(
      id: documentId,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      date: map['date'] ?? '',
      mood: map['mood'] ?? '😊',
      thumbnailImageUrl: map['thumbnailImageUrl'],
    );
  }
}