import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  TimeOfDay? reminderTime;
  TimeOfDay? sleepTime;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _timezoneInitialized = false;
  bool _notificationsEnabled = false;
  bool _exactAlarmsPermitted = false;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Check notification permission
    final notificationStatus = await Permission.notification.status;
    
    // Check exact alarm permission (Android 12+)
    bool exactAlarmPermission = true;
    if (Platform.isAndroid) {
      try {
        exactAlarmPermission = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.canScheduleExactNotifications() ?? false;
      } catch (e) {
        debugPrint('Error checking exact alarm permission: $e');
        exactAlarmPermission = false;
      }
    }

    setState(() {
      _notificationsEnabled = notificationStatus.isGranted;
      _exactAlarmsPermitted = exactAlarmPermission;
    });

    debugPrint('📱 Notifications enabled: $_notificationsEnabled');
    debugPrint('⏰ Exact alarms permitted: $_exactAlarmsPermitted');
  }

  Future<void> _requestPermissions() async {
    // Request notification permission
    final notificationStatus = await Permission.notification.request();
    
    // Request exact alarm permission for Android 12+
    if (Platform.isAndroid && !_exactAlarmsPermitted) {
      try {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestExactAlarmsPermission();
      } catch (e) {
        debugPrint('Error requesting exact alarm permission: $e');
      }
    }

    // Refresh permission status
    await _checkPermissions();
  }

  Future<void> _initNotifications() async {
    _ensureTimezoneInitialized();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Firebase foreground push notifications
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        _showLocalNotification(notification.title, notification.body);
      }
    });

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle notification tap - navigate to specific screen if needed
  }

  void _ensureTimezoneInitialized() {
    if (!_timezoneInitialized) {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Africa/Kigali'));
      _timezoneInitialized = true;
    }
  }

  Future<void> _showLocalNotification(String? title, String? body, {String? payload}) async {
    const androidDetails = AndroidNotificationDetails(
      'mood_channel',
      'Mood Reminders',
      channelDescription: 'Notifications for mood tracking reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title ?? 'Mood Tracker',
      body ?? 'Time to check your mood!',
      details,
      payload: payload,
    );
  }

  // Get custom notification message based on reminder type
  String _getNotificationMessage(String title) {
    if (title.toLowerCase().contains('sleep')) {
      // Sleep reminder messages
      final sleepMessages = [
        '💤 Time to wind down and prepare for a restful night!',
        '🌙 Your bedtime is here - sweet dreams await!',
        '😴 It\'s time to get some quality sleep for tomorrow!',
        '🛌 Time to relax and recharge for a new day!',
        '✨ Your body needs rest - time for bed!',
      ];
      return sleepMessages[DateTime.now().millisecond % sleepMessages.length];
    } else {
      // Mood reminder messages
      final moodMessages = [
        '💭 How are you feeling right now? Take a moment to reflect!',
        '🌟 Time for your daily mood check-in - how\'s your day going?',
        '💚 Remember to track your mood and celebrate your progress!',
        '🎯 A quick mood check can help you stay mindful of your wellbeing!',
        '🌈 Take a breath and check in with yourself - how do you feel?',
        '📝 Your daily mood reminder is here - let\'s see how you\'re doing!',
      ];
      return moodMessages[DateTime.now().millisecond % moodMessages.length];
    }
  }

  Future<void> _scheduleMoodNotification(TimeOfDay time, String title) async {
    if (!_notificationsEnabled) {
      _showPermissionDialog();
      return;
    }

    try {
      _ensureTimezoneInitialized();

      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      // Get custom message based on reminder type
      final notificationMessage = _getNotificationMessage(title);

      // Choose scheduling method based on permission
      if (_exactAlarmsPermitted) {
        // Use exact scheduling
        await flutterLocalNotificationsPlugin.zonedSchedule(
          title.hashCode,
          title,
          notificationMessage,
          scheduled,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'mood_channel',
              'Mood Reminders',
              channelDescription: 'Notifications for mood tracking reminders',
              importance: Importance.max,
              priority: Priority.high,
              enableVibration: true,
              playSound: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: title.toLowerCase().contains('sleep') ? 'sleep_reminder' : 'mood_reminder',
        );
        debugPrint('✅ Exact notification scheduled at $scheduled');
      } else {
        // Use inexact scheduling (fallback)
        await flutterLocalNotificationsPlugin.zonedSchedule(
          title.hashCode,
          title,
          notificationMessage,
          scheduled,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'mood_channel',
              'Mood Reminders',
              channelDescription: 'Notifications for mood tracking reminders',
              importance: Importance.max,
              priority: Priority.high,
              enableVibration: true,
              playSound: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: title.toLowerCase().contains('sleep') ? 'sleep_reminder' : 'mood_reminder',
        );
        debugPrint('⚠️ Inexact notification scheduled at $scheduled (exact alarms not permitted)');
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${title} set for ${time.format(context)}'),
            backgroundColor: const Color(0xff8654B0),
            duration: const Duration(seconds: 2),
          ),
        );
      }

    } catch (e, st) {
      debugPrint('⚠️ Error scheduling notification: $e\n$st');

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to schedule notification: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Try immediate notification as fallback
      await _showLocalNotification(
        "Reminder Set",
        "Your reminder has been saved, but may not trigger exactly on time.",
      );
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('To receive notifications, please grant the following permissions:'),
            const SizedBox(height: 16),
            if (!_notificationsEnabled)
              const Row(
                children: [
                  Icon(Icons.notifications, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(child: Text('Notification Permission')),
                ],
              ),
            if (!_exactAlarmsPermitted)
              const Row(
                children: [
                  Icon(Icons.alarm, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(child: Text('Exact Alarm Permission (for precise timing)')),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _requestPermissions();
            },
            child: const Text('Grant Permissions'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveReminderToFirebase(TimeOfDay time, String type) async {
    try {
      final now = DateTime.now();
      final reminderDateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);

      final reminderData = {
        'type': type,
        'time': reminderDateTime.toIso8601String(),
        'timeFormatted': time.format(context),
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      await FirebaseFirestore.instance.collection('reminders').add(reminderData);
      debugPrint('✅ Reminder saved to Firebase: $type at ${time.format(context)}');
    } catch (e) {
      debugPrint('⚠️ Error saving reminder to Firebase: $e');
    }
  }

  Future<void> _pickTime({required bool isReminder}) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff8654B0),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final title = isReminder ? 'Mood Reminder' : 'Sleep Reminder';
      setState(() {
        if (isReminder) {
          reminderTime = pickedTime;
        } else {
          sleepTime = pickedTime;
        }
      });

      await _scheduleMoodNotification(pickedTime, title);
      await _saveReminderToFirebase(pickedTime, title);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff280446),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xff280446),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showPermissionDialog,
            tooltip: 'Notification Settings',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Permission status indicator
            if (!_notificationsEnabled || !_exactAlarmsPermitted)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        !_notificationsEnabled 
                          ? 'Notification permission required'
                          : 'Exact alarm permission recommended for precise timing',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: _requestPermissions,
                      child: const Text('Fix', style: TextStyle(color: Colors.orange)),
                    ),
                  ],
                ),
              ),

            const Text(
              'Mood Tracking',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xff8654B0),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTimeTile(
                      label: 'Daily Mood Check',
                      subtitle: 'Get reminded to track your mood',
                      time: reminderTime,
                      onPressed: () => _pickTime(isReminder: true),
                      icon: Icons.notifications_active,
                    ),
                    const Divider(
                      color: Colors.white24,
                      thickness: 1,
                      height: 32,
                    ),
                    _buildTimeTile(
                      label: 'Sleep Reminder',
                      subtitle: 'Get reminded when it\'s bedtime',
                      time: sleepTime,
                      onPressed: () => _pickTime(isReminder: false),
                      icon: Icons.bedtime,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            
            // Test notification button
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _showLocalNotification(
                    'Test Notification',
                    'This is a test notification to verify everything is working!',
                  );
                },
                icon: const Icon(Icons.notifications),
                label: const Text('Test Notification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff8654B0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTile({
    required String label,
    required String subtitle,
    TimeOfDay? time,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    final timeText = time != null ? time.format(context) : 'Not set';
    final isSet = time != null;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            timeText,
            style: TextStyle(
              color: isSet ? Colors.white : Colors.white.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      trailing: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          iconSize: 20,
          icon: Icon(
            isSet ? Icons.edit : Icons.add,
            color: Colors.white,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}