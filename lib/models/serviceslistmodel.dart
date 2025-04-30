class Serviceslistmodel {
  int? statusCode;
  bool? success;
  List<String>? messages;
  List<Data>? data;

  Serviceslistmodel({this.statusCode, this.success, this.messages, this.data});

  factory Serviceslistmodel.initial() => Serviceslistmodel(
        statusCode: 0,
        success: false,
        messages: [],
        data: [],
      );

  Serviceslistmodel copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return Serviceslistmodel(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }

  Serviceslistmodel.fromJson(Map<String, dynamic> json) {
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
  bool? activated;
  String? adminApproval;
  String? sId;
  String? name;
  String? details;
  int? price;
  String? distributorId;
  List<String>? productIds;
  String? createdAt;
  String? updatedAt;
  int? iV;

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

  factory Data.initial() => Data(
        activated: false,
        adminApproval: '',
        sId: '',
        name: '',
        details: '',
        price: 0,
        distributorId: '',
        productIds: [],
        createdAt: '',
        updatedAt: '',
        iV: 0,
      );

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

  Data.fromJson(Map<String, dynamic> json) {
    activated = json['activated'];
    adminApproval = json['adminApproval'];
    sId = json['_id'];
    name = json['name'];
    details = json['details'];
    price = json['price'];
    distributorId = json['distributorId'];
    productIds = json['productIds'].cast<String>();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['activated'] = this.activated;
    data['adminApproval'] = this.adminApproval;
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['details'] = this.details;
    data['price'] = this.price;
    data['distributorId'] = this.distributorId;
    data['productIds'] = this.productIds;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
