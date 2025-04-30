import 'package:flutter/material.dart';
import 'package:gomed_admin/screens/notification_screen.dart';

class TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBackPressed;

  const TopBar({
    required this.title,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
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
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 28,
                  ),
                  onPressed: onBackPressed,
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(
                Icons.notifications,
                size: 28,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
