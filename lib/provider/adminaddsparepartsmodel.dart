import 'dart:convert';
import 'dart:io';
import 'package:gomed_admin/models/adminaddsparepartsmodel.dart';
import 'package:gomed_admin/provider/adminaddproductsprovider.dart';
import 'package:gomed_admin/provider/loader.dart';
import 'package:gomed_admin/provider/loginprovider.dart';
import 'package:http/http.dart' as http;
import '../utils/gomed_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/retry.dart';
import 'package:http_parser/http_parser.dart';

class Sparepartprovider extends StateNotifier<SparePartModel> {
  final Ref ref; // To access other providers
  Sparepartprovider(this.ref) : super((SparePartModel.initial()));

  Future<void> addSpareParts(
    String? sparepartName,
    String? description,
    String? categoryid,
    String? parentid,
    List<File>? image,
  ) async {
    final loadingState = ref.read(loadingProvider.notifier);
    // final productState = ref.read(productProvider).data ?? [];

    print(
        'Spare parts data: sparepartName: $sparepartName,  description: $description, categoryid: $categoryid ,parentid: $parentid , count: ${image?.length},');
  try {
     loadingState.state = true;

      // Print images if available
      if (image != null && image.isNotEmpty) {
        print("Images:");
        for (var i = 0; i < image.length; i++) {
          print("Image ${i + 1}: Path = ${image[i].path}");
        }
      } else {
        print("No images available.");
      }

            // ✅ Get token directly from loginProvider model
      final currentUser = ref.read(loginProvider);
      final token = currentUser.data?.first.accessToken;

      if (token == null || token.isEmpty) {
        throw Exception("Access token is missing. Please log in again.");
      }

      // Initialize HTTP retry client
      final client = RetryClient(
        http.Client(),
        retries: 3, // Retry up to 3 times
        when: (response) =>
            response.statusCode == 400 || response.statusCode == 401,
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 &&
              (res?.statusCode == 400 || res?.statusCode == 401)) {
            // Attempt token refresh
            String? newAccessToken =
                await ref.read(loginProvider.notifier).restoreAccessToken();
            req.headers['Authorization'] = 'Bearer $newAccessToken';
          }
        },
      );

      // Constructing your list of products
    List<Map<String, dynamic>> products = [
      {
        "productName": sparepartName ?? "",
        "productDescription": description ?? "",
        "catId":categoryid ??"" ,
        "parentId": parentid ,
      }
    ];

    // Encoding it to JSON
    String encodedProducts = jsonEncode(products);

      // Create HTTP request
      var request = http.MultipartRequest('POST', Uri.parse(Bbapi.add))
        ..headers.addAll({
          "Authorization": "Bearer $token",
          "Content-Type": "multipart/form-data"
        })
        ..fields['products'] = encodedProducts;
       

      // Attach images if available
      if (image != null && image.isNotEmpty) {
        for (var img in image) {
          final fileExtension = img.path.split('.').last.toLowerCase();
          final contentType = MediaType('image', fileExtension);

          request.files.add(await http.MultipartFile.fromPath(
            'productImages',
            img.path,
            contentType: contentType,
          ));
        }
      }

      // Send request
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // Handle response
      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Spare part added successfully!");
      
