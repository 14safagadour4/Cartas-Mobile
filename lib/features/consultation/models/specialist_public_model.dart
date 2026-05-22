class SpecialistPublicModel {
  final int id;
  final String firstName;
  final String lastName;
  final String? title;
  final String? specialty;
  final String? bio;
  final String? avatarUrl;
  final double rate;
  final String? phone;

  SpecialistPublicModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.title,
    this.specialty,
    this.bio,
    this.avatarUrl,
    required this.rate,
    this.phone,
  });

  String get fullName => '${title != null ? "$title " : ""}$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  factory SpecialistPublicModel.fromJson(Map<String, dynamic> json) {
    return SpecialistPublicModel(
      id: json['id'] as int,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      title: json['title'],
      specialty: json['specialty'],
      bio: json['bio'],
      avatarUrl: json['avatarUrl'],
      rate: (json['rate'] ?? 0).toDouble(),
      phone: json['phone'],
    );
  }
}
