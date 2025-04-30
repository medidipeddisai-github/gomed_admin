import 'package:flutter/material.dart';
import 'package:gomed_admin/screens/adminaddproducts/products_screen.dart';
import 'package:gomed_admin/screens/adminaddservices/services_screen.dart';
import 'package:gomed_admin/screens/category/category_screen.dart';
import 'package:gomed_admin/screens/dashboard_screen.dart';
import 'package:gomed_admin/screens/analytics/analytics.dart';
import 'package:gomed_admin/screens/financial_management/manage_screen.dart';
import 'package:gomed_admin/screens/user_management/manageusers_screen.dart';
import 'package:gomed_admin/screens/settings_screen.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key,});

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0;

   void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> get _pages => [
     DashboardScreen(),  // Home
     AnalyticsReportsScreen(), 
     ProductScreen(),
     ServicesPage(), // Analytics
     CategoryScreen(),  // Profile
     SettingsScreen(),  // Settings
  ];

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: null,
      body:  _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
      backgroundColor: const Color(0xFF2A9D8F),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2E3236),
      unselectedItemColor: Colors.white,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Product'),
        BottomNavigationBarItem(icon: Icon(Icons.miscellaneous_services), label: 'Services'),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'category'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gomed_admin/screens/adminaddproducts/products_screen.dart';
// import 'package:gomed_admin/screens/adminaddservices/services_screen.dart';
// import 'package:gomed_admin/screens/dashboard_screen.dart';
// import 'package:gomed_admin/screens/analytics/analytics.dart';
// import 'package:gomed_admin/screens/financial_management/manage_screen.dart';
// import 'package:gomed_admin/screens/settings_screen.dart';

// class CustomBottomNavigationBar extends ConsumerWidget {
//  const CustomBottomNavigationBar({super.key});

//   void navigateTo(BuildContext context, int index) {
//     final routes = [
//       "/dashboard",
//       "/analytics",
//       "/products",
//       "/services",
//       "/financescreen",
//       "/settings",
//     ];

//     if (ModalRoute.of(context)?.settings.name == routes[index]) return;

//     Widget page;
//     switch (index) {
//       case 0:
//         page = const DashboardScreen();
//         break;
//       case 1:
//         page = const AnalyticsReportsScreen();
//         break;
//       case 2:
//         page = const ProductScreen();
//         break;
//       case 3:
//         page = const ServicesPage();
//         break;
//       case 4:
//          page = const ManageScreen();
//         break;
//       case 5:
//         page = const SettingsScreen();
//         break; 
//       // You can add more cases for additional pages like Services and Settings
//       default:
//         return;
//     }

//     // Use pushReplacement to avoid stacking pages
//    Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => page, settings: RouteSettings(name: routes[index])),
//     );
//   }  

//   int _getCurrentIndex(BuildContext context) {
//     final route = ModalRoute.of(context)?.settings.name;

//     switch (route) {
//       case "/dashboard":
//         return 0;
//       case "/analytics":
//         return 1;
//       case "/products":
//         return 2;
//       case "/services":
//         return 3;
//       case "/financescreen":
//         return 4;
//       case "/settings":
//         return 5;  
//       default:
//         return 0; // Default to Home
//     }
//   }

//   @override
//   Widget build(BuildContext context,WidgetRef ref) {

//    return BottomNavigationBar(
//       currentIndex: _getCurrentIndex(context),
//       backgroundColor: const Color(0xFF2A9D8F),
//       type: BottomNavigationBarType.fixed,
//       selectedItemColor: Colors.black,
//       unselectedItemColor: Colors.white,
//       selectedIconTheme: const IconThemeData(color: Colors.black, size: 28),
//       unselectedIconTheme: const IconThemeData(color: Colors.white, size: 24),
//       onTap: (index) => navigateTo(context, index),
//       items: const [
//         BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//         BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
//         BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Product'),
//         BottomNavigationBarItem(icon: Icon(Icons.miscellaneous_services), label: 'Services'),
//         BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//         BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
//       ],
      
//     );
//   }
// }
