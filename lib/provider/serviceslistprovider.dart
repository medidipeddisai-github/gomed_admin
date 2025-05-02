import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gomed_admin/models/serviceslistmodel.dart';
import 'package:gomed_admin/provider/loader.dart';
import 'package:gomed_admin/provider/loginprovider.dart';
import 'package:gomed_admin/utils/gomed_api.dart';
import 'package:http/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;



class ServicesListNotifier extends StateNotifier<Serviceslistmodel> {
  final Ref ref;
  ServicesListNotifier(this.ref) : super(Serviceslistmodel.initial());
  
  Future<void> getservicesList() async {
    final loadingState = ref.read(loadingProvider.notifier);
    try {
      loadingState.state = true;
      // Retrieve the token from SharedPreferences
      print('get serviceslist');
      final pref = await SharedPreferences.getInstance();
      String? userDataString = pref.getString('userData');
      if (userDataString == null || userDataString.isEmpty) {
        throw Exception("User token is missing. Please log in again.");
      }
      final Map<String, dynamic> userData = jsonDecode(userDataString);
      String? token = userData['data'][0]['access_token'];
      // String? token = userData['accessToken'];
      // if (token == null || token.isEmpty) {
      //   token = userData['data'] != null &&
      //           (userData['data'] as List).isNotEmpty &&
      //           userData['data'][0]['access_token'] != null
      //       ? userData['data'][0]['access_token']
      //       : null;
      // }
      print('Retrieved Token from getservicelist: $token');
      // Initialize RetryClient for handling retries
      final client = RetryClient(
        http.Client(),
        retries: 3, // Retry up to 3 times
        when: (response) =>
            response.statusCode == 401 || response.statusCode == 400,
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 &&
              (res?.statusCode == 401 || res?.statusCode == 400)) {
            String? newAccessToken =
                await ref.read(loginProvider.notifier).restoreAccessToken();
            req.headers['Authorization'] = 'Bearer $newAccessToken';
            print("refreshed serce token $newAccessToken");
          }
          
        },
      );
      final response = await client.get(
        Uri.parse(Bbapi.getserviceslist),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      final responseBody = response.body;
      print('Get servicesList Status Code: ${response.statusCode}');
      print('Get servicesList Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = json.decode(responseBody);
        // Check if the response body contains
        final serviceslist = Serviceslistmodel.fromJson(res);
        state = serviceslist;
        print("productlist fetched successfully.${serviceslist.messages}");
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(responseBody);
        final errorMessage =
            errorBody['message'] ?? "Unexpected error occurred.";
        throw Exception("Error fetching productlist: $errorMessage");
      }
    } catch (e) {
      print("Failed to fetch productlist: $e");
    }
  }
Future<void> updatservicelist(
  BuildContext context, // ✅ Pass BuildContext
  String? serviceId,
  bool? value,
   // Active or Inactive
) async {
  print(
      'Updating productslist : ID: $serviceId');

  final loadingState = ref.read(loadingProvider.notifier);

  try {
    loadingState.state = true;
    final prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');

    if (userDataString == null || userDataString.isEmpty) {
      throw Exception("User token is missing. Please log in again.");
    }

    final Map<String, dynamic> userData = jsonDecode(userDataString);
    String? token = userData['data'][0]['access_token'];
    // String? token = userData['accessToken'];

    // if (token == null || token.isEmpty) {
    //   token = userData['data'] != null &&
    //           (userData['data'] as List).isNotEmpty &&
    //           userData['data'][0]['access_token'] != null
    //       ? userData['data'][0]['access_token']
    //       : null;
    // }

    print('Retrieved Token: $token');

    final client = RetryClient(
      http.Client(),
      retries: 3,
      when: (response) => response.statusCode == 400 || response.statusCode == 401,
      onRetry: (req, res, retryCount) async {
        if (retryCount == 0 && (res?.statusCode == 400 || res?.statusCode == 401)) {
          String? newAccessToken =
              await ref.read(loginProvider.notifier).restoreAccessToken();
          print('Restored Token for update: $newAccessToken');
          req.headers['Authorization'] = 'Bearer $newAccessToken';
        }
      },
    );

    final response = await client.put(
      Uri.parse("${Bbapi.updateserviceapi}/$serviceId"), // API Endpoint
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
         "activated" : true,
      }),
    );

    print("Update Response: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ servicelist updated successfully!");
      getservicesList(); 
      
      // ✅ Close the screen before showing the message
      Navigator.pop(context); 

      // ✅ Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("servicesList updated successfully!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      print("❌ Failed to update serviceslist. Status_code: ${response.statusCode}");

      // ✅ Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update serviceList."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } catch (e) {
    print("❌ Error while updating data: $e");

    // ✅ Show error message if exception occurs
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: ${e.toString()}"),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  } finally {
    loadingState.state = false;
  }
}

 Future<bool> deleteService(String? serviceId) async {
    final loadingState = ref.read(loadingProvider.notifier);
    const String apiUrl = Bbapi.deleteService;
   try {

        loadingState.state = true;
        final prefs = await SharedPreferences.getInstance();
        String? userDataString = prefs.getString('userData');

        if (userDataString == null || userDataString.isEmpty) {
          throw Exception("User token is missing. Please log in again.");
        }


        final Map<String, dynamic> userData = jsonDecode(userDataString);
        String? token = userData['data'][0]['access_token'];
        // String? token = userData['accessToken'];

        // if (token == null || token.isEmpty) {
        //   token = userData['data'] != null &&
        //           (userData['data'] as List).isNotEmpty &&
        //           userData['data'][0]['access_token'] != null
        //       ? userData['data'][0]['access_token']
        //       : null;
        // }

    print('Retrieved Token: $token');
      final client = RetryClient(
        http.Client(),
        retries: 4,
        when: (response) {
          return response.statusCode == 401 || response.statusCode == 400
              ? true
              : false;
        },
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 && res?.statusCode == 401 ||
              res?.statusCode == 400) {
            // Here, handle your token restoration logic
            // You can access other providers using ref.read if needed
            var accessToken =
                await ref.watch(loginProvider.notifier).restoreAccessToken();

            //print(accessToken); // Replace with actual token restoration logic
            req.headers['Authorization'] = 'Bearer $accessToken';
          }
        },
      );

      final response = await client.delete(
        Uri.parse("$apiUrl/$serviceId"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("service deleted successfully!");
        getservicesList();
        return true;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            "Error deleting product: ${errorBody['message'] ?? 'Unexpected error occurred.'}");
      }
    } catch (error) {
      throw Exception("Error deleting service: $error");
    }
  }


}

final servicelistProvider = StateNotifierProvider<ServicesListNotifier, Serviceslistmodel>((ref) {
  return ServicesListNotifier(ref);
});