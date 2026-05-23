import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/specialist_public_model.dart';
import '../providers/consultation_provider.dart';

class BookingScreen extends StatefulWidget {
  final SpecialistPublicModel specialist;
  final String? preselectedSlot;
  const BookingScreen({super.key, required this.specialist, this.preselectedSlot});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedHour;
  final TextEditingController _reasonCtrl = TextEditingController();
  bool _booked = false;

  final List<String> _hours = [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '14:00', '14:30', '15:00', '15:30', '16:00', '16:30',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.preselectedSlot != null) {
      // Parse le créneau pré-sélectionné si fourni
      _selectedHour = '10:00';
    }
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  String get _isoDateTime {
    final h = int.parse(_selectedHour!.split(':')[0]);
    final m = int.parse(_selectedHour!.split(':')[1]);
    final dt = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, h, m);
    return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)}T${_pad(dt.hour)}:${_pad(dt.minute)}:00';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  Future<void> _confirm() async {
    if (_selectedHour == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un créneau horaire.')),
      );
      return;
    }
    final provider = context.read<ConsultationProvider>();
    final ok = await provider.bookConsultation(
      widget.specialist.id,
      _isoDateTime,
      _reasonCtrl.text.trim(),
    );
    if (ok && mounted) setState(() => _booked = true);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la réservation. Veuillez réessayer.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_booked) return _buildSuccessScreen(context);
    return Scaffold(
      backgroundColor: AppColors.petalCream,
      appBar: AppBar(
        backgroundColor: AppColors.petalCream,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.roseDeep),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Prise de rendez-vous', style: AppTextStyles.title(16, AppColors.roseDeep)),
            Text(widget.specialist.fullName,
                style: AppTextStyles.body(12, AppColors.rose)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDatePicker(),
            const SizedBox(height: 24),
            _buildTimeSlots(),
            const SizedBox(height: 24),
            _buildReasonField(),
            const SizedBox(height: 24),
            _buildSummaryCard(),
            const SizedBox(height: 32),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choisir une date', style: AppTextStyles.title(15, AppColors.roseDeep)),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 14,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final day = DateTime.now().add(Duration(days: i + 1));
              final isSelected = _selectedDate.day == day.day &&
                  _selectedDate.month == day.month;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedDate = day;
                  _selectedHour = null;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 60,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.roseDeep : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim']
                            [day.weekday - 1],
                        style: AppTextStyles.body(10,
                            isSelected ? Colors.white70 : AppColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: AppTextStyles.body(18,
                            isSelected ? Colors.white : AppColors.roseDeep,
                            weight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlots() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choisir un créneau', style: AppTextStyles.title(15, AppColors.roseDeep)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _hours.map((h) {
            final isSelected = _selectedHour == h;
            return GestureDetector(
              onTap: () => setState(() => _selectedHour = h),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.roseDeep : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.roseDeep : AppColors.textDim.withOpacity(0.15),
                  ),
                ),
                child: Text(h,
                    style: AppTextStyles.body(13,
                        isSelected ? Colors.white : AppColors.textPrimary,
                        weight: FontWeight.w600)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Motif de la consultation', style: AppTextStyles.title(15, AppColors.roseDeep)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
          ),
          child: TextField(
            controller: _reasonCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Décrivez brièvement votre problème ou votre question...',
              hintStyle: AppTextStyles.body(13, AppColors.textDim),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.rosePale.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.rose.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Spécialiste', widget.specialist.fullName),
          const Divider(height: 16),
          _buildSummaryRow('Date',
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
          const Divider(height: 16),
          _buildSummaryRow('Heure', _selectedHour ?? '—'),
          const Divider(height: 16),
          _buildSummaryRow('Tarif', '${widget.specialist.rate.toStringAsFixed(0)} DT'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body(13, AppColors.textMuted)),
        Text(value, style: AppTextStyles.body(13, AppColors.roseDeep, weight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return Consumer<ConsultationProvider>(
      builder: (context, provider, _) => ElevatedButton(
        onPressed: provider.isLoading ? null : _confirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.roseDeep,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: provider.isLoading
            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 20),
                  const SizedBox(width: 10),
                  Text('Confirmer le rendez-vous',
                      style: AppTextStyles.body(15, Colors.white, weight: FontWeight.w700)),
                ],
              ),
      ),
    );
  }

  Widget _buildSuccessScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.petalCream,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Color(0xFF388E3C), size: 56),
              ),
              const SizedBox(height: 24),
              Text('Demande envoyée !', style: AppTextStyles.title(22, AppColors.roseDeep)),
              const SizedBox(height: 12),
              Text(
                'Votre demande de rendez-vous a bien été transmise à ${widget.specialist.fullName}. Vous recevrez une confirmation dès que le spécialiste l\'aura acceptée.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body(13, AppColors.textMuted),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.roseDeep,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text('Retour à l\'accueil',
                    style: AppTextStyles.body(15, Colors.white, weight: FontWeight.w700)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.push('/my-consultations'),
                child: Text('Voir mes rendez-vous',
                    style: AppTextStyles.body(14, AppColors.rose, weight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
