import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cartas/features/consultation/providers/consultation_provider.dart';
import 'package:cartas/features/phyto_lab/providers/phyto_lab_provider.dart';

class SpecialistPickerScreen extends StatefulWidget {
  const SpecialistPickerScreen({super.key});

  @override
  State<SpecialistPickerScreen> createState() => _SpecialistPickerScreenState();
}

class _SpecialistPickerScreenState extends State<SpecialistPickerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ConsultationProvider>(context, listen: false).fetchSpecialists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final consultProvider = Provider.of<ConsultationProvider>(context);
    final phytoProvider = Provider.of<PhytoLabProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFDE4E4),
      appBar: AppBar(
        title: const Text('Choisir un Spécialiste', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: consultProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF85A1)))
          : consultProvider.specialists.isEmpty
              ? const Center(child: Text("Aucun spécialiste disponible pour le moment."))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: consultProvider.specialists.length,
                  itemBuilder: (context, index) {
                    final spec = consultProvider.specialists[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(spec.avatarUrl ?? 'https://via.placeholder.com/150'),
                        ),
                        title: Text(spec.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Text(spec.specialty ?? "Phytothérapeute", style: const TextStyle(color: Colors.grey)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFFF85A1)),
                        onTap: phytoProvider.isLoading 
                          ? null 
                          : () async {
                              bool success = await phytoProvider.saveAnalysisAsRemedy(spec.id);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Remède envoyé à ${spec.fullName} ! ✅"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                context.go('/home');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Erreur lors de l'envoi."),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      ),
                    );
                  },
                ),
    );
  }
}
