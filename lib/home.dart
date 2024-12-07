import 'package:flutter/material.dart';
import 'package:notification/core/locate.dart';
import 'package:notification/portofilio.dart';

import 'notification.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage tasks'),
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationDemo()));
              },
              child: const Text('Task1 notifications')),
          const SizedBox(
            height: 40,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PortfolioPDFGenerator()));
              },
              child: const Text('Task2 pdf')),
          const SizedBox(
            height: 40,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LocationFetcher()));
              },
              child: const Text('Task3 locations'))
        ],
      ),
    );
  }
}
