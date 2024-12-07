import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:async';

class NotificationDemo extends StatefulWidget {
  const NotificationDemo({super.key});

  @override
  _NotificationDemoState createState() => _NotificationDemoState();
}

class _NotificationDemoState extends State<NotificationDemo> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  List<PendingNotificationRequest> pendingNotifications = [];
  Map<int, Duration> notificationCountdowns = {};

  @override
  void initState() {
    super.initState();
    _initializeTimeZone();
    _initializeNotifications();
    _loadPendingNotifications();
  }

  void _initializeTimeZone() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/New_York')); // Update as needed
    debugPrint("Time zone initialized to ${tz.local}");
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    if (result != true) {
      debugPrint("Notification permissions not granted");
    }

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notification clicked: ${response.payload}");
      },
    );

    debugPrint("Notification plugin initialized");
  }

  Future<void> showInstantNotification() async {
    try {
      // Safe ID generation
      int notificationId = DateTime.now().millisecondsSinceEpoch % 2147483647;

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'default_channel',
        'Instant Notifications',
        channelDescription: 'Channel for instant notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        notificationId,
        'Test Notification',
        'This is a test notification.',
        notificationDetails,
      );

      debugPrint("Instant notification shown with ID: $notificationId");
    } catch (e) {
      debugPrint("Error showing instant notification: $e");
    }
  }

  Future<void> scheduleNotification(DateTime scheduledTime) async {
    try {
      // Generate a safe ID
      int id = DateTime.now().millisecondsSinceEpoch % 2147483647;

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'scheduled_channel',
        'Scheduled Notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      final tz.TZDateTime tzScheduledTime =
          tz.TZDateTime.from(scheduledTime, tz.local);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'Scheduled Notification',
        'This notification is scheduled.',
        tzScheduledTime,
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      startCountdown(id, scheduledTime);
      debugPrint("Scheduled notification with ID: $id at $scheduledTime");
      _loadPendingNotifications();
    } catch (e) {
      debugPrint("Error scheduling notification: $e");
    }
  }

  void startCountdown(int id, DateTime scheduledTime) {
    final remaining = scheduledTime.difference(DateTime.now());
    if (remaining.isNegative) return;

    setState(() {
      notificationCountdowns[id] = remaining;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        final updatedRemaining = scheduledTime.difference(DateTime.now());
        if (updatedRemaining.isNegative) {
          notificationCountdowns.remove(id);
          timer.cancel();
          debugPrint("Countdown ended for notification ID: $id");
        } else {
          notificationCountdowns[id] = updatedRemaining;
        }
      });
    });
  }

  Future<void> clearAllNotifications() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
      debugPrint("All notifications cleared");
      _loadPendingNotifications();
    } catch (e) {
      debugPrint("Error clearing all notifications: $e");
    }
  }

  Future<void> clearNotificationById(int id) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id);
      debugPrint("Notification cleared with ID: $id");
      _loadPendingNotifications();
    } catch (e) {
      debugPrint("Error clearing notification with ID $id: $e");
    }
  }

  Future<void> _loadPendingNotifications() async {
    try {
      final notifications =
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      debugPrint('Pending Notifications Count: ${notifications.length}');
      for (var notification in notifications) {
        debugPrint(
            'Notification ID: ${notification.id}, Title: ${notification.title}');
      }
      setState(() {
        pendingNotifications = notifications;
      });
    } catch (e) {
      debugPrint("Error loading pending notifications: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime? selectedDate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Manager'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: showInstantNotification,
              child: const Text('Show Instant Notification'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: clearAllNotifications,
              child: const Text('Clear All Notifications'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  selectedDate = date.add(const Duration(seconds: 10));
                  await scheduleNotification(selectedDate!);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Notification scheduled at $selectedDate'),
                  ));
                }
              },
              child: const Text('Schedule Notification'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pending Notifications:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: pendingNotifications.length,
                itemBuilder: (context, index) {
                  final notification = pendingNotifications[index];
                  return ListTile(
                    title: Text(notification.title ?? 'No Title'),
                    subtitle: Text(
                        'ID: ${notification.id} - Remaining: ${notificationCountdowns[notification.id]?.inSeconds ?? 0}s'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        clearNotificationById(notification.id);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
