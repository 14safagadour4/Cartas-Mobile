import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/specialist_public_model.dart';
import '../providers/consultation_provider.dart';

class ConsultationListScreen extends StatefulWidget {
  const ConsultationListScreen({super.key});

  @override
  State<ConsultationListScreen> createState() => _ConsultationListScreenState();
}

class _ConsultationListScreenState extends State<ConsultationListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedSpecialty = 'Tous';
  final List<String> _specialties = [
    'Tous',
    'Phytothérapie',
    'Naturopathie',
    'Herboristerie'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsultationProvider>().fetchSpecialists();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.petalCream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(child: _buildSpecialistList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06), blurRadius: 8)
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 16, color: AppColors.roseDeep),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Consultation',
                  style: AppTextStyles.title(22, AppColors.roseDeep)),
              Text('Trouvez votre spécialiste',
                  style: AppTextStyles.body(12, AppColors.textMuted)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.push('/my-consultations'),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.rosePale,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_month_outlined,
                  size: 18, color: AppColors.roseDeep),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)
          ],
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Rechercher un spécialiste...',
            hintStyle: AppTextStyles.body(13, AppColors.textDim),
            border: InputBorder.none,
            icon: const Icon(Icons.search, color: AppColors.textDim, size: 20),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear,
                        size: 16, color: AppColors.textDim),
                    onPressed: () => setState(() => _searchCtrl.clear()),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
        scrollDirection: Axis.horizontal,
        itemCount: _specialties.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final s = _specialties[i];
          final isActive = s == _selectedSpecialty;
          return GestureDetector(
            onTap: () => setState(() => _selectedSpecialty = s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              decoration: BoxDecoration(
                color: isActive ? AppColors.roseDeep : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? AppColors.roseDeep
                      : AppColors.textDim.withOpacity(0.15),
                ),
              ),
              child: Text(
                s,
                style: AppTextStyles.body(
                    12, isActive ? Colors.white : AppColors.textMuted,
                    weight: FontWeight.w600),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpecialistList() {
    return Consumer<ConsultationProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.rose));
        }
        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_outlined,
                    size: 48, color: AppColors.textDim),
                const SizedBox(height: 12),
                Text('Connexion impossible',
                    style: AppTextStyles.body(14, AppColors.textMuted)),
                const SizedBox(height: 8),
                TextButton(
                    onPressed: () => provider.fetchSpecialists(),
                    child: Text('Réessayer',
                        style: AppTextStyles.body(13, AppColors.rose))),
              ],
            ),
          );
        }
        final list = provider.filtered(_selectedSpecialty, _searchCtrl.text);
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_search_outlined,
                    size: 56, color: AppColors.textDim),
                const SizedBox(height: 12),
                Text('Aucun spécialiste trouvé',
                    style: AppTextStyles.body(14, AppColors.textMuted)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _SpecialistCard(specialist: list[i]),
        );
      },
    );
  }
}

class _SpecialistCard extends StatelessWidget {
  final SpecialistPublicModel specialist;
  const _SpecialistCard({required this.specialist});

  // Rating fictif basé sur l'ID (sera remplacé par une vraie notation)
  double get _mockRating => 4.5 + (specialist.id % 5) * 0.08;
  int get _mockReviews => 50 + (specialist.id * 17) % 150;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/specialist-detail', extra: specialist),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.rosePale, AppColors.rose.withOpacity(0.3)],
                ),
              ),
              child: specialist.avatarUrl != null
                  ? ClipOval(
                      child: Image.network(specialist.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildInitials()))
                  : _buildInitials(),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(specialist.fullName,
                            style: AppTextStyles.body(14, AppColors.roseDeep,
                                weight: FontWeight.w700)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Disponible',
                            style: AppTextStyles.body(
                                10, const Color(0xFF388E3C),
                                weight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (specialist.specialty != null)
                    Text(specialist.specialty!,
                        style: AppTextStyles.body(12, AppColors.rose,
                            weight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFB74D), size: 16),
                      const SizedBox(width: 3),
                      Text(_mockRating.toStringAsFixed(1),
                          style: AppTextStyles.body(12, AppColors.textPrimary,
                              weight: FontWeight.w600)),
                      Text(' ($_mockReviews)',
                          style: AppTextStyles.body(11, AppColors.textMuted)),
                      const Spacer(),
                      Text('${specialist.rate.toStringAsFixed(0)} DT',
                          style: AppTextStyles.body(14, AppColors.roseDeep,
                              weight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(specialist.initials,
          style: AppTextStyles.title(20, AppColors.roseDeep)),
    );
  }
}
