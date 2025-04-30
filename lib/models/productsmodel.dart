class ProductsModel {
  int? statusCode;
  bool? success;
  List<String>? messages;
  List<Data>? data;

 ProductsModel({this.statusCode, this.success, this.messages, this.data});

  factory ProductsModel.initial() => ProductsModel(
        statusCode: 0,
        success: false,
        messages: [],
        data: [],
      );

 ProductsModel copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return ProductsModel(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }

 ProductsModel.fromJson(Map<String, dynamic> json) {
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
    data['statusCode'] = this.statusCode;
    data['success'] = this.success;
    data['messages'] = this.messages;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? productId;
  String? distributorId;
  String? firmName;
  String? ownerName;
  String? productName;
  String? productDescription;
  double? price;
  String? category;
  String? spareParts;
  List<String>? productImages;
  bool? activated;

  Data({
    this.productId,
    this.distributorId,
    this.firmName,
    this.ownerName,
    this.productName,
    this.productDescription,
    this.price,
    this.category,
    this.spareParts,
    this.productImages,
    this.activated,
  });

  factory Data.initial() => Data(
        productId: '',
        distributorId: '',
        firmName: '',
        ownerName: '',
        productName: '',
        productDescription: '',
        price: 0.0,
        category: '',
        spareParts: '',
        productImages: [],
        activated: false,
      );

  Data copyWith({
    String? productId,
    String? distributorId,
    String? firmName,
    String? ownerName,
    String? productName,
    String? productDescription,
    double? price,
    String? category,
    String? spareParts,
    List<String>? productImages,
    bool? activated,
  }) {
    return Data(
      productId: productId ?? this.productId,
      distributorId: distributorId ?? this.distributorId,
      firmName: firmName ?? this.firmName,
      ownerName: ownerName ?? this.ownerName,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      price: price ?? this.price,
      category: category ?? this.category,
      spareParts: spareParts ?? this.spareParts,
      productImages: productImages ?? this.productImages,
      activated: activated ?? this.activated,
    );
  }

  Data.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    distributorId = json['distributorId'];
    firmName = json['firmName'];
    ownerName = json['ownerName'];
    productName = json['productName'];
    productDescription = json['productDescription'];
    price = (json['price'] is int)
        ? (json['price'] as int).toDouble()
        : json['price'];
    category = json['category'];
    spareParts = json['spareParts'];
    productImages = json['productImages'].cast<String>();
    activated = json['activated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['productId'] = this.productId;
    data['distributorId'] = this.distributorId;
    data['firmName'] = this.firmName;
    data['ownerName'] = this.ownerName;
    data['productName'] = this.productName;
    data['productDescription'] = this.productDescription;
    data['price'] = this.price;
    data['category'] = this.category;
    data['spareParts'] = this.spareParts;
    data['productImages'] = this.productImages;
    data['activated'] = this.activated;
    return data;
  }
}
