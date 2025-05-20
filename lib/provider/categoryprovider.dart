import 'dart:convert';
import 'dart:io';

import 'package:gomed_admin/models/categorymodel.dart';
import 'package:gomed_admin/provider/loader.dart';
import 'package:gomed_admin/provider/loginprovider.dart';
import 'package:gomed_admin/utils/gomed_api.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/retry.dart';
import 'package:http_parser/http_parser.dart';


class CategoryNotifier extends StateNotifier<CategoryModel> {
  final Ref ref; // To access other providers
  CategoryNotifier(this.ref) : super((CategoryModel.initial()));


  
  Future<bool> addcategory(
      String?categoryName, 
   ) async {
    print('categoryname:$categoryName');

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
        retries: 3, // Retry up to 3 times
        when: (response) =>
            response.statusCode == 400 ||
            response.statusCode == 401, // Retry on 401 Unauthorized
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 && res?.statusCode == 400 ||
              res?.statusCode == 401) {
            // Handle token restoration logic on the first retry
            String? newAccessToken =
                await ref.read(loginProvider.notifier).restoreAccessToken();

            print('Restored Token add service e: $newAccessToken');
            req.headers['Authorization'] = 'Bearer $newAccessToken';
          }
        },
      );

      final response = await client.post(Uri.parse(Bbapi.addcategory),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "name": categoryName,
            
          }));

      print("Response Body: ${response.body}");

      //  final streamedResponse = await client.send(response);
      // final responseBody = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
            var serviceDetails = json.decode(response.body);
            print('add category response body: $serviceDetails');
          } catch (e) {
            print("⚠️ Invalid response format: ${response.body}");
          }
          print("category added successfully!");
          getcategory();
          return true;
      } else {
        print(
            "Failed to category data to api-Status code: ${response.statusCode}");
         return false;   
      }
    } catch (e) {
      print("Error while sending category data to the API: $e");
      return false;   
    }
  }


  Future<void> getcategory() async {
    final loadingState = ref.read(loadingProvider.notifier);
    try {
      loadingState.state = true;
      // Retrieve the token from SharedPreferences
      print('get category');
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
        Uri.parse(Bbapi.getcategory),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      final responseBody = response.body;
      print('Get category Status Code: ${response.statusCode}');
      print('Get category Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = json.decode(responseBody);
        // Check if the response body contains
        final categoryData = CategoryModel.fromJson(res);
        state = categoryData;
        print("categories fetched successfully.${categoryData.messages}");
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(responseBody);
        final errorMessage =
            errorBody['message'] ?? "Unexpected error occurred.";
        throw Exception("Error fetching catyegories: $errorMessage");
      }
    } catch (e) {
      print("Failed to fetch categories: $e");
    }
  }

  Future<bool> updatecategory(
      String?categoryName,
      String?categoryId,
   ) async {
    print('categoryname:$categoryName');
    print('categoryId:$categoryId');

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
        retries: 3, // Retry up to 3 times
        when: (response) =>
            response.statusCode == 400 ||
            response.statusCode == 401, // Retry on 401 Unauthorized
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 && res?.statusCode == 400 ||
              res?.statusCode == 401) {
            // Handle token restoration logic on the first retry
            String? newAccessToken =
                await ref.read(loginProvider.notifier).restoreAccessToken();

            print('Restored Token add service e: $newAccessToken');
            req.headers['Authorization'] = 'Bearer $newAccessToken';
          }
        },
      );

      final response = await client.put(Uri.parse("${Bbapi.updatecategory}/$categoryId"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "name": categoryName,
            
          }));

      print("Response Body: ${response.body}");

      //  final streamedResponse = await client.send(response);
      // final responseBody = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
            var serviceDetails = json.decode(response.body);
            print('update category response body: $serviceDetails');
          } catch (e) {
            print("⚠️ Invalid response format: ${response.body}");
          }
          print("category updated added successfully!");
          getcategory();
          return true;
      } else {
        print(
            "Failed to category updated data to api-Status code: ${response.statusCode}");
            return false;
      }
    } catch (e) {
      print("Error while sending updated category data to the API: $e");
      return false;
    }
  }

Future<bool> deletecategory(
  String? categoryId
    ) async {
  final loadingState = ref.read(loadingProvider.notifier);
  const String apiUrl = Bbapi.deletecategory;
 
  try {
    
    loadingState.state = true; // Show loading state
         // ✅ Get token directly from loginProvider model
      final currentUser = ref.read(loginProvider);
      final token = currentUser.data?.first.accessToken;

      if (token == null || token.isEmpty) {
        throw Exception("Access token is missing. Please log in again.");
      }

      print('Retrieved Token: $token');
    final client = RetryClient(
      http.Client(),
      retries: 4,
      when: (response) => response.statusCode == 401 || response.statusCode == 400,
      onRetry: (req, res, retryCount) async {
        if (retryCount == 0 && (res?.statusCode == 401 || res?.statusCode == 400)) {
          var accessToken = await ref.watch(loginProvider.notifier).restoreAccessToken();
          req.headers['Authorization'] = 'Bearer $accessToken';
        }
      },
    );

    final response = await client.delete(
      Uri.parse("$apiUrl/$categoryId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    print("Delete category API Response Code: ${response.statusCode}");
    print("Delete category API Response Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ category deleted successfully!");
      return true;
    } else {
      print("❌ Error Deleting category. Response: ${response.body}");
      return false;
    }
  } catch (error) {
    print("❌ Error deleting category: $error");
    return false;
  } finally {
    loadingState.state = false;
  }
}

}

final categoryProvider =StateNotifierProvider<CategoryNotifier,CategoryModel>((ref) {
  return CategoryNotifier(ref);
});