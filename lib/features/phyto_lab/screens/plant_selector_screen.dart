import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cartas/features/herbier/providers/plant_provider.dart';
import 'package:cartas/features/phyto_lab/providers/phyto_lab_provider.dart';

class PlantSelectorScreen extends StatefulWidget {
  const PlantSelectorScreen({super.key});

  @override
  State<PlantSelectorScreen> createState() => _PlantSelectorScreenState();
}

class _PlantSelectorScreenState extends State<PlantSelectorScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les plantes si la liste est vide
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final plantProvider = Provider.of<PlantProvider>(context, listen: false);
      if (plantProvider.plants.isEmpty) {
        plantProvider.fetchPlants();
      }
      Provider.of<PhytoLabProvider>(context, listen: false).warmupIA();
    });
  }

  @override
  Widget build(BuildContext context) {
    final plantProvider = Provider.of<PlantProvider>(context);
    final labProvider = Provider.of<PhytoLabProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Sélection des Plantes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF81C784), Color(0xFFAED581)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Étape 2: Choisissez vos ingrédients",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Sélectionnez entre 3 et 4 plantes (${labProvider.selectedPlants.length}/4)",
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              if (labProvider.selectedPlants.isNotEmpty)
                Container(
                  height: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: labProvider.selectedPlants.length,
                    itemBuilder: (context, index) {
                      final plant = labProvider.selectedPlants[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white54),
                        ),
                        child: Row(
                          children: [
                            Text(plant.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap: () => labProvider.togglePlantSelection(plant),
                              child: const Icon(Icons.close, size: 18, color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                  ),
                  child: plantProvider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF81C784)))
                    : plantProvider.plants.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.eco_outlined, size: 80, color: Colors.grey),
                                const SizedBox(height: 10),
                                const Text("Aucune plante trouvée", style: TextStyle(color: Colors.grey, fontSize: 18)),
                                TextButton(
                                  onPressed: () => plantProvider.fetchPlants(),
                                  child: const Text("Réessayer", style: TextStyle(color: Color(0xFF81C784))),
                                )
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(20),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                            ),
                            itemCount: plantProvider.plants.length,
                            itemBuilder: (context, index) {
                              final plant = plantProvider.plants[index];
                              bool isSelected = labProvider.selectedPlants.contains(plant);
                              
                              return GestureDetector(
                                onTap: () => labProvider.togglePlantSelection(plant),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF81C784) : Colors.grey.shade200,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected ? Colors.green.withOpacity(0.2) : Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                                          child: Image.network(
                                            plant.imagePath,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.eco, size: 50, color: Colors.green),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              plant.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              plant.nameLatin,
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                                              maxLines: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ),
              
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: (labProvider.selectedPlants.length >= 3)
                      ? () {
                          context.push('/analysis-result');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF81C784),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: Text(
                    labProvider.selectedPlants.length < 3
                        ? "Sélectionnez au moins 3 plantes"
                        : "Lancer l'analyse AI ✨",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
