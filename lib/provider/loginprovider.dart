import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_admin/provider/loader.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gomed_admin/models/login_model.dart';
import '../utils/gomed_api.dart';
import 'package:http_parser/http_parser.dart';

class LoginNotifier extends StateNotifier<UserModel> {
  final Ref ref;
  LoginNotifier(this.ref) : super(UserModel.initial());

Future<bool> tryAutoLogin() async {
  final prefs = await SharedPreferences.getInstance();

  // Check if the key exists
  if (!prefs.containsKey('userData')) {
    print('No user data found.');
    return false;
  }

  try {
    // Retrieve stored JSON string
   final extractedData =
          json.decode(prefs.getString('userData')!) as Map<String, dynamic>;

    
   if (extractedData.containsKey('statusCode') &&
          extractedData.containsKey('success') &&
          extractedData.containsKey('messages') &&
          extractedData.containsKey('data')) {
    // Decode JSON and map it to the UserModel
    final userModel = UserModel.fromJson((extractedData));
    print("User Model from SharedPreferences: $userModel");
    // Validate necessary fields
    if (userModel.data != null && userModel.data!.isNotEmpty) {
      final firstData = userModel.data![0];
      if (firstData.accessToken == null || firstData.user == null) {
        print('Invalid user data structure.');
        return false;
      }
    }

        // Update the state with the decoded user data
        state = state.copyWith(
          statusCode: userModel.statusCode,
          success: userModel.success,
          messages: userModel.messages,
          data: userModel.data,
        );
      print('Auto-login successful. User ID: ${state.data?[0].user?.sId}');
      return true;
    } else {
      print('User data structure is empty or invalid.');
      return false;
    }
  } catch (e, stackTrace) {
    print('Error during auto-login: $e');
    print(stackTrace);
    return false;
  }
}
  /// Handles the API call for login
Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    const String apiUrl = Bbapi.login;
    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"email": email, "password": password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Login successful. Response: ${response.body}");

        final userDetails = json.decode(response.body);
        final user = UserModel.fromJson(userDetails);
         print("Response: ${response.body}");

        // Debug: Print the user data to check if it's correct
        print("User Data to Save: ${user.toJson()}");

        // Save the user data in SharedPreferences
        final userData = json.encode({
          'statusCode': user.statusCode ?? 0,
          'success': user.success,
          'messages': user.messages,
          'data': user.data?.map((data) => data.toJson()).toList(),
        });

        // Debug: Print userData before saving
        print("User Data to Save in SharedPreferences: $userData");

        await prefs.setString('userData', userData);

        // Update the state
        state = user;
        print("Login state updated: ${state.toJson()}");
        return user;
      } else {
        print("Login failed. Status code: ${response.statusCode}");
        throw Exception(
            "Login failed. Status code: ${response.statusCode}, Body: ${response.body}");
      }
    } catch (e) {
      print("Error during login: $e");
      throw Exception("Login failed. Please check your credentials.");
    }
  }

