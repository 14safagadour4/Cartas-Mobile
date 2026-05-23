import 'package:flutter/material.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import '../widgets/art_therapy_drawer.dart';
import '../services/art_therapy_service.dart';
import '../models/art_therapy_models.dart';

class ReviewsListArtTherapist extends StatefulWidget {
  const ReviewsListArtTherapist({super.key});

  @override
  State<ReviewsListArtTherapist> createState() => _ReviewsListArtTherapistState();
}

class _ReviewsListArtTherapistState extends State<ReviewsListArtTherapist> {
  final ArtTherapyService _service = ArtTherapyService();
  List<Review> _reviews = [];
  bool _isLoading = true;
  final Color bordeaux = const Color(0xFF6B3340);
  final Color textDeep = const Color(0xFF4D2C34);
  final Color bgColor = const Color(0xFFFDFBF7);
  String _selectedFilter = 'Tous';

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final list = await _service.getReviews();
      if (mounted) {
        setState(() {
          _reviews = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
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
              'Avis reçus',
              style: AppTextStyles.display(18, bordeaux, weight: FontWeight.w700),
            ),
          ],
        ),
      ),
      drawer: const ArtTherapyDrawer(),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: bordeaux))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRatingSummary(),
                const SizedBox(height: 24),
                _buildFilters(),
                const SizedBox(height: 20),
                ..._reviews
                    .where((r) => _selectedFilter == 'Tous' || r.workshopTitle == _selectedFilter)
                    .map((r) => _buildReviewCard(r)),
              ],
            ),
          ),
    );
  }

  Widget _buildRatingSummary() {
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
      child: Row(
        children: [
          Column(
            children: [
              Text('4.8', style: AppTextStyles.display(32, bordeaux, weight: FontWeight.w800)),
              Row(
                children: List.generate(5, (index) => Icon(
                  index < 4 ? Icons.star : Icons.star_half,
                  color: const Color(0xFFC8AD7F),
                  size: 16,
                )),
              ),
              const SizedBox(height: 4),
              Text('4 avis', style: AppTextStyles.body(12, textDeep.withOpacity(0.4))),
            ],
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              children: [
                _buildRatingBar(5, 0.8, '3'),
                _buildRatingBar(4, 0.4, '1'),
                _buildRatingBar(3, 0.0, '0'),
                _buildRatingBar(2, 0.0, '0'),
                _buildRatingBar(1, 0.0, '0'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int star, double percent, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$star', style: AppTextStyles.body(12, textDeep.withOpacity(0.5))),
          const SizedBox(width: 8),
          Icon(Icons.star, size: 12, color: const Color(0xFFC8AD7F).withOpacity(0.5)),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: const Color(0xFFF2ECEE),
                color: const Color(0xFFC8AD7F),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(count, style: AppTextStyles.body(11, textDeep.withOpacity(0.4))),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('Tous'),
          _buildFilterChip('Mandala & Méditation'),
          _buildFilterChip('Aquarelle Botanique'),
          _buildFilterChip('Atelier Argile & Plantes'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? bordeaux : const Color(0xFFEFE6E8),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(13, isSelected ? Colors.white : bordeaux, weight: isSelected ? FontWeight.w700 : FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
          Row(
            children: [
              CircleAvatar(
                backgroundColor: bordeaux.withOpacity(0.1),
                radius: 20,
                child: Text(r.userInitial, style: AppTextStyles.body(14, bordeaux, weight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.userName, style: AppTextStyles.body(15, textDeep, weight: FontWeight.w700)),
                    Text('${r.workshopTitle} • ${r.date}', style: AppTextStyles.body(11, textDeep.withOpacity(0.4))),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) => Icon(
                  Icons.star,
                  color: index < r.rating ? const Color(0xFFC8AD7F) : Colors.grey[200],
                  size: 14,
                )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            r.comment,
            style: AppTextStyles.body(13, textDeep.withOpacity(0.7)),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF2ECEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 14, color: textDeep.withOpacity(0.6)),
                  const SizedBox(width: 8),
                  Text('Répondre', style: AppTextStyles.body(12, textDeep.withOpacity(0.6), weight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
