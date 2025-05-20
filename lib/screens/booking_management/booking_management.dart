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
                             return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(service.name ?? '-', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(service.details ?? '', style: const TextStyle(color: Colors.grey)),
                                    const SizedBox(height: 8),
                                    if (isAssigned) ...[
                                      Text(
                                        'Assigned to: ${assignedEngineer?.name ?? 'Unknown'}',
                                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton(
                                          onPressed: () => _showAssignPopup(context, booking.sId ?? '', engineers),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text('Re-Assign', style: TextStyle(color: Colors.white)),
                                        ),
                                      ),
                                    ] else
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton(
                                          onPressed: () => _showAssignPopup(context, booking.sId ?? '', engineers),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color.fromARGB(255, 63, 149, 117),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text('Assign', style: TextStyle(color: Colors.white)),
                                        ),
                                      ),
                                  ],
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
// import 'package:gomed_admin/models/bookingServices.dart' as booking;
// import 'package:gomed_admin/provider/bookingServicesprovider.dart';
// import 'package:gomed_admin/provider/serviceengineersprovider.dart';
// import 'package:gomed_admin/screens/notification_screen.dart';
// import 'package:gomed_admin/widgets/topbar.dart';
// import "package:gomed_admin/models/serviceengineers.dart" as engineer ;
// class BookingManagement extends ConsumerStatefulWidget {
//   const BookingManagement({super.key});

//   @override
//   ConsumerState<BookingManagement> createState() => _BookingManagementState();
// }

// class _BookingManagementState extends ConsumerState<BookingManagement> {
//   String searchQuery = '';
//   String? selectedEngineerId;

//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       ref.read(bookingserviceProvider.notifier).getBookingServices();
//       ref.read(serviceEngineerProvider.notifier).getUsers();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bookings = ref.watch(bookingserviceProvider).data ?? [];
//     final engineers = ref.watch(serviceEngineerProvider).data ?? [];

//     final filteredBookings = bookings.where((booking) {
//       return (booking.serviceIds??[]).any((service) =>
//           service.name?.toLowerCase().contains(searchQuery.toLowerCase()) ??
//           false);
//     }).toList();

//     final double screenWidth = MediaQuery.of(context).size.width;
//     final double screenHeight = MediaQuery.of(context).size.height;

//     final double paddingHorizontal = screenWidth * 0.02;
//     final double searchBarHeight = screenHeight * 0.08;

//     return SafeArea(
//       child: Scaffold(
//         appBar: PreferredSize(
//               preferredSize: Size.fromHeight(80),
//               child: TopBar(title: 'Booking Management', onBackPressed: () => Navigator.pop(context)),
//             ),
//         body: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Column(
//             children: [
              
//               _buildSearchBar(paddingHorizontal, searchBarHeight),
//               const SizedBox(height: 10),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: filteredBookings.length,
//                   itemBuilder: (context, index) {
//                     final booking = filteredBookings[index];
//                     final user = booking.userId;
      
//                     return Card(
//                       color: Colors.white,
//                       elevation: 4,
//                       margin: const EdgeInsets.symmetric(vertical: 8),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(user?.name ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
//                             Text(user?.email ?? '-'),
//                             const Divider(),
//                             ...(booking.serviceIds??[]).map((service) {
//                              final isAssigned = booking.serviceEngineerId != null && booking.serviceEngineerId!.isNotEmpty;
       
//                                 // Find the engineer name if assigned
//                               final assignedEngineer = isAssigned
//                                   ? engineers.firstWhere(
//                                       (eng) => eng.sId == booking.serviceEngineerId,
//                                       orElse: () => engineer.Data.initial(),
//                                     )
//                                   : null;
//                               return ListTile(
//                                 title: Text(service.name ?? '-'),
//                                 subtitle: Text(service.details ?? ''),
//                                 trailing:isAssigned
//                                     ? Text(
//                                         'Assigned to: ${assignedEngineer?.name ?? 'Unknown'}',
//                                         style: const TextStyle(
//                                           color: Colors.green,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       )
//                                     : ElevatedButton(
//                                   onPressed: () => _showAssignPopup(context, booking.sId ?? '', engineers),
                                  
//                                    style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color.fromARGB(255, 63, 149, 117), // Nice green background
//                                   foregroundColor: Colors.white,            // Text/icon color
//                                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                                 child: const Text('Assign',style: TextStyle(color: Colors.white),),
//                                 ),
//                               );
//                             }).toList(),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//    Widget _buildSearchBar(double paddingHorizontal, double searchBarHeight) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
//       child: SizedBox(
//         height: searchBarHeight,
//         child: TextField(
//           onChanged: (value) => setState(() => searchQuery = value),
//           decoration: InputDecoration(
//             hintText: 'Search by servicename',
//             prefixIcon: const Icon(Icons.search),
//             filled: true,
//             fillColor: Colors.white,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               // borderSide: BorderSide.none,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showAssignPopup(BuildContext context, String serviceId, List<dynamic> engineers) {
//     String engineerSearch = '';
//     List<dynamic> filteredEngineers = engineers;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (ctx) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     onChanged: (value) {
//                       setState(() {
//                         engineerSearch = value;
//                         filteredEngineers = engineers.where((e) =>
//                             e.name.toLowerCase().contains(engineerSearch.toLowerCase())).toList();
//                       });
//                     },
//                     decoration: InputDecoration(
//                       hintText: 'Search engineer',
//                       prefixIcon: const Icon(Icons.search),
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   SizedBox(
//                     height: 250,
//                     child: ListView.builder(
//                       itemCount: filteredEngineers.length,
//                       itemBuilder: (context, index) {
//                         final engineer = filteredEngineers[index];
//                         return RadioListTile(
//                           value: engineer.sId,
//                           groupValue: selectedEngineerId,
//                           onChanged: (value) => setState(() => selectedEngineerId = value),
//                           title: Text(engineer.name ?? ''),
//                         );
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   ElevatedButton(
//                     onPressed: () async {
//                             final isSuccess = await ref
//                                 .read(bookingserviceProvider.notifier)
//                                 .updateServiceBookinglist(context, serviceId, selectedEngineerId);

//                             Navigator.pop(context);

//                             if (isSuccess) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text("✅ Service assigned successfully!"),
//                                   backgroundColor: Colors.green,
//                                 ),
//                               );
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text("❌ Failed to assign service. Please try again."),
//                                   backgroundColor: Colors.red,
//                                 ),
//                               );
//                             }
//                           },

//                     child: const Text("Book Assign"),
//                   )
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }