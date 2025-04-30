import 'package:flutter/material.dart';
import 'package:gomed_admin/screens/notification_screen.dart';

class mainTopBar extends StatelessWidget {
  final String title;

  const mainTopBar({
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // Fixed height for app bar
      decoration: const BoxDecoration(
        color: Color(0xFFD2F1E4),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(60),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.notifications,
                size: 28,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
