// 📁 lib/screens/requested_products_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_admin/provider/loader.dart';
import 'package:gomed_admin/provider/requestGetProvider.dart';
import 'package:gomed_admin/provider/distributorprovider.dart';
import 'package:gomed_admin/widgets/mainappbar.dart';
import 'package:gomed_admin/widgets/topbar.dart';

class RequestedProductsScreen extends ConsumerStatefulWidget {
  const RequestedProductsScreen({super.key});

  @override
  ConsumerState<RequestedProductsScreen> createState() => _RequestedProductsScreenState();
}

class _RequestedProductsScreenState extends ConsumerState<RequestedProductsScreen> {
  final List<Map<String, dynamic>> selectedItems = []; // ✅ New list for approval payload
  final accept="accepted";
  final reject="rejected";
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.watch(distributorProvider.notifier).getUsers());
    Future.microtask(() => ref.watch(requestedproductsProvider.notifier).getRequestedProducts());
  }

  void handleSelectItem(Map<String, dynamic> item, bool selected) {
    setState(() {
      selectedItems.removeWhere((e) => e['productId'] == item['productId']);
      if (selected) selectedItems.add(item);
    });
  }

 void handleUpdateStatus(Map<String, dynamic> item, String status) async {
  print("Single update trigger: $item");

  final updatedItem = {
    ...item,
    "status": status,
  };

  final updatedList = [updatedItem]; // 👈 wrap single item in a list
  final individualstatus = status=="accepted"?"accepted":"rejected";
  try {
    await ref
        .read(requestedproductsProvider.notifier)
        .approveproducts(context, updatedList,individualstatus); // ✅ send list with one item
  } catch (e) {
    print("Error updating product: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    final requestedData = ref.watch(requestedproductsProvider).data ?? [];
    final distributorData = ref.watch(distributorProvider).data ?? [];

    // if (distributorData.isEmpty || requestedData.isEmpty) {
    //   return const Center(child: CircularProgressIndicator());
    // }


    final groupedByDistributor = <String, List<dynamic>>{};
    for (var item in requestedData) {
      groupedByDistributor.putIfAbsent(item.distributorId ?? '', () => []).add(item);
    }

   String getDistributorName(String id) {
    try {
      final dist = distributorData.firstWhere((d) => d.sId == id);
      return dist.ownerName?? 'Unknown';
    } catch (e) {
      print("Distributor not found for ID: $id");
      return 'Unknown';
    }
  }


  String getProductName(String? productId) {
    try {
      final product = requestedData.firstWhere((p) => p.productId == productId);
      return product.productName ?? '';
    } catch (e) {
      return ''; // if not found
    }
   }

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFE8F7F2),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: TopBar(title: 'Requested Products', onBackPressed: () => Navigator.pop(context)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: groupedByDistributor.entries.map((entry) {
                    final distributorId = entry.key;
                    final products = entry.value;

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        title: Text(" ${getDistributorName(distributorId)}"),
                        children: products.map<Widget>((product) {
                          final isSparePart = product.parentId != null;
                          final status = product.adminApproval ?? 'pending';
                          final isAccepted = status == 'accepted';
                          final isRejected = status == 'rejected';

                          if (isAccepted || isRejected) {
                            return ListTile(
                              title: Text(product.productName ?? ''),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Type: ${isSparePart ? "Spare Part" : "Product"}"),
                                  if (isSparePart) Text("Parent: ${getProductName(product.parentId)}"),
                                  Text("Quantity: ${product.quantity}"),
                                  Text("Price: ${product.price}"),
                                  Text("status:${product.adminApproval}",style: TextStyle(color:product.adminApproval=='accepted'?Colors.green:product.adminApproval=='rejected'? Colors.red:Colors.blue),)
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  // Call update API with new status here
                                  handleUpdateStatus({
                                    "productId": product.productId,
                                    "parentId": product.parentId,
                                    "distributorId": product.distributorId
                                  }, value);
                                },
                                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                  if (isAccepted)
                                    const PopupMenuItem<String>(
                                      value: 'rejected',
                                      child: Text('Reject'),
                                    ),
                                  if (isRejected)
                                    const PopupMenuItem<String>(
                                      value: 'accepted',
                                      child: Text('Accept'),
                                    ),
                                ],
                              ),
                            );
                          } else {
                            return CheckboxListTile(
                              value: selectedItems.any((e) => e['productId'] == product.productId),
                              onChanged: (bool? value) {
                                handleSelectItem({
                                  "productId": product.productId,
                                  "distributorId": product.distributorId,
                                  "parentId": product.parentId,
                                  "status": "pending", // default, changed on button click
                                }, value ?? false);
                              },
                              title: Text(product.productName ?? ''),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Type: ${isSparePart ? "Spare Part" : "Product"}"),
                                  if (isSparePart) Text("Parent: ${getProductName(product.parentId)}"),
                                  Text("Quantity: ${product.quantity}"),
                                  Text("Price: ${product.price}"),
                                ],
                              ),
                            );
                          }
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async{
                        // Accept
                        final updated = selectedItems.map((e) => {...e, "status": "accepted"}).toList();
                        
                         try{
                          await ref.read(requestedproductsProvider.notifier).approveproducts(context, updated,accept);
                        }
                        catch(e){
                          print("Error accepting items: $e");
                        };
                        print("updated accepted$updated");
                        // Call your provider here with updated
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text("Accept Selected"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async{
                        final updated = selectedItems.map((e) => {...e, "status": "rejected"}).toList();

                        try{
                          await ref.read(requestedproductsProvider.notifier).approveproducts(context, updated,reject);
                        }
                        catch(e){
                          print("Error accepting items: $e");
                        };
                        print("updated rejected$updated");
                        // Call your provider here with updated
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text("Reject Selected"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
