// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gomed_admin/provider/adminaddproductsprovider.dart';
// import 'package:gomed_admin/provider/adminaddsparepartsmodel.dart';
// import "package:gomed_admin/models/adminaddproductsmodel.dart" as product_model;
// import 'package:gomed_admin/screens/adminaddproducts/products_edit.dart';
// import 'package:gomed_admin/screens/booking_management/booking_management.dart';
// import 'package:gomed_admin/widgets/mainappbar.dart';

// class ProductScreen extends ConsumerStatefulWidget {
//   const ProductScreen({super.key});

//   @override
//   ConsumerState<ProductScreen> createState() => _ProductScreenState();
// }

// class _ProductScreenState extends ConsumerState<ProductScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       ref.watch(productProvider.notifier).getProducts();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final List<product_model.Data> productState =ref.watch(productProvider).data ?? [];
//     print('productsstate...$productState');
//     // final List<sparepart_model.Data> sparePartsState = ref.watch(sparepartProvider).data ?? [];
//     // print(
//     //     'sparepartstate...$sparePartsState');

//     return SafeArea(
//       child: Scaffold(
//         // backgroundColor: const Color(0xFFE8F7F2),
//         appBar: const PreferredSize(
//             preferredSize: const Size.fromHeight(80), // Set AppBar height
//             child: mainTopBar(title: 'products'),
//           ),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildHeaderActions(context),
//               const SizedBox(height: 16),
//               Expanded(
//                 child: productState.isEmpty
//                     ? const Center(child: CircularProgressIndicator())
//                     : _buildProductList(context,productState),
//               ),
//             ],
//           ),
//         ),
//         // bottomNavigationBar:const  CustomBottomNavigationBar(),
//       ),
//     );
//   }

//   Widget _buildHeaderActions(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         _buildActionButton(context, 'Add New \nProducts', const AddProductScreen()),
//         _buildActionButton(context, 'Manage \nbookings', const BookingManagement()),
//       ],
//     );
//   }

//   Widget _buildProductList(BuildContext context,List<product_model.Data> productState) {
//     if (productState.isEmpty) {
//       return const Center(
//         child: Text(
//           'No products available',
//           style: TextStyle(fontSize: 16, color: Colors.black54),
//         ),
//       );
//     }

//     return ListView.builder(
//       itemCount: productState.length,
//       itemBuilder: (context, index) {
//         final product = productState[index];
//         return _buildProductCard(context, product);
//       },
//     );
//   }

//   Widget _buildActionButton(BuildContext context, String label, Widget page) {
//     return ElevatedButton(
//       onPressed: () {
//         Navigator.push(context, MaterialPageRoute(builder: (context) => page));
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: const Color(0x801BA4CA),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       ),
//       child: Text(label, style: const TextStyle(color: Colors.black)),
//     );
//   }

//   Widget _buildProductCard(BuildContext context, product_model.Data product) {
//   return Container(
//     margin: const EdgeInsets.only(bottom: 16),
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(12),
//       boxShadow: [
//         BoxShadow(
//           color: const Color.fromARGB(255, 23, 22, 22).withOpacity(0.4),
//           blurRadius: 3,
//           offset: const Offset(0, 3),
//         ),
//       ],
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Product Name at the Top
//           Text(
//             product.productName ?? '',
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),

//           const SizedBox(height: 8),

