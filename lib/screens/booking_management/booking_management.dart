import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_admin/models/bookingServices.dart' as booking;
import 'package:gomed_admin/provider/bookingServicesprovider.dart';
import 'package:gomed_admin/provider/serviceengineersprovider.dart';
import 'package:gomed_admin/screens/notification_screen.dart';
import 'package:gomed_admin/widgets/topbar.dart';
import "package:gomed_admin/models/serviceengineers.dart" as engineer ;
class BookingManagement extends ConsumerStatefulWidget {
  const BookingManagement({super.key});

  @override
  ConsumerState<BookingManagement> createState() => _BookingManagementState();
}

class _BookingManagementState extends ConsumerState<BookingManagement> {
  String searchQuery = '';
  String? selectedEngineerId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(bookingserviceProvider.notifier).getBookingServices();
      ref.read(serviceEngineerProvider.notifier).getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(bookingserviceProvider).data ?? [];
    final engineers = ref.watch(serviceEngineerProvider).data ?? [];

    final filteredBookings = bookings.where((booking) {
      return (booking.serviceIds??[]).any((service) =>
          service.name?.toLowerCase().contains(searchQuery.toLowerCase()) ??
          false);
    }).toList();

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final double paddingHorizontal = screenWidth * 0.02;
    final double searchBarHeight = screenHeight * 0.08;

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
              preferredSize: Size.fromHeight(80),
              child: TopBar(title: 'Booking Management', onBackPressed: () => Navigator.pop(context)),
            ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // TopBar(
              //   title: 'Booking Management',
              //   onBackPressed: () {
              //     Navigator.pop(context);
              //   },
              // ),
              // TextField(
              //   decoration: const InputDecoration(
              //     hintText: 'Search by service name',
              //     prefixIcon: Icon(Icons.search),
              //   ),
              //   onChanged: (value) => setState(() => searchQuery = value),
              // ),
              _buildSearchBar(paddingHorizontal, searchBarHeight),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) {
                    final booking = filteredBookings[index];
                    final user = booking.userId;
      
                    return Card(
                      color: Colors.white,
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.name ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(user?.email ?? '-'),
                            const Divider(),
                            ...(booking.serviceIds??[]).map((service) {
                             final isAssigned = booking.serviceEngineerId != null && booking.serviceEngineerId!.isNotEmpty;
       
                                // Find the engineer name if assigned
                              final assignedEngineer = isAssigned
                                  ? engineers.firstWhere(
                                      (eng) => eng.sId == booking.serviceEngineerId,
                                      orElse: () => engineer.Data.initial(),
                                    )
                                  : null;
                              return ListTile(
                                title: Text(service.name ?? '-'),
                                subtitle: Text(service.details ?? ''),
                                trailing:isAssigned
                                    ? Text(
                                        'Assigned to: ${assignedEngineer?.name ?? 'Unknown'}',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    : ElevatedButton(
                                  onPressed: () => _showAssignPopup(context, booking.sId ?? '', engineers),
                                  
                                   style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 63, 149, 117), // Nice green background
                                  foregroundColor: Colors.white,            // Text/icon color
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Assign',style: TextStyle(color: Colors.white),),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

   Widget _buildSearchBar(double paddingHorizontal, double searchBarHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
      child: SizedBox(
        height: searchBarHeight,
        child: TextField(
          onChanged: (value) => setState(() => searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search by servicename',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              // borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  void _showAssignPopup(BuildContext context, String serviceId, List<dynamic> engineers) {
    String engineerSearch = '';
    List<dynamic> filteredEngineers = engineers;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        engineerSearch = value;
                        filteredEngineers = engineers.where((e) =>
                            e.name.toLowerCase().contains(engineerSearch.toLowerCase())).toList();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search engineer',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 250,
                    child: ListView.builder(
                      itemCount: filteredEngineers.length,
                      itemBuilder: (context, index) {
                        final engineer = filteredEngineers[index];
                        return RadioListTile(
                          value: engineer.sId,
                          groupValue: selectedEngineerId,
                          onChanged: (value) => setState(() => selectedEngineerId = value),
                          title: Text(engineer.name ?? ''),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                            final isSuccess = await ref
                                .read(bookingserviceProvider.notifier)
                                .updateServiceBookinglist(context, serviceId, selectedEngineerId);

                            Navigator.pop(context);

                            if (isSuccess) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("✅ Service assigned successfully!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("❌ Failed to assign service. Please try again."),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },

                    child: const Text("Book Assign"),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gomedserv/provider/bookingServicesprovider.dart';
// import 'package:gomedserv/provider/serviceengineersprovider.dart';
// import 'package:gomedserv/screens/booking_management/add_commission.dart';
// import 'package:gomedserv/widgets/topbar.dart';
// import 'package:gomedserv/models/manage_users_model.dart';

// class BookingManagement extends ConsumerStatefulWidget {
//   const BookingManagement({super.key});

//   @override
//   ConsumerState<BookingManagement> createState() => _BookingManagementState();
// }


// class _BookingManagementState extends ConsumerState<BookingManagement> {
//   String searchQuery = '';

//    @override
//    void initState() {
//     super.initState();
//     Future.microtask(() => ref.read(bookingserviceProvider.notifier).getBookingServices());
//   }

//   @override
//   Widget build(BuildContext context) {
//     final servicebookingdata=ref.watch(bookingserviceProvider).data??[];
//     final serviceenginerlist =ref.watch(serviceEngineerProvider).data??[];
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final double screenHeight = MediaQuery.of(context).size.height;

//     // Define padding and height based on screen dimensions
//     final double paddingHorizontal = screenWidth * 0.04; // 4% of screen width
//     final double topBarHeight = screenHeight * 0.07; // 7% of screen height
//     final double searchBarHeight = screenHeight * 0.06; // 6% of screen height
//     final double listHeight = screenHeight * 0.6; // 60% of screen height

//     final filteredUsers = servicebookingdata
//         .where((user) =>
//             user.serviceIds[0]?.name().contains(searchQuery.toLowerCase()) ??
//             false)
//         .toList();

//     return SafeArea(
//       child: Scaffold(
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               TopBar(
//                 title: 'Booking Management',
//                 onBackPressed: () {
//                   Navigator.pop(context);
//                 },
//               ),
//               SizedBox(height: screenHeight * 0.01), // 1% of screen height
//               _buildSearchBar(paddingHorizontal, searchBarHeight),
//               SizedBox(height: screenHeight * 0.01), // 1% of screen height
//               _buildUserListRow(context, paddingHorizontal),
//               if (filteredUsers.isEmpty)
//                 Padding(
//                   padding:
//                       EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
//                   child: Text(
//                     'No users found.',
//                     style: TextStyle(
//                         fontSize: screenHeight * 0.02, color: Colors.grey),
//                   ),
//                 )
//               else
//                 _buildUserList(filteredUsers, listHeight),
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

//   Widget _buildUserListRow(BuildContext context, double paddingHorizontal) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
//       child:const  Row(
//         children: [
//           Text(
//             'Booking Overview',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
          
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchBar(double paddingHorizontal, double searchBarHeight) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
//       child: SizedBox(
//         height: searchBarHeight,
//         child: TextField(
//           onChanged: (query) {
//             setState(() {
//               searchQuery = query;
//             });
//           },
//           decoration: InputDecoration(
//             hintText: 'Search by username or email',
//             suffixIcon: const Icon(
//               Icons.search,
//               size: 25,
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserList(List<User> users, double listHeight) {
//     return SizedBox(
//       height: listHeight,
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
//             margin: EdgeInsets.symmetric(
//               vertical: listHeight * 0.01, // 1% of list height
//               horizontal: listHeight * 0.02, // 2% of list height
//             ),
//             child: ListTile(
//               title: Text(
//                 "${user.username ?? "No Name"}",
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: listHeight * 0.03, // Adjust based on list height
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
//                     style: TextStyle(
//                       fontSize:
//                           listHeight * 0.02, // Adjust based on list height
//                     ),
//                   ),
//                   Text(
//                     "${user.date ?? "No Date"}",
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize:
//                           listHeight * 0.02, // Adjust based on list height
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
//                       fontSize:
//                           listHeight * 0.02, // Adjust based on list height
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => AddCommission()),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
