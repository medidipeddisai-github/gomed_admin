class DistributorModel {
  int? statusCode;
  bool? success;
  List<String>? messages;
  List<Data>? data;

  DistributorModel({this.statusCode, this.success, this.messages, this.data});

  DistributorModel.fromJson(Map<String, dynamic> json) {
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

  // copyWith method
  DistributorModel copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return DistributorModel(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }

  // Initial method
  static DistributorModel initial() {
    return DistributorModel(
      statusCode: 200, // Default status code
      success: true,   // Default success status
      messages: [],    // Empty list of messages
      data: [],        // Empty list of Data
    );
  }
}

class Data {
  String? sId;
  String? name;
  String? mobile;
  String? firmName;
  String? gstNumber;
  String? role;
  String? email;
  String? address;
  List<String>? distributorImage;
  String?ownerName;
  String? status;
  List<dynamic>? products; // Changed from List<Null> to List<dynamic>
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data({
    this.sId,
    this.name,
    this.mobile,
    this.firmName,
    this.gstNumber,
    this.role,
    this.email,
    this.address,
    this.distributorImage,
    this.ownerName,
    this.status,
    this.products,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    mobile = json['mobile'];
    firmName = json['firmName'];
    gstNumber = json['gstNumber'];
    role = json['role'];
    email = json['email'];
    address = json['address'];
    distributorImage = json['distributorImage'].cast<String>();
    ownerName=json["ownerName"];
    status = json['status'];
    products = json['products'] ?? [];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['mobile'] = this.mobile;
    data['firmName'] = this.firmName;
    data['gstNumber'] = this.gstNumber;
    data['role'] = this.role;
    data['email'] = this.email;
    data['address'] = this.address;
    data['distributorImage'] = this.distributorImage;
    data['ownerName']=this.ownerName;
    data['status'] = this.status;
    data['products'] = this.products;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }

  // copyWith method
  Data copyWith({
    String? sId,
    String? name,
    String? mobile,
    String? firmName,
    String? gstNumber,
    String? role,
    String? email,
    String? address,
    List<String>? distributorImage,
    String?ownerName,
    String? status,
    List<dynamic>? products,
    String? createdAt,
    String? updatedAt,
    int? iV,
  }) {
    return Data(
      sId: sId ?? this.sId,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      firmName: firmName ?? this.firmName,
      gstNumber: gstNumber ?? this.gstNumber,
      role: role ?? this.role,
      email: email ?? this.email,
      address: address ?? this.address,
      distributorImage: distributorImage ?? this.distributorImage,
      ownerName:ownerName??this.ownerName,
      status: status ?? this.status,
      products: products ?? this.products,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      iV: iV ?? this.iV,
    );
  }

  // Initial method
  static Data initial() {
    return Data(
      sId: '',
      name: '',
      mobile: '',
      firmName: '',
      gstNumber: '',
      role: '',
      email: '',
      address: '',
      distributorImage: [],
      ownerName:'',
      status: '',
      products: [],
      createdAt: '',
      updatedAt: '',
      iV: 0,
    );
  }
}
