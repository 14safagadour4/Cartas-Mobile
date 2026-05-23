import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cartas/features/phyto_lab/providers/phyto_lab_provider.dart';

class HealthProfileFormScreen extends StatefulWidget {
  const HealthProfileFormScreen({super.key});

  @override
  State<HealthProfileFormScreen> createState() => _HealthProfileFormScreenState();
}

class _HealthProfileFormScreenState extends State<HealthProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PhytoLabProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profil Santé', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            colors: [Color(0xFFFFB7C5), Color(0xFFFDE4E4)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Étape 1: Votre Profil",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Ces informations nous permettent de calculer la synergie parfaite pour vous.",
                        style: TextStyle(fontSize: 15, color: Color(0xFF6D4C41), fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/my-remedies'),
                      icon: const Icon(Icons.history, size: 18, color: Color(0xFFFF4081)),
                      label: const Text("Mes Remèdes", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF4081))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                
                // Form Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Age Slider
                        _buildSectionTitle("Âge", Icons.person_outline),
                        Slider(
                          value: provider.age.toDouble(),
                          min: 18,
                          max: 90,
                          divisions: 72,
                          activeColor: const Color(0xFFFF85A1),
                          inactiveColor: const Color(0xFFFFB7C5).withOpacity(0.3),
                          label: provider.age.toString(),
                          onChanged: (val) => provider.updateAge(val.toInt()),
                        ),
                        Text("${provider.age} ans", style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Divider(height: 40),

                        // Medical Conditions
                        _buildSectionTitle("Conditions Médicales", Icons.medical_services_outlined),
                        _buildSwitchTile("Diabète", provider.hasDiabetes, (v) => provider.toggleDiabetes(v)),
                        _buildSwitchTile("Hypertension", provider.hasHypertension, (v) => provider.toggleHypertension(v)),
                        _buildSwitchTile("Maladie Rénale", provider.hasKidneyDisease, (v) => provider.toggleKidneyDisease(v)),
                        _buildSwitchTile("Enceinte ?", provider.isPregnant, (v) => provider.togglePregnancy(v)),
                        const Divider(height: 40),

                        // Medications
                        _buildSectionTitle("Médicaments", Icons.medication_outlined),
                        const Text("Combien de médicaments prenez-vous par jour ?"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => provider.updateMedicationsCount(provider.medicationsCount > 0 ? provider.medicationsCount - 1 : 0),
                            ),
                            Text(
                              "${provider.medicationsCount}",
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => provider.updateMedicationsCount(provider.medicationsCount + 1),
                            ),
                          ],
                        ),
                        _buildSwitchTile("Anticoagulants ?", provider.usesAnticoagulants, (v) => provider.toggleAnticoagulants(v)),
                        const Divider(height: 40),

                        // Goal
                        _buildSectionTitle("Objectif du Remède", Icons.star_border),
                        Wrap(
                          spacing: 10,
                          children: [
                            _buildGoalChip("Énergie", "Energy", provider),
                            _buildGoalChip("Sommeil", "Sleep", provider),
                            _buildGoalChip("Digestion", "Digestion", provider),
                            _buildGoalChip("Immunité", "Immunity", provider),
                            _buildGoalChip("Douleur", "Pain", provider),
                            _buildGoalChip("Stress", "Stress", provider),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Next Button
                        ElevatedButton(
                          onPressed: () {
                            context.push('/plant-selector');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF85A1),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 5,
                          ),
                          child: const Text("Continuer vers les Plantes 🌿", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF85A1)),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41)),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      activeThumbColor: const Color(0xFFFF85A1),
      onChanged: onChanged,
    );
  }

  Widget _buildGoalChip(String label, String value, PhytoLabProvider provider) {
    bool isSelected = provider.currentGoal == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) provider.updateGoal(value);
      },
      selectedColor: const Color(0xFFFF85A1),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
    );
  }
}
