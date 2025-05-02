import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gomed_admin/provider/loginprovider.dart';
import 'package:gomed_admin/widgets/topbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:gomed_admin/models/login_model.dart";

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
  User? user;

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Load existing user data when the screen opens
  }

  void _loadUserProfile() {
  final fetchedUser = ref.read(loginProvider).data?.first.user;

  if (fetchedUser != null) {
    setState(() {
      user = fetchedUser;
      nameController.text = user?.name ?? '';
      emailController.text = user?.email ?? '';
    });
  }
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
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
                preferredSize: Size.fromHeight(80),
                child: TopBar(title: 'Update Profile', onBackPressed: () => Navigator.pop(context)),
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
      ),
    );
  }

 Widget _buildImageUploadSection() {
  String? profileImageUrl = (user?.profileImage != null && user!.profileImage!.isNotEmpty)
      ? user!.profileImage!.first
      : null;

  return GestureDetector(
    onTap: _showImageSourceDialog,
    child: Center(
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey[300],
        backgroundImage: _profileImage != null
            ? FileImage(_profileImage!) // user picked image
            : (profileImageUrl != null)
                ? NetworkImage(profileImageUrl) // API image
                : null,
        child: (_profileImage == null && profileImageUrl == null)
            ? const Icon(Icons.camera_alt, size: 40, color: Colors.black54)
            : null,
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
