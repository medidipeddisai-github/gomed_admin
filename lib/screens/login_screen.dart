
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../screens/dashboard_screen.dart';
// import '../provider/loginprovider.dart';

// class LoginScreen extends ConsumerStatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends ConsumerState<LoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool isKeyboardVisible = false;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     // Check if user is already logged in when screen initializes
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       setState(() => _isLoading = true);

//       final loginNotifier = ref.read(loginProvider.notifier);
//       bool isLoggedIn = await loginNotifier.tryAutoLogin();

//       if (isLoggedIn && mounted) {
//         // Navigate to dashboard if already logged in
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => DashboardScreen()),
//         );
//       }

//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bottomInset =
//         MediaQuery.of(context).viewInsets.bottom; // Keyboard height
//     final screenHeight = MediaQuery.of(context).size.height;
//     isKeyboardVisible = bottomInset > 0;

//     // Accessing the login provider's state and notifier
//     final userModel = ref.watch(loginProvider);
//     final loginNotifier = ref.read(loginProvider.notifier);

//     // Check if user is successfully authenticated
//     // Look for valid access token in the user model
//     bool isAuthenticated = userModel.data != null &&
//         userModel.data!.isNotEmpty &&
//         userModel.data![0].accessToken != null &&
//         userModel.data![0].accessToken!.isNotEmpty;

//     // Navigate to dashboard if authenticated
//     if (isAuthenticated) {
//       // Use Future.microtask to avoid calling setState during build
//       Future.microtask(() {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => DashboardScreen()),
//         );
//       });
//     }

//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       body: Stack(
//         children: [
//           // Background Gradient
//           Positioned.fill(
//             child: Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Color(0xFF6EE883), // Green color
//                     Color(0xFFFFFFFF), // White color
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // Loading Overlay
//           if (_isLoading)
//             Positioned.fill(
//               child: Container(
//                 color: Colors.black.withOpacity(0.3),
//                 child: const Center(
//                   child: CircularProgressIndicator(),
//                 ),
//               ),
//             ),

//           // Logo Section
//           Positioned(
//             top: isKeyboardVisible ? 30 : screenHeight * 0.10,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: Container(
//                 width: 300,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(30),
//                   child: Image.asset(
//                     'assets/logo.jpg',
//                     width: 300,
//                     height: 100,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // Input Container Section
//           AnimatedPositioned(
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//             top: isKeyboardVisible ? screenHeight * 0.25 : screenHeight * 0.49,
//             left: 0,
//             right: 0,
//             child: Container(
//               width: double.infinity,
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Color(0xFF8ED6F8), // Light blue
//                     Color(0xFFFEFFF9), // Off-white
//                   ],
//                   stops: [0.18, 0.98],
//                 ),
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(160), // Top-left curve
//                 ),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Email/Username Field
//                   TextField(
//                     controller: _emailController,
//                     decoration: InputDecoration(
//                       hintText: 'Email/Username',
//                       filled: true,
//                       fillColor: Colors.grey[200],
//                       prefixIcon: const Icon(Icons.person_outline),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                     keyboardType: TextInputType.emailAddress,
//                     enabled: !_isLoading,
//                   ),
//                   const SizedBox(height: 16),

//                   // Password Field
//                   TextField(
//                     controller: _passwordController,
//                     decoration: InputDecoration(
//                       hintText: 'Password',
//                       filled: true,
//                       fillColor: Colors.grey[200],
//                       prefixIcon: const Icon(Icons.lock_outline),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                     obscureText: true,
//                     enabled: !_isLoading,
//                   ),
//                   const SizedBox(height: 8),

//                   // Forgot Password Link
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: TextButton(
//                       onPressed: _isLoading
//                           ? null
//                           : () {
//                               // Handle forgot password logic here
//                             },
//                       child: const Text(
//                         "Forgot Password?",
//                         style: TextStyle(color: Color(0xFF6418C3)),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 15),

//                   // Login Button
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _isLoading
//                           ? null
//                           : () async {
//                               final email = _emailController.text.trim();
//                               final password = _passwordController.text.trim();

//                               if (email.isEmpty || password.isEmpty) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text(
//                                         "Please enter both email and password."),
//                                     backgroundColor: Colors.red,
//                                   ),
//                                 );
//                                 return;
//                               }

//                               // Set loading state
//                               setState(() => _isLoading = true);

//                               // Trigger provider's login method
//                               try {
//                                 await loginNotifier.login(
//                                   email: email,
//                                   password: password,
//                                 );

//                                 // Note: We don't need to navigate here
//                                 // The state watcher in build() will detect authentication
//                                 // and navigate automatically
//                               } catch (e) {
//                                 // Handle login errors
//                                 if (mounted) {
//                                   setState(() => _isLoading = false);

//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content:
//                                           Text("Login failed: ${e.toString()}"),
//                                       backgroundColor: Colors.red,
//                                     ),
//                                   );
//                                 }
//                               }
//                             },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF0E7AAB),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                       ),
//                       child: _isLoading
//                           ? const SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                   color: Colors.white, strokeWidth: 2))
//                           : const Text(
//                               'Login',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_admin/widgets/bottomnavigation.dart';
import '../screens/dashboard_screen.dart';
import '../provider/loginprovider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isKeyboardVisible = false;

  bool isLoading = false;  // 👉 add this local loading state

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom; // Keyboard height
    final screenHeight = MediaQuery.of(context).size.height;
    isKeyboardVisible = bottomInset > 0;

    // Accessing the login provider's state and notifier
    final loginState = ref.watch(loginProvider);
    final authNotifier = ref.read(loginProvider.notifier);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6EE883), // Green color
                    Color(0xFFFFFFFF), // White color
                  ],
                ),
              ),
            ),
          ),

          // Logo Section
          Positioned(
            top: isKeyboardVisible ? 30 : screenHeight * 0.10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 300,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/logo.jpg',
                    width: 300,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // Input Container Section
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: isKeyboardVisible ? screenHeight * 0.25 : screenHeight * 0.533,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF8ED6F8), // Light blue
                    Color(0xFFFEFFF9), // Off-white
                  ],
                  stops: [0.18, 0.98],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(160), // Top-left curve
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Email/Username Field
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email/Username',
                      filled: true,
                      fillColor: Colors.grey[200],
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      fillColor: Colors.grey[200],
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 8),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Handle forgot password logic here
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Color(0xFF6418C3)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null  // disable button while loading
                          : () async {
                              final email = _emailController.text.trim();
                              final password = _passwordController.text.trim();

                              if (email.isEmpty || password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please enter both email and password."),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                isLoading = true;  // 👉 start loading
                              });

                              try {
                                await authNotifier.login(
                                  email: email,
                                  password: password,
                                );
                                 Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) =>CustomBottomNavigationBar()),
                                  );
                              // ✅ success: you may navigate here
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Something went wrong. Please try again."),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                setState(() {
                                  isLoading = false;  // 👉 stop loading
                                });
                              }
                            },
                    
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E7AAB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
