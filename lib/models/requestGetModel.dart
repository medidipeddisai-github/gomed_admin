class RequestGetModel {
  int? statusCode;
  bool? success;
  List<String>? messages;
  List<Data>? data;

  RequestGetModel({this.statusCode, this.success, this.messages, this.data});

  RequestGetModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    messages = json['messages'].cast<String>();
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['statusCode'] = statusCode;
    data['success'] = success;
    data['messages'] = messages;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  /// ✅ Initial factory
  factory RequestGetModel.initial() => RequestGetModel(
        statusCode: 0,
        success: false,
        messages: [],
        data: [],
      );

  /// ✅ CopyWith
  RequestGetModel copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return RequestGetModel(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }
}

class Data {
  String? distributorId;
  String? productId;
  String? parentId;
  String? productName;
  String? categoryId;
  String? categoryName;
  String? productDescription;
  List<String>? productImages;
  int? price;
  int? quantity;
  String? adminApproval;
  bool? activated;

  Data({
    this.distributorId,
    this.productId,
    this.parentId,
    this.productName,
    this.categoryId,
    this.categoryName,
    this.productDescription,
    this.productImages,
    this.price,
    this.quantity,
    this.adminApproval,
    this.activated,
  });

  Data.fromJson(Map<String, dynamic> json) {
    distributorId = json['distributorId'];
    productId = json['productId'];
    parentId = json['parentId'];
    productName = json['productName'];
    categoryId = json['categoryId'];
    categoryName = json['categoryName'];
    productDescription = json['productDescription'];
    productImages = json['productImages'].cast<String>();
    price = json['price'];
    quantity = json['quantity'];
    adminApproval = json['adminApproval'];
    activated = json['activated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['distributorId'] = distributorId;
    data['productId'] = productId;
    data['parentId'] = parentId;
    data['productName'] = productName;
    data['categoryId'] = categoryId;
    data['categoryName'] = categoryName;
    data['productDescription'] = productDescription;
    data['productImages'] = productImages;
    data['price'] = price;
    data['quantity'] = quantity;
    data['adminApproval'] = adminApproval;
    data['activated'] = activated;
    return data;
  }

  /// ✅ Initial factory
  factory Data.initial() => Data(
        distributorId: '',
        productId: '',
        parentId: '',
        productName: '',
        categoryId: '',
        categoryName: '',
        productDescription: '',
        productImages: [],
        price: 0,
        quantity: 0,
        adminApproval: '',
        activated: false,
      );

  /// ✅ CopyWith
  Data copyWith({
    String? distributorId,
    String? productId,
    String? parentId,
    String? productName,
    String? categoryId,
    String? categoryName,
    String? productDescription,
    List<String>? productImages,
    int? price,
    int? quantity,
    String? adminApproval,
    bool? activated,
  }) {
    return Data(
      distributorId: distributorId ?? this.distributorId,
      productId: productId ?? this.productId,
      parentId: parentId ?? this.parentId,
      productName: productName ?? this.productName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      productDescription: productDescription ?? this.productDescription,
      productImages: productImages ?? this.productImages,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      adminApproval: adminApproval ?? this.adminApproval,
      activated: activated ?? this.activated,
    );
  }
}
