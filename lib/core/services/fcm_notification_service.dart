import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../routes/app_router.dart';

// Fonction de haut niveau (top-level) pour gérer les messages en arrière-plan
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Message reçu en arrière-plan: ${message.messageId}");
}

class FCMNotificationService {
  // Singleton pattern
  static final FCMNotificationService _instance = FCMNotificationService._internal();
  factory FCMNotificationService() => _instance;
  FCMNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init(String userId) async {
    // 1. Demander la permission
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Configurer les notifications locales
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationClick(null); 
      },
    );

    // 3. Récupérer le token FCM
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await saveTokenToDatabase(userId, token);
    }

    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      saveTokenToDatabase(userId, newToken);
    });

    // 4. Gérer les messages quand l'application est OUVERTE (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message reçu alors que l\'application est au premier plan !');
      if (message.notification != null) {
        _showLocalNotification(
          title: message.notification!.title ?? 'Nouvelle Notification',
          body: message.notification!.body ?? '',
          data: message.data,
        );
      }
    });

    // 5. Gérer les messages quand l'application est FERMÉE (Background)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 6. Gérer le clic sur la notification quand l'application est en arrière-plan
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification cliquée (App en arrière-plan)');
      _handleNotificationClick(message);
    });

    // 7. Gérer si l'application a été ouverte via une notification (App tuée)
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('Notification cliquée (App tuée)');
      _handleNotificationClick(initialMessage);
    }
  }

  void _handleNotificationClick(RemoteMessage? message) {
    if (message != null && message.data['type'] == 'specialist_validated') {
      String role = message.data['role'] ?? 'SPECIALIST';
      String roleParam = role.toLowerCase() == 'specialist' ? 'specialiste' : 'art-therapeute';
      AppRouter.router.goNamed('login', pathParameters: {'role': roleParam});
      return;
    }
    
    AppRouter.router.push('/my-consultations');
  }

  // Enregistrer le Token dans Firebase Realtime Database
  Future<void> saveTokenToDatabase(String userId, String token) async {
    try {
      await _dbRef.child('userTokens/$userId').set({
        'fcmToken': token,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
      print('FCM Token enregistré avec succès pour l\'utilisateur : $userId');
    } catch (e) {
      print('Erreur lors de l\'enregistrement du FCM Token : $e');
    }
  }

  // Afficher une alerte visuelle quand l'application est ouverte
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'cartas_channel_id',
      'Notifications CARTAS',
      channelDescription: 'Canal principal pour les notifications de consultations',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
        
    await _localNotificationsPlugin.show(
      id: DateTime.now().millisecond,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: data.toString(),
    );
  }
}
