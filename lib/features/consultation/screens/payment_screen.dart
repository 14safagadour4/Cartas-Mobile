import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/consultation_model.dart';
import '../providers/consultation_provider.dart';

class PaymentScreen extends StatefulWidget {
  final ConsultationModel consultation;
  const PaymentScreen({super.key, required this.consultation});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;
  String? _errorMessage;

  Future<void> _handleStripePayment() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final provider = context.read<ConsultationProvider>();

      // 1. Créer le PaymentIntent côté backend
      final intentData = await provider.createPaymentIntent(widget.consultation.id);
      
      if (intentData == null) {
        setState(() {
          _isProcessing = false;
          _errorMessage = provider.error ?? 'Erreur lors de la création du paiement.';
        });
        return;
      }

      final clientSecret = intentData['clientSecret'] as String;

      // 2. Initialiser le Stripe Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'CARTAS Phytothérapie',
          style: ThemeMode.light,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: AppColors.roseDeep,
            ),
            shapes: PaymentSheetShape(
              borderRadius: 16,
            ),
          ),
        ),
      );

      // 3. Afficher le Payment Sheet natif Stripe
      await Stripe.instance.presentPaymentSheet();

      // 4. Si on arrive ici, le paiement a réussi côté Stripe
      // Confirmer côté backend
      final success = await provider.confirmPayment(widget.consultation.id);
      
      setState(() => _isProcessing = false);

      if (success && mounted) {
        _showSuccessDialog();
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Le paiement Stripe a réussi mais la confirmation serveur a échoué.';
        });
      }

    } on StripeException catch (e) {
      setState(() {
        _isProcessing = false;
        if (e.error.code == FailureCode.Canceled) {
          _errorMessage = null; // L'utilisateur a annulé, pas d'erreur
        } else {
          _errorMessage = e.error.localizedMessage ?? 'Erreur de paiement Stripe.';
        }
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Erreur inattendue : $e';
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.1),
              ),
              child: const Icon(Icons.check_circle_outline, size: 60, color: Colors.green),
            ),
            const SizedBox(height: 20),
            Text('Paiement Réussi !', style: AppTextStyles.title(20, AppColors.roseDeep)),
            const SizedBox(height: 12),
            Text(
              'Votre consultation est désormais confirmée.\nVous pouvez accéder au lien vidéo dans vos rendez-vous.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body(13, AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.consultation.specialist?.rate.toStringAsFixed(3) ?? "0"} DT débité',
                style: AppTextStyles.body(14, Colors.green, weight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.pop(); // fermer dialog
                  context.pop(); // revenir à la liste
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.roseDeep,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Retour à mes rendez-vous', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rate = widget.consultation.specialist?.rate ?? 0;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.roseDeep),
          onPressed: () => context.pop(),
        ),
        title: Text('Paiement Sécurisé', style: AppTextStyles.title(18, AppColors.roseDeep)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge Stripe
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF635BFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 16, color: Color(0xFF635BFF)),
                    const SizedBox(width: 6),
                    Text('Powered by Stripe', style: AppTextStyles.body(12, const Color(0xFF635BFF), weight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Résumé de la consultation
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.rosePale.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.rosePale),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Service', 'Consultation Spécialisée'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Spécialiste', widget.consultation.specialist?.fullName ?? 'Expert'),
                  const Divider(height: 24),
                  _buildSummaryRow('Total à payer', '${rate.toStringAsFixed(3)} DT', isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info : comment ça marche
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue, size: 18),
                      const SizedBox(width: 8),
                      Text('Comment ça marche ?', style: AppTextStyles.body(14, Colors.blue, weight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoStep('1', 'Le montant est bloqué sur votre carte'),
                  _buildInfoStep('2', 'Après la consultation, le montant est transféré au spécialiste'),
                  _buildInfoStep('3', 'En cas de refus, vous êtes remboursé(e) à 100%'),
                  _buildInfoStep('4', 'En cas d\'annulation de votre part, des frais de 10 DT s\'appliquent'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Message d'erreur
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_errorMessage!, style: AppTextStyles.body(12, Colors.red))),
                  ],
                ),
              ),

            // Bouton Payer
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _handleStripePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF635BFF), // Couleur Stripe
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: const Color(0xFF635BFF).withOpacity(0.3),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.credit_card, color: Colors.white, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'Payer ${rate.toStringAsFixed(3)} DT',
                            style: AppTextStyles.body(16, Colors.white, weight: FontWeight.w700),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Sécurité
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_user_outlined, size: 14, color: Colors.green.withOpacity(0.7)),
                  const SizedBox(width: 4),
                  Text('Paiement 100% sécurisé par Stripe', style: TextStyle(fontSize: 11, color: Colors.green.withOpacity(0.7))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body(14, isTotal ? AppColors.roseDeep : AppColors.textMuted, weight: isTotal ? FontWeight.w700 : FontWeight.normal)),
        Text(value, style: AppTextStyles.body(isTotal ? 18 : 14, AppColors.roseDeep, weight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildInfoStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.15),
            ),
            child: Center(
              child: Text(number, style: AppTextStyles.body(11, Colors.blue, weight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.body(12, AppColors.textMuted))),
        ],
      ),
    );
  }
}
