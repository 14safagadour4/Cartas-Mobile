class CommunityComment {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String content;
  final DateTime createdAt;

  CommunityComment({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    required this.createdAt,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    return CommunityComment(
      id: json['id'].toString(),
      authorName: json['authorName'] ?? 'Utilisateur',
      authorAvatar: json['authorAvatar'] ?? 'assets/images/forom cumm/62d42fb5d9b7d594b95f9797c2bb5f27.jpg',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'content': content,
    };
  }
}
