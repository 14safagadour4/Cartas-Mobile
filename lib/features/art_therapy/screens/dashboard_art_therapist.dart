import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import '../widgets/art_therapy_drawer.dart';
import '../services/art_therapy_service.dart';
import '../models/art_therapy_models.dart';
import 'package:intl/intl.dart';

class DashboardArtTherapist extends StatefulWidget {
  const DashboardArtTherapist({super.key});

  @override
  State<DashboardArtTherapist> createState() => _DashboardArtTherapistState();
}

class _DashboardArtTherapistState extends State<DashboardArtTherapist> {
  final ArtTherapyService _service = ArtTherapyService();
  ArtTherapist? _profile;
  Map<String, dynamic> _stats = {};
  List<Workshop> _workshops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait<dynamic>([
        _service.getProfile(),
        _service.getDashboardStats(),
        _service.getMyWorkshops(),
      ]);

      if (mounted) {
        setState(() {
          _profile = results[0] as ArtTherapist?;
          _stats = results[1] as Map<String, dynamic>;
          _workshops = results[2] as List<Workshop>;
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
    const Color bordeaux = Color(0xFF6B3340);
    const Color textDeep = Color(0xFF4D2C34);
    const Color bgColor = Color(0xFFFDFBF7);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator(color: bordeaux)),
      );
    }

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
              'Tableau de bord',
              style: AppTextStyles.display(18, bordeaux, weight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFEFE6E8),
              backgroundImage: _profile?.avatarUrl != null ? NetworkImage(_profile!.avatarUrl!) : null,
              child: _profile?.avatarUrl == null
                  ? Text(
                      '${_profile?.firstName.isNotEmpty == true ? _profile!.firstName[0] : ''}${_profile?.lastName.isNotEmpty == true ? _profile!.lastName[0] : ''}',
                      style: AppTextStyles.body(14, bordeaux, weight: FontWeight.w700),
                    )
                  : null,
            ),
          ),
        ],
      ),
      drawer: const ArtTherapyDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: bordeaux,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Row(
                children: [
                  Text(
                    'Bonjour ${_profile?.firstName ?? ''}',
                    style: AppTextStyles.display(28, bordeaux, weight: FontWeight.w800),
                  ),
                  const SizedBox(width: 10),
                  const Text('🌸', style: TextStyle(fontSize: 24)),
                ],
              ),
              Text(
                'Voici un aperçu de votre activité',
                style: AppTextStyles.body(14, textDeep.withOpacity(0.6)),
              ),
              const SizedBox(height: 25),
    
              // Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  _buildStatCard(
                    '${_stats['activeWorkshops'] ?? 0}',
                    'Ateliers actifs',
                    Icons.palette_outlined,
                    const Color(0xFFF5E8EA),
                    const Color(0xFF6B3340),
                  ),
                  _buildStatCard(
                    '${_stats['totalParticipants'] ?? 0}',
                    'Participants',
                    Icons.people_outline,
                    const Color(0xFFF2F9F4),
                    const Color(0xFF336B4D),
                  ),
                  _buildStatCard(
                    '${_stats['averageRating'] ?? 0.0}',
                    'Note moyenne',
                    Icons.star_outline,
                    const Color(0xFFFDF7E6),
                    const Color(0xFFB5932F),
                  ),
                  _buildStatCard(
                    '${_stats['growth'] ?? '0%'}',
                    'Ce mois',
                    Icons.trending_up,
                    const Color(0xFFF2EFF9),
                    const Color(0xFF4D336B),
                  ),
                ],
              ),
              const SizedBox(height: 25),
    
              // Create Workshop Action
              Container(
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
                child: InkWell(
                  onTap: () {
                    context.pushNamed('art-therapy-workshops');
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: bordeaux,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Créer un workshop',
                              style: AppTextStyles.display(18, bordeaux, weight: FontWeight.w700),
                            ),
                            Text(
                              'Lancez une nouvelle séance d\'art-thérapie',
                              style: AppTextStyles.body(12, textDeep.withOpacity(0.5)),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: bordeaux.withOpacity(0.3), size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
    
              // Upcoming Workshops
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Prochains ateliers',
                    style: AppTextStyles.display(20, bordeaux, weight: FontWeight.w800),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to full list
                    },
                    child: Text(
                      'Voir tout',
                      style: AppTextStyles.body(14, bordeaux, weight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              if (_workshops.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Aucun atelier prévu pour le moment.',
                      style: AppTextStyles.body(14, textDeep.withOpacity(0.4)),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _workshops.length > 3 ? 3 : _workshops.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final w = _workshops[index];
                    return _buildWorkshopItem(
                      w.title,
                      '${DateFormat('yyyy-MM-dd').format(w.date)} · ${DateFormat('HH:mm').format(w.date)}',
                      '${w.price.toInt()} DT',
                      '${w.currentParticipants}/${w.maxParticipants}',
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B3340).withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.display(24, const Color(0xFF4D2C34), weight: FontWeight.w800),
              ),
              Text(
                label,
                style: AppTextStyles.body(11, const Color(0xFF4D2C34).withOpacity(0.5), weight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkshopItem(String title, String subtitle, String price, String filling) {
    const Color bordeaux = Color(0xFF6B3340);
    const Color textDeep = Color(0xFF4D2C34);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: bordeaux.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF5E8EA),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.calendar_month_outlined, color: bordeaux, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.display(16, bordeaux, weight: FontWeight.w700),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.body(12, textDeep.withOpacity(0.5)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: AppTextStyles.display(16, bordeaux, weight: FontWeight.w800),
              ),
              Text(
                filling,
                style: AppTextStyles.body(11, textDeep.withOpacity(0.5), weight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