Future<String> restoreAccessToken() async {
    
    const url = Bbapi.refreshToken; 

    final prefs = await SharedPreferences.getInstance();

    try {
        // Retrieve stored user data
    String? storedUserData = prefs.getString('userData');
    if (storedUserData == null) {
      throw Exception("No stored Admin data found.");
    }

    UserModel user = UserModel.fromJson(json.decode(storedUserData));
    String? currentRefreshToken = user.data?.isNotEmpty == true ? user.data![0].refreshToken : null;

    print("older refreshtoken: $currentRefreshToken");
    print('older access token: ${user.data![0].accessToken}');
    
    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      throw Exception("No valid refresh token found.");
    }

     var response = await http.post(
      Uri.parse(url),
      headers: {  
        'Authorization': 'Bearer $currentRefreshToken',
         'Content-Type': 'application/json; charset=UTF-8',

      },
      body: json.encode({"refresh_token": currentRefreshToken}),
    );

      var userDetails = json.decode(response.body);
      print('restore token response $userDetails');
      switch (response.statusCode) {
        case 401:
          // Handle 401 Unauthorized
          // await logout();
          // await tryAutoLogin();
          print("shared preferance ${prefs.getString('userTokens')}");
      
          break;
       // loading(false); // Update loading state
        case 200:
          print("Refresh access token success");

          // Extract the new access token and refresh token
          final newAccessToken = userDetails['data']['access_token'];
          final newRefreshToken = userDetails['data']['refresh_token'];

          print('New access token: $newAccessToken');
          print('New refresh token: $newRefreshToken');

          // Retrieve existing user data from SharedPreferences
          String? storedUserData = prefs.getString('userData');

          if (storedUserData != null) {
            // Parse the stored user data into a UserModel object
            UserModel user = UserModel.fromJson(json.decode(storedUserData));

            // Update the accessToken and refreshToken in the existing data model
            user = user.copyWith(
              data: [
                user.data![0].copyWith(
                  accessToken: newAccessToken,
                  refreshToken: newRefreshToken,
                ),
              ],
            );
                // Convert the updated UserModel back to JSON
            final updatedUserData = json.encode({
              'statusCode': user.statusCode,
              'success': user.success,
              'messages': user.messages,
              'data': user.data?.map((data) => data.toJson()).toList(),
            });

            // Debug: Print updated user data before saving
            print("Updated User Data to Save in SharedPreferences: $updatedUserData");

            // Save the updated user data in SharedPreferences
            await prefs.setString('userData', updatedUserData);

            // Debug: Print user data after saving
            print("User Data saved in SharedPreferences: ${prefs.getString('userData')}");
            print("updated accesstoken ${user.data![0].accessToken}");

            return newAccessToken; // Return the new access token
          } else {

            // Handle the case where there is no existing user data in SharedPreferences
            print("No user data found in SharedPreferences.");
          }

        // loading(false); // Update loading state
       }
    } on FormatException catch (formatException) {
      print('Format Exception: ${formatException.message}');
      print('Invalid response format.');
    } on HttpException catch (httpException) {
      print('HTTP Exception: ${httpException.message}');
    } catch (e) {
      print('General Exception: ${e.toString()}');
      if (e is Error) {
        print('Stack Trace: ${e.stackTrace}');
      }
    }
    return ''; // Return null in case of any error
 }

   Future<void> updateProfile(
    String? name,
    String? email,
    String? password,
    File? selectedImage,
    WidgetRef ref,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final userModel =
        ref.read(loginProvider); // Retrieve UserModel from the provider
    final userId = userModel.data![0].user?.sId;// Get user ID, default to empty string if null
    final token = userModel
        .data?[0].accessToken; // Get token, default to empty string if null
    final loadingState = ref.read(loadingProvider.notifier);

    // final userId = prefs.getString('userId');
    // final token = prefs.getString('firebaseToken');

    print(
        'name--$name, email--$email, paswword--$password, photo--${selectedImage?.path}');

    if (userId == null || token == null) {
      print('User ID or Firebase token is missing.');
      return;
    }

    final apiUrl = "${Bbapi.updateAdminProfile}/$userId";

    try {
      loadingState.state = true; // Show loading state
      final retryClient = RetryClient(
        http.Client(),
        retries: 4,
        when: (response) {
          return response.statusCode == 400 || response.statusCode == 401
              ? true
              : false;
        },
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 && res?.statusCode == 400 ||
              res?.statusCode == 401) {
            // Here, handle your token restoration logic
            // You can access other providers using ref.read if needed
            var accessToken = await restoreAccessToken();

            //print(accessToken); // Replace with actual token restoration logic
            req.headers['Authorization'] = "Bearer ${accessToken.toString()}";
          }
        },
      );
      final request = http.MultipartRequest('PUT', Uri.parse(apiUrl))
        ..headers.addAll({
          "Authorization": "Bearer $token",
          "Content-Type": "multipart/form-data",
        })
        ..fields['name'] = name ?? ''
        ..fields['email'] = email ?? ''
        ..fields['password'] = password ?? '';

          if (selectedImage != null) {
        if (await selectedImage.exists()) {
          // ✅ Extract file extension
          final fileExtension = selectedImage.path.split('.').last.toLowerCase();

          // ✅ Set the correct content type dynamically
          final contentType = MediaType('image', fileExtension);

          request.files.add(await http.MultipartFile.fromPath(
            'profileImage',
            selectedImage.path,
            contentType: contentType, // ✅ Ensures correct content type
          ));
        } else {
          print("Profile image file does not exist: ${selectedImage.path}");
          throw Exception("Profile image file not found");
        }
      }

      print("Request Fields: ${request.fields}");
      print("Request Headers: ${request.headers}");

      //final response = await request.send();
      //final response = await http.Response.fromStream(response);
      // Send the request using the inner client of RetryClient
      final streamedResponse = await retryClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);
        print("profile outside statuscode:${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("profile inside statuscode:${response.statusCode}");
        print("Admin Profile updated successfully.");

        var userDetails = json.decode(response.body);
        UserModel user = UserModel.fromJson(userDetails);
        print(" updated Response: ${response.body}");

        // Debug: Print the user data to check if it's correct
        print("updated User Data to Save: ${user.toJson()}");

        //state=state.copyWith(messages:userDetails['message'],

        //data: [Data.fromJson(userDetails['user'])],); // Assuming userDetails['user'] maps to the Data model
        state = user;
        final userData = json.encode({
          // 'accessToken': user.data?[0].accessToken,
          'statusCode': user.statusCode,
          'success': user.success,
          'messages': user.messages,
          'data': user.data
              ?.map((data) => data.toJson())
              .toList(), // Serialize all Data objects
        });
        // Debug: Print userData before saving
        print("updated User Data to Save in SharedPreferences: $userData");

        await prefs.setString('userData', userData);
      } else {
        print("Failed to update Admin profile. Status code: ${response.statusCode}");
        print("Response: ${response.body}");
      }
    } catch (e) {
      print("Error while updating profile: $e");
    } finally {
      loadingState.state = false; // Hide loading state
    }
  }

  Future<void> deleteAccount(String?userId, String?token ,BuildContext context) async {
  final String apiUrl = "${Bbapi.deleteAdminProfile}/$userId"; // Replace with your API URL for delete account
  final loadingState = ref.read(loadingProvider.notifier);

  try {
    loadingState.state = true; // Show loading state
    final client = RetryClient(
        http.Client(),
        retries: 4,
        when: (response) {
          return response.statusCode == 401 ? true : false;
        },
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 && res?.statusCode == 401) {
            // Here, handle your token restoration logic
            // You can access other providers using ref.read if needed
            var accessToken = await restoreAccessToken();

            //print(accessToken); // Replace with actual token restoration logic
            req.headers['Authorization'] = accessToken.toString();
          }
        },
      );
    final response = await client.delete(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // Include the token
      },
  
    );

    if (response.statusCode == 200 || response.statusCode == 201) {

        print("delete statuscode:${response.statusCode}");
        print("deleteresponse:${response.body}");
        print("Account (Api) successfully deleted.");

        // Optionally, clear local user data (e.g., shared preferences)
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        
       
      print("Navigating to login screen after account deletion.");
    } else {
      print("Failed to delete account. Status code: ${response.statusCode}");
      print("Response: ${response.body}");
    }
  } catch (e) {
    print("Error while deleting account: $e");
  } finally {
    loadingState.state = false; // Hide loading state
  }
}
}

final loginProvider = StateNotifierProvider<LoginNotifier, UserModel>((ref) {
  return LoginNotifier(ref);
});
