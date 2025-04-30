import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gomed_admin/provider/adminaddproductsprovider.dart';
import 'package:gomed_admin/provider/adminaddsparepartsmodel.dart';
import 'package:gomed_admin/provider/categoryprovider.dart';
import 'package:gomed_admin/widgets/topbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:gomed_admin/models/adminaddproductsmodel.dart";
import "package:gomed_admin/models/categorymodel.dart" as cate;
class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddProductScreen> createState() => ProductScreenState();
}

class ProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  
  bool isLoading = false;
  List<Data> filteredProductsList = [];
  String? selectedCategoryId;

  
  final TextEditingController _searchController = TextEditingController();
  String? productId;
  String? type;
  String? sparePartId;
 

  // Local variable for selected dropdown item
  String? selectedProduct;

  // Image Picker variables
  List<File> _image = [];
  final ImagePicker _picker = ImagePicker();

  // Track checkbox state
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(productProvider.notifier).getProducts();  // ✅ Correct
        ref.read(categoryProvider.notifier).getcategory(); // ✅ Correct
      });
    _searchController.addListener(() {
      setState(() {
        filteredProductsList = [];
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();


    final productState = ref.watch(productProvider).data ?? [];
    filteredProductsList = productState;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      setState(() {
        productNameController.text = args['productName'] ?? '';
        descriptionController.text = args['description'] ?? '';
        selectedCategoryId = args['categoryId'] ?? '';
        categoryController.text = args['categoryName'] ?? '';
        type = args['type'] ?? '';
        productId = args['productId'] ?? '';
        sparePartId = args['sparepartId'] ?? '';
        isChecked = args['isChecked'] ?? false;
        selectedProduct = args['selectedProduct'] ?? '';
      });
    }

    _searchController.addListener(() {
      setState(() {
        filteredProductsList = productState
            .where((product) => product.productName!
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take a Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        final fileSizeInBytes = await imageFile.length();
        final maxFileSize = 2 * 1024 * 1024; // 2MB

        if (fileSizeInBytes > maxFileSize) {
          _showAlertDialog(
              'Error', 'File size exceeds 2MB. Please select a smaller file.');
        } else {
          setState(() {
            _image = [imageFile];
            // _image.add(File(imageFile.path));
          });
        }
      }
    } catch (e) {
      _showAlertDialog('Error', 'Failed to pick image: $e');
    }
  }

  void _showNoSparePartsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("No products Available"),
          content: const Text(
              "There are no products available. Would you like to add a new product?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const AddProductScreen()), // Navigate to Add Product page
                );
              },
              child: const Text("Add Product"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider).data??[];
    final categoryState =ref.watch(categoryProvider).data??[];
    // final filteredProducts =
    //     productState.where((product) => product.parentId == null).toList();

    void _showProductSelection(BuildContext context) {
      TextEditingController searchController = TextEditingController();
      List<Data> filteredList = List.from(productState);

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return AlertDialog(
                title: const Text("Select Product"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Search Field
                      TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setModalState(() {
                            filteredList = productState
                                .where((product) => product.productName!
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          });
                        },

                        decoration: InputDecoration(
                          labelText: "Search Product",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // List of Products
                      SizedBox(
                        height: 400,
                        width: 500,
                        child: ListView.builder(
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final Data product = filteredList[index];
                            return ListTile(
                               title: Text(product.productName ?? "Unnamed"),
                              onTap: () {
                                setState(() {
                                  selectedProduct = product.productName;
                                  productId = product.productId; // Save product ID if needed
                                  categoryController.text =product.categoryName ??" ";
                                  
                                });
                                Navigator.pop(context);
                                  },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(80),
            child: TopBar(title: 'Products', onBackPressed: () => Navigator.pop(context)),
          ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        type == 'edit' ? 'Edit Products' : 'Add Products',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 70),
                      Row(
                        children: [
                          Checkbox(
                            value: isChecked,
                            onChanged: (bool? value) async {
                              setState(() {
                                isChecked = value ?? false;
                              });
                              if (isChecked && productState.isEmpty) {
                                _showNoSparePartsDialog();
                              }
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isChecked = !isChecked;
                              });
                              if (isChecked && productState.isEmpty) {
                                _showNoSparePartsDialog();
                              }
                            },
                            child: const Text(
                              'SpareParts',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 0),
                  if (isChecked && productState.isNotEmpty)
                 
                    GestureDetector(
                      onTap: () {
                        _showProductSelection(context);
      
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          title: Text(selectedProduct ?? 'Select Product'),
                          trailing: const Icon(Icons.arrow_drop_down),
                        ),
                      ),
                    ),
                    
                  const SizedBox(height: 8),
      
                  GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                      ),
                      child: _image.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(_image.first, fit: BoxFit.cover),
                            )
                          : const Center(
                              child: Icon(Icons.add_a_photo,
                                  size: 40, color: Colors.grey),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
               
                   _buildTextField(
                      controller: productNameController,
                      labelText: isChecked ? "Spare Part Name" : "Product Name",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return isChecked
                              ? "Spare part name is required."
                              : "Product name is required.";
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: descriptionController,
                    labelText: "Description",
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
      
                  if (isChecked)
                        TextField(
                          controller: categoryController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: "Category",
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          ),
                          readOnly: true,
                        )
                      else
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Select Category',
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // <--- padding added here
                          ),
                          value: selectedCategoryId?.isNotEmpty == true ? selectedCategoryId : null,
                          items: categoryState.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat.sId,
                              child: Text(cat.name ?? ''),
                            );
                          }).toList(),
                          onChanged: (String? newId) {
                            final selectedCategory =
                                categoryState.firstWhere((cat) => cat.sId == newId, orElse: () => cate.Data.initial());
                            setState(() {
                              selectedCategoryId = newId;
                              categoryController.text = selectedCategory.name ?? '';
                            });
                          },
                        ),
      
      
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (!isChecked) // Show Add Product button when checkbox is unchecked
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                          
                                 if (type == 'edit') {
                                  try {
                                    await ref
                                        .read(productProvider.notifier)
                                        .updateProduct(
                                            productNameController.text,
                                            descriptionController.text,
                                            categoryController.text,
                                            productId,
                                            _image);
      
                                    // Clear form fields
                                    productNameController.clear();
                                    descriptionController.clear();
                                    categoryController.clear();
      
                                    _showSnackBar(
                                        context, "Product updated successfully!");
                                    Navigator.of(context).pop();
                                  } catch (e) {
                                    _showSnackBar(context, e.toString());
                                  }
                                } else {
                                  try {

                                   
                                    await ref
                                        .read(productProvider.notifier)
                                        .addProduct(
                                             productNameController.text,
                                             descriptionController.text,
                                             selectedCategoryId,
                                             productId,
                                            _image,
                                            );
      
                                    // Clear form fields
                                    productNameController.clear();
                                    descriptionController.clear();
                                    categoryController.clear();
                                   
      
                                    _showSnackBar(
                                        context, "Product added successfully!");
                                    Navigator.of(context).pop();
                                  } catch (e) {
                                    _showSnackBar(context, e.toString());
                                  }
                                }
                              } else {
                                _showSnackBar(context, "Please fill all fields.");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0x801BA4CA),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text(type == 'edit'
                                ? 'Update Product'
                                : 'Add Product'),
                          ),
                        ),
                      if (isChecked) // Show Add SparePart button when checkbox is checked
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    print(
                                        'sparepartbutton works.......................');
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                    
                                      print('printed...........');
      
                                      
                                      if (type == 'edit') {
                                        try {
                                          await ref
                                              .read(sparepartProvider.notifier)
                                              .updateSparePart(
                                                  productNameController.text,
                                                  descriptionController.text,
                                                  categoryController.text,
                                                  _image,
                                                  sparePartId,
                                              );
                                          // Fetch updated spare parts to refresh the UI
                                          await ref
                                              .read(sparepartProvider.notifier)
                                              .getSpareParts();
      
                                          // Clear form fields
                                          productNameController.clear();
                                          categoryController.clear();
                                          descriptionController.clear();
      
                                          _showSnackBar(context,
                                              "sparepart updated successfully!");
                                          Navigator.of(context).pop();
                                        } catch (e) {
                                          _showSnackBar(context, e.toString());
                                        }
                                      } else {
                                        try {
                                         
                                         // ✅ Find categoryId based on category name
                                              final selectedCategory = categoryState.firstWhere(
                                                (cat) => cat.name == categoryController.text,
                                                orElse: () => cate.Data.initial(),
                                              );

                                              final String? categoryIdToSend = selectedCategory.sId;

                                        
                                          print(
                                              'Description: ${descriptionController.text}');
                                          print(
                                              'Selected Product: $selectedProduct');
                                          print('Image: $_image');
      
                                          await ref
                                              .read(sparepartProvider.notifier)
                                              .addSpareParts(
                                                productNameController.text,
                                                descriptionController.text,
                                                categoryIdToSend,
                                                 productId,
                                                _image,
                                              );
                                          print('try exicuted==========');
                                          // Fetch updated spare parts to refresh the UI
                                          await ref
                                              .read(productProvider.notifier)
                                              .getProducts();
      
                                          // Clear form fields
                                          productNameController.clear();
                                          categoryController.clear();
                                          descriptionController.clear();
      
                                          _showSnackBar(context,
                                              "Sparepart added successfully!");
                                      
      
                                          Navigator.of(context).pop();
                                     
                                        } catch (e, stackTrace) {
                                          print('Error: $e');
                                          print('Stack Trace: $stackTrace');
                                          _showSnackBar(context, e.toString());
                                        }
                                      }
                                    } else {
                                      _showSnackBar(
                                          context, "Please fill all fields.");
                                      print('else executed');
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0x801BA4CA),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text(type == 'edit'
                                ? 'update Sparepart'
                                : 'Add SparePart'),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
      validator: validator,
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            message == "Please fill all fields." ? Colors.red : Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
























// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:gomed_admin/provider/adminaddproductsprovider.dart';
// import 'package:gomed_admin/provider/adminaddsparepartsmodel.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class AddProductScreen extends ConsumerStatefulWidget {
//   const AddProductScreen({Key? key}) : super(key: key);

//   @override
//   ConsumerState<AddProductScreen> createState() => ProductScreenState();
// }

// class ProductScreenState extends ConsumerState<AddProductScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController productNameController = TextEditingController();
//   final TextEditingController priceController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   final TextEditingController categoryController = TextEditingController();
//   final TextEditingController sparePartsContoller = TextEditingController();
//   final TextEditingController sparePartNameController = TextEditingController();
//   bool isLoading = false;
//   List filteredProductsList = [];
//   final TextEditingController _searchController = TextEditingController();
//   String? productId;
//   String? type;
//   String? sparePartId;
//   String? sparePartName;

//   // Local variable for selected dropdown item
//   String? selectedProduct;

//   // Image Picker variables
//   List<File> _image = [];
//   final ImagePicker _picker = ImagePicker();

//   // Track checkbox state
//   bool isChecked = false;

//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(() {
//       setState(() {
//         filteredProductsList = [];
//       });
//     });
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final productState = ref.watch(productProvider).data ?? [];
//     filteredProductsList = productState;

