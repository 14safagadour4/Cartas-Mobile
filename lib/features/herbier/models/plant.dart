// Plant categories related to their main therapeutic use

enum PlantCategory { calmant, digestion, immunite, energie, peau, sommeil }

extension PlantCategoryExt on PlantCategory {
  String get label {
    switch (this) {
      case PlantCategory.calmant: return 'Calm.\nStress';
      case PlantCategory.digestion: return 'Digest.';
      case PlantCategory.immunite: return 'Immun.';
      case PlantCategory.energie: return 'Énergie';
      case PlantCategory.peau: return 'Beauté';
      case PlantCategory.sommeil: return 'Sommeil';
    }
  }

  String get translationKey {
    switch (this) {
      case PlantCategory.calmant: return 'cat_calmant';
      case PlantCategory.digestion: return 'cat_digestion';
      case PlantCategory.immunite: return 'cat_immunite';
      case PlantCategory.energie: return 'cat_energie';
      case PlantCategory.peau: return 'cat_peau';
      case PlantCategory.sommeil: return 'cat_sommeil';
    }
  }

  String get icon {
    switch (this) {
      case PlantCategory.calmant: return '🌸';
      case PlantCategory.digestion: return '🍃';
      case PlantCategory.immunite: return '🛡️';
      case PlantCategory.energie: return '⚡';
      case PlantCategory.peau: return '🧴';
      case PlantCategory.sommeil: return '😴';
    }
  }
}

class Plant {
  final int id;
  final String name;
  final String nameAr;
  final String nameLatin;
  final String imagePath;
  final PlantCategory category;
  final String description;
  final String history;
  final String region;
  final List<String> benefits;
  final String usage;
  final String precautions;
  final String shopLink;
  final double rating;
  bool isFavorite;

  Plant({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.nameLatin,
    required this.imagePath,
    required this.category,
    required this.description,
    required this.history,
    required this.region,
    required this.benefits,
    required this.usage,
    required this.precautions,
    required this.shopLink,
    required this.rating,
    this.isFavorite = false,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    PlantCategory mapCategory(String catStr) {
      switch (catStr.toUpperCase()) {
        case 'CALMANT': return PlantCategory.calmant;
        case 'DIGESTION': return PlantCategory.digestion;
        case 'IMMUNITE': return PlantCategory.immunite;
        case 'ENERGIE': return PlantCategory.energie;
        case 'PEAU': return PlantCategory.peau;
        case 'SOMMEIL': return PlantCategory.sommeil;
        default: return PlantCategory.calmant; // Default fallback
      }
    }

    return Plant(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      nameLatin: json['nameLatin'] ?? '',
      imagePath: json['imagePath'] ?? '',
      category: mapCategory(json['category'] ?? ''),
      description: json['description'] ?? '',
      history: json['history'] ?? '',
      region: json['region'] ?? '',
      benefits: List<String>.from(json['benefits'] ?? []),
      usage: json['usage_ins'] ?? json['usage'] ?? '',
      precautions: json['precautions'] ?? '',
      shopLink: json['shopLink'] ?? '',
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) ?? 0.0 : 0.0,
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}
