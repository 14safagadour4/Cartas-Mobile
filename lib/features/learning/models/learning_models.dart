import 'dart:convert';
import 'package:flutter/material.dart';

class LearningCategory {
  final String id;
  final String title;
  final String subtitle;
  final Color baseColor;

  LearningCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.baseColor,
  });

  factory LearningCategory.fromJson(Map<String, dynamic> json) {
    return LearningCategory(
      id: json['id'].toString(),
      title: json['name'] ?? '',
      subtitle: json['description'] ?? '',
      baseColor: _parseColor(json['icon'] ??
          '#E8F2E2'), // On utilise icon pour stocker la couleur ou un code
    );
  }

  static Color _parseColor(String colorStr) {
    if (colorStr.startsWith('#')) {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    }
    return const Color(0xFFE8F2E2);
  }
}

class LearningModule {
  final String id;
  final String categoryId;
  final String title;
  final String description;
  final double progress;
  final int totalLessons;
  final String duration;
  final String imageUrl;
  final String? contentType;
  final List<Lesson> lessons; // Correction du nom de type

  LearningModule({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.progress,
    required this.totalLessons,
    required this.duration,
    required this.imageUrl,
    this.contentType,
    this.lessons = const [],
  });

  factory LearningModule.fromJson(Map<String, dynamic> json) {
    var lessonsList = json['lessons'] as List? ?? [];
    List<Lesson> parsedLessons =
        lessonsList.map((l) => Lesson.fromJson(l)).toList();

    return LearningModule(
      id: json['id'].toString(),
      categoryId: json['categoryId']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      progress: 0.0,
      totalLessons: json['totalLessons'] ?? 0,
      duration: json['duration'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      contentType: json['contentType'],
      lessons: parsedLessons,
    );
  }
}

class QuizQuestion {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  QuizQuestion({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      questionText: json['questionText'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex: json['correctAnswerIndex'] ?? 0,
      explanation: json['explanation'] ?? '',
    );
  }
}

class Quiz {
  final String id;
  final String title;
  final String subtitle;
  final List<QuizQuestion> questions;
  final Color baseColor;

  Quiz({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.questions,
    required this.baseColor,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      questions: (json['questions'] as List?)
              ?.map((q) => QuizQuestion.fromJson(q))
              .toList() ??
          [],
      baseColor: _parseColor(json['baseColor'] ?? '#FEF3F5'),
    );
  }

  static Color _parseColor(String colorStr) {
    if (colorStr.startsWith('#')) {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    }
    return const Color(0xFFFEF3F5);
  }
}

class LessonBlock {
  final String type; // 'text', 'image', 'tip', 'interactive'
  final String content;
  final String? extraData;

  LessonBlock({required this.type, required this.content, this.extraData});

  factory LessonBlock.fromJson(Map<String, dynamic> json) {
    return LessonBlock(
      type: json['type'] ?? 'text',
      content: json['content'] ?? '',
      extraData: json['extraData'],
    );
  }
}

class Lesson {
  final String id;
  final String moduleId;
  final String title;
  final List<LessonBlock> blocks;
  final String duration;
  final Quiz? attachedQuiz;

  Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.blocks,
    required this.duration,
    this.attachedQuiz,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'].toString(),
      moduleId: json['moduleId']?.toString() ?? '',
      title: json['title'] ?? '',
      blocks: _parseBlocks(json['blocksJson']),
      duration: json['duration'] ?? '',
      attachedQuiz: json['attachedQuiz'] != null
          ? Quiz.fromJson(json['attachedQuiz'])
          : null,
    );
  }

  static List<LessonBlock> _parseBlocks(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> list = json.decode(jsonStr);
      return list.map((b) => LessonBlock.fromJson(b)).toList();
    } catch (e) {
      return [];
    }
  }
}

// --- MOCK DATA ---
class LearningMockData {
  static final List<LearningCategory> categories = [
    LearningCategory(
      id: 'c1',
      title: 'Plantes Traditionnelles',
      subtitle: 'Trésors de la nature',
      baseColor: const Color(0xFFE8F2E2),
    ),
    LearningCategory(
      id: 'c2',
      title: 'Espace Maman-Enfant',
      subtitle: 'Partage interactif',
      baseColor: const Color(0xFFFDE8E9),
    ),
    LearningCategory(
      id: 'c3',
      title: 'Héritage Tunisien',
      subtitle: 'Histoires anciennes',
      baseColor: const Color(0xFFDFE2F2),
    ),
    LearningCategory(
      id: 'c4',
      title: 'Nutrition Saine',
      subtitle: 'Recettes & Bien-être',
      baseColor: const Color(0xFFFFF4E0),
    ),
  ];

