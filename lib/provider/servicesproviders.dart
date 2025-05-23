import 'dart:convert';
import 'package:gomed_admin/provider/loginprovider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_admin/models/services.dart';
import 'package:gomed_admin/models/users.dart';
import 'package:gomed_admin/provider/loader.dart';
import 'package:gomed_admin/utils/gomed_api.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:flutter/material.dart";

class ServiceNotifier extends StateNotifier<ServiceModel> {
   final Ref ref; 
  ServiceNotifier(this.ref) : super(ServiceModel.initial());
   
   Future<void> getSevices() async {
    final loadingState = ref.read(loadingProvider.notifier);
    try {
      loadingState.state = true;
      // Retrieve the token from SharedPreferences
      print('get service');

       // ✅ Get token directly from loginProvider model
    final currentUser = ref.read(loginProvider);
    final token = currentUser.data?.first.accessToken;

    if (token == null || token.isEmpty) {
      throw Exception("Access token is missing. Please log in again.");
    }
      // final pref = await SharedPreferences.getInstance();
      // String? userDataString = pref.getString('userData');
      // if (userDataString == null || userDataString.isEmpty) {
      //   throw Exception("User token is missing. Please log in again.");
      // }
      // final Map<String, dynamic> userData = jsonDecode(userDataString);
      // String? token = userData['data'][0]['access_token'];
      // String? token = userData['accessToken'];
      // if (token == null || token.isEmpty) {
      //   token = userData['data'] != null &&
      //           (userData['data'] as List).isNotEmpty &&
      //           userData['data'][0]['access_token'] != null
      //       ? userData['data'][0]['access_token']
      //       : null;
      // }
      print('Retrieved Token from services: $token');
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
        Uri.parse(Bbapi.getService),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      final responseBody = response.body;
      print('Get service Status Code: ${response.statusCode}');
      print('Get service Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = json.decode(responseBody);
        // Check if the response body contains
        final serviceData = ServiceModel.fromJson(res);
        state = serviceData;
        print("services fetched successfully.${serviceData.messages}");
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(responseBody);
        final errorMessage =
            errorBody['message'] ?? "Unexpected error occurred.";
        throw Exception("Error fetching services: $errorMessage");
      }
    } catch (e) {
      print("Failed to fetch services: $e");
    }
  }
}

final serviceprovider = StateNotifierProvider<ServiceNotifier, ServiceModel>((ref) {
  return ServiceNotifier(ref);
});