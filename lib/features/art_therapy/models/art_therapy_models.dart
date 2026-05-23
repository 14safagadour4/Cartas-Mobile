class ArtTherapist {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? bio;
  final String? artDiscipline;
  final String? avatarUrl;
  final String status;

  ArtTherapist({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.bio,
    this.artDiscipline,
    this.avatarUrl,
    required this.status,
  });

  factory ArtTherapist.fromJson(Map<String, dynamic> json) {
    return ArtTherapist(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      bio: json['bio'],
      artDiscipline: json['artDiscipline'],
      avatarUrl: json['avatarUrl'],
      status: json['status'],
    );
  }
}

class Workshop {
  final int id;
  final String title;
  final String? description;
  final DateTime date;
  final double price;
  final int maxParticipants;
  final int currentParticipants;
  final String? imageUrl;
  final String status;
  final String format;
  final String? location;

  Workshop({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.price,
    required this.maxParticipants,
    required this.currentParticipants,
    this.imageUrl,
    required this.status,
    required this.format,
    this.location,
  });

  factory Workshop.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      if (json['date'] != null) {
        if (json['date'] is List) {
          // Gère le format [YYYY, MM, DD, HH, mm] renvoyé parfois par Spring
          final List d = json['date'];
          parsedDate = DateTime(d[0], d[1], d[2], d.length > 3 ? d[3] : 0, d.length > 4 ? d[4] : 0);
        } else {
          parsedDate = DateTime.parse(json['date'].toString());
        }
      } else {
        parsedDate = DateTime.now();
      }
    } catch (e) {
      parsedDate = DateTime.now();
    }

    return Workshop(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? 'Sans titre',
      description: json['description']?.toString(),
      date: parsedDate,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      maxParticipants: json['maxParticipants'] ?? 10,
      currentParticipants: json['currentParticipants'] ?? 0,
      imageUrl: json['imageUrl']?.toString(),
      status: json['status']?.toString() ?? 'UPCOMING',
      format: json['format']?.toString() ?? 'ONLINE',
      location: json['location']?.toString(),
    );
  }
}

class AppUser {
  final int id;
  final String firstName;
  final String lastName;
  final String email;

  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
    );
  }
}

class WorkshopRegistration {
  final int id;
  final AppUser user;
  final Workshop workshop;
  final String status;
  final DateTime registeredAt;

  WorkshopRegistration({
    required this.id,
    required this.user,
    required this.workshop,
    required this.status,
    required this.registeredAt,
  });

  factory WorkshopRegistration.fromJson(Map<String, dynamic> json) {
    return WorkshopRegistration(
      id: json['id'],
      user: AppUser.fromJson(json['user']),
      workshop: Workshop.fromJson(json['workshop']),
      status: json['status'],
      registeredAt: DateTime.parse(json['registeredAt']),
    );
  }
}
class Review {
  final int id;
  final String userName;
  final String userInitial;
  final String workshopTitle;
  final double rating;
  final String comment;
  final String date;

  Review({
    required this.id,
    required this.userName,
    required this.userInitial,
    required this.workshopTitle,
    required this.rating,
    required this.comment,
    required this.date,
  });
}
