import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gomed_admin/provider/loginprovider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminProfile extends ConsumerStatefulWidget {
  const AdminProfile({super.key});

  @override
  ConsumerState<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends ConsumerState<AdminProfile> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final _validationKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Load existing user data when the screen opens
  }

  void _loadUserProfile() {
    // Fetch existing user details from API or local storage
    setState(() {
      nameController.text = "John Doe"; // Replace with actual user name
      emailController.text = "john.doe@example.com"; // Replace with actual email
      _profileImage = null; // Replace with user's existing profile image if available
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        // Check the file size (maximum 2MB)
        final fileSizeInBytes = await imageFile.length();
        const maxFileSize = 2 * 1024 * 1024; // 2MB in bytes

        if (fileSizeInBytes > maxFileSize) {
          _showAlertDialog('Error', 'File size exceeds 2MB. Please select a smaller file.');
        } else {
          setState(() {
            _profileImage = imageFile;
          });
        }
      }
    } catch (e) {
      _showAlertDialog('Error', 'Failed to pick image: $e');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
        backgroundColor: const Color(0xFF2A9D8F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _validationKey,
            child: Column(
              children: [
                _buildImageUploadSection(),
                const SizedBox(height: 20),
                _buildTextField(nameController, "User Name", "Please enter user name"),
                _buildTextField(emailController, "Email", "Please enter email",
                    keyboardType: TextInputType.emailAddress),
                _buildTextField(passwordController, "New Password (optional)", "", obscureText: true),
                _buildTextField(confirmPasswordController, "Confirm Password", "", obscureText: true),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {

                    if (_validationKey.currentState!.validate()) {
                      if (passwordController.text.isNotEmpty &&
                          passwordController.text != confirmPasswordController.text) {
                        _showAlertDialog("Error", "Passwords do not match!");
                        return ;
                        }
                      try {
                          await ref .read(loginProvider.notifier).updateProfile(
                                      nameController.text,
                                      emailController.text,
                                      passwordController.text,
                                      _profileImage,
                                      ref,
                                      );

                              // Clear form fields
                              // productNameController.clear();
                              // priceController.clear();
                              // descriptionController.clear();
                              // categoryController.clear();
                               Navigator.of(context).pop();

                              _showSnackBar(
                                  context, "Profile updated successfully!");
                               
                                
                            } catch (e) {
                              _showSnackBar(context, e.toString());
                            } 

                          // // Call API to update profile
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(
                          //     content: Text("Profile updated successfully!"),
                          //     backgroundColor: Colors.green,
                          //   ),
                          // );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A9D8F),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Update Profile",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Center(
          child: _profileImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _profileImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 40, color: Colors.black54),
                    SizedBox(height: 10),
                    Text("Upload Profile Image", style: TextStyle(color: Colors.black54)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String errorMsg, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (errorMsg.isNotEmpty && (value == null || value.isEmpty)) {
            return errorMsg;
          }
          return null;
        },
      ),
    );
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
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
