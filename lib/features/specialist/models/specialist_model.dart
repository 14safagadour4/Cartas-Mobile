class SpecialistModel {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String? specialty;
  final String? bio;
  final String? title;
  final String? phone;
  final double rate;
  final String? avatarUrl;

  SpecialistModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.specialty,
    this.bio,
    this.title,
    this.phone,
    required this.rate,
    this.avatarUrl,
  });

  factory SpecialistModel.fromJson(Map<String, dynamic> json) {
    return SpecialistModel(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      specialty: json['specialty'],
      bio: json['bio'],
      title: json['title'],
      phone: json['phone'],
      rate: (json['rate'] ?? 0.0).toDouble(),
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'specialty': specialty,
      'bio': bio,
      'title': title,
      'phone': phone,
      'rate': rate,
    };
  }
}
