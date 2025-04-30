import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_admin/provider/adminaddproductsprovider.dart';
import 'package:gomed_admin/provider/adminaddservicesprovider.dart';
import 'package:gomed_admin/widgets/topbar.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
// import '../providers/products.dart';
// import '../providers/serviceProvider.dart';

class ServicesPageEdit extends ConsumerStatefulWidget {
  const ServicesPageEdit({super.key});

  @override
  _ServicesPageEditState createState() => _ServicesPageEditState();
}

class _ServicesPageEditState extends ConsumerState<ServicesPageEdit> {
  final TextEditingController serviceController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  List<String> selectedProducts = [];
  Map<String, String> productMap = {};
  List<String> productNames = [];
  String? type;
  List<String> productId = [];
  String? serviceId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null && productId.isEmpty) { // Prevent overwriting selected products
      setState(() {
        serviceController.text = args['name'] ?? '';
        priceController.text = args['price']?.toString() ?? '';
        descriptionController.text = args['details'] ?? '';
        productId = List<String>.from(args['productIds'] ?? []);
        type = args['type'] ?? '';
        serviceId = args['serviceId'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider).data ?? [];
    // print("productsData--${produc}");

    // Map product ID to Name
    productMap = {
      for (var p in products) p.productId ?? "": p.productName ?? "Unknown"
    };
    productNames = productMap.values.toList();

    //  Ensure pre-selected products appear in dropdown
    selectedProducts = productId
        .map((id) => productMap[id] ?? "")
        .where((name) => name.isNotEmpty)
        .toList();

    return SafeArea(
      child: Scaffold(
        // backgroundColor: const Color(0xFFE8F7F2),
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(80),
            child: TopBar(title: 'Services', onBackPressed: () => Navigator.pop(context)),
          ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type == 'edit' ? 'Edit Service' : 'Add Service',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
      
                  // Select Products
                  buildLabel("Select Products"),
                  MultiSelectDialogField(
                    items: productNames
                        .map((name) => MultiSelectItem<String>(name, name))
                        .toList(),
                    title: const Text("Select Products"),
                    buttonText: const Text("Choose Products"),
                    searchable: true,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    initialValue: selectedProducts, // ✅ Pre-selection works
                    chipDisplay: MultiSelectChipDisplay.none(),
                    onConfirm: (values) {
                      setState(() {
                        selectedProducts = values.cast<String>();
      
                        // ✅ Ensure productId updates based on selectedProducts
                        productId = selectedProducts
                            .map((name) => productMap.entries
                                .firstWhere((entry) => entry.value == name,
                                    orElse: () => MapEntry("", ""))
                                .key)
                            .where((id) => id.isNotEmpty)
                            .toList();
                      });
                    },
                  ),
      
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: selectedProducts.map((name) {
                      return Chip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(name,
                                style: const TextStyle(color: Colors.white)),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedProducts = List.from(selectedProducts)
                                    ..remove(name);
                                  productId = productId.where((id) {
                                    final product = productMap[id];
                                    return product != name;
                                  }).toList();
                                });
                              },
                              child: const Icon(Icons.close,
                                  size: 16, color: Colors.white),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green,
                      );
                    }).toList(),
                  ),
      
                  const SizedBox(height: 16),
                  buildLabel("Service Name"),
                  TextFormField(
                      controller: serviceController,
                      decoration: buildInputDecoration()),
                  const SizedBox(height: 10),
      
                  buildLabel("Price"),
                  TextFormField(
                    controller: priceController,
                    decoration: buildInputDecoration(),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
      
                  buildLabel("Description"),
                  TextFormField(
                      controller: descriptionController,
                      decoration: buildInputDecoration()),
                  const SizedBox(height: 20),
      
                  // Submit Button
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            List<String> updatedProductIds = selectedProducts
                                .map((name) => productMap.entries
                                    .firstWhere((entry) => entry.value == name,
                                        orElse: () => MapEntry("", ""))
                                    .key)
                                .where((id) => id.isNotEmpty)
                                .toList();
      
                            final double? parsedPrice =
                                double.tryParse(priceController.text);
      
                            if (type == 'edit') {
                              bool success = await ref
                                  .read(serviceProvider.notifier)
                                  .updateService(
                                    serviceController.text,
                                    descriptionController.text,
                                    parsedPrice,
                                    updatedProductIds, // ✅ Use the updated product list
                                    serviceId,
                                  );
      
                              if (success) {
                                setState(() {
                                  productId = updatedProductIds;
                                });
      
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Service updated successfully!")),
                                );
                              }
                            } else {
                              await ref.read(serviceProvider.notifier).addService(
                                    serviceController.text,
                                    descriptionController.text,
                                    parsedPrice,
                                    updatedProductIds,
                                  );
                              Navigator.of(context).pop();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor:const Color(0xFF2A9D8F)),
                        child: Text(
                            type == 'edit' ? 'Update Service' : 'Add Service'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.bold));
  }

  InputDecoration buildInputDecoration() {
    return const InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5))),
    );
  }
}