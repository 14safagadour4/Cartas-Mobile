class CommunityPost {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String timeAgo;
  final String content;
  final List<String> images;
  int likes;
  int comments;
  int shares;
  bool isLiked;

  CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.timeAgo,
    required this.content,
    this.images = const [],
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.isLiked = false,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'].toString(),
      authorName: json['authorName'] ?? 'Utilisateur',
      authorAvatar: json['authorAvatar'] ?? 'assets/images/forom cumm/62d42fb5d9b7d594b95f9797c2bb5f27.jpg',
      timeAgo: json['timeAgo'] ?? 'À l\'instant',
      content: json['content'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      isLiked: false, // Default to false locally
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'timeAgo': timeAgo,
      'content': content,
      'images': images,
      'likes': likes,
      'comments': comments,
      'shares': shares,
    };
  }
}
