// Plant categories related to their main therapeutic use

enum PlantCategory {
  calmant('🌸', 'Calm.\nStress', 'cat_calmant'),
  digestion('🍃', 'Digest.', 'cat_digestion'),
  immunite('🛡️', 'Immun.', 'cat_immunite'),
  energie('⚡', 'Énergie', 'cat_energie'),
  peau('🧴', 'Beauté', 'cat_peau'),
  sommeil('😴', 'Sommeil', 'cat_sommeil');

  final String icon;
  final String label;
  final String translationKey;

  const PlantCategory(this.icon, this.label, this.translationKey);
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
