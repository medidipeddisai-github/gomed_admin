import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_admin/models/distributors.dart';
import 'package:gomed_admin/provider/adminApprovedProvider.dart';
import 'package:gomed_admin/provider/distributorprovider.dart';
import 'package:gomed_admin/provider/productslist.dart';
import 'package:gomed_admin/provider/serviceslistprovider.dart';
import 'package:gomed_admin/widgets/topbar.dart';
import 'package:gomed_admin/models/manage_users_model.dart';
import 'package:intl/intl.dart';

class VendorList extends ConsumerStatefulWidget {
  @override
  ConsumerState<VendorList> createState() => _VendorListState();
}

class _VendorListState extends ConsumerState<VendorList> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(distributorProvider.notifier).getUsers());
    Future.microtask(() => ref.read(adminApprovedProductsProvider.notifier).getAdminApprovedProducts());
    // Future.microtask(() => ref.read(servicelistProvider.notifier).getservicesList());
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(distributorProvider);
    final distributors = usersState.data ?? [];
    final productlist = ref.watch(productlistProvider).data??[];
    final serviceslist =ref.watch(servicelistProvider).data??[];
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double userListHeight = screenHeight * 0.6;

    final filteredUsers = distributors.where((user) {
      return (user.name?.toLowerCase().contains(searchQuery.toLowerCase()) ??
              false) ||
          (user.email?.toLowerCase().contains(searchQuery.toLowerCase()) ??
              false);
    }).toList();

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            TopBar(
              title: 'Vendor List',
              onBackPressed: () => Navigator.pop(context),
            ),
            _buildSearchBar(),
            _buildUserListRow(),
            Expanded(
              child: filteredUsers.isEmpty
                  ? const Center(
                      child: Text('No vendors found',
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                    )
                  : _buildUserList(filteredUsers),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildUserListRow() {
  return const Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Distributors List',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (query) {
          setState(() {
            searchQuery = query;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search by name or email',
          prefixIcon: const Icon(Icons.search, size: 25),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

Widget _buildUserList(List<Data> distributors) {
  return ListView.builder(
    padding: const EdgeInsets.all(8.0),
    itemCount: distributors.length,
    itemBuilder: (context, index) {
      final distributor = distributors[index];
      bool isActive = distributor.status == "Active";

      return GestureDetector(
        onTap: () => _showDistributorDetails(context, distributor),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(12.0), // Padding to prevent overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row with Distributor Name and Switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        distributor.name ?? "No Name",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Switch(
                          value: isActive,
                          onChanged: (value) {
                            _showStatusChangeDialog(context, distributor.sId!, value);
                          },
                          activeColor: Colors.green,
                          inactiveTrackColor: Colors.grey,
                        ),
                        Text(
                          distributor.status ?? "Active",
                          style: TextStyle(
                            color: isActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Email
                Text(distributor.email ?? "No Email"),

                const SizedBox(height: 4),

                // Date
                Text(
                  DateFormat('dd/MM/yyyy').format(DateTime.parse(distributor.createdAt ?? 'No Date')),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                // Products & Services Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showProductsOnlyDialog(context, distributor.sId!),
                      icon: const Icon(Icons.shopping_cart, size: 18),
                      label: const Text("Products"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 63, 149, 117),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showSparePartsOnlyDialog(context, distributor.sId!),
                      icon: const Icon(Icons.miscellaneous_services, size: 18),
                      label: const Text("Spare parts"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 63, 149, 117),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}


  void _showStatusChangeDialog(BuildContext context, String distributorId, bool newStatus) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(newStatus ? "Activate Distributor" : "Deactivate Distributor"),
        content: Text(
          newStatus
              ? "Do you want to activate this distributor?"
              : "Do you want to deactivate this distributor?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel action
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              _updateDistributorStatus(context, distributorId, newStatus); // Call API
            },
            child: Text(newStatus ? "Activate" : "Deactivate",
                style: TextStyle(color: newStatus ? Colors.green : Colors.red)),
          ),
        ],
      );
    },
  );
}

Future<void> _updateDistributorStatus(BuildContext context, String distributorId, bool newStatus) async {
  final provider = ref.read(distributorProvider.notifier);
  bool success = await provider.updateDistributorStatus(distributorId, newStatus);

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Distributor ${newStatus ? "Activated" : "Deactivated"} Successfully!"),
        backgroundColor: newStatus ? Colors.green : Colors.red,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Failed to update distributor status."),
        backgroundColor: Colors.red,
      ),
    );
  }
}



  void _showDistributorDetails(BuildContext context, Data distributor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(distributor.name ?? "Vendor Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("name:${distributor.name}"),
              Text("Mobile: ${distributor.mobile ?? "-"}"),
              Text("Firm Name: ${distributor.firmName ?? "-"}"),
              Text("GST Number: ${distributor.gstNumber ?? "-"}"),
              Text("Email: ${distributor.email ?? "-"}"),
              Text("Address: ${distributor.address ?? "-"}"),
              
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
  void _showProductsOnlyDialog(BuildContext context, String distributorId) {
  final allItems = ref.read(adminApprovedProductsProvider).data ?? [];
  final products = allItems.where((item) => item.distributorId == distributorId && item.parentId == null).toList();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Products"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              title: Text(product.productName ?? "-"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Description: ${product.productDescription ?? '-'}"),
                  Text("Price: ₹${product.price ?? 0}"),
                  Text("Quantity: ${product.quantity ?? 0}"),
                  Text("Status: ${product.adminApproval ?? '-'}", style: TextStyle(
                    color: product.adminApproval == 'accepted'
                        ? Colors.green
                        : product.adminApproval == 'rejected'
                            ? Colors.red
                            : Colors.orange,
                  )),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    ),
  );
}

