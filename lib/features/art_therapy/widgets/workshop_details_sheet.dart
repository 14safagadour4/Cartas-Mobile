import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:cartas/features/art_therapy/providers/art_therapy_provider.dart';

class WorkshopDetailsSheet extends StatefulWidget {
  final int id;
  final String title;
  final String description;
  final String instructor;
  final String rating;
  final String date;
  final String time;
  final String places;
  final String price;
  final bool isOnline;
  final String imagePath;

  const WorkshopDetailsSheet({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.rating,
    required this.date,
    required this.time,
    required this.places,
    required this.price,
    required this.isOnline,
    required this.imagePath,
  });

  @override
  State<WorkshopDetailsSheet> createState() => _WorkshopDetailsSheetState();
}

class _WorkshopDetailsSheetState extends State<WorkshopDetailsSheet> {
  bool _isBooking = false;

  Future<void> _handleBooking(BuildContext context) async {
    setState(() => _isBooking = true);
    
    final provider = Provider.of<ArtTherapyProvider>(context, listen: false);
    
    // Simulate user email (in real app, get from AuthProvider)
    final success = await provider.bookWorkshop(widget.id, "user@example.com");

    if (mounted) {
      setState(() => _isBooking = false);
      
      if (success) {
        Navigator.pop(context);
        _showSuccessDialog(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${provider.error}')),
        );
      }
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.sageTendre.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.sage, size: 60),
            ),
            const SizedBox(height: 24),
            Text(
              'Réservation Confirmée !',
              style: AppTextStyles.title(18, AppColors.roseDeep, weight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              'Votre place pour "${widget.title}" est bien réservée. Un email de confirmation vous a été envoyé.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body(13, AppColors.textDim),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.roseDeep,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Génial !', style: AppTextStyles.body(13, Colors.white, weight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.petalCream,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: AppTextStyles.title(18, AppColors.roseDeep, weight: FontWeight.w800),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Instructor Info
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      widget.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        color: AppColors.roseVif,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.instructor,
                        style: AppTextStyles.title(14, AppColors.roseDeep, weight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Art-thérapeute certifiée',
                        style: AppTextStyles.body(11, AppColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.gold, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            widget.rating.contains('avis') ? widget.rating : '${widget.rating} avis',
                            style: AppTextStyles.body(11, AppColors.textMuted, weight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              widget.description,
              style: AppTextStyles.body(13, AppColors.textDim),
            ),
            const SizedBox(height: 20),

            // Details Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white),
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.calendar_today_outlined, '${widget.date} - ${widget.time}'),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    widget.isOnline ? Icons.videocam_outlined : Icons.location_on_outlined,
                    widget.isOnline ? 'Visioconférence (lien envoyé par email)' : 'En centre de thérapie (Sur place)',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.group_outlined, widget.places.contains('disponibles') ? widget.places : '${widget.places} disponibles'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              widget.price,
              style: AppTextStyles.title(22, AppColors.roseDeep, weight: FontWeight.w800),
            ),
            const SizedBox(height: 16),

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isBooking ? null : () => _handleBooking(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.roseDeep,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isBooking 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Réserver en ligne',
                          style: AppTextStyles.body(14, Colors.white, weight: FontWeight.w700),
                        ),
                      ],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body(13, AppColors.textDim),
          ),
        ),
      ],
    );
  }
}