//           // Product Image Below Name
//           if ((product.productImages?.isNotEmpty ?? false))
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: Image.network(
//                 product.productImages!.first,
//                 height: 150,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) =>
//                     const Icon(Icons.broken_image),
//               ),
//             )
//           else
//             const Icon(Icons.image_not_supported, size: 100),

//           const SizedBox(height: 8),
//         Text('Category: ${product.categoryName ?? 'Unknown'}',
//             style: const TextStyle(fontSize: 14)),
//         Text('Description: ${product.productDescription ?? ''}',
//             style: const TextStyle(fontSize: 14)),
//             // Text('status:${product.activated}'),
//   //           Text('Status: ${product.activated == true ? "Active" : "Inactive"}', style: TextStyle(color: product.activated == true ? Colors.green : Colors.red, // ✅ Green for Active, Red for Inactive
//   //   fontWeight: FontWeight.bold,
//   // ),),

//         const SizedBox(height: 16),

//         /// **Row to Align Buttons Side by Side**
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space buttons evenly
//           children: [
//             _buildActionButtonCard(context, 'SpareParts', Colors.green, () {
//               _showSparePartsDialog(context, product.productId,product.linkedSpareParts ?? []);
//             }),
//             _buildActionButtonCard(context, 'Edit', Colors.grey, () {
//               Navigator.pushNamed(
//                 context,
//                 'addproductscreen',
//                 arguments: {
//                   'type': "edit",
//                   'productName': product.productName,
//                   'price': product.price.toString(),
//                   'category': product.categoryName,
//                   'description': product.productDescription,
//                   'productId': product.productId
//                 },
//               );
//             }),
//             _buildActionButtonCard(context, 'Delete', Colors.red, () {
//               // _showConfirmationDialog(
//                 // context,
//                 // 'Delete',
//                 // 'Are you sure you want to delete this product?',
//                 // () => ref
//                     // .read(productProvider.notifier)
//                     // .deleteProduct(product.productId),
//               // );
//             }),
//           ],
//         ),
//       ],
//     ),
//   );
// }


//   Widget _buildActionButtonCard(
//       BuildContext context, String label, Color color, VoidCallback onPressed) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       ),
//       child: Text(label, style: const TextStyle(color: Colors.white)),
//     );
//   }

//   void _showSparePartsDialog(BuildContext context, String? productId,
//       List<product_model.LinkedSpareParts> spareParts) {
//     // print("Total Spare Parts: ${sparePartsState.length}"); // Debugging log
    
//     showDialog(
//       context: context,
//       builder: (context) {
//         return Dialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text('Spare Parts',
//                     style:
//                         TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 16),
//                 Expanded(
//                   child: spareParts.isEmpty
//                       ? const Center(child: Text("No Spare Parts Available"))
//                       : ListView(
//                           children: spareParts
//                               .map((part) => _buildSparePartItem(context, part))
//                               .toList(),
//                         ),
//                 ),
//                 const SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Close'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

// Widget _buildSparePartItem(
//     BuildContext context, product_model.LinkedSpareParts sparePart) {
  
//   /// Function to truncate text
//   String truncateText(String text, {int maxLength = 20}) {
//     return (text.length > maxLength) ? '${text.substring(0, maxLength)}...' : text;
//   }

//   return Container(
//     margin: const EdgeInsets.only(bottom: 16),
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: const Color.fromARGB(175, 193, 199, 201),
//       borderRadius: BorderRadius.circular(12),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.grey.withOpacity(0.2),
//           blurRadius: 5,
//           offset: const Offset(0, 3),
//         ),
//       ],
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         /// **Spare Part Name (Truncated)**
//         Text(
//           truncateText(sparePart.productName ?? 'Unknown', maxLength: 25),
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           overflow: TextOverflow.ellipsis, // Ensures name doesn't overflow
//         ),
//       // Spare part image
//           if ((sparePart.productImages?.isNotEmpty ?? false))
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: Image.network(
//                 sparePart.productImages!.first,
//                 height: 100,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) =>
//                     const Icon(Icons.broken_image),
//               ),
//             )
//           else
//             const Icon(Icons.image_not_supported, size: 100),

//           const SizedBox(height: 8),
//         Text(
//           'category${sparePart.productDescription ?? "---"}',
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
//         ),

//         const SizedBox(height: 8),

//         /// **Description (Truncated)**
//         Text(
//           truncateText(sparePart.productDescription ?? '', maxLength: 50),
//           style: const TextStyle(fontSize: 14),
//           overflow: TextOverflow.ellipsis, // Ensures description doesn't overflow
//         ),

//         const SizedBox(height: 16),
        

//         /// **Icons Row (Edit & Delete)**
//         Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.edit, color: Colors.blue),
//               onPressed: () {
//                 // Handle edit logic here
//                 Navigator.pushNamed(
//                 context,
//                 'addproductscreen',
//                 arguments: {
//                   'type': "edit",
//                   'isChecked':true,
//                   'sparepartName': sparePart.productName,
//                   'price': sparePart.price,
//                   // 'productName':sparePart.productName,
//                   'description': sparePart.productDescription,
//                   'sparepartId': sparePart.productId,
//                   'productId':sparePart.parentId,
//                   'selectedProduct':sparePart.productName
//                 },
//               );


//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.delete, color: Colors.red),
//               onPressed: () {
//                 // Handle delete logic here
//                 _showConfirmationDialog(
//                 context,
//                 'Delete',
//                 'Are you sure you want to delete this sparepart?',
//                 () => ref
//                     .read(sparepartProvider.notifier)
//                     .deleteSpareparts(sparePart.productId),
//               );
//               },
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }



//   void _showConfirmationDialog(BuildContext context, String action,
//       String message, VoidCallback onConfirmed) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(action),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 onConfirmed();
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }



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
  bool _isRefreshing = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isRefreshing = true);
    try {
      await ref.read(productProvider.notifier).getProducts();
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  List<product_model.Data> _getFilteredProducts(List<product_model.Data> products) {
    if (_searchQuery.isEmpty) return products;
    return products.where((product) {
      final name = product.productName?.toLowerCase() ?? '';
      final category = product.categoryName?.toLowerCase() ?? '';
      final description = product.productDescription?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      
      return name.contains(query) || 
             category.contains(query) || 
             description.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<product_model.Data> productState = ref.watch(productProvider).data ?? [];
    final filteredProducts = _getFilteredProducts(productState);
    
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: mainTopBar(title: 'Products'),
        ),
        body: RefreshIndicator(
          onRefresh: _loadProducts,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(context, productState.length),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 16),
                Expanded(
                  child: _isRefreshing
                      ? const Center(child: CircularProgressIndicator())
                      : _buildProductList(context, filteredProducts),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, int totalProducts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Management',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalProducts products available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.inventory_2,
                  color: Color(0xFF1976D2),
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            'Add New Product',
            Icons.add_box,
            const Color(0xFF4CAF50),
            const AddProductScreen(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            context,
            'Manage Bookings',
            Icons.bookmark_border,
            const Color(0xFF2196F3),
            const BookingManagement(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    Widget page,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search products by name, category, or description...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
      ),
    );
  }

  Widget _buildProductList(BuildContext context, List<product_model.Data> products) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty 
                  ? 'No products found for "$_searchQuery"'
                  : 'No products available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                child: const Text('Clear search'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(context, product);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, product_model.Data product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with gradient overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: (product.productImages?.isNotEmpty ?? false)
                    ? Image.network(
                        product.productImages!.first,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 180,
                          color: Colors.grey[100],
                          child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        ),
                      )
                    : Container(
                        height: 180,
                        color: Colors.grey[100],
                        child: const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                      ),
              ),
              // // Status badge
              // Positioned(
              //   top: 12,
              //   right: 12,
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //     decoration: BoxDecoration(
              //       color: (product.activated ?? false) 
              //           ? Colors.green.withOpacity(0.9)
              //           : Colors.red.withOpacity(0.9),
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     child: Text(
              //       (product.activated ?? false) ? 'Active' : 'Inactive',
              //       style: const TextStyle(
              //         color: Colors.white,
              //         fontSize: 12,
              //         fontWeight: FontWeight.w600,
              //       ),
              //     ),
              //   ),
              // ),
              // // Spare parts count badge
              if ((product.linkedSpareParts?.isNotEmpty ?? false))
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${product.linkedSpareParts!.length} Parts',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          // Product details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName ?? 'Unknown Product',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Icon(Icons.category, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        product.categoryName ?? 'Unknown Category',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                if (product.productDescription?.isNotEmpty ?? false) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.description, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product.productDescription!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ] else 
                  const SizedBox(height: 8),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButtonCard(
                      context,
                      'Spare Parts',
                      Icons.build,
                      const Color(0xFF4CAF50),
                      () => _showSparePartsDialog(
                        context,
                        product.productId,
                        product.linkedSpareParts ?? [],
                      ),
                    ),
                    _buildActionButtonCard(
                      context,
                      'Edit',
                      Icons.edit,
                      const Color(0xFF2196F3),
                      () => Navigator.pushNamed(
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
                      ),
                    ),
                    _buildActionButtonCard(
                      context,
                      'Delete',
                      Icons.delete,
                      Colors.red,
                      () => _showConfirmationDialog(
                        context,
                        'Delete Product',
                        'Are you sure you want to delete "${product.productName}"? This action cannot be undone.',
                        () => ref.read(productProvider.notifier).deleteProduct(product.productId),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonCard(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showSparePartsDialog(
    BuildContext context,
    String? productId,
    List<product_model.LinkedSpareParts> spareParts,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Spare Parts',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${spareParts.length} items',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                
                Expanded(
                  child: spareParts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.build_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No Spare Parts Available",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: spareParts.length,
                          itemBuilder: (context, index) {
                            return _buildSparePartItem(context, spareParts[index]);
                          },
                        ),
                ),
                
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSparePartItem(
    BuildContext context,
    product_model.LinkedSpareParts sparePart,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Spare part image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (sparePart.productImages?.isNotEmpty ?? false)
                ? Image.network(
                    sparePart.productImages!.first,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 60,
                      width: 60,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 24),
                    ),
                  )
                : Container(
                    height: 60,
                    width: 60,
                    color: Colors.grey[200],
                    child: const Icon(Icons.build, size: 24),
                  ),
          ),
          const SizedBox(width: 12),
          
          // Spare part details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sparePart.productName ?? 'Unknown Spare Part',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                
                if (sparePart.price != null) ...[
                  Text(
                    '₹${sparePart.price}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                
                if (sparePart.productDescription?.isNotEmpty ?? false)
                  Text(
                    sparePart.productDescription!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          
          // Action buttons
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF2196F3), size: 20),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    'addproductscreen',
                    arguments: {
                      'type': "edit",
                      'isChecked': true,
                      'sparepartName': sparePart.productName,
                      'price': sparePart.price,
                      'description': sparePart.productDescription,
                      'sparepartId': sparePart.productId,
                      'productId': sparePart.parentId,
                      'selectedProduct': sparePart.productName
                    },
                  );
                },
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () {
                  _showConfirmationDialog(
                    context,
                    'Delete Spare Part',
                    'Are you sure you want to delete "${sparePart.productName}"?',
                    () => ref.read(sparepartProvider.notifier).deleteSpareparts(sparePart.productId),
                  );
                },
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirmed,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.orange[600],
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirmed();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}