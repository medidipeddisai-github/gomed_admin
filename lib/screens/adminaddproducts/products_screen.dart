import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_admin/provider/adminaddproductsprovider.dart';
import 'package:gomed_admin/provider/adminaddsparepartsmodel.dart';
import "package:gomed_admin/models/adminaddproductsmodel.dart" as product_model;
import 'package:gomed_admin/screens/adminaddproducts/products_edit.dart';
import 'package:gomed_admin/screens/booking_management/booking_management.dart';
import 'package:gomed_admin/widgets/mainappbar.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.watch(productProvider.notifier).getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<product_model.Data> productState =ref.watch(productProvider).data ?? [];
    print('productsstate...$productState');
    // final List<sparepart_model.Data> sparePartsState = ref.watch(sparepartProvider).data ?? [];
    // print(
    //     'sparepartstate...$sparePartsState');

    return SafeArea(
      child: Scaffold(
        // backgroundColor: const Color(0xFFE8F7F2),
        appBar: const PreferredSize(
            preferredSize: const Size.fromHeight(80), // Set AppBar height
            child: mainTopBar(title: 'products'),
          ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderActions(context),
              const SizedBox(height: 16),
              Expanded(
                child: productState.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _buildProductList(context,productState),
              ),
            ],
          ),
        ),
        // bottomNavigationBar:const  CustomBottomNavigationBar(),
      ),
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(context, 'Add New \nProducts', const AddProductScreen()),
        _buildActionButton(context, 'Manage \nbookings', const BookingManagement()),
      ],
    );
  }

  Widget _buildProductList(BuildContext context,List<product_model.Data> productState) {
    if (productState.isEmpty) {
      return const Center(
        child: Text(
          'No products available',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return ListView.builder(
      itemCount: productState.length,
      itemBuilder: (context, index) {
        final product = productState[index];
        return _buildProductCard(context, product);
      },
    );
  }

  Widget _buildActionButton(BuildContext context, String label, Widget page) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0x801BA4CA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      child: Text(label, style: const TextStyle(color: Colors.black)),
    );
  }

  Widget _buildProductCard(BuildContext context, product_model.Data product) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              product.productName ?? '',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Text(
            //   'Price: ₹${product.price ?? 0}',
            //   style:
            //       const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            // ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Category: ${product.categoryName ?? 'Unknown'}',
            style: const TextStyle(fontSize: 14)),
        Text('Description: ${product.productDescription ?? ''}',
            style: const TextStyle(fontSize: 14)),
            // Text('status:${product.activated}'),
  //           Text('Status: ${product.activated == true ? "Active" : "Inactive"}', style: TextStyle(color: product.activated == true ? Colors.green : Colors.red, // ✅ Green for Active, Red for Inactive
  //   fontWeight: FontWeight.bold,
  // ),),

        const SizedBox(height: 16),

        /// **Row to Align Buttons Side by Side**
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space buttons evenly
          children: [
            _buildActionButtonCard(context, 'SpareParts', Colors.green, () {
              _showSparePartsDialog(context, product.productId,product.linkedSpareParts ?? []);
            }),
            _buildActionButtonCard(context, 'Edit', Colors.grey, () {
              Navigator.pushNamed(
                context,
                'addproductscreen',
                arguments: {
                  'type': "edit",
                  'productName': product.productName,
                  'price': product.price.toString(),
                  'category': product.categoryName,
                  'description': product.productDescription,
                  'productId': product.productId
                },
              );
            }),
            _buildActionButtonCard(context, 'Delete', Colors.red, () {
              // _showConfirmationDialog(
                // context,
                // 'Delete',
                // 'Are you sure you want to delete this product?',
                // () => ref
                    // .read(productProvider.notifier)
                    // .deleteProduct(product.productId),
              // );
            }),
          ],
        ),
      ],
    ),
  );
}


  Widget _buildActionButtonCard(
      BuildContext context, String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  void _showSparePartsDialog(BuildContext context, String? productId,
      List<product_model.LinkedSpareParts> spareParts) {
    // print("Total Spare Parts: ${sparePartsState.length}"); // Debugging log
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Spare Parts',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: spareParts.isEmpty
                      ? const Center(child: Text("No Spare Parts Available"))
                      : ListView(
                          children: spareParts
                              .map((part) => _buildSparePartItem(context, part))
                              .toList(),
                        ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

Widget _buildSparePartItem(
    BuildContext context, product_model.LinkedSpareParts sparePart) {
  
  /// Function to truncate text
  String truncateText(String text, {int maxLength = 20}) {
    return (text.length > maxLength) ? '${text.substring(0, maxLength)}...' : text;
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color.fromARGB(175, 193, 199, 201),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// **Spare Part Name (Truncated)**
        Text(
          truncateText(sparePart.productName ?? 'Unknown', maxLength: 25),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis, // Ensures name doesn't overflow
        ),

        const SizedBox(height: 4),

        /// **Price**
        Text(
          'category${sparePart.productDescription ?? "---"}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
        ),

        const SizedBox(height: 8),

        /// **Description (Truncated)**
        Text(
          truncateText(sparePart.productDescription ?? '', maxLength: 50),
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis, // Ensures description doesn't overflow
        ),

        const SizedBox(height: 16),
        

        /// **Icons Row (Edit & Delete)**
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                // Handle edit logic here
                Navigator.pushNamed(
                context,
                'addproductscreen',
                arguments: {
                  'type': "edit",
                  'isChecked':true,
                  'sparepartName': sparePart.productName,
                  'price': sparePart.price,
                  // 'productName':sparePart.productName,
                  'description': sparePart.productDescription,
                  'sparepartId': sparePart.productId,
                  'productId':sparePart.parentId,
                  'selectedProduct':sparePart.productName
                },
              );


              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Handle delete logic here
                _showConfirmationDialog(
                context,
                'Delete',
                'Are you sure you want to delete this sparepart?',
                () => ref
                    .read(sparepartProvider.notifier)
                    .deleteSpareparts(sparePart.productId),
              );
              },
            ),
          ],
        ),
      ],
    ),
  );
}



  void _showConfirmationDialog(BuildContext context, String action,
      String message, VoidCallback onConfirmed) {
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