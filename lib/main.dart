import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gomed_admin/provider/loginprovider.dart';
import 'package:gomed_admin/screens/adminProfile.dart';
import 'package:gomed_admin/screens/adminaddservices/services_edit.dart';
import 'package:gomed_admin/screens/login_screen.dart';
import 'package:gomed_admin/screens/dashboard_screen.dart';
import 'package:gomed_admin/screens/analytics/analytics.dart';
import 'package:gomed_admin/screens/booking_management/add_commission.dart';
import 'package:gomed_admin/screens/booking_management/booking_management.dart';
import 'package:gomed_admin/screens/financial_management/manage_screen.dart';
import 'package:gomed_admin/screens/financial_management/payment_screen.dart';
import 'package:gomed_admin/screens/service_management/add_service.dart';
import 'package:gomed_admin/screens/service_management/manage_services.dart';
import 'package:gomed_admin/screens/user_management/manageusers_screen.dart';
import 'package:gomed_admin/screens/user_management/user_profile.dart';
import 'package:gomed_admin/screens/vendor_management/add_vendor.dart';
import 'package:gomed_admin/screens/vendor_management/vendor_list.dart';
import 'package:gomed_admin/screens/notification_screen.dart';
import 'package:gomed_admin/screens/notification_settings.dart';
import 'package:gomed_admin/screens/settings_screen.dart';
import 'package:gomed_admin/widgets/bottomnavigation.dart';


// 🟢 Global key for showing SnackBar from anywhere
final GlobalKey<ScaffoldMessengerState> globalMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  runApp(
    const ProviderScope(
      child: MyApp()
      ));
}

// Authentication state provider
final authStateProvider = StateProvider<bool>((ref) => false);

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final Connectivity _connectivity;
  late final Stream<ConnectivityResult> _connectivityStream;

  @override
  void initState() {
    super.initState();

    _connectivity = Connectivity();
   _connectivityStream = _connectivity.onConnectivityChanged.map((list) => list.first);


    _connectivityStream.listen((ConnectivityResult result) {
      final isConnected = result != ConnectivityResult.none;

      globalMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            isConnected ? '✅ Back online' : '🚫 No internet connection',
          ),
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
      final authState = ref.watch(loginProvider);
    final accessToken = authState.data?.isNotEmpty == true
        ? authState.data![0].accessToken
        : null;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: globalMessengerKey,
      home: Consumer(builder: (context, ref, child) {
        // print("build main.dart");

        // final authState = ref.watch(loginProvider);
        // // Watch the authentication state
        // // Check for a valid access token
        // final accessToken = authState.data?.isNotEmpty == true
        //     ? authState.data![0].accessToken: null;

        print('token/main $accessToken');
        // // Check if the user has a valid refresh token
        if (accessToken != null && accessToken.isNotEmpty) {
          return const CustomBottomNavigationBar(); // User is authenticated, redirect to Home
        } else {
          print('No valid refresh token, trying auto-login');
        }

        // / Attempt auto-login if refresh token is not available
            return FutureBuilder<bool>(
              future: ref
                  .read(loginProvider.notifier)
                  .tryAutoLogin(), // Attempt auto-login
              builder: (context, snapshot) {
                print(
                    'Token after auto-login attempt: $accessToken');

                if (snapshot.connectionState == ConnectionState.waiting) {
                  // While waiting for auto-login to finish, show loading indicator
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasData &&
                    snapshot.data == true &&
                     ( accessToken != null && accessToken.isNotEmpty)
                     ) {
                  // If auto-login is successful and refresh token is available, go to Dashboard
                  return const CustomBottomNavigationBar();
                } else {
                  // If auto-login fails or no token, redirect to LoginScreen
                  return LoginScreen();
                }
              },
            );
        
      }),
      routes: {
        "loginscreen": (context) => LoginScreen(),
        "analyticsreport": (context) => AnalyticsReportsScreen(),
        "addcommission": (context) => AddCommission(),
        "bookingmanagement": (context) => const BookingManagement(),
        "mangescreen": (context) => ManageScreen(),
        "addvendor": (context) => AddVendor(),
        "vendorlist": (context) => VendorList(),
        "dashboardscreen": (context) => DashboardScreen(),
        "notificationsettings": (context) => NotificationSettings(),
        "settingsscreen": (context) => SettingsScreen(),
        "addsevicescreen": (context) => AddServiceScreen(),
        "manageservices": (context) => ManageServices(),
        "manageusersscreen": (context) => ManageUsersScreen(),
        "mangeadminprofile":(context) => const AdminProfile(),
        "serviceAddEdit":(context)=>const ServicesPageEdit()
      },
    );
  }
}
