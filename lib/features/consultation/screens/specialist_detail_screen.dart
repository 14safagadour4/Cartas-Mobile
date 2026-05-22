import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/specialist_public_model.dart';

class SpecialistDetailScreen extends StatelessWidget {
  final SpecialistPublicModel specialist;
  const SpecialistDetailScreen({super.key, required this.specialist});

  double get _mockRating => 4.5 + (specialist.id % 5) * 0.08;
  int get _mockReviews => 50 + (specialist.id * 17) % 150;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.petalCream,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildBody(context)),
        ],
      ),
      bottomNavigationBar: _buildBookButton(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      backgroundColor: AppColors.roseDeep,
      pinned: true,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.roseDeep, AppColors.rose],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white24,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: specialist.avatarUrl != null
                    ? ClipOval(child: Image.network(specialist.avatarUrl!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildInitials()))
                    : _buildInitials(),
              ),
              const SizedBox(height: 10),
              Text(specialist.fullName,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              if (specialist.specialty != null)
                Text(specialist.specialty!,
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(specialist.initials,
          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats rapides
          _buildStatsRow(),
          const SizedBox(height: 24),
          // Bio
          if (specialist.bio != null && specialist.bio!.isNotEmpty) ...[
            Text('À propos', style: AppTextStyles.title(16, AppColors.roseDeep)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
              ),
              child: Text(specialist.bio!,
                  style: AppTextStyles.body(13, AppColors.textPrimary), maxLines: 6, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 20),
          ],
          // Disponibilités simulées
          Text('Prochaines disponibilités', style: AppTextStyles.title(16, AppColors.roseDeep)),
          const SizedBox(height: 12),
          _buildAvailabilitySlots(context),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard('⭐', _mockRating.toStringAsFixed(1), 'Note', AppColors.goldPale),
        const SizedBox(width: 10),
        _buildStatCard('💬', '$_mockReviews', 'Avis', AppColors.rosePale),
        const SizedBox(width: 10),
        _buildStatCard('💰', '${specialist.rate.toStringAsFixed(0)} DT', 'Tarif', const Color(0xFFE8F5E9)),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(value, style: AppTextStyles.body(13, AppColors.roseDeep, weight: FontWeight.w700)),
            Text(label, style: AppTextStyles.body(11, AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilitySlots(BuildContext context) {
    // Créneaux simulés (seront remplacés par de vraies disponibilités)
    final slots = [
      'Aujourd\'hui, 14h00',
      'Aujourd\'hui, 16h30',
      'Demain, 10h00',
      'Demain, 15h00',
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: slots.map((slot) => GestureDetector(
        onTap: () => context.push('/booking', extra: {'specialist': specialist, 'slot': slot}),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.rose.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time, size: 14, color: AppColors.rose),
              const SizedBox(width: 6),
              Text(slot, style: AppTextStyles.body(12, AppColors.roseDeep, weight: FontWeight.w600)),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildBookButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      color: AppColors.petalCream,
      child: ElevatedButton(
        onPressed: () => context.push('/booking', extra: {'specialist': specialist, 'slot': null}),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.roseDeep,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today_outlined, size: 18),
            const SizedBox(width: 10),
            Text('Prendre rendez-vous',
                style: AppTextStyles.body(15, Colors.white, weight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
