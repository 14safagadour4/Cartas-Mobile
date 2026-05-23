class ActiveMember {
  final int rank;
  final String name;
  final String title;
  final String points;
  final String posts;
  final String avatar;
  final String icon;
  final String iconColor;

  ActiveMember({
    required this.rank,
    required this.name,
    required this.title,
    required this.points,
    required this.posts,
    required this.avatar,
    required this.icon,
    required this.iconColor,
  });

  factory ActiveMember.fromJson(Map<String, dynamic> json) {
    return ActiveMember(
      rank: json['rank'] ?? 0,
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      points: json['points'] ?? '0',
      posts: json['posts'] ?? '0',
      avatar: json['avatar'] ?? 'assets/images/forom cumm/olivia.jpg',
      icon: json['icon'] ?? 'eco',
      iconColor: json['iconColor'] ?? 'green',
    );
  }
}