  static final List<LearningModule> modules = [
    LearningModule(
      id: 'm1',
      categoryId: 'c1',
      title: 'Histoire des plantes médicinales',
      description:
          'De Carthage à nos jours, découvrez comment nos ancêtres utilisaient la nature.',
      progress: 0.0,
      totalLessons: 3,
      duration: '15 min',
      imageUrl: 'assets/images/screen2.png',
    ),
    LearningModule(
      id: 'm2',
      categoryId: 'c1',
      title: 'Remèdes naturels tunisiens',
      description: 'Recettes ancestrales pour le bien-être quotidien.',
      progress: 0.0,
      totalLessons: 2,
      duration: '13 min',
      imageUrl: 'assets/images/remedes.png',
    ),
    LearningModule(
      id: 'm3',
      categoryId: 'c4',
      title: 'Recettes & tutoriels santé',
      description: 'Apprenez à cuisiner avec les herbes de notre terroir.',
      progress: 0.0,
      totalLessons: 2,
      duration: '20 min',
      imageUrl: 'assets/images/nutri.jpg',
    ),
    LearningModule(
      id: 'm4',
      categoryId: 'c4',
      title: 'Alternatives Naturelles',
      description: 'Remplacez les produits synthétiques par le naturel.',
      progress: 0.0,
      totalLessons: 1,
      duration: '10 min',
      imageUrl: 'assets/images/saine.jpg',
    ),
  ];

  static final List<Lesson> lessons = [
    // Leçons pour le module 'm1'
    Lesson(
      id: 'l1',
      moduleId: 'm1',
      title: 'Les origines carthaginoises',
      duration: '5 min',
      blocks: [
        LessonBlock(
            type: 'text',
            content:
                'Carthage était non seulement une puissance maritime, mais aussi un centre de savoir botanique exceptionnel. Les jardins de Carthage étaient célèbres pour leur diversité, abritant des espèces rapportées de tout le bassin méditerranéen.'),
        LessonBlock(type: 'image', content: 'assets/images/aloe.png'),
        LessonBlock(
            type: 'tip',
            content:
                'Le saviez-vous ? L\'aloé vera était appelé "Plante de l\'immortalité" et était utilisé pour soigner les brûlures des soldats après les batailles.'),
        LessonBlock(
            type: 'text',
            content:
                'Les prêtresses de Tanit utilisaient également le pavot et la mandragore pour leurs propriétés apaisantes lors des cérémonies sacrées.'),
      ],
      attachedQuiz: Quiz(
        id: 'q1',
        title: 'Origines Antiques',
        subtitle: 'Vérifiez vos connaissances',
        baseColor: const Color(0xFFE8F2E2),
        questions: [
          QuizQuestion(
            questionText:
                'Quelle plante était surnommée "Plante de l\'immortalité" à Carthage ?',
            options: ['La Menthe', 'L\'Aloé Vera', 'Le Romarin'],
            correctAnswerIndex: 1,
            explanation:
                'Exact ! L\'Aloé Vera était sacrée pour ses vertus apaisantes et régénératrices.',
          ),
          QuizQuestion(
            questionText:
                'Les jardins de Carthage étaient-ils connus pour leur diversité ?',
            options: [
              'Oui, absolument',
              'Non, c\'était un désert',
              'Seulement pour les oliviers'
            ],
            correctAnswerIndex: 0,
            explanation:
                'En effet, Carthage importait des plantes de toute la Méditerranée pour ses jardins botaniques.',
          ),
        ],
      ),
    ),
    Lesson(
      id: 'l2',
      moduleId: 'm1',
      title: 'L\'Héritage Andalou',
      duration: '10 min',
      blocks: [
        LessonBlock(
            type: 'text',
            content:
                'Avec l\'arrivée des Andalous en Tunisie, l\'art de la distillation s\'est perfectionné. Les techniques de "l\'Alambic" ont permis d\'extraire les essences les plus pures de nos fleurs.'),
        LessonBlock(type: 'image', content: 'assets/images/huile.jpg'),
        LessonBlock(
            type: 'text',
            content:
                'L\'eau de fleur d\'oranger (Zhar) et l\'eau de rose (Ma Ward) sont devenues les piliers de la pharmacopée et de la gastronomie tunisienne.'),
        LessonBlock(
            type: 'interactive',
            content: 'Touchez pour découvrir le secret de la distillation !',
            extraData: 'FlipCard'),
      ],
    ),
    // Leçons pour 'm2'
    Lesson(
      id: 'l4',
      moduleId: 'm2',
      title: 'Le Romarin : Force du Sud',
      duration: '5 min',
      blocks: [
        LessonBlock(
            type: 'text',
            content:
                'Le romarin (klil) est la plante emblématique des montagnes tunisiennes. Puissant antioxydant, il stimule la mémoire et facilite la digestion.'),
        LessonBlock(type: 'image', content: 'assets/images/romarin.png'),
        LessonBlock(
            type: 'tip',
            content:
                'Astuce de grand-mère : Une branche de romarin sous l\'oreiller aiderait à avoir les idées claires au réveil !'),
      ],
      attachedQuiz: Quiz(
        id: 'q2',
        title: 'Le pouvoir du Romarin',
        subtitle: 'Testez-vous',
        baseColor: const Color(0xFFE8F2E2),
        questions: [
          QuizQuestion(
            questionText: 'Quel est le nom local du Romarin ?',
            options: ['Zatar', 'Klil', 'Randa'],
            correctAnswerIndex: 1,
            explanation:
                'C\'est bien le Klil ! Très utilisé aussi bien en cuisine que pour ses vertus médicinales.',
          ),
        ],
      ),
    ),
    // Leçons pour 'm3' - Nutrition Saine
    Lesson(
      id: 'l5',
      moduleId: 'm3',
      title: 'Thé glacé Menthe-Citron',
      duration: '10 min',
      blocks: [
        LessonBlock(
            type: 'text',
            content:
                'Une boisson rafraîchissante et détoxifiante, parfaite pour les après-midi d\'été en Tunisie.'),
        LessonBlock(type: 'image', content: 'assets/images/menthe.png'),
        LessonBlock(
            type: 'text',
            content:
                'Ingrédients :\n- Une poignée de menthe fraîche\n- 2 citrons bio\n- Un peu de miel naturel\n- Eau de source'),
        LessonBlock(
            type: 'tip',
            content:
                'Le conseil de Tawhida : Ne faites pas bouillir la menthe, laissez-la infuser dans l\'eau chaude éteinte pour garder tous les arômes.'),
      ],
    ),
    Lesson(
      id: 'l6',
      moduleId: 'm3',
      title: 'Poulet au Romarin et Olives',
      duration: '15 min',
      blocks: [
        LessonBlock(
            type: 'text',
            content:
                'Un plat équilibré qui allie les protéines du poulet aux bienfaits digestifs du romarin et des graisses saines de l\'olive.'),
        LessonBlock(type: 'image', content: 'assets/images/huil recipe.jpg'),
        LessonBlock(
            type: 'text',
            content:
                'La cuisson lente permet aux arômes du terroir de pénétrer la chair pour un goût authentique.'),
      ],
    ),
    // Leçons pour 'm4' - Alternatives
    Lesson(
      id: 'l7',
      moduleId: 'm4',
      title: 'Sommeil : Adieu le chimique',
      duration: '10 min',
      blocks: [
        LessonBlock(
            type: 'text',
            content:
                'Plutôt que des somnifères synthétiques, tournez-vous vers l\'alliance apaisante de la Lavande et du Zhar.'),
        LessonBlock(type: 'image', content: 'assets/images/lavande.png'),
        LessonBlock(
            type: 'tip',
            content:
                'Rituel du soir : Une cuillère à café d\'eau de fleur d\'oranger (Zhar) dans un verre d\'eau tiède avant de dormir fait des merveilles.'),
      ],
    ),
  ];

