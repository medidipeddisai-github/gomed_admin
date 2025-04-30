// import 'package:flutter/material.dart';

// class LoginScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // Get the screen width
//     double screenWidth = MediaQuery.of(context).size.width;

//     return Stack(
//       children: [
//         Align(
//           alignment: Alignment.bottomCenter,
//           child: Container(
//             width: double.infinity, // Full width
//             height: MediaQuery.of(context).size.height *
//                 0.65, // Adjust this as needed
//             decoration: BoxDecoration(
//               color: Color(0xFFD2F1E4), // Container background color
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(
//                     screenWidth * 0.7), // Scaled top-left radius
//               ),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Container(
//                 margin: EdgeInsets.only(left: 30),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   // Center alignment for all widgets
//                   children: [
//                     // Uncomment the logo if you have the correct asset path
//                     // Align(
//                     //   alignment: Alignment.topCenter,
//                     //   child: Image.asset(
//                     //     'assets/logo.png', // Replace with your logo asset
//                     //     height: 60,
//                     //   ),
//                     // ),
//                     // SizedBox(height: 20.0),
//                     Container(
//                       width: MediaQuery.of(context).size.width * 0.70,
//                       child: Column(
//                         children: [
//                           Align(
//                             alignment: Alignment.topLeft,
//                             child: Text(
//                               'Phone Number',
//                               style: TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 5.0),

//                           // Phone Number Field
//                           Container(
//                             width: screenWidth *
//                                 0.8, // Adjust width of the TextFormField
//                             child: TextFormField(
//                               decoration: InputDecoration(
//                                 fillColor: Colors.white,
//                                 filled: true,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(
//                                       8.0), // Rounded corners
//                                   borderSide: BorderSide.none,
//                                 ),
//                               ),
//                               keyboardType: TextInputType.phone,
//                             ),
//                           ),
//                           SizedBox(height: 20.0),

//                           Align(
//                             alignment: Alignment.topLeft,
//                             child: Text(
//                               'OTP',
//                               style: TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 5.0),

//                           Container(
//                             width: screenWidth * 0.8,
//                             child: Row(
//                               // Center align row contents
//                               children: [
//                                 Flexible(
//                                   flex:
//                                       2, // Take up more space for the text field
//                                   child: Container(
//                                     width: screenWidth *
//                                         0.5, // Adjust width of the OTP TextFormField
//                                     child: TextFormField(
//                                       decoration: InputDecoration(
//                                         fillColor: Colors.white,
//                                         filled: true,
//                                         border: OutlineInputBorder(
//                                           borderRadius: BorderRadius.circular(
//                                               8.0), // Rounded corners
//                                           borderSide: BorderSide.none,
//                                         ),
//                                       ),
//                                       keyboardType: TextInputType.number,
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(width: 10.0),
//                                 Flexible(
//                                   flex: 1, // Take up less space for the button
//                                   child: ElevatedButton(
//                                     onPressed: () {
//                                       // OTP verification logic
//                                     },
//                                     child: Text(
//                                       'Verify',
//                                       style: TextStyle(
//                                           color: Colors
//                                               .white), // Button text color set to white
//                                     ),
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.teal,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(
//                                             8.0), // Rounded button corners
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 20.0),

//                           // Login Button
//                           Container(
//                             width: screenWidth *
//                                 0.8, // Adjust width of the Login button
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 // Login logic
//                               },
//                               child: Text(
//                                 'Login',
//                                 style: TextStyle(
//                                     color: Colors
//                                         .white), // Button text color set to white
//                               ),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.teal,
//                                 minimumSize: Size(double.infinity,
//                                     50), // Make button full-width of container
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(
//                                       8.0), // Rounded button corners
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 20.0),

//                           // Additional Links

//                           SizedBox(height: 10.0),

//                           GestureDetector(
//                             onTap: () {
//                               // Handle "Have trouble?" action
//                             },
//                             child: Text(
//                               'Have trouble? click here',
//                               style: TextStyle(
//                                 color: Colors.teal,
//                                 decoration: TextDecoration.underline,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
// //  routes: {
//         "loginscreen": (context) => LoginScreen(),
//         "analyticsreport": (context) => AnalyticsReportsScreen(),
//         "addcommission": (context) => AddCommission(),
//         "bookingmanagement": (context) => BookingManagement(),
//         "mangescreen": (context) => ManageScreen(),
//         // "userprofilrscreen": (context) => UserProfileScreen(),
//         "addvendor": (context) => AddVendor(),
//         "vendorlist": (context) => VendorList(),
//         "dashboardscreen": (context) => DashboardScreen(),
        
//         "notificationsettings": (context) => NotificationSettings(),
//         "settingsscreen": (context) => SettingsScreen(),
//         // "paymentscreen":(context)=>const PaymentScreen(),
//         "addsevicescreen":(context)=>AddServiceScreen (),
//         "manageservices":(context)=>ManageServices (),
//         "manageusersscreen":(context)=>ManageUsersScreen (),
        
        

// //       },
// import 'package:flutter/material.dart';
// import 'package:gomedserv/screens/login_screen.dart';
// import 'package:gomedserv/screens/dashboard_screen.dart';
// import 'package:gomedserv/screens/analytics/analytics.dart';
// import 'package:gomedserv/screens/booking_management/add_commission.dart';
// import 'package:gomedserv/screens/booking_management/booking_management.dart';
// import 'package:gomedserv/screens/financial_management/manage_screen.dart';


// import 'package:gomedserv/screens/financial_management/payment_screen.dart';
// import 'package:gomedserv/screens/service_management/add_service.dart';
// import 'package:gomedserv/screens/service_management/manage_services.dart';
// import 'package:gomedserv/screens/user_management/manageusers_screen.dart';
// import 'package:gomedserv/screens/user_management/user_profile.dart';
// import 'package:gomedserv/screens/vendor_management/add_vendor.dart';
// import 'package:gomedserv/screens/vendor_management/vendor_list.dart';
// import 'package:gomedserv/screens/notification_screen.dart';
// import 'package:gomedserv/screens/notification_settings.dart';
// import 'package:gomedserv/screens/settings_screen.dart';