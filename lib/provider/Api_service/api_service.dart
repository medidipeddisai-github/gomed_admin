import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gomed_admin/main.dart'; // to access globalMessengerKey
import 'package:gomed_admin/provider/loginprovider.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global snackbar
void showGlobalSnackBar(String message) {
  globalMessengerKey.currentState?.showSnackBar(
    SnackBar(content: Text(message)),
  );
}

/// ✅ Authenticated GET/POST/PUT/DELETE API
Future<http.Response> safeApiCall({
  required Ref ref,
  required Future<http.Response> Function(RetryClient client) apiCallFn,
  int retries = 3,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');

    if (userDataString == null || userDataString.isEmpty) {
      throw Exception("User token is missing. Please log in again.");
    }

    final userData = jsonDecode(userDataString);
    final token = userData['data'][0]['access_token'];

    if (token == null || token.isEmpty) {
      throw Exception("User token is invalid. Please log in again.");
    }

    final client = RetryClient(
      http.Client(),
      retries: retries,
      when: (res) => res.statusCode == 401,
      onRetry: (req, res, retryCount) async {
        if (retryCount == 0 && res?.statusCode == 401) {
          String? newToken = await ref.read(loginProvider.notifier).restoreAccessToken();
          req.headers['Authorization'] = 'Bearer $newToken';
        }
      },
    );

    final response = await apiCallFn(client);

    if (response.statusCode >= 500) {
      showGlobalSnackBar("Server error: ${response.statusCode}");
    }

    return response;
  } on SocketException {
    showGlobalSnackBar("Network error: Please check your connection.");
    rethrow;
  } catch (e) {
    showGlobalSnackBar("Unexpected error: $e");
    rethrow;
  }
}

/// ✅ Multipart upload (file) API with auth
Future<http.StreamedResponse> safeMultipartCall({
  required Ref ref,
  required Future<http.StreamedResponse> Function(RetryClient client) multipartCallFn,
  int retries = 3,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');

    if (userDataString == null || userDataString.isEmpty) {
      throw Exception("User token is missing. Please log in again.");
    }

    final userData = jsonDecode(userDataString);
    final token = userData['data'][0]['access_token'];

    if (token == null || token.isEmpty) {
      throw Exception("User token is invalid. Please log in again.");
    }

    final client = RetryClient(
      http.Client(),
      retries: retries,
      when: (res) => false, // optional: handle retry manually
    );

    return await multipartCallFn(client);
  } on SocketException {
    showGlobalSnackBar("Network error: Please check your connection.");
    rethrow;
  } catch (e) {
    showGlobalSnackBar("Unexpected error: $e");
    rethrow;
  }
}

/// ✅ Unauthenticated API (e.g. login)
Future<http.Response> safeSimpleApiCall({
  required Future<http.Response> Function() apiCallFn,
}) async {
  try {
    final response = await apiCallFn();
    return response;
  } on SocketException {
    showGlobalSnackBar("Network error: Please check your connection.");
    rethrow;
  } catch (e) {
    showGlobalSnackBar("Unexpected error: $e");
    rethrow;
  }
}
