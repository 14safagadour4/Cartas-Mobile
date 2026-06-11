import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String? _userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.sage)),
      );
    }

    if (_userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: Text('Veuillez vous connecter pour voir vos notifications')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text('Mes Notifications', style: AppTextStyles.title(20, AppColors.sage)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.sage),
      ),
      body: StreamBuilder(
        stream: _database.child('notifications/$_userId').orderByChild('timestamp').onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.sage));
          }

          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return _buildEmptyState();
          }

          // Convertir les données en liste et trier par date décroissante
          Map<dynamic, dynamic> values = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          List<Map<String, dynamic>> notifications = [];
          
          values.forEach((key, value) {
            notifications.add({
              'id': key,
              ...Map<String, dynamic>.from(value as Map),
            });
          });

          // Trier par timestamp décroissant
          notifications.sort((a, b) => (b['timestamp'] ?? '').compareTo(a['timestamp'] ?? ''));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return _buildNotificationCard(notif);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 80, color: AppColors.sage.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'Aucune notification pour le moment',
            style: AppTextStyles.body(16, AppColors.sage.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif) {
    final type = notif['type'] ?? 'info';
    final isUnread = notif['status'] == 'unread';
    
    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'consultation_request':
        iconData = Icons.calendar_today_rounded;
        iconColor = AppColors.sage;
        break;
      case 'consultation_response':
      case 'consultation_accepted':
        iconData = Icons.check_circle_outline_rounded;
        iconColor = Colors.green;
        break;
      case 'consultation_rejected':
        iconData = Icons.block_rounded;
        iconColor = Colors.orange;
        break;
      case 'consultation_cancelled':
        iconData = Icons.cancel_outlined;
        iconColor = Colors.red;
        break;
      case 'remedy_validation_request':
        iconData = Icons.assignment_turned_in_outlined;
        iconColor = AppColors.lavande;
        break;
      default:
        iconData = Icons.notifications_active_outlined;
        iconColor = AppColors.roseMid;
    }

    DateTime? date;
    if (notif['timestamp'] != null) {
      date = DateTime.parse(notif['timestamp']);
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isUnread ? AppColors.sage.withOpacity(0.3) : Colors.transparent,
          width: 1,
        ),
      ),
      color: isUnread ? Colors.white : Colors.white.withOpacity(0.7),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, color: iconColor, size: 24),
        ),
        title: Text(
          notif['title'] ?? 'Notification',
          style: AppTextStyles.body(15, AppColors.textPrimary, weight: isUnread ? FontWeight.bold : FontWeight.normal),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notif['body'] ?? '',
              style: AppTextStyles.body(13, AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            Text(
              date != null ? DateFormat('dd/MM HH:mm').format(date) : '',
              style: AppTextStyles.body(11, Colors.grey),
            ),
          ],
        ),
        onTap: () {
          // Marquer comme lu
          if (isUnread) {
            _database.child('notifications/$_userId/${notif['id']}/status').set('read');
          }

          // Navigation vers l'écran dédié
          switch (type) {
            case 'consultation_request':
              context.pushNamed('consultation-requests');
              break;
            case 'consultation_response':
            case 'consultation_accepted':
            case 'consultation_rejected':
              context.pushNamed('my-consultations');
              break;
            case 'consultation_cancelled':
              context.pushNamed('consultation-requests');
              break;
            case 'remedy_validation_request':
              context.pushNamed('remedy-validation');
              break;
            default:
              break;
          }
        },
      ),
    );
  }
}
