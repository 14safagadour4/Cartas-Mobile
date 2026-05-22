import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:cartas/core/services/auth_service.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';
import 'package:cartas/features/specialist/providers/specialist_provider.dart';

class SpecialistHomeScreen extends StatefulWidget {
  const SpecialistHomeScreen({super.key});

  @override
  State<SpecialistHomeScreen> createState() => _SpecialistHomeScreenState();
}

class _SpecialistHomeScreenState extends State<SpecialistHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SpecialistProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;
        
        if (provider.isLoading && profile == null) {
          return const Center(child: CircularProgressIndicator(color: AppColors.sage));
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section + Logout
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildWelcomeSection(profile?.firstName ?? 'Salma'),
                    IconButton(
                      onPressed: () async {
                        await AuthService.logout();
                        if (mounted) context.go('/onboarding');
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                          ],
                        ),
                        child: const Icon(Icons.logout, color: AppColors.roseDeep, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Stat Cards Row
                _buildStatCards(),
                const SizedBox(height: 30),

                // Performance Chart
                _buildPerformanceSection(),
                const SizedBox(height: 30),

                // AI Intelligence Monitor Card
                _buildIAMonitorCard(),
                const SizedBox(height: 30),

                // Today's Appointments
                _buildRemindersSection(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bon retour,',
          style: AppTextStyles.body(14, AppColors.textMuted),
        ),
        Text(
          '${name.startsWith('Dr') ? '' : 'Dr. '}$name 🌿',
          style: AppTextStyles.title(22, AppColors.textPrimary),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'À venir',
            value: '12',
            icon: Icons.calendar_today_rounded,
            color: AppColors.sage,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Revenus',
            value: '450 DT',
            icon: Icons.account_balance_wallet_outlined,
            color: AppColors.goldDeep,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Avis',
            value: '4.9',
            icon: Icons.star_rounded,
            color: AppColors.lavandeDeep,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPerformanceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Performance (Semaine)', style: AppTextStyles.title(16, AppColors.textPrimary)),
              const Icon(Icons.more_horiz, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 3),
                      const FlSpot(1, 1),
                      const FlSpot(2, 4),
                      const FlSpot(3, 2),
                      const FlSpot(4, 5),
                      const FlSpot(5, 3),
                      const FlSpot(6, 4),
                    ],
                    isCurved: true,
                    color: AppColors.sage,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.sage.withOpacity(0.05),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildIAMonitorCard() {
    return GestureDetector(
      onTap: () => context.push('/ai-dashboard'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.psychology, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Intelligence Monitor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Suivez l\'apprentissage de l\'IA en temps réel', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildRemindersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Consultations du Jour', style: AppTextStyles.title(18, AppColors.textPrimary)),
            Text('Voir tout', style: AppTextStyles.body(12, AppColors.sage)),
          ],
        ),
        const SizedBox(height: 15),
        const _AppointmentItem(
          name: 'Leila Ben Youssef',
          time: '09:00 - 09:30',
          type: 'Phytothérapie',
          isNew: true,
        ),
        const _AppointmentItem(
          name: 'Amira Dridi',
          time: '11:00 - 11:30',
          type: 'Aromathérapie',
          isNew: false,
        ),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.title(18, AppColors.textPrimary)),
          Text(title, style: AppTextStyles.body(10, AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _AppointmentItem extends StatelessWidget {
  final String name;
  final String time;
  final String type;
  final bool isNew;

  const _AppointmentItem({
    required this.name,
    required this.time,
    required this.type,
    required this.isNew,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.sagePale,
            ),
            child: const Center(child: Text('👩', style: TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.body(14, AppColors.textPrimary, weight: FontWeight.bold)),
                Text(time, style: AppTextStyles.body(11, AppColors.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isNew)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.sagePale,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('NOUVEAU', style: AppTextStyles.body(8, AppColors.sage, weight: FontWeight.bold)),
                ),
              const SizedBox(height: 4),
              Text(type, style: AppTextStyles.body(10, AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
