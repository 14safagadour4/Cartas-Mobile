class CommunityTopic {
  final String id;
  final String name;
  final String icon;

  CommunityTopic({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory CommunityTopic.fromJson(Map<String, dynamic> json) {
    return CommunityTopic(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
    );
  }
}
