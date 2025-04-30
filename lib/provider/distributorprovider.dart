import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_admin/models/distributors.dart';
import 'package:gomed_admin/models/users.dart';
import 'package:gomed_admin/provider/loader.dart';
import 'package:gomed_admin/provider/loginprovider.dart';
import 'package:gomed_admin/utils/gomed_api.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:flutter/material.dart";

class DistributorNotifier extends StateNotifier<DistributorModel> {
 final Ref ref;
 DistributorNotifier(this.ref) : super(DistributorModel.initial());

  Future<void> getUsers() async {
    final loadingState = ref.read(loadingProvider.notifier);
    try {
      loadingState.state = true;
      // Retrieve the token from SharedPreferences
      print('get distributors');
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
          }
        },
      );
      final response = await client.get(
        Uri.parse(Bbapi.getdistributor),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      final responseBody = response.body;
      print('Get distributors Status Code: ${response.statusCode}');
      print('Get distributors Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = json.decode(responseBody);
        // Check if the response body contains
        final distributordata = DistributorModel.fromJson(res);
        state = distributordata;
        print("distributors fetched successfully.${distributordata.messages}");
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(responseBody);
        final errorMessage =
            errorBody['message'] ?? "Unexpected error occurred.";
        throw Exception("Error fetching distributors: $errorMessage");
      }
    } catch (e) {
      print("Failed to fetch distributors: $e");
    }
  }

Future<bool> updateDistributorStatus(String distributorId, bool newStatus) async {
  final loadingState = ref.read(loadingProvider.notifier);
  print("update distributor status:$newStatus");

    try {
      loadingState.state = true;
      // Retrieve the token from SharedPreferences
    
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
   
    final response = await client.put(
      Uri.parse("${Bbapi.updateDistributor}/$distributorId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "status": newStatus ? "Active" : "Inactive",
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ Distributor status updated successfully!");
      getUsers(); // Refresh the list
      return true;
    } else {
      print("❌ Failed to update status. Status code: ${response.statusCode}");
      return false;
    }
  } catch (e) {
    print("❌ Error updating distributor status: $e");
    return false;
  } finally {
    loadingState.state = false;
  }
}


}

final distributorProvider = StateNotifierProvider<DistributorNotifier, DistributorModel>((ref) {
  return DistributorNotifier(ref);
});