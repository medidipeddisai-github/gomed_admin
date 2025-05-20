import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_admin/models/requestGetModel.dart';
import 'package:gomed_admin/provider/loader.dart';
import 'package:gomed_admin/provider/loginprovider.dart';
import 'package:gomed_admin/utils/gomed_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/retry.dart';
import 'package:http/http.dart' as http;


class RequestProvider extends StateNotifier<RequestGetModel> {
  final Ref ref; // To access other providers
  RequestProvider(this.ref) : super((RequestGetModel.initial()));
    
    Future<void> getRequestedProducts() async {
    final loadingState = ref.read(loadingProvider.notifier);
    try {
      loadingState.state = true;
      // Retrieve the token from SharedPreferences
      print('get Requested Products');
           // ✅ Get token directly from loginProvider model
      final currentUser = ref.read(loginProvider);
      final token = currentUser.data?.first.accessToken;

      if (token == null || token.isEmpty) {
        throw Exception("Access token is missing. Please log in again.");
      }
      print('Retrieved Token: $token');
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
        Uri.parse(Bbapi.getRequestedProducts),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      final responseBody = response.body;
      print('Get Requested Status Code: ${response.statusCode}');
      print('Get Requested Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = json.decode(responseBody);
        // Check if the response body contains
        final requestedProductsData = RequestGetModel.fromJson(res);
        state = requestedProductsData;
        print("Requested products fetched successfully.${requestedProductsData.messages}");
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(responseBody);
        final errorMessage =
            errorBody['message'] ?? "Unexpected error occurred.";
        throw Exception("Error fetching to get requested products: $errorMessage");
      }
    } catch (e) {
      print("Failed to fetch Requested Products: $e");
    }
  }

Future<void> approveproducts(
  BuildContext context, // ✅ Pass BuildContext
  List<Map<String, dynamic>> updated,
  String datas
  
 
) async {
  print(
      'Updating approved products: ID: $updated');

  final loadingState = ref.read(loadingProvider.notifier);

  try {
    loadingState.state = true;
         // ✅ Get token directly from loginProvider model
      final currentUser = ref.read(loginProvider);
      final token = currentUser.data?.first.accessToken;

      if (token == null || token.isEmpty) {
        throw Exception("Access token is missing. Please log in again.");
      }

    print('Retrieved Token: $token');

    final client = RetryClient(
      http.Client(),
      retries: 3,
      when: (response) => response.statusCode == 400 || response.statusCode == 401,
      onRetry: (req, res, retryCount) async {
        if (retryCount == 0 && (res?.statusCode == 400 || res?.statusCode == 401)) {
          String? newAccessToken =
              await ref.read(loginProvider.notifier).restoreAccessToken();
          print('Restored Token for update approce products: $newAccessToken');
          req.headers['Authorization'] = 'Bearer $newAccessToken';
        }
      },
    );

    final response = await client.put(
      Uri.parse("${Bbapi.updateRequestedProducts}"), // API Endpoint
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body:  jsonEncode(updated), // <-- send directly as array
    );

    print("Update approved products and spareparts from api Response: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ products and spareparts approved successfully!");

      getRequestedProducts();
       // Refresh the list of products and spareparts
      
      // ✅ Close the screen before showing the message
      Navigator.pop(context); 

      // ✅ Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:Text("products and spareparts approved successfully!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      print("❌ Failed to approve products and spareparts approved. Status: ${response.statusCode}");

      // ✅ Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to approved products and spareparts."),
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

  
}
  final requestedproductsProvider =
    StateNotifierProvider<RequestProvider, RequestGetModel>((ref) {
  return RequestProvider(ref);
});