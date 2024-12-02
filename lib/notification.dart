import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationDemo extends StatefulWidget {
  const NotificationDemo({super.key});

  @override
  _NotificationDemoState createState() => _NotificationDemoState();
}

class _NotificationDemoState extends State<NotificationDemo> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  List<PendingNotificationRequest> pendingNotifications = [];

  @override
  void initState() {
    super.initState();
    _initializeTimeZone();
    _initializeNotifications();
    _loadPendingNotifications();
  }

  void _initializeTimeZone() {
    tz.initializeTimeZones();
    tz.setLocalLocation(
        tz.getLocation('America/New_York')); // Use your preferred time zone
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification response if needed
      },
    );
  }

  Future<void> showInstantNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'instant_channel',
      'Instant Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
      'Instant Notification',
      'This is an instant notification.',
      notificationDetails,
    );
    _loadPendingNotifications();
  }

  Future<void> scheduleNotification(DateTime scheduledTime) async {
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
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
      'Scheduled Notification',
      'This notification is scheduled.',
      tzScheduledTime,
      notificationDetails,
      //androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    _loadPendingNotifications();
  }

  Future<void> clearAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    _loadPendingNotifications();
  }

  Future<void> clearNotificationById(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    _loadPendingNotifications();
  }

  Future<void> _loadPendingNotifications() async {
    final notifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    setState(() {
      pendingNotifications = notifications;
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime? selectedDate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Manager'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: showInstantNotification,
              child: const Text('Show Instant Notification'),
            ),
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
                    subtitle: Text('ID: ${notification.id}'),
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
