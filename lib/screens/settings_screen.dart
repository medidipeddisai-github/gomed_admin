import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_admin/provider/loginprovider.dart';
import 'package:gomed_admin/screens/login_screen.dart';
import 'package:gomed_admin/widgets/bottomnavigation.dart';
import 'package:gomed_admin/screens/notification_settings.dart';
import 'package:gomed_admin/widgets/mainappbar.dart';
import 'package:gomed_admin/widgets/topbar.dart';
import "package:gomed_admin/provider/logout_notifier.dart";


class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsPageState();
}

// ignore: camel_case_types
class _SettingsPageState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final logoutNotifier = ref.read(logoutProvider.notifier);
    return SafeArea(
      child: Scaffold(
         appBar: const PreferredSize(
          preferredSize: const Size.fromHeight(80), // Set AppBar height
          child: mainTopBar(title: 'Settings Screen'),
        ),
         body: SingleChildScrollView(
          child: Column(
            children: [
              // TopBar(
              //   title: 'Settings Screen',
              //   onBackPressed: () {
              //     Navigator.pop(context);
              //   },
              // ),
              const SizedBox(height: 20),
              SettingsTile(
                title: 'Profile Settings',
                onTap: () {
                  Navigator.of(context).pushNamed("mangeadminprofile");
                },
              ),
              SettingsTile(
                title: 'Payment History',
                onTap: () {
                  // Handle Payment History action
                },
              ),
              SettingsTile(
                title: 'Notification Settings',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  NotificationSettings(),
                    ),
                  );
                },
              ),
              SettingsTile(
                title: 'Wallet',
                onTap: () {
                  // Handle Wallet action
                },
              ),
              SettingsTile(
                title: 'Logout',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm Logout"),
                        content: const Text("Are you sure you want to log out?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: const Text("No"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                              logoutNotifier.logout(context); // Call logout function
                            },
                            child: const Text("Yes"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              ListTile(
                title: const Text(
                  'Leave a Review',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A9D8F),
                  ),
                ),
                onTap: () {
                  // Handle Leave a Review action
                },
              ),
              const SizedBox(height: 170),
              ListTile(
                title: const Text(
                  'Delete Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                onTap: () {
                 _showDeleteAccountDialog(context,ref);
                },
              ),
            ],
          ),
        ),
        //  bottomNavigationBar:const  CustomBottomNavigationBar(),
      ),
    );
  }
  void _showDeleteAccountDialog(BuildContext parentContext, WidgetRef ref) {
  final userModel = ref.read(loginProvider); // Retrieve UserModel from the provider
  final userId = userModel.data?[0].user?.sId; // Get user ID, default to empty string if null
  final token = userModel.data?[0].accessToken; // Get token, default to empty string if null

  showDialog(
    context: parentContext,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // ✅ close dialog using dialogContext
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
               Navigator.of(dialogContext).pop(); // ✅ close dialog first

              try {
                await ref.read(loginProvider.notifier).deleteAccount(userId, token);

                    if (!mounted) return; // ✅ ensure widget is still alive

                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      const SnackBar(content: Text('Account deleted successfully')),
                    );

                    Navigator.of(parentContext).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                      (route) => false,
                    );
                  
              } catch (error) {
                   print("Error deleting account: $error");
                    if (!mounted) return;

                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      const SnackBar(content: Text('Failed to delete account. Please try again.')),
                    );
              }
              },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}
void _removeAccount(BuildContext context) {
    // Add your account deletion logic here (e.g., API call or local storage update)

    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Account deleted successfully')),
    );

    // Navigate to login or onboarding page after account deletion
   // Navigator.of(context).pushReplacementNamed('/loginscreen');
   
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  LoginScreen()),
        );
      
  }
}

class SettingsTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final TextStyle? textStyle;

  const SettingsTile({
    super.key,
    required this.title,
    required this.onTap,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: textStyle ??
            const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      onTap: onTap,
    );
  }
}
