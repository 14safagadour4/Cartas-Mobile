class TherapyColoring {
  final int id;
  final String title;
  final String difficulty;
  final String duration;
  final String tagColor;
  final String imagePath;

  TherapyColoring({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.duration,
    required this.tagColor,
    required this.imagePath,
  });

  factory TherapyColoring.fromJson(Map<String, dynamic> json) {
    return TherapyColoring(
      id: json['id'],
      title: json['title'] ?? '',
      difficulty: json['difficulty'] ?? '',
      duration: json['duration'] ?? '',
      tagColor: json['tagColor'] ?? '',
      imagePath: json['imagePath'] ?? '',
    );
  }
}
