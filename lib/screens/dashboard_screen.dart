import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_admin/provider/adminApprovedProvider.dart';
import 'package:gomed_admin/provider/adminaddservicesprovider.dart';
import 'package:gomed_admin/provider/distributorprovider.dart';
import 'package:gomed_admin/provider/requestGetProvider.dart';
import 'package:gomed_admin/provider/serviceengineersprovider.dart';
import 'package:gomed_admin/provider/serviceslistprovider.dart';
import 'package:gomed_admin/provider/usersdataprovider.dart';
import 'package:gomed_admin/screens/analytics/analytics.dart';
import 'package:gomed_admin/screens/booking_management/booking_management.dart';
import 'package:gomed_admin/screens/financial_management/manage_screen.dart';
import 'package:gomed_admin/screens/notification_screen.dart';
import 'package:gomed_admin/screens/requestingproducts/requested_products.dart';
import 'package:gomed_admin/screens/service_management/manage_services.dart';
import 'package:gomed_admin/screens/settings_screen.dart';
import 'package:gomed_admin/screens/user_management/manageusers_screen.dart';
import 'package:gomed_admin/screens/vendor_management/vendor_list.dart';
import 'package:gomed_admin/widgets/bottomnavigation.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState()=> dashboardscreenstate();

}
class dashboardscreenstate extends ConsumerState<DashboardScreen>{
 
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(usersProvider.notifier).getUsers());
    Future.microtask(() => ref.read(distributorProvider.notifier).getUsers());
    Future.microtask(() => ref.read(serviceEngineerProvider.notifier).getUsers());
    Future.microtask(() => ref.read(servicelistProvider.notifier).getservicesList());
    Future.microtask(() => ref.read(adminApprovedProductsProvider.notifier).getAdminApprovedProducts());
    Future.microtask(() => ref.read(requestedproductsProvider.notifier).getRequestedProducts());
  }

  @override
  Widget build(BuildContext context) {
    final users=ref.watch(usersProvider).data ?? [];
    final vendors =ref.watch(distributorProvider).data ?? [];
    final services =ref.watch(servicelistProvider).data ?? [];
    final serviceEngineers =ref.watch(serviceEngineerProvider).data ?? [];
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Count Metrics
    final int totalUsers = users.length;

    final int activeVendors = vendors.where((vendor) => vendor.status == "Active").length;

    final int availableServices = services.where((service) => service.activated == true).length;

    final int activeServiceEngineers = serviceEngineers.where((engineer) => engineer.status == "active").length;

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.1), // Set height for AppBar
          child: _buildTopBar(context, screenHeight),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
               Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  
                    SizedBox(height: screenHeight * 0.02),
                    _buildButtonRow(context, screenWidth),
                    SizedBox(height: screenHeight * 0.02),
                    _buildRequestProductsButton(screenWidth),
                    SizedBox(height: screenHeight * 0.02),
                    _buildSectionTitle('Key Metrics'),
                    _buildCard(
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           _buildMetricRow('Total Number Of Users : $totalUsers'),
                           _buildMetricRow('Active distributors : $activeVendors'),
                           _buildMetricRow('Active Service Engineers : $activeServiceEngineers'),
                           _buildMetricRow('Available Services : $availableServices'),
                                                
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    _buildAlertsAndNotifications(screenWidth),
                  ],
                ),
              ),
            ],
          ),
        ),
        // bottomNavigationBar:const  CustomBottomNavigationBar(),
      ),
    );
  }

  Widget _buildButtonRow(BuildContext context, double screenWidth) {
    final double buttonWidth = screenWidth * 0.2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSquareButton('Manage Users', context, buttonWidth),
        _buildSquareButton('Manage Services', context, buttonWidth),
        _buildSquareButton('Manage Bookings', context, buttonWidth),
        _buildSquareButton('Manage Vendors', context, buttonWidth),
      ],
    );
  }

  Widget _buildSquareButton(String title, BuildContext context, double width) {
    return GestureDetector(
      onTap: () {
        if (title == 'Manage Users') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ManageUsersScreen()),
          );
        } else if (title == 'Manage Services') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ManageServices()),
          );
        } else if (title == 'Manage Bookings') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BookingManagement()),
          );
        } else if (title == 'Manage Vendors') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VendorList()),
          );
        }
      },
      child: Container(
        width: width,
        height: width,
        decoration: BoxDecoration(
          color: const Color(0xFFD2F1E4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildRequestProductsButton(double screenWidth) {
  return SizedBox(
    width: screenWidth * 1.0,
    height: 50,
    child: ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RequestedProductsScreen()), // <-- Replace with your actual screen
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1BA4CA),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: const Text(
        'Request Products',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    ),
  );
}


  Widget _buildSearchBar(double screenWidth) {
    return SizedBox(
      width: screenWidth * 0.9,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search',
          suffixIcon: const Icon(
            Icons.search,
            size: 25,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget content}) {
    return Card(
      color: const Color(0xFFD2F1E4),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: content,
      ),
    );
  }

  Widget _buildMetricRow(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsAndNotifications(double screenWidth) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Alerts and Notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _buildCard(
          content: const Row(
            children: [
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Alerts and notifications content goes here...',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, double screenHeight) {
    return Container(
      height: screenHeight * 0.1,
      decoration: const BoxDecoration(
        color: Color(0xFFD2F1E4),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: screenHeight * 0.070,
              height: screenHeight * 0.070,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: AssetImage('assets/gomedlogo.jpeg'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Row(
              children: [
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
          ],
        ),
      ),
    );
  }
}

















// import 'package:flutter/material.dart';
// import 'package:gomedserv/screens/analytics/analytics.dart';
// import 'package:gomedserv/screens/financial_management/manage_screen.dart';
// import 'package:gomedserv/screens/settings_screen.dart';
// import 'package:gomedserv/widgets/bottomnavigation.dart';

// class DashboardScreen extends StatefulWidget {
//   @override
//   _DashboardScreenState createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   int _selectedIndex = 0;

//   static const List<Widget> _widgetOptions = <Widget>[
//     HomeScreen(), // Main dashboard content
//     AnalyticsReportsScreen(),
//     ManageScreen(),
//     SettingsScreen(),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _selectedIndex,
//         children: _widgetOptions,
//       ),
//       bottomNavigationBar: CustomBottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final double screenHeight = MediaQuery.of(context).size.height;

//     return SafeArea(
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             _buildTopBar(context, screenHeight),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Status: ',
//                         style: TextStyle(color: Colors.black, fontSize: 18),
//                       ),
//                       Text(
//                         'Active',
//                         style: TextStyle(color: Colors.green, fontSize: 18),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: screenHeight * 0.02),
//                   _buildButtonRow(context, screenWidth),
//                   SizedBox(height: screenHeight * 0.02),
//                   _buildSearchBar(screenWidth),
//                   SizedBox(height: screenHeight * 0.02),
//                   _buildSectionTitle('Key Metrics'),
//                   _buildCard(
//                     content: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildMetricRow('Total Number Of Users'),
//                         _buildMetricRow('Active Vendors'),
//                         _buildMetricRow('Available Services'),
//                         _buildMetricRow('Bookings Today'),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: screenHeight * 0.02),
//                   _buildAlertsAndNotifications(screenWidth),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildButtonRow(BuildContext context, double screenWidth) {
//     final double buttonWidth = screenWidth * 0.2;

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         _buildSquareButton('Manage Users', context, buttonWidth),
//         _buildSquareButton('Manage Services', context, buttonWidth),
//         _buildSquareButton('Manage Bookings', context, buttonWidth),
//         _buildSquareButton('Manage Vendors', context, buttonWidth),
//       ],
//     );
//   }

//   Widget _buildSquareButton(String title, BuildContext context, double width) {
//     return GestureDetector(
//       onTap: () {
//         if (title == 'Manage Users') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => ManageUsersScreen()),
//           );
//         } else if (title == 'Manage Services') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => ManageServices()),
//           );
//         } else if (title == 'Manage Bookings') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => BookingManagement()),
//           );
//         } else if (title == 'Manage Vendors') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => VendorList()),
//           );
//         }
//       },
//       child: Container(
//         width: width,
//         height: width,
//         decoration: BoxDecoration(
//           color: const Color(0xFFD2F1E4),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Center(
//           child: Text(
//             title,
//             style: const TextStyle(
//                 color: Colors.black, fontWeight: FontWeight.bold),
//             textAlign: TextAlign.center,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchBar(double screenWidth) {
//     return SizedBox(
//       width: screenWidth * 0.9,
//       child: TextField(
//         decoration: InputDecoration(
//           hintText: 'Search',
//           suffixIcon: const Icon(
//             Icons.search,
//             size: 25,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCard({required Widget content}) {
//     return Card(
//       color: const Color(0xFFD2F1E4),
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: content,
//       ),
//     );
//   }

//   Widget _buildMetricRow(String label) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         children: [
//           const SizedBox(width: 12),
//           Text(
//             label,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//           ),
//           // Add any additional widgets or styling here
//         ],
//       ),
//     );
//   }
//  Widget _buildAlertsAndNotifications(double screenWidth) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Alerts and Notifications',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               TextButton(
//                 onPressed: () {},
//                 child: const Text('View All'),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         _buildCard(
//           content: const Row(
//             children: [
//               SizedBox(width: 16),
//               Expanded(
//                 child: Text(
//                   'Alerts and notifications content goes here...',
//                   style: TextStyle(fontSize: 16),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTopBar(BuildContext context, double screenHeight) {
//     return Container(
//       height: screenHeight * 0.1,
//       decoration: const BoxDecoration(
//         color: Color(0xFFD2F1E4),
//         borderRadius: BorderRadius.only(
//           bottomRight: Radius.circular(50),
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Container(
//               width: screenHeight * 0.070,
//               height: screenHeight * 0.070,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.rectangle,
//                 borderRadius: BorderRadius.circular(8),
//                 image: const DecorationImage(
//                   image: AssetImage('assets/medapplogo.jpg'),
//                   fit: BoxFit.fill,
//                 ),
//               ),
//             ),
//             Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(
//                     Icons.notifications,
//                     size: 28,
//                   ),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => NotificationScreen()),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




