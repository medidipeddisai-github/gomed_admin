import 'package:flutter/material.dart';
import 'package:gomed_admin/widgets/bottomnavigation.dart';
import 'package:gomed_admin/widgets/topbar.dart';

class NotificationSettings extends StatefulWidget {
  @override
  _NotificationSettingsState createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  bool isPromotionsEnabled = false;
  bool isPaymentHistoryEnabled = false;
  bool isNotificationSettingsEnabled = false;
  bool isWalletEnabled = false;

  bool isEventReminderEnabled = false;
  bool isEventUpdatesEnabled = false;
  bool isEventAlertsEnabled = false;
  bool isEventFeedbackEnabled = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopBar(
                title: 'Settings Screen',
                onBackPressed: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 20),

              // Mobile Notifications Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Mobile Notifications',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SizedBox(height: 10),
              ToggleSettingsTile(
                title: 'Promotions',
                value: isPromotionsEnabled,
                onChanged: (newValue) {
                  setState(() {
                    isPromotionsEnabled = newValue;
                  });
                },
              ),
              ToggleSettingsTile(
                title: 'Payment History',
                value: isPaymentHistoryEnabled,
                onChanged: (newValue) {
                  setState(() {
                    isPaymentHistoryEnabled = newValue;
                  });
                },
              ),
              ToggleSettingsTile(
                title: 'Notification Settings',
                value: isNotificationSettingsEnabled,
                onChanged: (newValue) {
                  setState(() {
                    isNotificationSettingsEnabled = newValue;
                  });
                },
              ),
              ToggleSettingsTile(
                title: 'Wallet',
                value: isWalletEnabled,
                onChanged: (newValue) {
                  setState(() {
                    isWalletEnabled = newValue;
                  });
                },
              ),

              SizedBox(height: 30),

              // Event Notifications Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Event Notifications',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SizedBox(height: 10),
              ToggleSettingsTile(
                title: 'Event Reminders',
                value: isEventReminderEnabled,
                onChanged: (newValue) {
                  setState(() {
                    isEventReminderEnabled = newValue;
                  });
                },
              ),
              ToggleSettingsTile(
                title: 'Event Updates',
                value: isEventUpdatesEnabled,
                onChanged: (newValue) {
                  setState(() {
                    isEventUpdatesEnabled = newValue;
                  });
                },
              ),
              ToggleSettingsTile(
                title: 'Event Alerts',
                value: isEventAlertsEnabled,
                onChanged: (newValue) {
                  setState(() {
                    isEventAlertsEnabled = newValue;
                  });
                },
              ),
              ToggleSettingsTile(
                title: 'Event Feedback',
                value: isEventFeedbackEnabled,
                onChanged: (newValue) {
                  setState(() {
                    isEventFeedbackEnabled = newValue;
                  });
                },
              ),
            ],
          ),
        ),
        // bottomNavigationBar: CustomBottomNavigationBar(
        //   currentIndex: 3,
        //   onTap: (index) {
        //     Navigator.pop(context);
        //   },
        // ),
      ),
    );
  }
}

class ToggleSettingsTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleSettingsTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Color(0xFF2A9D8F),
      ),
    );
  }
}
