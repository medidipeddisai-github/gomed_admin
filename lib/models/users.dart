class UsersListModel {
  int? statusCode;
  bool? success;
  List<String>? messages;
  List<Data>? data;

 UsersListModel({this.statusCode, this.success, this.messages, this.data});

 UsersListModel.fromJson(Map<String, dynamic> json) {
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
 UsersListModel copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return UsersListModel(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }

  // Initial method
  static UsersListModel initial() {
    return UsersListModel(
      statusCode: 200, // Default status code
      success: true,   // Default success status
      messages: [],    // Empty list of messages
      data: [],        // Empty list of Data
    );
  }
}

class Data {
  String? sId;
  String? mobile;
  String? password;
  String? role;
  String? name;
  String? email;
  String? address;
  String? employeeNumber;
  String? certificate;
  String? experience;
  String? ownerName;
  List<String>? profileImage;
  String? aadhar;
  String? gstNumber;
  String? firmName;
  int? activity;
  String? products;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data({
    this.sId,
    this.mobile,
    this.password,
    this.role,
    this.name,
    this.email,
    this.address,
    this.employeeNumber,
    this.certificate,
    this.experience,
    this.ownerName,
    this.profileImage,
    this.aadhar,
    this.gstNumber,
    this.firmName,
    this.activity,
    this.products,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    mobile = json['mobile'];
    password = json['password'];
    role = json['role'];
    name = json['name'];
    email = json['email'];
    address = json['address'];
    employeeNumber = json['employeeNumber'];
    certificate = json['certificate'];
    experience = json['experience'];
    ownerName = json['ownerName'];
    profileImage = json['profileImage'] != null
    ? List<String>.from(json['profileImage'])
    : [];
    aadhar = json['aadhar'];
    gstNumber = json['gstNumber'];
    firmName = json['firmName'];
    activity = json['activity'];
    products = json['products'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = this.sId;
    data['mobile'] = this.mobile;
    data['password'] = this.password;
    data['role'] = this.role;
    data['name'] = this.name;
    data['email'] = this.email;
    data['address'] = this.address;
    data['employeeNumber'] = this.employeeNumber;
    data['certificate'] = this.certificate;
    data['experience'] = this.experience;
    data['ownerName'] = this.ownerName;
    data['profileImage'] = this.profileImage;
    data['aadhar'] = this.aadhar;
    data['gstNumber'] = this.gstNumber;
    data['firmName'] = this.firmName;
    data['activity'] = this.activity;
    data['products'] = this.products;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }

  // copyWith method
  Data copyWith({
    String? sId,
    String? mobile,
    String? password,
    String? role,
    String? name,
    String? email,
    String? address,
    String? employeeNumber,
    String? certificate,
    String? experience,
    String? ownerName,
    List<String>? profileImage,
    String? aadhar,
    String? gstNumber,
    String? firmName,
    int? activity,
    String? products,
    String? createdAt,
    String? updatedAt,
    int? iV,
  }) {
    return Data(
      sId: sId ?? this.sId,
      mobile: mobile ?? this.mobile,
      password: password ?? this.password,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
      employeeNumber: employeeNumber ?? this.employeeNumber,
      certificate: certificate ?? this.certificate,
      experience: experience ?? this.experience,
      ownerName: ownerName ?? this.ownerName,
      profileImage: profileImage ?? this.profileImage,
      aadhar: aadhar ?? this.aadhar,
      gstNumber: gstNumber ?? this.gstNumber,
      firmName: firmName ?? this.firmName,
      activity: activity ?? this.activity,
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
      mobile: '',
      password: '',
      role: '',
      name: '',
      email: '',
      address: '',
      employeeNumber: '',
      certificate: '',
      experience: '',
      ownerName: '',
      profileImage: [],
      aadhar: '',
      gstNumber: '',
      firmName: '',
      activity: 0,
      products: '',
      createdAt: '',
      updatedAt: '',
      iV: 0,
    );
  }
}
