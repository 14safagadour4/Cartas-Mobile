import 'package:flutter/material.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import '../widgets/art_therapy_drawer.dart';
import '../services/art_therapy_service.dart';
import '../models/art_therapy_models.dart';
import 'package:intl/intl.dart';

class WorkshopsListArtTherapist extends StatefulWidget {
  const WorkshopsListArtTherapist({super.key});

  @override
  State<WorkshopsListArtTherapist> createState() => _WorkshopsListArtTherapistState();
}

class _WorkshopsListArtTherapistState extends State<WorkshopsListArtTherapist> with SingleTickerProviderStateMixin {
  final ArtTherapyService _service = ArtTherapyService();
  late TabController _tabController;
  List<Workshop> _workshops = [];
  bool _isLoading = true;
  final Color bordeaux = const Color(0xFF6B3340);
  final Color textDeep = const Color(0xFF4D2C34);
  final Color bgColor = const Color(0xFFFDFBF7);
  
  // Controllers for creation
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _maxPartCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedFormat = 'En ligne';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadWorkshops();
  }

  Future<void> _loadWorkshops() async {
    try {
      setState(() => _isLoading = true);
      final list = await _service.getMyWorkshops();
      
      if (mounted) {
        setState(() {
          _workshops = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: bordeaux.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.menu, color: bordeaux, size: 20),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Espace Art-thérapeute',
              style: AppTextStyles.body(12, textDeep.withOpacity(0.5)),
            ),
            Text(
              'Mes Workshops',
              style: AppTextStyles.display(18, bordeaux, weight: FontWeight.w700),
            ),
          ],
        ),
      ),
      drawer: const ArtTherapyDrawer(),
      body: Column(
        children: [
          // Filter Tabs & Create Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFE6E8),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: bordeaux,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: bordeaux.withOpacity(0.6),
                      labelStyle: AppTextStyles.body(13, Colors.white, weight: FontWeight.w700),
                      tabs: const [
                        Tab(text: 'Tous'),
                        Tab(text: 'Publiés'),
                        Tab(text: 'Terminés'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _showCreateWorkshopDialog,
                  child: Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: bordeaux,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Row(
                        children: [
                          const Icon(Icons.add, color: Colors.white, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            'Créer',
                            style: AppTextStyles.body(14, Colors.white, weight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Workshops List
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: bordeaux))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildListView(_workshops),
                    _buildListView(_workshops.where((w) => w.status == 'UPCOMING').toList()),
                    _buildListView(_workshops.where((w) => w.status == 'COMPLETED').toList()),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Workshop> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.palette_outlined, size: 48, color: bordeaux.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text(
              'Aucun atelier trouvé',
              style: AppTextStyles.body(14, textDeep.withOpacity(0.4)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWorkshops,
      color: bordeaux,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final w = list[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildWorkshopCard(
              title: w.title,
              status: w.status == 'UPCOMING' ? 'Publié' : w.status,
              statusColor: w.status == 'UPCOMING' ? const Color(0xFF4ECCA3) : bordeaux,
              description: w.description ?? 'Pas de description.',
              date: DateFormat('yyyy-MM-dd').format(w.date),
              time: DateFormat('HH:mm').format(w.date),
              type: w.format == 'ONLINE' ? 'Session active' : (w.location ?? 'Sur place'),
              typeIcon: w.format == 'ONLINE' ? Icons.videocam_outlined : Icons.location_on_outlined,
              participants: '${w.currentParticipants}/${w.maxParticipants} inscrits',
              price: '${w.price.toInt()} DT',
              filling: w.maxParticipants > 0 
                  ? '${((w.currentParticipants / w.maxParticipants) * 100).toInt()}%'
                  : '0%',
              onEdit: () => _editWorkshop(w),
              onDelete: () => _confirmDelete(w),
            ),
          );
        },
      ),
    );
  }

  void _editWorkshop(Workshop workshop) {
    // On ouvre une boîte de dialogue avec les infos pré-remplies
    showDialog(
      context: context,
      builder: (context) => _buildEditDialog(workshop),
    );
  }

  Widget _buildEditDialog(Workshop workshop) {
    final titleController = TextEditingController(text: workshop.title);
    final priceController = TextEditingController(text: workshop.price.toString());
    final descController = TextEditingController(text: workshop.description);
    String selectedFormat = workshop.format;

    return AlertDialog(
      title: Text('Modifier : ${workshop.title}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Titre')),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Prix (DT)'), keyboardType: TextInputType.number),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
            DropdownButtonFormField<String>(
              initialValue: selectedFormat,
              items: const [
                DropdownMenuItem(value: 'ONLINE', child: Text('En ligne')),
                DropdownMenuItem(value: 'PRESENTIAL', child: Text('Présentiel')),
              ],
              onChanged: (val) => selectedFormat = val!,
              decoration: const InputDecoration(labelText: 'Format'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () async {
            final updatedData = {
              'title': titleController.text,
              'price': double.tryParse(priceController.text) ?? workshop.price,
              'description': descController.text,
              'format': selectedFormat,
              'date': workshop.date.toIso8601String(), // On garde la même date pour simplifier
            };
            
            Navigator.pop(context);
            final success = await _service.updateWorkshop(workshop.id, updatedData);
            if (success) {
              _loadWorkshops();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Workshop mis à jour !')));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur de mise à jour')));
            }
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }

  void _confirmDelete(Workshop workshop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'atelier ?'),
        content: Text('Voulez-vous vraiment supprimer "${workshop.title}" ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _service.deleteWorkshop(workshop.id);
              if (success) {
                _loadWorkshops(); // Recharger la liste
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Atelier supprimé avec succès')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erreur lors de la suppression')),
                );
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkshopCard({
    required String title,
    required String status,
    required Color statusColor,
    required String description,
    required String date,
    required String time,
    required String type,
    required IconData typeIcon,
    required String participants,
    required String price,
    required String filling,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: bordeaux.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.display(18, bordeaux, weight: FontWeight.w800),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: AppTextStyles.body(10, statusColor, weight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
               Row(
                children: [
                  _buildIconButton(Icons.edit_outlined, const Color(0xFFE5D8DA), bordeaux, onEdit),
                  const SizedBox(width: 8),
                  _buildIconButton(Icons.delete_outline, const Color(0xFFFBE8E8), Colors.redAccent, onDelete),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: AppTextStyles.body(13, textDeep.withOpacity(0.6)),
          ),
          const SizedBox(height: 16),
          
          // Details Grid
          Row(
            children: [
              _buildDetailItem(Icons.calendar_month_outlined, date),
              const SizedBox(width: 20),
              _buildDetailItem(Icons.access_time, time),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildDetailItem(typeIcon, type),
              const SizedBox(width: 20),
              _buildDetailItem(Icons.people_outline, participants),
            ],
          ),
          
          const Divider(height: 32, color: Color(0xFFF2ECEE)),
          
          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: AppTextStyles.display(20, bordeaux, weight: FontWeight.w800),
              ),
              Text(
                'Remplissage : $filling',
                style: AppTextStyles.body(12, textDeep.withOpacity(0.5), weight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color bg, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: bordeaux.withOpacity(0.4), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body(12, textDeep.withOpacity(0.7), weight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateWorkshopDialog() {
    showDialog(
      context: context,
      barrierColor: bordeaux.withOpacity(0.4),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nouveau Workshop',
                        style: AppTextStyles.display(20, bordeaux, weight: FontWeight.w800),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(backgroundColor: Colors.grey[100]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Titre de l\'atelier'),
                  _buildInput(_titleCtrl, 'Ex: Mandala & Méditation'),
                  const SizedBox(height: 16),
                  _buildLabel('Description'),
                  _buildInput(_descCtrl, 'Décrivez le contenu...', maxLines: 3),
                  const SizedBox(height: 16),
                  _buildLabel('Format'),
                  Row(
                    children: [
                      _buildFormatBtn('En ligne', Icons.videocam_outlined, setModalState),
                      const SizedBox(width: 12),
                      _buildFormatBtn('Sur place', Icons.location_on_outlined, setModalState),
                    ],
                  ),
                  if (_selectedFormat == 'Sur place') ...[
                    const SizedBox(height: 16),
                    _buildLabel('Lieu'),
                    _buildInput(_locationCtrl, 'Ex: Centre Rachma, La Marsa'),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Date'),
                            _buildDatePicker(setModalState),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Horaire'),
                            _buildInput(TextEditingController(text: '14:00 - 16:00'), '14:00 - 16:00'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Prix (DT)'),
                            _buildInput(_priceCtrl, '45', keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Participants max'),
                            _buildInput(_maxPartCtrl, '12', keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _submitWorkshop,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC8AD7F),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Publier le Workshop',
                        style: AppTextStyles.body(16, Colors.white, weight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: AppTextStyles.body(13, textDeep, weight: FontWeight.w600)),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String hint, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body(14, textDeep.withOpacity(0.3)),
        filled: true,
        fillColor: const Color(0xFFF8F5F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: textDeep.withOpacity(0.05)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: textDeep.withOpacity(0.05)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildFormatBtn(String label, IconData icon, StateSetter setModalState) {
    bool isSelected = _selectedFormat == label;
    return Expanded(
      child: InkWell(
        onTap: () => setModalState(() => _selectedFormat = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? bordeaux.withOpacity(0.05) : const Color(0xFFF8F5F2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isSelected ? bordeaux : Colors.transparent, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? bordeaux : textDeep.withOpacity(0.4)),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.body(13, isSelected ? bordeaux : textDeep.withOpacity(0.5), weight: isSelected ? FontWeight.w700 : FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(StateSetter setModalState) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setModalState(() => _selectedDate = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F5F2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: AppTextStyles.body(14, textDeep)),
            Icon(Icons.calendar_today_outlined, size: 16, color: textDeep.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }

  Future<void> _submitWorkshop() async {
    if (_titleCtrl.text.isEmpty || _priceCtrl.text.isEmpty) return;

    final newWorkshop = Workshop(
      id: 0,
      title: _titleCtrl.text,
      description: _descCtrl.text,
      date: _selectedDate,
      price: double.tryParse(_priceCtrl.text) ?? 0.0,
      maxParticipants: int.tryParse(_maxPartCtrl.text) ?? 10,
      currentParticipants: 0,
      status: 'UPCOMING',
      format: _selectedFormat == 'En ligne' ? 'ONLINE' : 'ON_SITE',
      location: _selectedFormat == 'Sur place' ? _locationCtrl.text : null,
    );

    // Prepare data map for service
    final data = {
      'title': newWorkshop.title,
      'description': newWorkshop.description,
      'date': newWorkshop.date.toIso8601String(),
      'price': newWorkshop.price,
      'maxParticipants': newWorkshop.maxParticipants,
      'currentParticipants': 0,
      'status': 'UPCOMING',
      'format': _selectedFormat == 'En ligne' ? 'ONLINE' : 'ON_SITE',
      'location': _selectedFormat == 'Sur place' ? _locationCtrl.text : null,
    };

    final success = await _service.createWorkshopFromMap(data);
    if (success) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Workshop créé !')));
        
        // Add to local list so it appears in UI during demo
        setState(() {
          _workshops.insert(0, newWorkshop);
        });
        // _loadWorkshops(); // commented out so mock doesn't overwrite our new item

        _titleCtrl.clear();
        _descCtrl.clear();
        _priceCtrl.clear();
        _maxPartCtrl.clear();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors de la publication')));
      }
    }
  }
}