void _showSparePartsOnlyDialog(BuildContext context, String distributorId) {
  final allItems = ref.read(adminApprovedProductsProvider).data ?? [];

  final spareParts = allItems.where((item) =>
    item.distributorId == distributorId && item.parentId != null).toList();

  final Map<String, String?> productNamesById = {
    for (var item in allItems) if (item.parentId == null) item.productId!: item.productName
  };

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Spare Parts"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: spareParts.length,
          itemBuilder: (context, index) {
            final sparePart = spareParts[index];
            final parentName = productNamesById[sparePart.parentId ?? ""] ?? "Unknown";

            return ListTile(
              title: Text(sparePart.productName ?? "-"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Spare Part of: $parentName"),
                  Text("Description: ${sparePart.productDescription ?? '-'}"),
                  Text("Price: ₹${sparePart.price ?? 0}"),
                  Text("Quantity: ${sparePart.quantity ?? 0}"),
                  Text("Status: ${sparePart.adminApproval ?? '-'}", style: TextStyle(
                    color: sparePart.adminApproval == 'accepted'
                        ? Colors.green
                        : sparePart.adminApproval == 'rejected'
                            ? Colors.red
                            : Colors.orange,
                  )),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    ),
  );
}


  void _showProductsDialog(BuildContext context, String distributorId) {
  final allProducts = ref.read(productlistProvider).data ?? [];
  final filteredProducts = allProducts.where((p) => p.distributorId == distributorId).toList();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Products"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            return Card(
              child: ListTile(
                title: Text(product.productName ?? "-"),
                subtitle: Text(product.productDescription ?? "-"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                          value: product.activated ?? false,
                          onChanged: (val) async {
                            final action = val ? "activate" : "deactivate";

                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Confirm"),
                                content: Text("Do you want to $action the product?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text("Yes"),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await ref.read(productlistProvider.notifier).updateproductlist(
                                context,
                                product.productId,
                                val,
                              );
                            }
                          },
                        ),

                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                         _showConfirmationDialog(
                            context,
                            'Delete',
                            'Are you sure you want to delete this service?',
                            () {
                              ref.read(productlistProvider.notifier).deleteProduct(product.productId);
                            },
                          );
                      },
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    ),
  );
}