//     final args =
//         ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

//     if (args != null) {
//       setState(() {
//         productNameController.text = args['productName'] ?? '';
//         priceController.text = args['price'] ?? '';
//         descriptionController.text = args['description'] ?? '';
//         categoryController.text = args['category'] ?? '';
//         sparePartNameController.text = args['sparepartName'] ?? '';
//         type = args['type'] ?? '';
//         productId = args['productId'] ?? '';
//         print('88888888888888888............$productId');
//         sparePartId = args['sparepartId'] ?? '';
//         isChecked = args['isChecked'] ?? false;
//         // productNameController.text = args['sparepartName'] ?? '';
//         selectedProduct = args['selectedProduct'] ?? '';
//       });
//     }

//     _searchController.addListener(() {
//       setState(() {
//         filteredProductsList = productState
//             .where((product) => product.productName!
//                 .toLowerCase()
//                 .contains(_searchController.text.toLowerCase()))
//             .toList();
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _showImagePickerOptions() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) {
//         return Wrap(
//           children: [
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text("Take a Photo"),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickImage(ImageSource.camera);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text("Choose from Gallery"),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickImage(ImageSource.gallery);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showAlertDialog(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(title),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text("OK"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(source: source);
//       if (pickedFile != null) {
//         File imageFile = File(pickedFile.path);
//         final fileSizeInBytes = await imageFile.length();
//         final maxFileSize = 2 * 1024 * 1024; // 2MB

//         if (fileSizeInBytes > maxFileSize) {
//           _showAlertDialog(
//               'Error', 'File size exceeds 2MB. Please select a smaller file.');
//         } else {
//           setState(() {
//             _image = [imageFile];
//             // _image.add(File(imageFile.path));
//           });
//         }
//       }
//     } catch (e) {
//       _showAlertDialog('Error', 'Failed to pick image: $e');
//     }
//   }

//   void _showNoSparePartsDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("No Spare Parts Available"),
//           content: const Text(
//               "There are no spare parts available. Would you like to add a new product?"),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text("Cancel"),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>
//                           const AddProductScreen()), // Navigate to Add Product page
//                 );
//               },
//               child: const Text("Add Product"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final productState = ref.watch(productProvider).data ?? [];
//     final filteredProducts =
//         productState.where((product) => product.spareParts == false).toList();

//     void _showProductSelection(BuildContext context) {
//       TextEditingController searchController = TextEditingController();
//       List filteredList = List.from(filteredProducts);

//       showDialog(
//         context: context,
//         builder: (context) {
//           return StatefulBuilder(
//             builder: (context, setModalState) {
//               return AlertDialog(
//                 title: const Text("Select Product"),
//                 content: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // Search Field
//                       TextField(
//                         controller: searchController,
//                         onChanged: (value) {
//                           setModalState(() {
//                             filteredList = filteredProducts
//                                 .where((product) => product.productName!
//                                     .toLowerCase()
//                                     .contains(value.toLowerCase()))
//                                 .toList();
//                           });
//                         },
//                         decoration: InputDecoration(
//                           labelText: "Search Product",
//                           prefixIcon: const Icon(Icons.search),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       // List of Products
//                       SizedBox(
//                         height: 400,
//                         width: 500,
//                         child: ListView.builder(
//                           itemCount: filteredList.length,
//                           itemBuilder: (context, index) {
//                             final product = filteredList[index];
//                             return ListTile(
//                               title: Text(product.productName!),
//                               onTap: () {
//                                 setState(() {
//                                   selectedProduct = product.productName;
//                                   sparePartsContoller.text =
//                                       product.productName!;
//                                 });
//                                 Navigator.pop(context);
//                               },
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF6BC37A),
//         title: const Text('Products'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Text(
//                       type == 'edit' ? 'Edit Products' : 'Add Products',
//                       style: const TextStyle(
//                           fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(width: 70),
//                     Row(
//                       children: [
//                         Checkbox(
//                           value: isChecked,
//                           onChanged: (bool? value) async {
//                             setState(() {
//                               isChecked = value ?? false;
//                             });
//                             if (isChecked && productState.isEmpty) {
//                               _showNoSparePartsDialog();
//                             }
//                           },
//                         ),
//                         GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               isChecked = !isChecked;
//                             });
//                             if (isChecked && productState.isEmpty) {
//                               _showNoSparePartsDialog();
//                             }
//                           },
//                           child: const Text(
//                             'SpareParts',
//                             style: TextStyle(
//                                 fontSize: 12, fontWeight: FontWeight.w500),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 0),
//                 if (isChecked && filteredProducts.isNotEmpty)
//                   // Column(
//                   // children: [
//                   // Display selected product above the search bar
//                   GestureDetector(
//                     onTap: () {
//                       _showProductSelection(context);
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: ListTile(
//                         title: Text(selectedProduct ?? 'Select Product'),
//                         trailing: const Icon(Icons.arrow_drop_down),
//                       ),
//                     ),
//                   ),

//                 // ],
//                 // ),
//                 const SizedBox(height: 8),
//                 GestureDetector(
//                   onTap: _showImagePickerOptions,
//                   child: Container(
//                     height: 180,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(10),
//                       color: Colors.grey[200],
//                     ),
//                     child: _image.isNotEmpty
//                         ? ClipRRect(
//                             borderRadius: BorderRadius.circular(10),
//                             child: Image.file(_image.first, fit: BoxFit.cover),
//                           )
//                         : const Center(
//                             child: Icon(Icons.add_a_photo,
//                                 size: 40, color: Colors.grey),
//                           ),
//                   ),
//                 ),
//                 const SizedBox(height: 8),

//                 if (isChecked && type == 'edit')
//                   _buildTextField(
//                     controller: sparePartNameController,
//                     labelText: isChecked ? "Spare Part Name" : "Product Name",
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return isChecked
//                             ? "Spare part name is required."
//                             : "Product name is required.";
//                       }
//                       return null;
//                     },
//                   ),
//                 if (isChecked == false && type != 'edit')
//                   _buildTextField(
//                     controller: productNameController,
//                     labelText: isChecked ? "Spare Part Name" : "Product Name",
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return isChecked
//                             ? "Spare part name is required."
//                             : "Product name is required.";
//                       }
//                       return null;
//                     },
//                   ),
//                 if (isChecked == true && type != 'edit')
//                   _buildTextField(
//                     controller: sparePartNameController,
//                     labelText: isChecked ? "Spare Part Name" : "Product Name",
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return isChecked
//                             ? "Spare part name is required."
//                             : "Product name is required.";
//                       }
//                       return null;
//                     },
//                   ),
//                 if (isChecked == false && type == 'edit')
//                   _buildTextField(
//                     controller: productNameController,
//                     labelText: isChecked ? "Spare Part Name" : "Product Name",
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return isChecked
//                             ? "Spare part name is required."
//                             : "Product name is required.";
//                       }
//                       return null;
//                     },
//                   ),

//                 const SizedBox(height: 8),
//                 _buildTextField(
//                   controller: priceController,
//                   labelText: "Price",
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Price is required.";
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 8),
//                 _buildTextField(
//                   controller: descriptionController,
//                   labelText: "Description",
//                   maxLines: 3,
//                 ),
//                 const SizedBox(height: 8),

//                 if (isChecked || type == 'edit')
//                   TextField(
//                     decoration: InputDecoration(
//                       border: const OutlineInputBorder(),
//                       contentPadding:
//                           const EdgeInsets.symmetric(horizontal: 12),
//                       hintText: categoryController.text.isNotEmpty
//                           ? categoryController.text
//                           : 'N/A',
//                     ),
//                     readOnly: true,
//                   )
//                 else
//                   _buildTextField(
//                     controller: categoryController,
//                     labelText: "Category",
//                   ),

//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     if (!isChecked) // Show Add Product button when checkbox is unchecked
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             if (_formKey.currentState?.validate() ?? false) {
//                               final double? parsedPrice =
//                                   double.tryParse(priceController.text);

//                               if (parsedPrice == null) {
//                                 _showSnackBar(
//                                     context, "Please enter a valid price.");
//                                 return;
//                               }

//                               if (type == 'edit') {
//                                 try {
//                                   await ref
//                                       .read(productProvider.notifier)
//                                       .updateProduct(
//                                           productNameController.text,
//                                           descriptionController.text,
//                                           parsedPrice,
//                                           categoryController.text,
//                                           productId,
//                                           _image);

//                                   // Clear form fields
//                                   productNameController.clear();
//                                   priceController.clear();
//                                   descriptionController.clear();
//                                   categoryController.clear();

//                                   _showSnackBar(
//                                       context, "Product updated successfully!");
//                                   Navigator.of(context).pop();
//                                 } catch (e) {
//                                   _showSnackBar(context, e.toString());
//                                 }
//                               } else {
//                                 try {
//                                   await ref
//                                       .read(productProvider.notifier)
//                                       .addProduct(
//                                           productNameController.text,
//                                           descriptionController.text,
//                                           parsedPrice,
//                                           categoryController.text,
//                                           _image,
//                                           sparePartsContoller.text);

//                                   // Clear form fields
//                                   productNameController.clear();
//                                   priceController.clear();
//                                   descriptionController.clear();
//                                   categoryController.clear();
//                                   sparePartsContoller.clear();

//                                   _showSnackBar(
//                                       context, "Product added successfully!");
//                                   Navigator.of(context).pop();
//                                 } catch (e) {
//                                   _showSnackBar(context, e.toString());
//                                 }
//                               }
//                             } else {
//                               _showSnackBar(context, "Please fill all fields.");
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0x801BA4CA),
//                             padding: const EdgeInsets.symmetric(vertical: 15),
//                           ),
//                           child: Text(type == 'edit'
//                               ? 'Update Product'
//                               : 'Add Product'),
//                         ),
//                       ),
//                     if (isChecked) // Show Add SparePart button when checkbox is checked
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: isLoading
//                               ? null
//                               : () async {
//                                   print(
//                                       'sparepartbutton works.......................');
//                                   if (_formKey.currentState?.validate() ??
//                                       false) {
//                                     final double? parsedPrice =
//                                         double.tryParse(priceController.text);
//                                     print('printed...........');

//                                     if (parsedPrice == null) {
//                                       _showSnackBar(context,
//                                           "Please enter a valid price.");
//                                       print('printes.................');
//                                       return;
//                                     }
//                                     if (type == 'edit') {
//                                       try {
//                                         await ref
//                                             .read(sparepartProvider.notifier)
//                                             .updateSparePart(
//                                                 sparePartNameController.text,
//                                                 descriptionController.text,
//                                                 parsedPrice,
//                                                 _image,
//                                                 sparePartId,
//                                                 // productNameController.text,
//                                                 productId);
//                                         // Fetch updated spare parts to refresh the UI
//                                         await ref
//                                             .read(sparepartProvider.notifier)
//                                             .getSpareParts();

//                                         // Clear form fields
//                                         productNameController.clear();
//                                         priceController.clear();
//                                         descriptionController.clear();

//                                         _showSnackBar(context,
//                                             "sparepart updated successfully!");
//                                         Navigator.of(context).pop();
//                                       } catch (e) {
//                                         _showSnackBar(context, e.toString());
//                                       }
//                                     } else {
//                                       try {
//                                         print('Parsed price: $parsedPrice');
//                                         print(
//                                             'Product Name: ${sparePartNameController.text}');
//                                         print(
//                                             'Description: ${descriptionController.text}');
//                                         print(
//                                             'Selected Product: $selectedProduct');
//                                         print('Image: $_image');

//                                         await ref
//                                             .read(sparepartProvider.notifier)
//                                             .addSpareParts(
//                                               sparePartNameController.text,
//                                               descriptionController.text,
//                                               parsedPrice,
//                                               selectedProduct,
//                                               _image,
//                                             );
//                                         print('try exicuted==========');
//                                         // Fetch updated spare parts to refresh the UI
//                                         await ref
//                                             .read(sparepartProvider.notifier)
//                                             .getSpareParts();

//                                         // Clear form fields
//                                         productNameController.clear();
//                                         priceController.clear();
//                                         descriptionController.clear();

//                                         _showSnackBar(context,
//                                             "Sparepart added successfully!");
//                                         await ref
//                                             .read(sparepartProvider.notifier)
//                                             .getSpareParts();

//                                         Navigator.of(context).pop();
//                                         await ref
//                                             .read(sparepartProvider.notifier)
//                                             .getSpareParts();
//                                       } catch (e, stackTrace) {
//                                         print('Error: $e');
//                                         print('Stack Trace: $stackTrace');
//                                         _showSnackBar(context, e.toString());
//                                       }
//                                     }
//                                   } else {
//                                     _showSnackBar(
//                                         context, "Please fill all fields.");
//                                     print('else executed');
//                                   }
//                                 },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0x801BA4CA),
//                             padding: const EdgeInsets.symmetric(vertical: 15),
//                           ),
//                           child: Text(type == 'edit'
//                               ? 'update Sparepart'
//                               : 'Add SparePart'),
//                         ),
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String labelText,
//     int maxLines = 1,
//     TextInputType keyboardType = TextInputType.text,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       maxLines: maxLines,
//       keyboardType: keyboardType,
//       decoration: InputDecoration(
//         labelText: labelText,
//         filled: true,
//         fillColor: Colors.grey[200],
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: Colors.grey),
//         ),
//       ),
//       validator: validator,
//     );
//   }

//   void _showSnackBar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor:
//             message == "Please fill all fields." ? Colors.red : Colors.blue,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }
// }