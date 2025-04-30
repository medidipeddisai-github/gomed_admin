import 'package:flutter/material.dart';
import 'package:gomed_admin/widgets/topbar.dart';

class NotificationItem extends StatelessWidget {
  final String title;
  final String sender;
  final String time;
  final bool isRead;
  final bool isImportant;

  NotificationItem({
    required this.title,
    required this.sender,
    required this.time,
    this.isRead = false,
    this.isImportant = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        isImportant ? Icons.star : Icons.notifications,
        color: Color(0xFF2A9D8F),
        size: 25,
      ),
      title: Text(title,
          style: TextStyle(
              fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
      subtitle: Text(sender),
      trailing: Text(time),
      onTap: () {
        // Handle notification tap here
      },
    );
  }
}

class NotificationList extends StatefulWidget {
  @override
  _NotificationListState createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  List<NotificationItem> allNotifications = [
    NotificationItem(
      title: 'Fermentum Venenatis Tortor',
      sender: 'Marvin McKinney',
      time: '10',
      isImportant: true,
    ),
    NotificationItem(
      title: 'Fermentum Venenatis Tortor',
      sender: 'Marvin McKinney',
      time: '10',
      isImportant: false,
    ),
    NotificationItem(
      title: 'Fermentum Venenatis Tortor',
      sender: 'Marvin McKinney',
      time: '10',
      isImportant: true,
    ),
    NotificationItem(
      title: 'Fermentum Venenatis Tortor',
      sender: 'Marvin McKinney',
      time: '10',
      isImportant: false,
    ),
    // ... other notifications
  ];

  List<NotificationItem> displayedNotifications = [];
  String filter = 'All';

  @override
  void initState() {
    super.initState();
    displayedNotifications = allNotifications;
  }

  void filterNotifications(String filter) {
    setState(() {
      this.filter = filter;
      switch (filter) {
        case 'Unread':
          displayedNotifications =
              allNotifications.where((n) => !n.isRead).toList();
          break;
        case 'Important':
          displayedNotifications =
              allNotifications.where((n) => n.isImportant).toList();
          break;
        case 'System':
          // Assuming you have a filter for system notifications
          // displayedNotifications = allNotifications.where((n) => n.isSystem).toList();
          break;
        default:
          displayedNotifications = allNotifications;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['All', 'Unread', 'System', 'Important'].map((label) {
            return ChoiceChip(
              selectedColor: Color(0xFF2A9D8F),
              label: Text(label),
              selected: filter == label,
              onSelected: (selected) {
                filterNotifications(label);
              },
            );
          }).toList(),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: displayedNotifications.length,
            itemBuilder: (context, index) {
              return NotificationItem(
                title: displayedNotifications[index].title,
                sender: displayedNotifications[index].sender,
                time: displayedNotifications[index].time,
                isRead: displayedNotifications[index].isRead,
                isImportant: displayedNotifications[index].isImportant,
              );
            },
          ),
        ),
      ],
    );
  }
}

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            TopBar(
              title: 'Notification',
              onBackPressed: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 5),
            Expanded(
              child: NotificationList(),
            ),
          ],
        ),
      ),
    );
  }
}
