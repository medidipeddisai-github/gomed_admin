class UserModel {
  final int? statusCode;
  final bool? success;
  final List<String>? messages;
  final List<Data>? data;

  UserModel({
    this.statusCode,
    this.success,
    this.messages,
    this.data,
  });

  /// ✅ **Initial values to prevent null issues**
  factory UserModel.initial() {
    return UserModel(
      statusCode: 0,
      success: false,
      messages: [],
      data: [],
    );
  }

  /// ✅ **CopyWith method to modify specific fields**
  UserModel copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return UserModel(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      statusCode: json['statusCode'],
      success: json['success'],
      messages: json['messages'] != null ? List<String>.from(json['messages']) : [],
      data: json['data'] != null
          ? List<Data>.from(json['data'].map((x) => Data.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'success': success,
      'messages': messages,
      'data': data?.map((x) => x.toJson()).toList(),
    };
  }
}

class Data {
  final String? accessToken;
  final String? refreshToken;
  final User? user;

  Data({
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  /// ✅ **Initial method to avoid null values**
  factory Data.initial() {
    return Data(
      accessToken: "",
      refreshToken: "",
      user: User.initial(),
    );
  }

  /// ✅ **CopyWith method**
  Data copyWith({
    String? accessToken,
    String? refreshToken,
    User? user,
  }) {
    return Data(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
    );
  }

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user?.toJson(),
    };
  }
}

class User {
  final String? sId;
  final String? mobile;
  final String? password;
  final String? role;
  final String? name;
  final String? email;
  final String? address;
  final String? employeeNumber;
  final String? certificate;
  final String? experience;
  final String? ownerName;
  final List<String>? profileImage;
  final String? aadhar;
  final String? gstNumber;
  final String? firmName;
  final String? activity;
  final String? products;
  final Location? location;

  User({
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
    this.location,
  });

  /// ✅ **Initial values to avoid null errors**
  factory User.initial() {
    return User(
      sId: "",
      mobile: "",
      password: "",
      role: "",
      name: "",
      email: "",
      address: "",
      employeeNumber: "",
      certificate: "",
      experience: "",
      ownerName: "",
      profileImage: [],
      aadhar: "",
      gstNumber: "",
      firmName: "",
      activity: "",
      products: "",
      location: Location.initial(),
    );
  }

  /// ✅ **CopyWith method**
  User copyWith({
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
    String? activity,
    String? products,
    Location? location,
  }) {
    return User(
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
      location: location ?? this.location,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      sId: json['_id'],
      mobile: json['mobile'],
      password: json['password'],
      role: json['role'],
      name: json['name'],
      email: json['email'],
      address: json['address'],
      employeeNumber: json['employeeNumber'],
      certificate: json['certificate'],
      experience: json['experience'],
      ownerName: json['ownerName'],
      profileImage :json['profileImage'] != null ? List<String>.from(json['profileImage']) : [],
      aadhar: json['aadhar'],
      gstNumber: json['gstNumber'],
      firmName: json['firmName'],
      activity: json['activity'],
      products: json['products'],
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'mobile': mobile,
      'password': password,
      'role': role,
      'name': name,
      'email': email,
      'address': address,
      'employeeNumber': employeeNumber,
      'certificate': certificate,
      'experience': experience,
      'ownerName': ownerName,
      'profileImage': profileImage,
      'aadhar': aadhar,
      'gstNumber': gstNumber,
      'firmName': firmName,
      'activity': activity,
      'products': products,
      'location': location?.toJson(),
    };
  }
}

class Location {
  final String? latitude;
  final String? longitude;

  Location({this.latitude, this.longitude});

  /// ✅ **Initial values**
  factory Location.initial() {
    return Location(
      latitude: "",
      longitude: "",
    );
  }

  /// ✅ **CopyWith method**
  Location copyWith({
    String? latitude,
    String? longitude,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
