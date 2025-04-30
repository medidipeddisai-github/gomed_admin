import 'package:flutter/material.dart';
import 'package:gomed_admin/widgets/topbar.dart';
import 'package:gomed_admin/widgets/custom_button.dart';
import 'package:gomed_admin/widgets/bottomnavigation.dart'; // Assuming you have this widget

class AddVendor extends StatefulWidget {
  @override
  _AddVendorState createState() => _AddVendorState();
}

class _AddVendorState extends State<AddVendor> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _selectedCategory;
  final List<String> _categories = [
    'Plumbing',
    'Electrical',
    'Cleaning',
    'Painting',
    'Gardening'
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double padding = screenHeight * 0.02;
    double formFieldHeight = screenHeight * 0.07;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              TopBar(
                title: 'Add Service',
                onBackPressed: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: padding), // Add spacing after the TopBar
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextFormField(
                      controller: _serviceNameController,
                      labelText: 'Vendor Name',
                      hintText: 'Enter the name of the vendor',
                      height: formFieldHeight,
                    ),
                    SizedBox(height: padding),
                    _buildTextFormField(
                      controller: _descriptionController,
                      labelText: 'Contact Person',
                      hintText: 'Enter the name of the contact person',
                      height: formFieldHeight,
                    ),
                    SizedBox(height: padding),
                    _buildTextFormField(
                      controller: _descriptionController,
                      labelText: 'Email',
                      hintText: 'Enter the contact Email',
                      height: formFieldHeight,
                    ),
                    SizedBox(height: padding),
                    _buildTextFormField(
                      controller: _priceController,
                      labelText: 'Phone Number',
                      hintText: 'Enter the contact phone number',
                      height: formFieldHeight,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid number';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: padding),
                    _buildDropdownFormField(),
                    SizedBox(
                        height: padding * 2), // Add spacing before the button
                    CustomButton(
                      text: 'Add Vendor',
                      color: const Color(0xFF2A9D8F),
                      screenWidth: screenWidth,
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          // Add your onTap logic here
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // bottomNavigationBar: CustomBottomNavigationBar(
        //   currentIndex: 0,
        //   onTap: (index) {
        //     // Add navigation logic if needed
        //   },
        // ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required double height,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      height: height,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF2A9D8F), width: 2.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF2A9D8F), width: 1.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownFormField() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Category',
        hintText: 'Select the Service category Offered',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF2A9D8F), width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF2A9D8F), width: 1.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      value: _selectedCategory,
      items: _categories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedCategory = newValue;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a category';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
