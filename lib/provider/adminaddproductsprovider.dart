import 'dart:convert';
import 'dart:io';
import 'package:gomed_admin/models/adminaddproductsmodel.dart';
import 'package:gomed_admin/provider/adminaddsparepartsmodel.dart';
import 'package:gomed_admin/provider/loader.dart';
import 'package:gomed_admin/provider/loginprovider.dart';
import 'package:http/http.dart' as http;
import '../utils/gomed_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/retry.dart';
import 'package:http_parser/http_parser.dart';



class ProductProvider extends StateNotifier<ProductModel> {
  final Ref ref; // To access other providers
  ProductProvider(this.ref) : super((ProductModel.initial()));

  // Function to add a product and handle the response
  Future<void> addProduct(
      String? productName,
      String? description,
      String? category,
      String? productid,
      List<File>? image,
     ) async {
    final loadingState = ref.read(loadingProvider.notifier);
    print(
        'addproductdata---$productName,  $description, ${image?.length},$category');
    try {
      loadingState.state = true;
     
      // Print images
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

      print('Retrieved Token: $token');
      // Initialize RetryClient for handling retries
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
            print('new acces Token from addproduct: $newAccessToken');
            req.headers['Authorization'] = 'Bearer $newAccessToken';
          }
        },
      );

      
    // Constructing your list of products
    List<Map<String, dynamic>> products = [
      {
        "productName": productName ?? "",
        "productDescription": description ?? "",
        "catId":category ??"" ,
        "parentid": productid ?? null,
      }
    ];

    // Encoding it to JSON
    String encodedProducts = jsonEncode(products);

    // Adding to the multipart request
    var request = http.MultipartRequest('POST', Uri.parse(Bbapi.add))
      ..headers.addAll({
        "Authorization": "Bearer $token",
        "Content-Type": "multipart/form-data"
      })
      ..fields['products'] = encodedProducts;
            

      // Adding Image File if Present
      if (image != null && image.isNotEmpty) {
        for (var img in image) {
          final fileExtension = img.path.split('.').last.toLowerCase();

          final contentType = MediaType('image', fileExtension);

          request.files.add(await http.MultipartFile.fromPath(
            'productImages', // Ensure this matches the expected field name
            img.path,
            contentType: contentType, // Adjust for actual file type
          ));
        }
      }

      // Sending Request
      // final response = await request.send();
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      // Reading Response
      // final responseBody = await response.stream.bytesToString();
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      try {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        // Continue with the usual process
      } catch (e) {
        print('Error decoding response body: $e');
        // Handle error or throw an exception
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Product added successfully!");
        getProducts(); // Refresh product list
        
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage =
            errorBody['message'] ?? 'Unexpected error occurred.';
        throw Exception("Error adding product: $errorMessage");
      }
    } catch (error) {
      print("Failed to add product: $error");
      rethrow;
    } finally {
      loadingState.state = false;
    }
  }

  Future<void> getProducts() async {
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
          }
        },
      );

      // Sending the GET request
      final response = await client.get(
        Uri.parse(Bbapi.getProduct),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      // .timeout(const Duration(seconds: 10)); // Adding timeout

      // Handle response
      final responseBody = response.body;
      print('Get Products Status Code: ${response.statusCode}');
      print('Get Products Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('inside  products if  condition----------');
        final res = json.decode(responseBody);
        // Check if the response body contains the necessary data
        // if (res.isEmpty || !res.containsKey('data')) {
        //   throw Exception("No data found in the response.");
        // }
        final productData = ProductModel.fromJson(res);
        state = productData;

        // if (productData.data == null || productData.data!.isEmpty) {
        //   throw Exception("No products found.");
        // }

        // Update product state
        // productState.state = productData.data!;
        print("Products fetched successfully.$productData");
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(responseBody);
        final errorMessage =
            errorBody['message'] ?? "Unexpected error occurred.";
        throw Exception("Error fetching products: $errorMessage");
      }
    } catch (error) {
      print("Failed to fetch products: $error");
      rethrow;
    } finally {
      loadingState.state = false;
    }
  }

  Future<bool> updateProduct(
    String? productName,
    String? description,
    String? category,
    String? productId,
    List<File>? image,
  ) async {

    final loadingState = ref.read(loadingProvider.notifier);
    loadingState.state = true;
     print('productupdate data productNamename:$productName,description:$description,image:$image,productIdId:$productId');

    try {
      // Retrieve the token from SharedPreferences
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
            response.statusCode == 401 || response.statusCode == 404,
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 &&
              (res?.statusCode == 401 || res?.statusCode == 404)) {
            String? newAccessToken =
                await ref.read(loginProvider.notifier).restoreAccessToken();
            req.headers['Authorization'] = 'Bearer $newAccessToken';
          }
        },
      );

      // Creating a Multipart Request
      var request =
          http.MultipartRequest('PUT', Uri.parse("${Bbapi.update}/$productId"))
            ..headers.addAll({
              "Authorization": "Bearer $token",
            })
            ..fields['productName'] = productName ?? ""
            ..fields['productDescription'] = description ?? ""
   
            ..fields['category'] = category ?? "";

     
       if (image != null && image.isNotEmpty) {
        for (var img in image) {
          final fileExtension = img.path.split('.').last.toLowerCase();

          final contentType = MediaType('image', fileExtension);

          request.files.add(await http.MultipartFile.fromPath(
            'productImages[]', // Ensure this matches the expected field name
            img.path,
            contentType: contentType, // Adjust for actual file type
          ));
        }
      }

      // Sending Request
      final response = await client.send(request);

      // Reading Response
      final responseBody = await response.stream.bytesToString();
      print('Update Status Code: ${response.statusCode}');
      print('Update Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Product updated successfully!");
        getProducts(); // Refresh product list
        return true;
      } else {
        final errorBody = jsonDecode(responseBody);
        final errorMessage =
            errorBody['message'] ?? 'Unexpected error occurred.';
        throw Exception("Error updating product: $errorMessage");
      }
    } catch (error) {
      print("Failed to update product: $error");
      rethrow;
    } finally {
      loadingState.state = false;
    }
  }

  Future<bool> deleteProduct(String? productId) async {
    final loadingState = ref.read(loadingProvider.notifier);
    const String apiUrl = Bbapi.delete;
   try {
   
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
        Uri.parse("$apiUrl/$productId"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Product deleted successfully!");
        getProducts();
        return true;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            "Error deleting product: ${errorBody['message'] ?? 'Unexpected error occurred.'}");
      }
    } catch (error) {
      throw Exception("Error deleting product: $error");
    }
  }
}

// Define productProvider with ref
final productProvider =
    StateNotifierProvider<ProductProvider,ProductModel>((ref) {
  return ProductProvider(ref);
});