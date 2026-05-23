import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import '../providers/learning_provider.dart';

class RecipeExerciseScreen extends StatefulWidget {
  const RecipeExerciseScreen({super.key});

  @override
  State<RecipeExerciseScreen> createState() => _RecipeExerciseScreenState();
}

class _RecipeExerciseScreenState extends State<RecipeExerciseScreen> {
  final Color titlePurple = const Color(0xFF764F7E);
  final Color subtitleMauve = const Color(0xFFA67FB6);
  final Color lightPinkBg = const Color(0xFFFEF3F5);

  int _currentStep = 0;
  final List<String> _selectedFruitsVeggies = [];
  final List<String> _selectedOilsAromas = [];
  String _selectedPlate = "";
  String _recipeName = "";

  final List<Map<String, dynamic>> _fruitsVeggies = [
    {
      'name': 'Citron', 
      'localName': 'Qares',
      'image': 'assets/images/citron.png',
      'benefit': 'Énergie & Vitamines',
      'description': 'Le citron donne du punch à ta peau et à ton corps !',
    },
    {
      'name': 'Concombre', 
      'localName': 'Khayar',
      'image': 'assets/images/cocamb.png', 
      'benefit': 'Hydratation Fraîche',
      'description': 'Le concombre est comme une gorgée d\'eau fraîche pour ton visage.',
    },
    {
      'name': 'Grenade', 
      'localName': 'Rouman',
      'image': 'assets/images/pomegran.png', 
      'benefit': 'Super Antioxydant',
      'description': 'La grenade est le trésor rouge de la Tunisie, elle te rend fort !',
    },
    {
      'name': 'Carotte', 
      'localName': 'Sfinaria',
      'image': 'assets/images/carrot.png', 
      'benefit': 'Bonne Mine',
      'description': 'Les carottes donnent des couleurs et aident à bien voir la nuit.',
    },
  ];

  final List<Map<String, dynamic>> _oilsAromas = [
    {
      'name': 'Eau de Rose', 
      'localName': 'Ma Wared',
      'image': 'assets/images/ma-ward.png', 
      'benefit': 'Douceur Fleurie',
      'description': 'L\'eau de rose sent le paradis et rend ta peau toute douce.',
    },
    {
      'name': 'Huile d\'Olive', 
      'localName': 'Zit Zitoun',
      'image': 'assets/images/olivehuil.png', 
      'benefit': 'Or Liquide',
      'description': 'C\'est le trésor de nos oliviers, elle nourrit tout ton corps.',
    },
    {
      'name': 'Eau de Fleur d\'Oranger', 
      'localName': 'Ma Zhar',
      'image': 'assets/images/orangema.png', 
      'benefit': 'Calme Royal',
      'description': 'Une goutte de Zhar et tout le monde est calme et joyeux.',
    },
  ];

  final List<Map<String, dynamic>> _plates = [
    {'name': 'Bol Traditionnel', 'image': 'assets/images/boll.png'},
    {'name': 'Assiette Fleurie', 'image': 'assets/images/assiet-fleur.png'},
    {'name': 'Assiette en Bois', 'image': 'assets/images/assiet-bois.png'},
  ];

