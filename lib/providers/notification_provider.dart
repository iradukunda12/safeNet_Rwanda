// notification_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

final notificationServiceProvider = Provider((ref) {
  return NotificationService()..init();
});

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> init() async {
    // ✅ Request permission (iOS/Android 13+)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // ✅ Setup local notification plugin
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        print('Notification tapped: ${response.payload}');
        _handleNotificationTap(response);
      },
    );

    // ✅ Get and store FCM token
    final token = await _messaging.getToken();
    print('🔑 FCM Token: $token');
    
    // Store token in Firestore for sending targeted messages
    if (token != null) {
      await _storeTokenInFirestore(token);
    }

    // ✅ Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      print('🔄 FCM Token refreshed: $newToken');
      _storeTokenInFirestore(newToken);
    });

    // ✅ Foreground message listener
    FirebaseMessaging.onMessage.listen((message) {
      print('📱 Foreground message received: ${message.messageId}');
      _handleForegroundMessage(message);
    });

    // ✅ App opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('📱 App opened from notification: ${message.messageId}');
      _handleNotificationOpen(message);
    });

    // ✅ Initialize random message collection in Firestore
    await _initializeRandomMessages();

    // ✅ Subscribe to topics for different message types
    await _subscribeToTopics();
  }

  /// Store FCM token in Firestore
  Future<void> _storeTokenInFirestore(String token) async {
    try {
      await _firestore.collection('user_tokens').doc(token).set({
        'token': token,
        'platform': 'flutter',
        'lastUpdated': FieldValue.serverTimestamp(),
        'isActive': true,
      }, SetOptions(merge: true));
      print('✅ Token stored in Firestore');
    } catch (e) {
      print('❌ Error storing token: $e');
    }
  }

  /// Subscribe to FCM topics
  Future<void> _subscribeToTopics() async {
    try {
      await _messaging.subscribeToTopic('random_messages');
      await _messaging.subscribeToTopic('mood_reminders');
      await _messaging.subscribeToTopic('sleep_reminders');
      print('✅ Subscribed to FCM topics');
    } catch (e) {
      print('❌ Error subscribing to topics: $e');
    }
  }

  /// Initialize random messages collection in Firestore
  Future<void> _initializeRandomMessages() async {
    try {
      final collection = _firestore.collection('random_messages');
      final snapshot = await collection.limit(1).get();
      
      // If no messages exist, create some default ones
      if (snapshot.docs.isEmpty) {
        await _createDefaultRandomMessages();
      }
    } catch (e) {
      print('❌ Error initializing random messages: $e');
    }
  }

  /// Create default random messages in Firestore
  Future<void> _createDefaultRandomMessages() async {
    final messages = [
      {
        'title': '🌟 Daily Motivation',
        'body': 'Remember, every small step counts towards your wellbeing journey!',
        'type': 'motivation',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': '💚 Mindfulness Moment',
        'body': 'Take a deep breath and appreciate this moment. You are doing great!',
        'type': 'mindfulness',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': '🌈 Positive Vibes',
        'body': 'Your feelings are valid, and it\'s okay to have ups and downs. Keep going!',
        'type': 'encouragement',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': '⭐ Self Care Reminder',
        'body': 'Don\'t forget to be kind to yourself today. You deserve love and care!',
        'type': 'self_care',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': '🎯 Progress Check',
        'body': 'Look how far you\'ve come! Every day is progress, no matter how small.',
        'type': 'progress',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': '🌸 Gentle Reminder',
        'body': 'It\'s perfectly okay to rest when you need to. Self-care is not selfish.',
        'type': 'rest',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': '💫 Inner Strength',
        'body': 'You have overcome challenges before, and you have the strength to do it again.',
        'type': 'strength',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': '🌻 Gratitude Moment',
        'body': 'What\'s one thing you\'re grateful for today? Even small things count!',
        'type': 'gratitude',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': '🦋 Growth Mindset',
        'body': 'Every experience, good or challenging, is helping you grow and learn.',
        'type': 'growth',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': '💝 You Matter',
        'body': 'Your presence in this world makes a difference. You are valued and important.',
        'type': 'worth',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    final batch = _firestore.batch();
    for (final message in messages) {
      final docRef = _firestore.collection('random_messages').doc();
      batch.set(docRef, message);
    }
    
    await batch.commit();
    print('✅ Default random messages created');
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null) {
      await _localNotifications.show(
        message.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'random_messages_channel',
            'Random Messages',
            channelDescription: 'Random motivational and mood messages',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data['type'] ?? 'random_message',
      );
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    print('Notification tapped with payload: $payload');
    
    // You can navigate to specific screens based on payload
    switch (payload) {
      case 'mood_reminder':
        // Navigate to mood tracking screen
        break;
      case 'sleep_reminder':
        // Navigate to sleep tracking screen
        break;
      case 'random_message':
        // Navigate to home or show motivational content
        break;
    }
  }

  /// Handle notification open from background/terminated state
  void _handleNotificationOpen(RemoteMessage message) {
    print('App opened from notification: ${message.data}');
    // Handle navigation based on message data
  }

  /// Get a random message from Firestore
  Future<Map<String, dynamic>?> getRandomMessage() async {
    try {
      final snapshot = await _firestore
          .collection('random_messages')
          .where('isActive', isEqualTo: true)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        final random = Random();
        final randomDoc = snapshot.docs[random.nextInt(snapshot.docs.length)];
        return {
          'id': randomDoc.id,
          ...randomDoc.data(),
        };
      }
      return null;
    } catch (e) {
      print('❌ Error getting random message: $e');
      return null;
    }
  }

  /// Send a random message to all subscribed users (admin function)
  Future<void> sendRandomMessageToTopic() async {
    try {
      final randomMessage = await getRandomMessage();
      if (randomMessage != null) {
        // This would typically be done from your backend/admin panel
        // For demo purposes, showing how the message structure should look
        print('📤 Would send message: ${randomMessage['title']} - ${randomMessage['body']}');
        
        // In a real app, you'd call your backend API which would use Firebase Admin SDK
        // to send the message to the topic
      }
    } catch (e) {
      print('❌ Error sending random message: $e');
    }
  }

  /// Add a new random message to Firestore
  Future<void> addRandomMessage({
    required String title,
    required String body,
    required String type,
  }) async {
    try {
      await _firestore.collection('random_messages').add({
        'title': title,
        'body': body,
        'type': type,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ Random message added to Firestore');
    } catch (e) {
      print('❌ Error adding random message: $e');
    }
  }

  /// Get all random messages from Firestore
  Future<List<Map<String, dynamic>>> getAllRandomMessages() async {
    try {
      final snapshot = await _firestore
          .collection('random_messages')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('❌ Error getting all random messages: $e');
      return [];
    }
  }

  /// Update a random message
  Future<void> updateRandomMessage(String messageId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('random_messages').doc(messageId).update(updates);
      print('✅ Random message updated');
    } catch (e) {
      print('❌ Error updating random message: $e');
    }
  }

  /// Delete a random message
  Future<void> deleteRandomMessage(String messageId) async {
    try {
      await _firestore.collection('random_messages').doc(messageId).update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Random message deleted');
    } catch (e) {
      print('❌ Error deleting random message: $e');
    }
  }

  /// Test local notification
  Future<void> testNotification() async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '🧪 Test Notification',
      'This is a test notification to verify everything is working!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Test notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'test',
    );
  }
}