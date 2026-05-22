import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';

class SpecialistAgendaScreen extends StatefulWidget {
  const SpecialistAgendaScreen({super.key});

  @override
  State<SpecialistAgendaScreen> createState() => _SpecialistAgendaScreenState();
}

class _SpecialistAgendaScreenState extends State<SpecialistAgendaScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildCalendarCard(),
          const SizedBox(height: 25),
          _buildAgendaHeader(),
          const SizedBox(height: 15),
          Expanded(child: _buildSlotsList()),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 5))
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2026, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() => _calendarFormat = format);
        },
        calendarStyle: const CalendarStyle(
          selectedDecoration: BoxDecoration(color: AppColors.sage, shape: BoxShape.circle),
          todayDecoration: BoxDecoration(color: AppColors.sagePale, shape: BoxShape.circle),
          todayTextStyle: TextStyle(color: AppColors.sage, fontWeight: FontWeight.bold),
          defaultTextStyle: TextStyle(color: AppColors.textPrimary),
          weekendTextStyle: TextStyle(color: AppColors.sage),
          outsideTextStyle: TextStyle(color: Colors.black26),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppTextStyles.title(16, AppColors.textPrimary),
          leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.sage),
          rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.sage),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: AppColors.textMuted, fontSize: 12),
          weekendStyle: TextStyle(color: AppColors.sage, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildAgendaHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Créneaux réservés', style: AppTextStyles.title(18, AppColors.textPrimary)),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('Ajouter'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.sagePale,
            foregroundColor: AppColors.sage,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildSlotsList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2))
            ],
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text(index == 0 ? '09:00' : '11:00', style: AppTextStyles.title(14, AppColors.textPrimary)),
                  Text(index == 0 ? '09:30' : '11:30', style: AppTextStyles.body(10, AppColors.textMuted)),
                ],
              ),
              const SizedBox(width: 20),
              Container(width: 1, height: 30, color: AppColors.sagePale),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(index == 0 ? 'Consultation Sarra' : 'Consultation Ines', 
                         style: AppTextStyles.body(14, AppColors.textPrimary, weight: FontWeight.bold)),
                    Text('Confirmé', style: AppTextStyles.body(10, AppColors.sage)),
                  ],
                ),
              ),
              const Icon(Icons.videocam_rounded, color: AppColors.sage, size: 22),
            ],
          ),
        );
      },
    );
  }
}
