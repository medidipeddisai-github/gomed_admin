class ServiceModel {
  final int? statusCode;
  final bool? success;
  final List<String>? messages;
  final List<Data>? data;

  ServiceModel({
    this.statusCode,
    this.success,
    this.messages,
    this.data,
  });

  // Initial values
  factory ServiceModel.initial() {
    return ServiceModel(
      statusCode: 0,
      success: false,
      messages: [],
      data: [],
    );
  }

  // CopyWith method
  ServiceModel copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return ServiceModel(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }

  // JSON Serialization
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      statusCode: json['statusCode'],
      success: json['success'],
      messages: List<String>.from(json['messages'] ?? []),
      data: json['data'] != null
          ? List<Data>.from(json['data'].map((v) => Data.fromJson(v)))
          : [],
    );
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
  final bool? activated;
  final String? adminApproval;
  final String? sId;
  final String? name;
  final String? details;
  final int? price;
  final String? distributorId;
  final List<String>? productIds;
  final String? createdAt;
  final String? updatedAt;
  final int? iV;

  Data({
    this.activated,
    this.adminApproval,
    this.sId,
    this.name,
    this.details,
    this.price,
    this.distributorId,
    this.productIds,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  // Initial values
  factory Data.initial() {
    return Data(
      activated: false,
      adminApproval: "",
      sId: "",
      name: "",
      details: "",
      price: 0,
      distributorId: "",
      productIds: [],
      createdAt: "",
      updatedAt: "",
      iV: 0,
    );
  }

  // CopyWith method
  Data copyWith({
    bool? activated,
    String? adminApproval,
    String? sId,
    String? name,
    String? details,
    int? price,
    String? distributorId,
    List<String>? productIds,
    String? createdAt,
    String? updatedAt,
    int? iV,
  }) {
    return Data(
      activated: activated ?? this.activated,
      adminApproval: adminApproval ?? this.adminApproval,
      sId: sId ?? this.sId,
      name: name ?? this.name,
      details: details ?? this.details,
      price: price ?? this.price,
      distributorId: distributorId ?? this.distributorId,
      productIds: productIds ?? this.productIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      iV: iV ?? this.iV,
    );
  }

  // JSON Serialization
  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      activated: json['activated'],
      adminApproval: json['adminApproval'],
      sId: json['_id'],
      name: json['name'],
      details: json['details'],
      price: json['price'],
      distributorId: json['distributorId'],
      productIds: List<String>.from(json['productIds'] ?? []),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      iV: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activated': activated,
      'adminApproval': adminApproval,
      '_id': sId,
      'name': name,
      'details': details,
      'price': price,
      'distributorId': distributorId,
      'productIds': productIds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': iV,
    };
  }
}