void _showServicesDialog(BuildContext context, String distributorId) {
  final allServices = ref.read(servicelistProvider).data ?? [];
  final filteredServices = allServices.where((s) => s.distributorId == distributorId).toList();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Services"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: filteredServices.length,
          itemBuilder: (context, index) {
            final service = filteredServices[index];
            return Card(
              child: ListTile(
                title: Text(service.name ?? "-"),
                subtitle: Text(service.details ?? "-"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: service.activated ?? false,
                      onChanged: (val) async{
                         final action = val ? "activate" : "deactivate";

                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Confirm"),
                                content: Text("Do you want to $action the service?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text("Yes"),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await ref.read(servicelistProvider.notifier).updatservicelist(
                                context,
                                service.sId,
                                val,
                              );
                            }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                          _showConfirmationDialog(
                            context,
                            'Delete',
                            'Are you sure you want to delete this service?',
                            () {
                              ref.read(servicelistProvider.notifier).deleteService(service.sId);
                            },
                          );
                      },
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    ),
  );
}

void _showConfirmationDialog(BuildContext context, String action, String message, VoidCallback onConfirmed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(action),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirmed();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gomedserv/models/distributors.dart';
// import 'package:gomedserv/provider/distributorprovider.dart';
// import 'package:gomedserv/widgets/topbar.dart';
// import 'package:gomedserv/models/manage_users_model.dart';
// import 'package:intl/intl.dart';

// class VendorList extends ConsumerStatefulWidget {
//   @override
//   ConsumerState<VendorList> createState() => _VendorListState();
// }

// class _VendorListState extends ConsumerState<VendorList> {
//   String searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() => ref.read(distributorProvider.notifier).getUsers());
//   }

//   @override
//   Widget build(BuildContext context) {
//     final usersState = ref.watch(distributorProvider);
//     final distributors = usersState.data ?? [];
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     double userListHeight = screenHeight * 0.6;

//     final filteredUsers = distributors.where((user) {
//       return (user.name?.toLowerCase().contains(searchQuery.toLowerCase()) ??
//               false) ||
//           (user.email?.toLowerCase().contains(searchQuery.toLowerCase()) ??
//               false);
//     }).toList();

//     return SafeArea(
//       child: Scaffold(
//         body: Column(
//           children: [
//             TopBar(
//               title: 'Vendor List',
//               onBackPressed: () => Navigator.pop(context),
//             ),
//             _buildSearchBar(),
//             _buildUserListRow(),
//             Expanded(
//               child: filteredUsers.isEmpty
//                   ? const Center(
//                       child: Text('No vendors found',
//                           style: TextStyle(fontSize: 16, color: Colors.grey)),
//                     )
//                   : _buildUserList(filteredUsers),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//  Widget _buildUserListRow() {
//   return const Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           'Distributors List',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//       ],
//     ),
//   );
// }

//   Widget _buildSearchBar() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: TextField(
//         onChanged: (query) {
//           setState(() {
//             searchQuery = query;
//           });
//         },
//         decoration: InputDecoration(
//           hintText: 'Search by name or email',
//           prefixIcon: const Icon(Icons.search, size: 25),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserList(List<Data> distributors) {
//     return ListView.builder(
//       padding: const EdgeInsets.all(8.0),
//       itemCount: distributors.length,
//       itemBuilder: (context, index) {
//         final distributor = distributors[index];
//         bool isActive = distributor.status == "Active"; // Check status
//         return GestureDetector(
//           onTap: () => _showDistributorDetails(context, distributor),
//           child: Card(
//             color: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10.0),
//             ),
//             elevation: 4,
//             child: ListTile(
//               title: Text(
//                 distributor.name ?? "No Name",
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(distributor.email ?? "No Email"),
//                   // Text(
//                   //   "Created: ${distributor.createdAt?.split('T')[0] ?? "-"}",
//                   //   style: const TextStyle(fontWeight: FontWeight.bold),
//                   // ),
//                   Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(distributor.createdAt ?? 'No Date'))),
//                   Text(
//                 distributor.status ?? "Active",
//                 style: TextStyle(
//                   color: distributor.status == 'Active'
//                       ? Colors.green
//                       : Colors.red,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//                 ],
//               ),
//               trailing: Switch(
//             value: isActive,
//             onChanged: (value) {
//               _showStatusChangeDialog(context, distributor.sId!, value);
//             },
//             activeColor: Colors.green,
//             inactiveTrackColor: Colors.grey,
//           ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _showStatusChangeDialog(BuildContext context, String distributorId, bool newStatus) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text(newStatus ? "Activate Distributor" : "Deactivate Distributor"),
//         content: Text(
//           newStatus
//               ? "Do you want to activate this distributor?"
//               : "Do you want to deactivate this distributor?",
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context), // Cancel action
//             child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context); // Close the dialog
//               _updateDistributorStatus(context, distributorId, newStatus); // Call API
//             },
//             child: Text(newStatus ? "Activate" : "Deactivate",
//                 style: TextStyle(color: newStatus ? Colors.green : Colors.red)),
//           ),
//         ],
//       );
//     },
//   );
// }

// Future<void> _updateDistributorStatus(BuildContext context, String distributorId, bool newStatus) async {

//   final provider = ref.read(distributorProvider.notifier);
//   bool success = await provider.updateDistributorStatus(distributorId, newStatus);

//   if (success) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text("Distributor ${newStatus ? "Activated" : "Deactivated"} Successfully!"),
//         backgroundColor: newStatus ? Colors.green : Colors.red,
//       ),
//     );
//   } else {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text("Failed to update distributor status."),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
// }



//   void _showDistributorDetails(BuildContext context, Data distributor) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(distributor.name ?? "Vendor Details"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("name:${distributor.name}"),
//               Text("Mobile: ${distributor.mobile ?? "-"}"),
//               Text("Firm Name: ${distributor.firmName ?? "-"}"),
//               Text("GST Number: ${distributor.gstNumber ?? "-"}"),
//               Text("Email: ${distributor.email ?? "-"}"),
//               Text("Address: ${distributor.address ?? "-"}"),
              
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Close"),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }








// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gomedserv/provider/distributorprovider.dart';
// import 'package:gomedserv/widgets/bottomnavigation.dart';
// import 'package:gomedserv/screens/vendor_management/add_vendor.dart';
// import 'package:gomedserv/widgets/topbar.dart';
// import 'package:gomedserv/models/manage_users_model.dart';

// class VendorList extends ConsumerStatefulWidget {

//   @override
//   ConsumerState<VendorList> createState() => _VendorListState();
// }

// class _VendorListState extends ConsumerState<VendorList> {
//   String searchQuery = '';

//     @override
//   void initState() {
//     super.initState();
//     Future.microtask(() => ref.read(distributorProvider.notifier).getUsers());
//   }

//   @override
//   Widget build(BuildContext context) {
//      final usersState = ref.watch(distributorProvider);
//     final usersData = usersState.data ?? [];
//     // Get the screen width and height
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;

//     // Define padding and spacing based on screen height
//     double padding = screenHeight * 0.02; // 2% of screen height
//     double spacing = screenHeight * 0.015; // 1.5% of screen height

//     // Define the max height for the user list based on screen height
//     double userListHeight = screenHeight * 0.6; // 50% of screen height

//     // Filter users based on search query
//     final filteredUsers = usersData
//         .where((user) =>
//             user.username?.toLowerCase().contains(searchQuery.toLowerCase()) ??
//             false ||
//                 // user.email?.toLowerCase().contains(searchQuery.toLowerCase()) ??
//                 false)
//         .toList();

//     return SafeArea(
//       child: Scaffold(
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               TopBar(
//                 title: 'Vendor List',
//                 onBackPressed: () {
//                   Navigator.pop(context);
//                 },
//               ),
//               // SizedBox(height: padding),
//               _buildSearchBar(),
//               // SizedBox(height: spacing), // Space between search bar and row
//               _buildUserListRow(context),
//               if (filteredUsers.isEmpty)
//                 Padding(
//                   padding: EdgeInsets.all(padding),
//                   child: Text(
//                     'No users found.',
//                     style: TextStyle(fontSize: 16, color: Colors.grey),
//                   ),
//                 )
//               else
//                 Container(
//                   height: userListHeight,
//                   child: _buildUserList(filteredUsers),
//                 ),
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

//   Widget _buildUserListRow(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(
//           horizontal: 0.02 * MediaQuery.of(context).size.width),
//       child: Row(
//         children: [
//           const Text(
//             'Booking Overview',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           // Spacer(),
//           // GestureDetector(
//           //   onTap: () {
//           //     Navigator.push(
//           //       context,
//           //       MaterialPageRoute(builder: (context) => AddVendor()),
//           //     );
//           //   },
//           //   child: const Text(
//           //     "Add Vendor",
//           //     style: TextStyle(
//           //       decoration: TextDecoration.underline,
//           //     ),
//           //   ),
//           // ),
//           // const SizedBox(width: 10), // Add some spacing between the buttons
//           // GestureDetector(
//           //   onTap: () {},
//           //   child: const Text(
//           //     "Edit",
//           //     style: TextStyle(
//           //       decoration: TextDecoration.underline,
//           //     ),
//           //   ),
//           // ),
//           const SizedBox(width: 10), // Add some spacing between the buttons
//           GestureDetector(
//             onTap: () {},
//             child: const Text(
//               "Approve",
//               style: TextStyle(
//                 decoration: TextDecoration.underline,
//               ),
//             ),
//           ),
//           // const SizedBox(width: 10), // Add some spacing between the buttons
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

//   Widget _buildSearchBar() {
//     return Padding(
//       padding: EdgeInsets.all(0.02 * MediaQuery.of(context).size.height),
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

//   Widget _buildUserList(List<User> users) {
//     return ListView.builder(
//       padding: EdgeInsets.zero,
//       itemCount: users.length,
//       itemBuilder: (context, index) {
//         final user = users[index];
//         return Card(
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//           elevation: 4,
//           child: ListTile(
//             title: Text(
//               "${user.username ?? "No Name"}",
//               style: const TextStyle(
//                 color: Colors.black,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "${user.email ?? "No Email"}",
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                 ),
//                 Text(
//                   "${user.date ?? "No Date"}",
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                   style: const TextStyle(
//                     color: Colors.black,
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             trailing: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   "${user.status ?? "Active"}",
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                   style: TextStyle(
//                     color: user.status == 'Active' ? Colors.green : Colors.red,
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             onTap: () {
//               // Handle tap action
//             },
//           ),
//         );
//       },
//     );
//   }
// }
