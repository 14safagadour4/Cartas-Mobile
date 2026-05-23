import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cartas/core/theme/app_colors.dart';

class NotificationBadge extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const NotificationBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userId = prefs.getString('userId');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return IconButton(
        onPressed: widget.onTap,
        icon: Icon(widget.icon, color: widget.color),
      );
    }

    return StreamBuilder(
      stream: _database.child('notifications/$_userId').onValue,
      builder: (context, snapshot) {
        int unreadCount = 0;
        if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
          final values = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          values.forEach((key, value) {
            if (value['status'] == 'unread') {
              unreadCount++;
            }
          });
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              onPressed: widget.onTap,
              icon: Icon(widget.icon, color: widget.color),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.roseMid,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