  void _showDetail(Map<String, dynamic> item, Function onAdd, bool isSelected, int max) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item['image'] != null) Image.asset(item['image'], height: 120),
              const SizedBox(height: 16),
              Text(
                '${item['name']} (${item['localName']})',
                style: AppTextStyles.title(22, titlePurple),
              ),
              const SizedBox(height: 12),
              Text(
                item['description'],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: titlePurple.withOpacity(0.8), height: 1.4),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onAdd();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: titlePurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  isSelected ? 'Retirer' : 'Ajouter',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Retour', style: TextStyle(color: subtitleMauve)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _finishExercise() {
    context.read<LearningProvider>().addMamanEnfantScore(100);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, color: Colors.amber, size: 80),
              const SizedBox(height: 20),
              Text('Atelier Terminé !', style: AppTextStyles.title(24, titlePurple)),
              const SizedBox(height: 12),
              Text(
                'Bravo ! Vous avez créé "$_recipeName" avec maman dans votre $_selectedPlate.',
                textAlign: TextAlign.center,
                style: TextStyle(color: subtitleMauve, fontSize: 16),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F2E2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.psychology, color: AppColors.sage, size: 24),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Conseil de Tawhida AI', style: TextStyle(fontWeight: FontWeight.bold, color: titlePurple))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Posez vos questions à Tawhida AI ! Elle peut vous suggérer d\'autres activités amusantes à faire avec votre enfant.',
                      style: TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: titlePurple,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Retour au Forum', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/chat');
                },
                child: Text('Parler à Tawhida AI', style: TextStyle(color: AppColors.sage, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: titlePurple),
          onPressed: () => context.pop(),
        ),
        title: Text('Atelier Créatif', style: AppTextStyles.title(20, titlePurple)),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _buildCurrentStep(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildIntroStep();
      case 1: return _buildNameStep();
      case 2: return _buildFruitsVeggiesStep();
      case 3: return _buildOilsAromasStep();
      case 4: return _buildPlateStep();
      case 5: return _buildFinalStep();
      default: return const SizedBox();
    }
  }

  Widget _buildIntroStep() {
    return SingleChildScrollView(
      key: const ValueKey(0),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset('assets/images/mam-enf cuisine.jpg', height: 250, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 32),
          Text('Bienvenue à l\'Atelier !', style: AppTextStyles.title(26, titlePurple), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(
            'Aujourd\'hui, on va préparer un mélange secret ensemble. On commence par choisir nos ingrédients !',
            style: TextStyle(fontSize: 18, color: subtitleMauve, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => setState(() => _currentStep = 1),
            style: ElevatedButton.styleFrom(
              backgroundColor: titlePurple,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('C\'est parti !', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildNameStep() {
    return Padding(
      key: const ValueKey(1),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📔', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 24),
          Text('Comment s\'appelle votre mélange ?', style: AppTextStyles.title(22, titlePurple), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          TextField(
            onChanged: (val) => _recipeName = val,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Ex: Le Masque Éclatant',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            ),
            style: TextStyle(fontSize: 20, color: titlePurple, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              if (_recipeName.isNotEmpty) setState(() => _currentStep = 2);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: titlePurple,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Continuer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFruitsVeggiesStep() {
    return _buildSelectionStep(
      key: 2,
      title: 'Étape 1 : Fruits & Légumes',
      subtitle: 'Choisis jusqu\'à 3 ingrédients',
      items: _fruitsVeggies,
      selectedItems: _selectedFruitsVeggies,
      max: 3,
      onNext: () => setState(() => _currentStep = 3),
    );
  }

  Widget _buildOilsAromasStep() {
    return _buildSelectionStep(
      key: 3,
      title: 'Étape 2 : Huiles & Arômes',
      subtitle: 'Choisis jusqu\'à 2 ingrédients',
      items: _oilsAromas,
      selectedItems: _selectedOilsAromas,
      max: 2,
      onNext: () => setState(() => _currentStep = 4),
    );
  }

  Widget _buildSelectionStep({required int key, required String title, required String subtitle, required List<Map<String, dynamic>> items, required List<String> selectedItems, required int max, required VoidCallback onNext}) {
    return Padding(
      key: ValueKey(key),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(title, style: AppTextStyles.title(20, titlePurple)),
          Text(subtitle, style: TextStyle(color: subtitleMauve)),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 16, mainAxisSpacing: 16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = selectedItems.contains(item['name']);
                return GestureDetector(
                  onTap: () => _showDetail(item, () {
                    setState(() {
                      if (isSelected) {
                        selectedItems.remove(item['name']);
                      } else if (selectedItems.length < max) selectedItems.add(item['name']);
                    });
                  }, isSelected, max),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? lightPinkBg : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isSelected ? titlePurple : Colors.transparent, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (item['image'] != null) Image.asset(item['image'], height: 60)
                        else Text(item['icon'] ?? '🌱', style: const TextStyle(fontSize: 40)),
                        const SizedBox(height: 8),
                        Text(item['name'], style: TextStyle(fontWeight: FontWeight.bold, color: titlePurple)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: selectedItems.isNotEmpty ? onNext : null,
            style: ElevatedButton.styleFrom(backgroundColor: titlePurple, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            child: const Text('Étape Suivante', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlateStep() {
    return Padding(
      key: const ValueKey(4),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Étape 3 : L\'Assiette', style: AppTextStyles.title(22, titlePurple)),
          const SizedBox(height: 32),
          ..._plates.map((plate) => GestureDetector(
            onTap: () => setState(() => _selectedPlate = plate['name']),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _selectedPlate == plate['name'] ? lightPinkBg : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _selectedPlate == plate['name'] ? titlePurple : Colors.transparent, width: 2),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(plate['image']!, width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 20),
                  Text(plate['name'], style: TextStyle(fontSize: 18, color: titlePurple, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          )),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _selectedPlate.isNotEmpty ? () => setState(() => _currentStep = 5) : null,
            style: ElevatedButton.styleFrom(backgroundColor: titlePurple, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            child: const Text('Mélanger le tout !', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalStep() {
    return Padding(
      key: const ValueKey(5),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wb_sunny, color: Colors.amber, size: 100),
          const SizedBox(height: 20),
          Text('Votre $_recipeName est prêt !', style: AppTextStyles.title(24, titlePurple), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(
            'Ingrédients : ${_selectedFruitsVeggies.join(", ")} avec ${_selectedOilsAromas.join(" et ")}.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: subtitleMauve),
          ),
          const SizedBox(height: 8),
          Text('Présenté dans : $_selectedPlate', style: const TextStyle(fontStyle: FontStyle.italic)),
          const SizedBox(height: 60),
          ElevatedButton(
            onPressed: _finishExercise,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.sage, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            child: const Text('C\'est Magique !', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ],
      ),
    );
  }
}

