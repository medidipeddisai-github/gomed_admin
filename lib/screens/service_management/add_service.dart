import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_admin/provider/serviceengineersprovider.dart';
import 'package:gomed_admin/provider/servicesproviders.dart';
import 'package:gomed_admin/widgets/topbar.dart';
import 'package:gomed_admin/widgets/custom_button.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';


class AddServiceScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends ConsumerState<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  List<String> _selectedServiceIds = []; // Stores selected service IDs
  Map<String, String> _serviceMap = {}; // Maps service IDs to Names
  List<String> _selectedDutyTimings = []; // Stores selected duty timings
  bool _status = false; // For Toggle Switch
  String? _type ; // "add" or "edit"
  String ?_engineerId; // Store engineer ID if editing

  final List<String> dutyTimings = [
    'everyday',
    'weekly',
    'weekends',
    'Flexible Hours'
  ];

  @override
void initState() {
  super.initState();

  Future.microtask(() {
    ref.read(serviceprovider.notifier).getSevices();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      setState(() {
        _serviceNameController.text = args['name'] ?? '';
        _emailController.text = args['email'] ?? '';
        _contactNumberController.text = args['mobile'] ?? '';
        _descriptionController.text = args['description'] ?? '';
        _experienceController.text = args['experience'] != null
            ? args['experience'].toString()
            : ''; // ✅ Ensure it's a string

        _selectedServiceIds = args['serviceIds'] != null
            ? List<String>.from(args['serviceIds'].map((id) => id.toString())) // ✅ Convert to String
            : [];

        _selectedDutyTimings = args['dutyTimings'] != null
            ? List<String>.from(args['dutyTimings']) // ✅ Ensure it's a list
            : [];

        _status = args['status'] ?? false;
        _type = args.containsKey('type') ? args['type'] : "add"; // ✅ Default to "add"
        _engineerId = args['engineerId'] ?? '';

        print("selected service ids: $_selectedServiceIds");
        print("experience: ${_experienceController.text}");
        print("type: $_type");
        print("dutytimings: $_selectedDutyTimings");
      });
    }
  });
}

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(serviceprovider).data ?? [];
        print("selected service ids$_selectedServiceIds");
        print("experience $_experienceController.text");
        print("type $_type");
        print("dutytimings$_selectedDutyTimings");
      

    // Map Service IDs to Service Names
    _serviceMap = {
      for (var service in services) service.sId ?? "": service.name ?? "Unknown"
    };

    List<String> serviceNames = _serviceMap.values.toList();

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              TopBar(
                title: _type == "edit" ? 'Edit Service Engineer' : 'Add Service Engineer',
                onBackPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _serviceNameController,
                        label: 'Engineer Name',
                        hint: 'Enter Engineer Name',
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Enter Email',
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _contactNumberController,
                        label: 'Contact Number',
                        hint: 'Enter Contact Number',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 15),

                      /// **🔹 Multi-Select Services Dropdown**
                      const Text(
                        'Select Services',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                     MultiSelectDialogField(
                          items: _serviceMap.values.map((name) => MultiSelectItem<String>(name, name)).toList(),
                          title: const Text("Select Services"),
                          buttonText: const Text("Choose Services"),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          initialValue: _selectedServiceIds
                              .map((id) => _serviceMap[id]) // ✅ Convert service IDs to service names
                              .where((name) => name != null) // ✅ Remove null values
                              .toList(),
                          onConfirm: (values) {
                            setState(() {
                              _selectedServiceIds = values
                                  .map((name) => _serviceMap.entries
                                      .firstWhere((entry) => entry.value == name,
                                          orElse: () => MapEntry("", ""))
                                      .key)
                                  .where((id) => id.isNotEmpty)
                                  .toList();
                            });
                          },
                        ),

                      const SizedBox(height: 15),

                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Enter Description',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _experienceController,
                        label: 'Experience',
                        hint: 'Enter Experience (Years)',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 15),

                      // **🔹 Duty Timings**
                      const Text('Select Duty Timings[9:00Am to 6:00Pm]', style: TextStyle(fontWeight: FontWeight.bold)),
                      Column(
                        children: dutyTimings.map((timing) {
                          return CheckboxListTile(
                            title: Text(timing),
                            value: _selectedDutyTimings.contains(timing),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedDutyTimings.add(timing);
                                } else {
                                  _selectedDutyTimings.remove(timing);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),

                      // **🔹 Status Toggle Button (Only in Edit Mode)**
                      if (_type == "edit") ...[
                        const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                        SwitchListTile(
                          title: Text(_status ? "Active" : "Inactive"),
                          value: _status,
                          onChanged: (value) {
                            setState(() {
                              _status = value;
                            });
                          },
                        ),
                      ],

                      const SizedBox(height: 25),

                      // **🔹 Submit Button**
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (_type == "edit") {
                              await ref.read(serviceEngineerProvider.notifier).updateEngineer(
                                 context,
                                _engineerId,
                                _serviceNameController.text.trim(),
                                _emailController.text.trim(),
                                _contactNumberController.text.trim(),
                                _descriptionController.text.trim(),
                                _experienceController.text.trim(),
                                _selectedServiceIds,
                                _selectedDutyTimings,
                                _status ? "active" : "inactive",
                              );
                            } else {
                              await ref.read(serviceEngineerProvider.notifier).addServiceEngineer(
                                _serviceNameController.text.trim(),
                                _emailController.text.trim(),
                                _contactNumberController.text.trim(),
                                _descriptionController.text.trim(),
                                _experienceController.text.trim(),
                                _selectedServiceIds,
                                _selectedDutyTimings,
                              );
                            }
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(_type == "edit" ? 'Update Engineer' : 'Add Engineer',style: TextStyle(color:_type =="edit"?Colors.blue:Colors.green),),
                      ),
                    ], 
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // / **🔹 Helper Widget for Text Fields**
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF2A9D8F), width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
    );
  }


  @override
  void dispose() {
    _serviceNameController.dispose();
    _contactNumberController.dispose();
    _descriptionController.dispose();
    super.dispose();
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


// class AddServiceScreen extends ConsumerStatefulWidget {
//   @override
//   ConsumerState<AddServiceScreen> createState() => _AddServiceScreenState();
// }

// class _AddServiceScreenState extends ConsumerState<AddServiceScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _serviceNameController = TextEditingController();
//   final TextEditingController _contactNumberController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _experienceController =TextEditingController();
//   final TextEditingController _emailController =TextEditingController();

//   List<String> _selectedServiceIds = []; // Stores selected service IDs
//   Map<String, String> _serviceMap = {}; // Maps service IDs to Names
//   List<String> _selectedDutyTimings = []; // Stores selected duty timings

//   final List<String> dutyTimings = [
//     'everday',
//     'weekly',
//     'weekends',
//     'Flexible Hours'
//   ];

//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() => ref.read(serviceprovider.notifier).getSevices());
//   }

//   @override
//   Widget build(BuildContext context) {
//     final services = ref.watch(serviceprovider).data ?? [];

//     // Map Service IDs to Service Names
//     _serviceMap = {
//       for (var service in services) service.sId ?? "": service.name ?? "Unknown"
//     };

//     List<String> serviceNames = _serviceMap.values.toList();

//     return SafeArea(
//       child: Scaffold(
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               TopBar(
//                 title: 'Add Service Engineer',
//                 onBackPressed: () {
//                   Navigator.pop(context);
//                 },
//               ),
//               const SizedBox(height: 20),
//               Form(
//                 key: _formKey,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildTextField(
//                         controller: _serviceNameController,
//                         label: 'Engineer Name',
//                         hint: 'Enter Engineer Name',
//                       ),
//                       const SizedBox(height: 15),
//                        _buildTextField(
//                         controller: _emailController,
//                         label: 'email',
//                         hint: 'email',
//                       ),
//                       const SizedBox(height: 15),
//                       _buildTextField(
//                         controller: _contactNumberController,
//                         label: 'Contact Number',
//                         hint: 'Enter Contact Number',
//                         keyboardType: TextInputType.phone,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter a contact number';
//                           } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
//                             return 'Enter a valid 10-digit number';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 15),

//                       /// **🔹 Multi-Select Services Dropdown**
//                       const Text(
//                         'Select Services',
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 5),
//                       MultiSelectDialogField(
//                         items: serviceNames
//                             .map((name) => MultiSelectItem<String>(name, name))
//                             .toList(),
//                         title: const Text("Select Services"),
//                         buttonText: const Text("Choose Services"),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                         initialValue: _selectedServiceIds.map((id) => _serviceMap[id]).toList(),
//                         onConfirm: (values) {
//                           setState(() {
//                             _selectedServiceIds = values
//                                 .map((name) => _serviceMap.entries
//                                     .firstWhere((entry) => entry.value == name,
//                                         orElse: () => MapEntry("", ""))
//                                     .key)
//                                 .where((id) => id.isNotEmpty)
//                                 .toList();
//                           });
//                         },
//                       ),
//                       const SizedBox(height: 15),

//                       _buildTextField(
//                         controller: _descriptionController,
//                         label: 'Description',
//                         hint: 'Enter Description',
//                         maxLines: 3,
//                       ),
//                       const SizedBox(height: 15),
//                       _buildTextField(
//                         controller:_experienceController,
//                         label: 'experience',
//                         hint: 'Enter year experience ',
//                         keyboardType:TextInputType.number
//                       ),
//                       const SizedBox(height: 15),

//                       /// **🔹 Duty Timings (Checkbox)**
//                       const Text(
//                         'Select Duty Timings',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       Column(
//                         children: dutyTimings.map((timing) {
//                           return CheckboxListTile(
//                             title: Text(timing),
//                             value: _selectedDutyTimings.contains(timing),
//                             onChanged: (bool? value) {
//                               setState(() {
//                                 if (value == true) {
//                                   _selectedDutyTimings.add(timing);
//                                 } else {
//                                   _selectedDutyTimings.remove(timing);
//                                 }
//                               });
//                             },
//                           );
//                         }).toList(),
//                       ),

//                       const SizedBox(height: 25),

//                       /// **🔹 Submit Button**
//                     ElevatedButton(
//                       onPressed: () async {
//                         if (_formKey.currentState!.validate()) {
//                           if (_selectedServiceIds.isEmpty) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text("Please select at least one service.")),
//                             );
//                             return;
//                           }
//                           if (_selectedDutyTimings.isEmpty) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text("Please select at least one duty timing.")),
//                             );
//                             return;
//                           }

//                           try {
//                             await ref.read(serviceEngineerProvider.notifier).addServiceEngineer(
//                                _serviceNameController.text.trim(),
//                                _emailController.text.trim(),
//                                _contactNumberController.text.trim(),
//                                _descriptionController.text.trim(),
//                                _experienceController.text.trim(),
//                                _selectedServiceIds, // ✅ Send selected service IDs
//                                _selectedDutyTimings, // ✅ Send selected duty timings
//                             );

//                             _showSnackBar(context, "Service Engineer added successfully!");

//                             Navigator.of(context).pop();

//                             // **Clear Form**
//                             _formKey.currentState!.reset();
//                             setState(() {
//                               _selectedServiceIds.clear();
//                               _selectedDutyTimings.clear();
//                             });
//                           } catch (e) {
//                             _showSnackBar(context, "Error: ${e.toString()}");
//                           }
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF2A9D8F),
//                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12.0),
//                         ),
//                       ),
//                       child: const Text(
//                         'Add Service Engineer',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),

//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /// **🔹 Helper Widget for Text Fields**
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     TextInputType keyboardType = TextInputType.text,
//     int maxLines = 1,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       maxLines: maxLines,
//       decoration: InputDecoration(
//         labelText: label,
//         hintText: hint,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
//         focusedBorder: OutlineInputBorder(
//           borderSide: const BorderSide(color: Color(0xFF2A9D8F), width: 2.0),
//           borderRadius: BorderRadius.circular(12.0),
//         ),
//       ),
//       validator: validator ??
//           (value) {
//             if (value == null || value.isEmpty) {
//               return 'Please enter $label';
//             }
//             return null;
//           },
//     );
//   }


//   @override
//   void dispose() {
//     _serviceNameController.dispose();
//     _contactNumberController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
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
