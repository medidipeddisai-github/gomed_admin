import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:gomed_admin/models/BookingServices.dart";
import 'package:gomed_admin/provider/loader.dart';
import 'package:gomed_admin/provider/loginprovider.dart';
import 'package:gomed_admin/utils/gomed_api.dart';
import 'package:http/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class BookingServicerNotifier extends StateNotifier<BookingServices> {
  final Ref ref;
  BookingServicerNotifier(this.ref) : super(BookingServices.initial());
  
  Future<void> getBookingServices() async {
    final loadingState = ref.read(loadingProvider.notifier);
    try {
      loadingState.state = true;
      // Retrieve the token from SharedPreferences
      print('get booking services');
      final pref = await SharedPreferences.getInstance();
      String? userDataString = pref.getString('userData');
      if (userDataString == null || userDataString.isEmpty) {
        throw Exception("User token is missing. Please log in again.");
      }
      final Map<String, dynamic> userData = jsonDecode(userDataString);
       String? token = userData['data'][0]['access_token'];
     
    
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
        Uri.parse(Bbapi.getBookingService),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      final responseBody = response.body;
      print('Get service booking Status Code: ${response.statusCode}');
      print('Get  service booking Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = json.decode(responseBody);
        // Check if the response body contains
        final bookingService = BookingServices.fromJson(res);
        state = bookingService;
        print("bookingservices fetched successfully.${bookingService.messages}");
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(responseBody);
        final errorMessage =
            errorBody['message'] ?? "Unexpected error occurred.";
        throw Exception("Error fetching booking services: $errorMessage");
      }
    } catch (e) {
      print("Failed to fetch bookingservices: $e");
    }
  }

Future<bool> updateServiceBookinglist(
  BuildContext context, // ✅ Pass BuildContext
  String? bookingId,
  String? serviceEngineerId
   
) async {

  print('Updating service-booking : ID: $bookingId  and service engineer id-:$serviceEngineerId');

  final loadingState = ref.read(loadingProvider.notifier);

  try {
    loadingState.state = true;
    final prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');

    if (userDataString == null || userDataString.isEmpty) {
      throw Exception("User token is missing from booking_service update. Please log in again.");
    }

    final Map<String, dynamic> userData = jsonDecode(userDataString);
    String? token = userData['data'][0]['access_token'];

    print('Retrieved Token from booking update service: $token');

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
      Uri.parse("${Bbapi.updateproductapi}/$bookingId"), // API Endpoint
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
         "serviceEngineerId":serviceEngineerId,
         "status":"confirmed"
      }),
    );

    print("Update Response from update_bookservice_engineer: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ bookingservice assigning updated successfully!");
      getBookingServices(); 
      
      // ✅ Close the screen before showing the message
      Navigator.pop(context); 

      // ✅ Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("service booking assigned succesfully!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return true;
    } else {
      print("❌ Failed to service booking assigned. Status_code: ${response.statusCode}");

      // ✅ Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to service booking assigning."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
  } catch (e) {
    print("❌ Error while service booking assigning: $e");

    // ✅ Show error message if exception occurs
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: ${e.toString()}"),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    return false;
  } finally {
    loadingState.state = false;
  }
}
}

final bookingserviceProvider = StateNotifierProvider<BookingServicerNotifier, BookingServices>((ref) {
  return BookingServicerNotifier(ref);
});