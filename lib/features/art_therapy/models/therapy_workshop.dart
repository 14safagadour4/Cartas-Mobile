class TherapyWorkshop {
  final int id;
  final String title;
  final String description;
  final String instructor;
  final String workshopDate;
  final String workshopTime;
  final String rating;
  final String places;
  final String price;
  final bool isOnline;
  final String imagePath;

  TherapyWorkshop({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.workshopDate,
    required this.workshopTime,
    required this.rating,
    required this.places,
    required this.price,
    required this.isOnline,
    required this.imagePath,
  });

  factory TherapyWorkshop.fromJson(Map<String, dynamic> json) {
    return TherapyWorkshop(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      instructor: json['instructor'] ?? '',
      workshopDate: json['workshopDate'] ?? '',
      workshopTime: json['workshopTime'] ?? '',
      rating: json['rating'] ?? '',
      places: json['places'] ?? '',
      price: json['price'] ?? '',
      isOnline: json['online'] ?? false,
      imagePath: json['imagePath'] ?? '',
    );
  }
}
