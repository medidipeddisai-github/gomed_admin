import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_admin/models/users.dart';
import 'package:gomed_admin/provider/loader.dart';
import 'package:gomed_admin/provider/loginprovider.dart';
import 'package:gomed_admin/utils/gomed_api.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:flutter/material.dart";

class UsersDataNotifier extends StateNotifier<UsersListModel> {
  final Ref ref;
  UsersDataNotifier(this.ref) : super(UsersListModel.initial());
  
  Future<void> getUsers() async {
    final loadingState = ref.read(loadingProvider.notifier);
    try {
      loadingState.state = true;
      // Retrieve the token from SharedPreferences
      print('get users api');

      
    // ✅ Get token directly from loginProvider model
    final currentUser = ref.read(loginProvider);
    final token = currentUser.data?.first.accessToken;

    if (token == null || token.isEmpty) {
      throw Exception("Access token is missing. Please log in again.");
    }
    
      print('Retrieved Token from users: $token');
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
              if (newAccessToken != null && newAccessToken.isNotEmpty) {
                req.headers['Authorization'] = 'Bearer $newAccessToken';
                print("New token applied: $newAccessToken");
              } else {
                print("Failed to retrieve new access token.");
              }
          }
        },
      );
      final response = await client.get(
        Uri.parse(Bbapi.getusers),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      final responseBody = response.body;
      print('Get usersdata Status Code: ${response.statusCode}');
      print('Get usersdata Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final res = jsonDecode(responseBody);
          final usersData = UsersListModel.fromJson(res);
          state = usersData;
          print("Users fetched successfully: ${usersData.messages}");
        } catch (e) {
          print("Invalid response format: $e");
          throw Exception("Error parsing user data.");
        }
      } else {
        print("Error fetching users: ${response.body}");
        throw Exception("Error fetching users: ${response.body}");
      }
    } catch (e) {
      print("Failed to fetch users: $e");
    }
  }
}

final usersProvider = StateNotifierProvider<UsersDataNotifier, UsersListModel>((ref) {
  return UsersDataNotifier(ref);
});