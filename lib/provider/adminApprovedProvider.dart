import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_admin/provider/loader.dart';
import 'package:gomed_admin/provider/loginprovider.dart';
import 'package:gomed_admin/utils/gomed_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/retry.dart';
import 'package:http/http.dart' as http;
import 'package:gomed_admin/models/adminApprovedModel.dart';

class AdminApprovedProvider extends StateNotifier<AdminAprrovedProducts> {
  final Ref ref; // To access other providers
  AdminApprovedProvider(this.ref) : super((AdminAprrovedProducts.initial()));
    
    Future<void> getAdminApprovedProducts() async {
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
        Uri.parse(Bbapi.adminApprovedProducts),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      final responseBody = response.body;
      print('Get admin approved products - Status Code: ${response.statusCode}');
      print('Get admin approved products - Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = json.decode(responseBody);
        // Check if the response body contains
        final approvedData = AdminAprrovedProducts.fromJson(res);
        state = approvedData;
        print("Admin approved products fetched successfully.${approvedData.messages}");
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(responseBody);
        final errorMessage =
            errorBody['message'] ?? "Unexpected error occurred.";
        throw Exception("Error fetching to get admin approved products: $errorMessage");
      }
    } catch (e) {
      print("Failed to fetch to get admin approved products: $e");
    }
  }
}
  final adminApprovedProductsProvider =
    StateNotifierProvider<AdminApprovedProvider, AdminAprrovedProducts>((ref) {
  return AdminApprovedProvider(ref);
});