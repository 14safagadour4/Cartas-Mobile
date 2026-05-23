import 'dart:convert';
import 'dart:io';
import 'lib/features/herbier/data/plants_data.dart';

void main() {
  final List<Map<String, dynamic>> jsonList = plantsData.map((plant) {
    return {
      'id': plant.id,
      'name': plant.name,
      'nameAr': plant.nameAr,
      'nameLatin': plant.nameLatin,
      'imagePath': plant.imagePath,
      'category': plant.category.name.toUpperCase(),
      'description': plant.description,
      'history': plant.history,
      'region': plant.region,
      'benefits': plant.benefits,
      'usage': plant.usage,
      'precautions': plant.precautions,
      'shopLink': plant.shopLink,
      'rating': plant.rating,
      'isFavorite': plant.isFavorite,
    };
  }).toList();

  final jsonString = jsonEncode(jsonList);
  final file = File('plants.json');
  file.writeAsStringSync(jsonString);
  print('Successfully generated plants.json with ${jsonList.length} plants.');
}
