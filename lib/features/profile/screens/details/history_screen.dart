import 'package:flutter/material.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:cartas/core/services/profile_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final result = await ProfileService.getHistory();
    if (mounted) {
      setState(() {
        if (result['success']) {
          _history = result['data'];
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.petalCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Historique d\'Activités',
          style: AppTextStyles.title(20, AppColors.roseDeep),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.rose))
          : _history.isEmpty
              ? _buildEmptyState()
              : _buildHistoryTimeline(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: AppColors.rose.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Aucune activité enregistrée',
            style: AppTextStyles.body(16, AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTimeline() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        return _buildHistoryItem(item, index == _history.length - 1);
      },
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item, bool isLast) {
    final date = DateTime.parse(item['timestamp']);
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(date);
    
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.rose,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.rose.withOpacity(0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getActionTitle(item['action']),
                    style: AppTextStyles.body(14, AppColors.roseDeep, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['details'] ?? '',
                    style: AppTextStyles.body(12, AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedDate,
                    style: AppTextStyles.body(10, AppColors.rose.withOpacity(0.6), weight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getActionTitle(String action) {
    switch (action) {
      case 'PLANT_SCANNED': return 'Plante identifiée 🌿';
      case 'QUIZ_COMPLETED': return 'Quiz terminé 🏆';
      case 'RECIPE_SAVED': return 'Recette enregistrée 📖';
      case 'LEVEL_UP': return 'Niveau supérieur ! ✨';
      default: return 'Activité effectuée';
    }
  }
}
