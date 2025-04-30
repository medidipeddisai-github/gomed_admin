class CategoryModel {
  int? statusCode;
  bool? success;
  List<String>? messages;
  List<Data>? data;

  CategoryModel({this.statusCode, this.success, this.messages, this.data});

  /// Initial Factory Method
  factory CategoryModel.initial() => CategoryModel(
        statusCode: 0,
        success: false,
        messages: [],
        data: [],
      );

  /// CopyWith Method
  CategoryModel copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return CategoryModel(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }

  CategoryModel.fromJson(Map<String, dynamic> json) {
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['success'] = success;
    data['messages'] = messages;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? sId;
  String? name;

  Data({this.sId, this.name});

  /// Initial Factory Method
  factory Data.initial() => Data(
        sId: '',
        name: '',
      );

  /// CopyWith Method
  Data copyWith({
    String? sId,
    String? name,
  }) {
    return Data(
      sId: sId ?? this.sId,
      name: name ?? this.name,
    );
  }

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    return data;
  }
}
