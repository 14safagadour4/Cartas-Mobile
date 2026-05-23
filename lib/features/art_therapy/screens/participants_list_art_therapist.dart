import 'package:flutter/material.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import '../widgets/art_therapy_drawer.dart';
import '../services/art_therapy_service.dart';
import '../models/art_therapy_models.dart';
import 'package:intl/intl.dart';

class ParticipantsListArtTherapist extends StatefulWidget {
  const ParticipantsListArtTherapist({super.key});

  @override
  State<ParticipantsListArtTherapist> createState() => _ParticipantsListArtTherapistState();
}

class _ParticipantsListArtTherapistState extends State<ParticipantsListArtTherapist> {
  final ArtTherapyService _service = ArtTherapyService();
  List<WorkshopRegistration> _registrations = [];
  bool _isLoading = true;
  final Color bordeaux = const Color(0xFF6B3340);
  final Color textDeep = const Color(0xFF4D2C34);
  final Color bgColor = const Color(0xFFFDFBF7);

  @override
  void initState() {
    super.initState();
    _loadRegistrations();
  }

  Future<void> _loadRegistrations() async {
    try {
      final list = await _service.getRegistrations();
      if (mounted) {
        setState(() {
          _registrations = list;
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
              'Participants',
              style: AppTextStyles.display(18, bordeaux, weight: FontWeight.w700),
            ),
          ],
        ),
      ),
      drawer: const ArtTherapyDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: bordeaux.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Rechercher une participante...',
                  hintStyle: AppTextStyles.body(14, textDeep.withOpacity(0.3)),
                  icon: Icon(Icons.search, color: textDeep.withOpacity(0.4)),
                ),
              ),
            ),
          ),

          // Filters Horizontal List
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                _buildFilterChip('Tous les ateliers', isActive: true),
                const SizedBox(width: 10),
                ...(_registrations.map((r) => r.workshop.title).toSet().map((title) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _buildFilterChip(title),
                ))),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              '${_registrations.length} participantes trouvées',
              style: AppTextStyles.body(13, textDeep.withOpacity(0.5), weight: FontWeight.w600),
            ),
          ),

          // Participants List
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: bordeaux))
              : RefreshIndicator(
                  onRefresh: _loadRegistrations,
                  color: bordeaux,
                  child: _registrations.isEmpty 
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _registrations.length,
                        itemBuilder: (context, index) {
                          final r = _registrations[index];
                          return _buildParticipantCard(
                            '${r.user.firstName} ${r.user.lastName}',
                            r.workshop.title,
                            'Inscrite le ${DateFormat('dd/MM/yyyy').format(r.registeredAt)}',
                            r.status == 'PAID' ? 'Payé' : 'En attente',
                          );
                        },
                      ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 48, color: bordeaux.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            'Aucune participante pour le moment',
            style: AppTextStyles.body(14, textDeep.withOpacity(0.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? bordeaux : const Color(0xFFEFE6E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.body(13, isActive ? Colors.white : bordeaux, weight: FontWeight.w700),
      ),
    );
  }

  Widget _buildParticipantCard(String name, String workshop, String time, String status) {
    bool isPaid = status == 'Payé';
    Color statusColor = isPaid ? const Color(0xFF4ECCA3) : const Color(0xFFE8A45A);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: bordeaux.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEFE6E8),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? (name.substring(0, 1) + (name.contains(' ') ? name.split(' ').last.substring(0, 1) : '')) : '??',
                style: AppTextStyles.body(14, bordeaux, weight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: AppTextStyles.display(16, bordeaux, weight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isPaid ? Icons.check_circle_outline : Icons.help_outline, color: statusColor, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            status,
                            style: AppTextStyles.body(9, statusColor, weight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  workshop,
                  style: AppTextStyles.body(12, textDeep.withOpacity(0.5), weight: FontWeight.w500),
                ),
                Text(
                  time,
                  style: AppTextStyles.body(10, textDeep.withOpacity(0.3)),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildActionIcon(Icons.chat_bubble_outline),
              const SizedBox(width: 8),
              _buildActionIcon(Icons.mail_outline),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFF2ECEE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: bordeaux.withOpacity(0.6), size: 18),
    );
  }
}