  // interactive offline quizzes displayed in the quiz section
  static final List<Quiz> interactiveQuizzes = [
    Quiz(
        id: 'quiz_feuilles',
        title: 'Identifier les\nFeuilles',
        subtitle: 'Quiz de 5 min',
        baseColor: const Color(0xFFFEF3F5),
        questions: [
          QuizQuestion(
            questionText:
                'Quelle est cette feuille fortement aromatique récoltée au printemps ?',
            options: ['Le Géranium', 'La Menthe', 'Le Thym'],
            correctAnswerIndex: 0,
            explanation:
                'Ah! Le géranium (Aterchya) a une feuille très reconnaissable et distillée au printemps.',
          ),
          QuizQuestion(
            questionText:
                'Quelle plante est utilisée pour le fameux thé tunisien ?',
            options: ['Le Laurier', 'La Menthe', 'Le Romarin'],
            correctAnswerIndex: 1,
            explanation:
                'Bravo ! La menthe (Nanaa) est l\'âme du thé tunisien.',
          ),
        ]),
    Quiz(
        id: 'quiz_anciens',
        title: 'Sagesse des\nAnciens',
        subtitle: 'Prêt pour le défi ?',
        baseColor: const Color(0xFFC2E9A7),
        questions: [
          QuizQuestion(
            questionText: 'Quel ingrédient est essentiel dans la Bassisa ?',
            options: ['Eau de rose', 'Graines de fenouil', 'Poivre noir'],
            correctAnswerIndex: 1,
            explanation:
                'Le fenouil et l\'anis apportent cette saveur caractéristique à la Bassisa.',
          ),
          QuizQuestion(
            questionText: 'Quel était l\'usage principal du Zhar autrefois ?',
            options: [
              'Nettoyer le sol',
              'Calmer les nerfs et parfumer',
              'Faire briller les chaussures'
            ],
            correctAnswerIndex: 1,
            explanation:
                'Le Zhar est depuis toujours utilisé pour ses vertus apaisantes et son parfum délicat.',
          ),
        ])
  ];
}
