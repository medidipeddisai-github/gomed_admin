import 'package:flutter/material.dart';
import 'package:gomed_admin/widgets/topbar.dart';
import 'package:gomed_admin/widgets/custom_button.dart';
import 'package:gomed_admin/widgets/bottomnavigation.dart';

class AddCommission extends StatefulWidget {
  @override
  _AddCommissionState createState() => _AddCommissionState();
}

class _AddCommissionState extends State<AddCommission> {
  String? selectedServiceVendor;
  final TextEditingController commissionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Define padding and spacing based on screen height
    double padding = screenHeight * 0.02; // 2% of screen height
    double spacing = screenHeight * 0.015; // 1.5% of screen height

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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align items to the left
                  children: [
                    SizedBox(height: spacing),
                    Text(
                      "Set Commission Rates",
                      style: TextStyle(
                        fontSize: screenHeight * 0.025, // Responsive font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: spacing),
                    Text(
                      "Manage commission rates for services and vendors",
                      style: TextStyle(
                        fontSize: screenHeight * 0.018, // Responsive font size
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: spacing * 2),
                    Text(
                      "Service/Vendor",
                      style: TextStyle(
                        fontSize: screenHeight * 0.022, // Responsive font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: spacing),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Service',
                        hintText: 'Select Service/Vendor',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFF2A9D8F), width: 2.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFF2A9D8F), width: 1.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      value: selectedServiceVendor,
                      items: [
                        DropdownMenuItem(
                          value: 'Service A',
                          child: Text('Service A'),
                        ),
                        DropdownMenuItem(
                          value: 'Vendor B',
                          child: Text('Vendor B'),
                        ),
                        // Add more services/vendors here
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedServiceVendor = value;
                        });
                      },
                    ),
                    SizedBox(height: spacing * 2),
                    Text(
                      "Commission Rate",
                      style: TextStyle(
                        fontSize: screenHeight * 0.022, // Responsive font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: spacing),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commissionController,
                            decoration: InputDecoration(
                              labelText: 'Commission',
                              hintText: 'Enter commission percentage',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFF2A9D8F), width: 2.0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFF2A9D8F), width: 1.0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(
                            width: screenWidth * 0.02), // Increased spacing
                        Text(
                          "%",
                          style: TextStyle(
                            fontSize:
                                screenHeight * 0.022, // Responsive font size
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing * 2),
                    CustomButton(
                      text: 'Save Commission',
                      color: const Color(0xFF2A9D8F),
                      screenWidth: screenWidth, // Pass screenWidth for button
                      onTap: () {
                        // Handle save action here
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
        //     // Handle bottom navigation tap
        //   },
        // ),
      ),
    );
  }
}
