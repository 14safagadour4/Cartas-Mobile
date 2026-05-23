class UserDrawing {
  final int? id;
  final String userEmail;
  final String templateTitle;
  final String templateImagePath;
  final String drawingDataJson;
  final DateTime? createdAt;

  UserDrawing({
    this.id,
    required this.userEmail,
    required this.templateTitle,
    required this.templateImagePath,
    required this.drawingDataJson,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userEmail': userEmail,
      'templateTitle': templateTitle,
      'templateImagePath': templateImagePath,
      'drawingDataJson': drawingDataJson,
    };
  }

  factory UserDrawing.fromJson(Map<String, dynamic> json) {
    return UserDrawing(
      id: json['id'],
      userEmail: json['userEmail'] ?? '',
      templateTitle: json['templateTitle'] ?? '',
      templateImagePath: json['templateImagePath'] ?? '',
      drawingDataJson: json['drawingDataJson'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
