import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_med/providers/auth_provider.dart';
// import 'package:go_med/providers/serviceProvider.dart';
// import 'package:go_med/providers/products.dart';
// import 'package:go_med/screens/BottomNavBar.dart';
// import 'package:go_med/screens/dashboard.dart';
// import 'package:go_med/screens/services_edit.dart';
// import 'package:go_med/model/servicesState.dart';
import 'package:gomed_admin/models/adminaddservicesmodel.dart';
import 'package:gomed_admin/provider/adminaddproductsprovider.dart';
import 'package:gomed_admin/provider/adminaddservicesprovider.dart';
import 'package:gomed_admin/provider/loginprovider.dart';
import 'package:gomed_admin/screens/adminaddservices/services_edit.dart';
import 'package:gomed_admin/widgets/bottomnavigation.dart';
import 'package:gomed_admin/widgets/mainappbar.dart';

class ServicesPage extends ConsumerStatefulWidget {
  const ServicesPage({super.key});

  @override
  ConsumerState<ServicesPage> createState() => ServiceScreenState();
}

class ServiceScreenState extends ConsumerState<ServicesPage> {
  Map<String, bool> expandedCards = {}; // Store expanded state for each card

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      ref.read(serviceProvider.notifier).getSevices();
      ref.read(productProvider.notifier).getProducts();
    });
    print('Fetching services and products...');
  }

  @override
  Widget build(BuildContext context) {
    final loginData=ref.watch(loginProvider).data ??[];
   
    final String? userId = loginData.isNotEmpty 
    ? loginData[0].user!.sId
    : null;
    print('userid........9..........$userId');
    final serviceData = ref.watch(serviceProvider).data ?? [];
    
    // Filter services where distributorId matches userId
    //  final List<Data> servicestate = serviceData
    // .where((service) => service.distributorId == userId)
    // .toList();

    //      print('Filtered Services: ${servicestate.length}');


    final products = ref.watch(productProvider).data ?? [];

    // Create a product map (ID -> Name)
    final productMap = {
      for (var p in products) p.productId ?? "": p.productName ?? "Unknown"
    };

    var role;
    return SafeArea(
      child: Scaffold(
        // backgroundColor: const Color(0xFFE8F7F2),
        appBar: const PreferredSize(
            preferredSize: const Size.fromHeight(80), // Set AppBar height
            child: mainTopBar(title: 'services'),
          ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Current Services",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ServicesPageEdit()),
                      );
                    },
                    child: const Text(
                      "Add Service",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: serviceData.isEmpty
                    ? const Center( child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: serviceData.length,
                        itemBuilder: (context, index) {
                          final service = serviceData[index];
                          return _buildServiceCard(context, service, productMap);
                        },
                      ),
              )
            ],
          ),
        ),
        //  bottomNavigationBar:const  CustomBottomNavigationBar(),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, Data service, Map<String, String> productMap) {
    final serviceId = service.sId ?? "";
    final isExpanded = expandedCards[serviceId] ?? false;

    List<String> productNames = (service.productIds ?? [])
        .map((id) => productMap[id] ?? "Unknown Product")
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color:  Colors.white,
        // color: const Color(0x401BA4CA)
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 23, 22, 22).withOpacity(0.4),
          blurRadius: 3,
           
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Name and Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  service.name ?? '',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Text(
                '₹${service.price ?? 0}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Service Details
          Text(
            'Details: ${service.details ?? ''}',
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),

        //   const SizedBox(height: 8),
        //         Text('Status: ${service.activated == true ? "Active" : "Inactive"}', style: TextStyle(
        //   color: service.activated == true ? Colors.green : Colors.red, // ✅ Green for Active, Red for Inactive
        //   fontWeight: FontWeight.bold,
        // ),),

          // Product Names (Initially show one, expand on click)
          if (productNames.isNotEmpty) ...[
            const Text(
              "Products:",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.lightBlue),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (isExpanded ? productNames : productNames.take(1))
                  .map((product) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          "- $product",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ))
                  .toList(),
            ),
            if (productNames.length > 1)
              TextButton(
                onPressed: () {
                  setState(() {
                    expandedCards[serviceId] = !isExpanded;
                  });
                },
                child: Text(
                  isExpanded ? "See Less" : "See More",
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
          ],

          // Edit & Delete Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.lightBlue),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    'serviceAddEdit',
                    arguments: {
                      'type': "edit",
                      'name': service.name,
                      'price': service.price.toString(),
                      'details': service.details,
                      'productIds': service.productIds,
                      'serviceId': service.sId
                    },
                  );
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
                      ref.read(serviceProvider.notifier).deleteService(service.sId);
                    },
                  );
                },
              ),
            ],
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