class Diary {
  final String? id;
  final String title;
  final String content;
  final String date;
  final String mood;

  Diary({this.id, required this.title, required this.content, required this.date, required this.mood});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'date': date,
      'mood': mood,
    };
  }

  factory Diary.fromMap(Map<String, dynamic> map, String id) {
    return Diary(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      date: map['date'] ?? '',
      mood: map['mood'] ?? '😊',
    );
  }
}