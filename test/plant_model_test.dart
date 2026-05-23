import 'package:flutter_test/flutter_test.dart';
import 'package:cartas/features/herbier/models/plant.dart';

void main() {
  group('Plant Model - Unit Tests & JSON Parsing', () {
    
    test('Devrait correctement parser un JSON complet et valide', () {
      // GIVEN : Un dictionnaire simulant un JSON complet reçu de l'API Spring Boot
      final Map<String, dynamic> jsonResponse = {
        'id': 42,
        'name': 'Romarin',
        'nameAr': 'إكليل الجبل',
        'nameLatin': 'Rosmarinus officinalis',
        'imagePath': 'assets/images/romarin.png',
        'category': 'IMMUNITE',
        'description': 'Plante aromatique méditerranéenne.',
        'history': 'Utilisé depuis l\'Antiquité pour stimuler la mémoire.',
        'region': 'Tunisie (Zaghouan)',
        'benefits': ['Stimulant digestif', 'Antioxydant', 'Favorise la mémoire'],
        'usage': 'Infusion de 10 min de feuilles séchées.',
        'precautions': 'Éviter en cas de grossesse.',
        'shopLink': 'https://cartas.tn/boutique/romarin',
        'rating': 4.7,
        'isFavorite': true,
      };

      // WHEN : Désérialisation via le constructeur factory fromJson
      final plant = Plant.fromJson(jsonResponse);

      // THEN : Vérification que chaque propriété est correctement mappée et typée
      expect(plant.id, 42);
      expect(plant.name, 'Romarin');
      expect(plant.nameAr, 'إكليل الجبل');
      expect(plant.nameLatin, 'Rosmarinus officinalis');
      expect(plant.imagePath, 'assets/images/romarin.png');
      expect(plant.category, PlantCategory.immunite); // Vérification de l'énumération
      expect(plant.description, 'Plante aromatique méditerranéenne.');
      expect(plant.history, 'Utilisé depuis l\'Antiquité pour stimuler la mémoire.');
      expect(plant.region, 'Tunisie (Zaghouan)');
      expect(plant.benefits, containsAll(['Stimulant digestif', 'Antioxydant', 'Favorise la mémoire']));
      expect(plant.usage, 'Infusion de 10 min de feuilles séchées.');
      expect(plant.precautions, 'Éviter en cas de grossesse.');
      expect(plant.shopLink, 'https://cartas.tn/boutique/romarin');
      expect(plant.rating, 4.7);
      expect(plant.isFavorite, isTrue);
    });

    test('🛡️ Devrait gérer les valeurs nulles et utiliser les valeurs par défaut', () {
      // GIVEN : Un JSON minimaliste avec beaucoup de valeurs manquantes ou nulles
      final Map<String, dynamic> minimalJson = {
        'id': 12,
        'name': 'Menthe',
        // D'autres champs sont manquants
      };

      // WHEN : Désérialisation
      final plant = Plant.fromJson(minimalJson);

      // THEN : Le modèle ne doit pas crasher et doit utiliser ses fallbacks par défaut
      expect(plant.id, 12);
      expect(plant.name, 'Menthe');
      expect(plant.nameAr, ''); // Par défaut chaîne vide
      expect(plant.nameLatin, '');
      expect(plant.imagePath, '');
      expect(plant.category, PlantCategory.calmant); // Fallback par défaut (calmant)
      expect(plant.description, '');
      expect(plant.benefits, isEmpty); // Liste vide
      expect(plant.rating, 0.0); // Zéro par défaut
      expect(plant.isFavorite, isFalse); // Faux par défaut
    });

    test('🔀 Devrait mapper correctement toutes les catégories (Case Insensitive)', () {
      final List<Map<String, dynamic>> testCases = [
        {'category': 'CALMANT', 'expected': PlantCategory.calmant},
        {'category': 'digestion', 'expected': PlantCategory.digestion},
        {'category': 'IMMUNITE', 'expected': PlantCategory.immunite},
        {'category': 'ENERGIE', 'expected': PlantCategory.energie},
        {'category': 'PEAU', 'expected': PlantCategory.peau},
        {'category': 'sommeil', 'expected': PlantCategory.sommeil},
        {'category': 'CATEGORIE_INCONNUE', 'expected': PlantCategory.calmant}, // Fallback
      ];

      for (var testCase in testCases) {
        final json = {'id': 1, 'category': testCase['category']};
        final plant = Plant.fromJson(json);
        expect(plant.category, testCase['expected'], 
          reason: 'La catégorie ${testCase['category']} doit être convertie en ${testCase['expected']}');
      }
    });

    test('🔢 Devrait parser les ratings qu\'ils soient Double, Int ou String', () {
      final List<Map<String, dynamic>> testCases = [
        {'rating': 4.5, 'expected': 4.5},
        {'rating': 5, 'expected': 5.0},
        {'rating': '3.8', 'expected': 3.8},
        {'rating': 'non-valide', 'expected': 0.0},
        {'rating': null, 'expected': 0.0},
      ];

      for (var testCase in testCases) {
        final json = {'id': 1, 'rating': testCase['rating']};
        final plant = Plant.fromJson(json);
        expect(plant.rating, testCase['expected'],
          reason: 'La note ${testCase['rating']} de type ${testCase['rating'].runtimeType} doit être convertie en ${testCase['expected']}');
      }
    });

    test('📝 Devrait supporter l\'usage sous la clé "usage_ins" ou "usage"', () {
      // GIVEN : Un JSON utilisant "usage_ins" comme clé (envoyée parfois par l'API)
      final Map<String, dynamic> jsonWithUsageIns = {
        'id': 1,
        'usage_ins': 'Appliquer sur la peau.'
      };

      // WHEN : Désérialisation
      final plant = Plant.fromJson(jsonWithUsageIns);

      // THEN : Le champ usage doit contenir la valeur de usage_ins
      expect(plant.usage, 'Appliquer sur la peau.');
    });
  });
}
