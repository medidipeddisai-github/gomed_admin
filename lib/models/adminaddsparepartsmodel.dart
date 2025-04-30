class SparePartModel {
  int? statusCode;
  bool? success;
  List<String>? messages;
  List<Data>? data;

  SparePartModel({this.statusCode, this.success, this.messages, this.data});

  factory SparePartModel.initial() {
    return SparePartModel(
      statusCode: 0,
      success: false,
      messages: [],
      data: [],
    );
  }

  SparePartModel copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return SparePartModel(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }

  SparePartModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    messages = json['messages']?.cast<String>();
    if (json['data'] != null) {
      data = (json['data'] as List).map((v) => Data.fromJson(v)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'success': success,
      'messages': messages,
      'data': data?.map((v) => v.toJson()).toList(),
    };
  }
}

class Data {
  String? sparepartId;
  String? sparepartName;
  String? productId;
  String? productName;
  String? price;
  String? description;
  List<String>? sparePartImages;

  Data({
    this.sparepartId,
    this.sparepartName,
    this.productId,
    this.productName,
    this.price,
    this.description,
    this.sparePartImages,
  });

  factory Data.initial() {
    return Data(
      sparepartId: '',
      sparepartName: '',
      productId: '',
      productName: '',
      price: '',
      description: '',
      sparePartImages: [],
    );
  }

  Data copyWith({
    String? sparepartId,
    String? sparepartName,
    String? productId,
    String? productName,
    String? price,
    String? description,
    List<String>? sparePartImages,
  }) {
    return Data(
      sparepartId: sparepartId ?? this.sparepartId,
      sparepartName: sparepartName ?? this.sparepartName,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      description: description ?? this.description,
      sparePartImages: sparePartImages ?? this.sparePartImages,
    );
  }

  Data.fromJson(Map<String, dynamic> json) {
    sparepartId = json['sparepartId'];
    sparepartName = json['sparepartName'];
    productId = json['productId'];
    productName = json['productName'];
    price = json['price'];
    description = json['description'];
    sparePartImages = json['sparePartImages']?.cast<String>();
  }

  Map<String, dynamic> toJson() {
    return {
      'sparepartId': sparepartId,
      'sparepartName': sparepartName,
      'productId': productId,
      'productName': productName,
      'price': price,
      'description': description,
      'sparePartImages': sparePartImages,
    };
  }
}
