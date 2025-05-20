import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_admin/provider/serviceengineersprovider.dart';
import 'package:gomed_admin/provider/servicesproviders.dart';
import 'package:gomed_admin/widgets/topbar.dart';
import 'package:gomed_admin/screens/service_management/add_service.dart';
import "package:gomed_admin/models/serviceengineers.dart";
import 'package:intl/intl.dart';
import 'package:gomed_admin/models/services.dart' as service_model;

class ManageServices extends ConsumerStatefulWidget {
  @override
  ConsumerState<ManageServices> createState() => _ManageServicesState();
}

class _ManageServicesState extends ConsumerState<ManageServices> {

    String searchQuery = '';
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(serviceEngineerProvider.notifier).getUsers());
    Future.microtask(() => ref.read(serviceprovider.notifier).getSevices());
  }

  @override
  Widget build(BuildContext context) {
    final engineers = ref.watch(serviceEngineerProvider).data ?? [];
    final services = ref.watch(serviceprovider).data ?? [];

    
  // 🟢 FILTER ENGINEERS by search query
final filteredEngineers = engineers.where((engineer) {
  return (engineer.name?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
         (engineer.email?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
}).toList();

     final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            TopBar(title: 'Manage Services Eng', onBackPressed: () => Navigator.pop(context)),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by username or email',
                  suffixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (query) {
                  setState(() {
                    searchQuery = query;
                  });
                },
              ),
            ),

            // Title + Add Service Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ServiceEngineer list', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AddServiceScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 193, 234, 205), // Button Color
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                    child: const Text("Add Engineer", style: TextStyle(color: Colors.black, fontSize: 14)),
                  ),
                ],
              ),
            ),

            // Service Engineers List
            Expanded(
                        child:filteredEngineers.isEmpty && searchQuery.isNotEmpty
                ? const Center(
                    child: Text('No engineers found',
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                  )
                :  ListView.builder(
                itemCount:filteredEngineers.length,
                itemBuilder: (context, index) {
                  final engineer = filteredEngineers[index];
                  final engineerServices = engineer.serviceIds?.map((id) {
                    return services.firstWhere((s) => s.sId == id, orElse: () => service_model.Data(name: 'Unknown')).name;
                  }).toList() ?? [];

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    child: ListTile(
                      title: Text(engineer.name ?? 'No Name', style:const TextStyle(fontWeight: FontWeight.bold, fontSize: 18,)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(engineer.email ?? 'No Email'),
                          Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(engineer.createdAt ?? 'No Date'))),
                          Text(
                                  engineer.status?.toLowerCase() == 'active' ? "Active" : "Inactive",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: engineer.status?.toLowerCase() == 'active' ? Colors.green : Colors.red,
                                    fontSize: 18, // Font size relative to screen height
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.pushNamed(
                            context,
                            'addsevicescreen',  // Ensure the route name matches
                            arguments: {
                              'type': "edit",
                              'name': engineer.name ?? '',
                              'email': engineer.email ?? '',
                              'mobile': engineer.mobile ?? '',
                              'description': engineer.description ?? '',
                              'experience': engineer.experience ?? '',
                              'serviceIds': engineer.serviceIds ?? [],  // Pass selected service IDs
                              'dutyTimings': engineer.dutyTimings ?? [],
                              'status': engineer.status?.toLowerCase() == 'active',
                              'engineerId': engineer.sId ?? ''
                            },
                          );
                        }
                        if (value == 'delete') {
                          _showDeleteConfirmationDialog(context, engineer.sId!);
                        };
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),

                      onTap: () => _showEngineerDetails(engineer, engineerServices),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Popup to show full details
  void _showEngineerDetails(Data engineer, List<String?> services) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(engineer.name ?? 'No Name'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Email: ${engineer.email}"),
              Text("Mobile: ${engineer.mobile}"),
              Text("Experience: ${engineer.experience} years"),
              Text("Status: ${engineer.status}"),
              Text("Duty Timings: ${engineer.dutyTimings?.join(', ') ?? 'N/A'}"),
              Text("Description:${engineer.description}"),
              Text("Services: ${services.join(', ')}"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Close')),
        ],
      ),
    );
  }


  void _showDeleteConfirmationDialog(BuildContext context, String engineerId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this service engineer?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              bool success = await ref.read(serviceEngineerProvider.notifier).deleteServiceEngineer(engineerId);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Service Engineer deleted successfully!")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to delete service engineer!")),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

}













// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gomedserv/provider/serviceengineersprovider.dart';
// import 'package:gomedserv/provider/servicesproviders.dart';
// import 'package:gomedserv/widgets/bottomnavigation.dart';
// import 'package:gomedserv/screens/service_management/add_service.dart';
// import 'package:gomedserv/widgets/topbar.dart';
// import 'package:gomedserv/models/manage_users_model.dart';

// class ManageServices extends ConsumerStatefulWidget {
//   @override
//   ConsumerState<ManageServices> createState() => _ManageServicesState();
// }

