import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_admin/models/serviceengineers.dart';
import 'package:gomed_admin/models/users.dart';
import 'package:gomed_admin/provider/loader.dart';
import 'package:gomed_admin/provider/loginprovider.dart';
import 'package:gomed_admin/utils/gomed_api.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:flutter/material.dart";

class ServiceEngineerNotifier extends StateNotifier<ServiceEngineerModel> {
  final Ref ref;
  ServiceEngineerNotifier(this.ref) : super(ServiceEngineerModel.initial());
   
   Future<void> getUsers() async {
    final loadingState = ref.read(loadingProvider.notifier);
    try {
      loadingState.state = true;
      print('get serviceenginerrs');

     // ✅ Get token directly from loginProvider model
      final currentUser = ref.read(loginProvider);
      final token = currentUser.data?.first.accessToken;

      if (token == null || token.isEmpty) {
        throw Exception("Access token is missing. Please log in again.");
      }
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
        Uri.parse(Bbapi.getServiceengineers),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      print('Get serviceengineers Status Code: ${response.statusCode}');
      print('Get serviceengineers Response Body: ${response.body}');

      // if (response.statusCode == 401) {
      //   print("Token expired, attempting refresh...");
      //   String? newAccessToken =
      //       await ref.read(loginProvider.notifier).restoreAccessToken();

      //   if (newAccessToken.isNotEmpty) {
      //     userData['accessToken'] = newAccessToken;
      //     pref.setString('userData', jsonEncode(userData));

      //     final retryResponse = await http.get(
      //       Uri.parse(Bbapi.getServiceengineers),
      //       headers: {
      //         "Authorization": "Bearer $newAccessToken",
      //       },
      //     );

      //     print('Retry Get serviceengineers Status Code: ${retryResponse.statusCode}');
      //     print('Retry Get serviceengineers Response Body: ${retryResponse.body}');

      //     if (retryResponse.statusCode == 200 || retryResponse.statusCode == 201) {
      //       final res = json.decode(retryResponse.body);
      //       final serviceengineerData = ServiceEngineerModel.fromJson(res);
      //       state = serviceengineerData;
      //       print("serviceengineers fetched successfully.${serviceengineerData.messages}");
      //       return;
      //     }
      //   }
      // }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = json.decode(response.body);
        final serviceengineerData = ServiceEngineerModel.fromJson(res);
        state = serviceengineerData;
        print("serviceengineers fetched successfully.${serviceengineerData.messages}");
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        final errorMessage =
            errorBody['message'] ?? "Unexpected error occurred.";
        throw Exception("Error fetching serviceengineers: $errorMessage");
      }
    } catch (e) {
      print("Failed to fetch serviceengineers: $e");
    }
  }

  Future<void> addServiceEngineer(
      String?engineerName, 
      String? email,
      String? contactNumber,
      String?description,
      String?experience,
      List<String>services,
      List<String> dutyTimings, 
      
      ) async {
    print(
        'service-engineer data: name:$engineerName,  email: $email, contactnumber:$contactNumber, description:$description, experience$experience, servicesids$services, dutytimings$dutyTimings');

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

      final response = await client.post(Uri.parse(Bbapi.addServiceengineer),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "name": engineerName,
            "mobile": contactNumber,
            "role": "serviceEngineer",
            "experience": experience,
            "status": "active",
            "address": "default hyderabad",
            "email": email,
            "serviceIds": services, 
            "description": description,
            "dutyTimings": dutyTimings,
          }));

      print("Response Body: ${response.body}");

      //  final streamedResponse = await client.send(response);
      // final responseBody = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
            var serviceDetails = json.decode(response.body);
            print('Service engineer response body: $serviceDetails');
          } catch (e) {
            print("⚠️ Invalid response format: ${response.body}");
          }
          print("Service engineer added successfully!");
          getUsers();
      } else {
        print(
            "Failed to send service engineer data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error while sending data to the API: $e");
    }
  }

Future<void> updateEngineer(
  BuildContext context, // ✅ Pass BuildContext
  String? engineerId,
  String? engineerName,
  String? email,
  String? contactNumber,
  String? description,
  String? experience,
  List<String> services,
  List<String> dutyTimings,
  String status, // Active or Inactive
) async {
  print(
      'Updating service engineer: ID: $engineerId, Name: $engineerName, Email: $email, Contact: $contactNumber, Description: $description, Experience: $experience, Services: $services, Duty Timings: $dutyTimings, Status: $status');

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
          print('Restored Token for update: $newAccessToken');
          req.headers['Authorization'] = 'Bearer $newAccessToken';
        }
      },
    );

    final response = await client.put(
      Uri.parse("${Bbapi.updateServiceEngineer}/$engineerId"), // API Endpoint
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "name": engineerName,
        "mobile": contactNumber,
        "role": "serviceEngineer",
        "experience": experience,
        "status": status, // Active or Inactive
        "address": "default hyderabad",
        "email": email,
        "serviceIds": services,
        "description": description,
        "dutyTimings": dutyTimings,
      }),
    );

    print("Update Response: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ Service engineer updated successfully!");
      getUsers(); // Refresh the list of users
      
      // ✅ Close the screen before showing the message
      Navigator.pop(context); 

      // ✅ Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Service Engineer updated successfully!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      print("❌ Failed to update service engineer. Status: ${response.statusCode}");

      // ✅ Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update Service Engineer."),
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



 Future<bool> deleteServiceEngineer(String? serviceEngineerId) async {
  final loadingState = ref.read(loadingProvider.notifier);
  const String apiUrl = Bbapi.deleteServiceEngineer;


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
      Uri.parse("$apiUrl/$serviceEngineerId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    print("Delete API Response Code: ${response.statusCode}");
    print("Delete API Response Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ Service engineer deleted successfully!");
      return true;
    } else {
      print("❌ Error Deleting Service Engineer. Response: ${response.body}");
      return false;
    }
  } catch (error) {
    print("❌ Error deleting service engineer: $error");
    return false;
  } finally {
    loadingState.state = false;
  }
}


}

final serviceEngineerProvider = StateNotifierProvider<ServiceEngineerNotifier, ServiceEngineerModel>((ref) {
  return ServiceEngineerNotifier(ref);
});