        ref
            .watch(productProvider.notifier)
            .getProducts(); // Refresh product list
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage =
            errorBody['message'] ?? 'Unexpected error occurred.';
        throw Exception("Error adding spare part: $errorMessage");
      }
    } catch (error) {
      print("Failed to add spare part: $error");
      rethrow;
    } finally {
      loadingState.state = false;
    }
  }

  Future<void> getSpareParts() async {
    final loadingState = ref.read(loadingProvider.notifier);
    final productState = ref.read(sparepartProvider.notifier);

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
          }
        },
      );

      // Sending the GET request
      final response = await client.get(
        Uri.parse(Bbapi.sparepartGet),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      // Handle response
      final responseBody = response.body;
      print('Get spareparts Status Code: ${response.statusCode}');
      print('Get spareparts Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('inside if condition----------');
        final res = json.decode(responseBody);

        final sparePartData = SparePartModel.fromJson(res);
        state = sparePartData;
        print(
            "Updated State: ${state.data}"); // Check if state is actually updating

        print("spareparts fetched successfully.$sparePartData");
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(responseBody);
        final errorMessage =
            errorBody['message'] ?? "Unexpected error occurred.";
        throw Exception("Error fetching spareparts: $errorMessage");
      }
    } catch (error) {
      print("Failed to fetch spareparts: $error");
      rethrow;
    } finally {
      loadingState.state = false;
    }
  }

  Future<bool> updateSparePart(
    String? sparePartName,
    String? description,
    String? category,
    List<File>? images,
    String? sparePartId,
  ) async {
    final loadingState = ref.watch(loadingProvider.notifier);
    loadingState.state = true;
    print(
        'sparepartupdate data sparepartname:$sparePartName,description:$description,image:${images!.length},spareparId:$sparePartId,');

    try {
           // ✅ Get token directly from loginProvider model
      final currentUser = ref.read(loginProvider);
      final token = currentUser.data?.first.accessToken;

      if (token == null || token.isEmpty) {
        throw Exception("Access token is missing. Please log in again.");
      }

      print('Retrieved Token: $token');

      // Validate sparePartId
      // if (sparePartId == null || sparePartId.isEmpty) {
      //   throw Exception("Invalid spare part ID.");
      // }

      // API URL
      final Uri apiUrl = Uri.parse("${Bbapi.sparepartupdate}/$sparePartId");

      // Initialize RetryClient for handling retries
      final client = RetryClient(
        http.Client(),
        retries: 3, // Retry up to 3 times
        when: (response) =>
            response.statusCode == 401 || response.statusCode == 404,
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 &&
              (res?.statusCode == 401 || res?.statusCode == 404)) {
            String? newAccessToken =
                await ref.watch(loginProvider.notifier).restoreAccessToken();
            req.headers['Authorization'] = 'Bearer $newAccessToken';
          }
        },
      );

      // Creating a Multipart Request
      var request = http.MultipartRequest('PUT', apiUrl)
        ..headers['sparepartId'] = sparePartId ?? ''
        ..fields['sparepartName'] = sparePartName ?? ''
        ..fields['description'] = description ?? '';
        // ..fields['price'] = price != null ? price.toString() : '0.0'
        // // ..fields['productName'] = productName ?? ''
        // ..fields['productId'] = productId ?? '';

      // Adding images if present
      if (images!=true && images.isNotEmpty) {
        for (var img in images) {
          final fileExtension = img.path.split('.').last.toLowerCase();

          final contentType = MediaType('image', fileExtension);

          request.files.add(await http.MultipartFile.fromPath(
            'sparePartImages[]', // Ensure this matches the expected field name
            img.path,
            contentType: contentType, // Adjust for actual file type
          ));
        }
      }

      // Sending the request
      final response = await client.send(request);

      // Reading Response
      final responseBody = await response.stream.bytesToString();
      print('Update Status Code: ${response.statusCode}');
      print('Update Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Spare part updated successfully!");
      // Refresh spare parts list
         // Manually update state before fetching new data
        // state = state.copyWith(
        //   data: state.data!.map((sp) {
        //     if (sp.sparepartId == sparePartId) {
        //       return sp.copyWith(
        //         sparepartName: sparePartName,
        //         description: description,
        //         price: price.toString(),
        //         // update other fields as needed
        //       );
        //     }
        //     return sp;
        //   }).toList(),
        // );
        // await getSpareParts();
        // return true;
         await getSpareParts(); // Refresh Spare Parts
      state = SparePartModel(data: [...state.data!]); // Force State Change
      return true;
      
      } else {
        final errorBody = jsonDecode(responseBody);
        final errorMessage =
            errorBody['messages'] != null && errorBody['messages'].isNotEmpty
                ? errorBody['messages'][0]
                : 'Unexpected error occurred.';
        throw Exception("Error updating spare part: $errorMessage");
      }
    } catch (error) {
      print("Failed to update spare part: $error");
      rethrow;
    } finally {
      loadingState.state = false;
    }
  }

  Future<bool> deleteSpareparts(String? sparepartId) async {
    final loadingState = ref.read(loadingProvider.notifier);
    const String apiUrl = Bbapi.sparepartdelete;
  

    try {
      // final prefs = await SharedPreferences.getInstance();
      // String? token = prefs.getString('authToken');

     
      loadingState.state = true; // Show loading state
      // ✅ Get token directly from loginProvider model
      final currentUser = ref.read(loginProvider);
      final token = currentUser.data?.first.accessToken;

      if (token == null || token.isEmpty) {
        throw Exception("Access token is missing. Please log in again.");
      }
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
        Uri.parse("$apiUrl/$sparepartId"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("sparepart deleted successfully!");
         // Remove item from local state before fetching new data
        state = state.copyWith(
          data: state.data!.where((sp) => sp.sparepartId != sparepartId).toList(),
        );
        getSpareParts();
        return true;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            "Error deleting sparepart: ${errorBody['message'] ?? 'Unexpected error occurred.'}");
      }
    } catch (error) {
      throw Exception("Error deleting sparepart: $error");
    }
  }
}

final sparepartProvider =
    StateNotifierProvider<Sparepartprovider, SparePartModel>((ref) {
  return Sparepartprovider(ref);
});