// class _ManageServicesState extends ConsumerState<ManageServices> {
//   String searchQuery = '';

//      @override
//   void initState() {
//     super.initState();
//     Future.microtask(()=>ref.read(serviceEngineerProvider.notifier).getUsers());
//     Future.microtask(()=>ref.read(serviceprovider.notifier).getSevices());
//     print('services engineers excuteded...........');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final paddingScale = screenWidth * 0.04; // Example: 4% of screen width
//     final spacingScale = screenHeight * 0.01; // Example: 2% of screen height
//     final buttonHeight = screenHeight * 0.06; // Example: 6% of screen height

//     final filteredUsers = usersData
//         .where((user) =>
//             user.username?.toLowerCase().contains(searchQuery.toLowerCase()) ??
//             false)
//         .toList();

//     return SafeArea(
//       child: Scaffold(
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               TopBar(
//                 title: 'Manage Services',
//                 onBackPressed: () {
//                   Navigator.pop(context);
//                 },
//               ),
//               SizedBox(height: spacingScale),
//               _buildSearchBar(paddingScale),
//               SizedBox(height: spacingScale),
//               _buildUserListRow(context, paddingScale),
//               if (filteredUsers.isEmpty)
//                 Padding(
//                   padding: EdgeInsets.all(paddingScale),
//                   child: Text(
//                     'No users found.',
//                     style: TextStyle(
//                         fontSize: screenWidth * 0.04, color: Colors.grey),
//                   ),
//                 )
//               else
//                 _buildUserList(filteredUsers, screenHeight),
//             ],
//           ),
//         ),
//         // bottomNavigationBar: CustomBottomNavigationBar(
//         //   currentIndex: 0,
//         //   onTap: (index) {
//         //     Navigator.pop(context);
//         //   },
//         // ),
//       ),
//     );
//   }

//   Widget _buildUserListRow(BuildContext context, double paddingScale) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: paddingScale),
//       child: Row(
//         children: [
//           const Text(
//             'Service Catalog',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//          const  Spacer(),
//          ElevatedButton(
//   onPressed: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddServiceScreen(),
//       ),
//     );
//   },
//   style: ElevatedButton.styleFrom(
//     backgroundColor: const Color.fromARGB(255, 193, 234, 205), // Customize color
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(8),
//     ),
//     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//   ),
//   child: const Text(
//     "Add Service",
//     style: TextStyle(color:Colors.black, fontSize: 14),
//   ),
// ),

//           // GestureDetector(
//           //   onTap: () {
//           //     Navigator.push(
//           //       context,
//           //       MaterialPageRoute(
//           //         builder: (context) => AddServiceScreen(),
//           //       ),
//           //     );
//           //   },
//           //   child: const Text(
//           //     "Add Service",
//           //     style: TextStyle(
//           //       decoration: TextDecoration.underline,
//           //     ),
//           //   ),
//           // ),
//           // SizedBox(
//           //     width: paddingScale * 0.4), // Responsive spacing between buttons
//           // GestureDetector(
//           //   onTap: () {},
//           //   child: const Text(
//           //     "Edit",
//           //     style: TextStyle(
//           //       decoration: TextDecoration.underline,
//           //     ),
//           //   ),
//           // ),
//           // SizedBox(
//           //     width: paddingScale * 0.4), // Responsive spacing between buttons
//           // GestureDetector(
//           //   onTap: () {},
//           //   child: const Text(
//           //     "Delete",
//           //     style: TextStyle(
//           //       decoration: TextDecoration.underline,
//           //     ),
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchBar(double paddingScale) {
//     return Padding(
//       padding: EdgeInsets.all(paddingScale),
//       child: TextField(
//         onChanged: (query) {
//           setState(() {
//             searchQuery = query;
//           });
//         },
//         decoration: InputDecoration(
//           hintText: 'Search by username or email',
//           suffixIcon: const Icon(
//             Icons.search,
//             size: 25,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserList(List<User> users, double screenHeight) {
//     return Container(
//       height: screenHeight *
//           0.6, // Adjust the height as per your need (e.g., 70% of screen height)
//       child: ListView.builder(
//         padding: EdgeInsets.zero,
//         itemCount: users.length,
//         itemBuilder: (context, index) {
//           final user = users[index];
//           return Card(
//             color: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8.0),
//             ),
//             elevation: 4,
//             margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
//             child: ListTile(
//               title: Text(
//                 "${user.username ?? "No Name"}",
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: screenHeight *
//                       0.025, // Font size relative to screen height
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "${user.email ?? "No Email"}",
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                   Text(
//                     "${user.date ?? "No Date"}",
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: screenHeight *
//                           0.02, // Font size relative to screen height
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               trailing: Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     "${user.status ?? "Active"}",
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                     style: TextStyle(
//                       color:
//                           user.status == 'Active' ? Colors.green : Colors.red,
//                       fontSize: screenHeight *
//                           0.02, // Font size relative to screen height
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => AddServiceScreen()),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }


