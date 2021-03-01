import 'package:meta/meta.dart';

class UserLoginData {
  int status;
  String message;
  final List<Data> data;

  UserLoginData({this.status, this.message, this.data});

  factory UserLoginData.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['data'] as List;
    print(list.runtimeType);
    List<Data> imagesList = list.map((i) => Data.fromJson(i)).toList();

    return UserLoginData(
        status: parsedJson['status'],
       // message: parsedJson['message'],
        data: imagesList);
  }
}

class Data {
  int id;
  String first_name;
  String last_name;
  String mobile;
  String email;
  String city;
  String pincode;
  String picture;
  String password;
  String device;
  String device_id;
  String status;

  Data(
      {this.id,
      this.first_name,
      this.last_name,
      this.mobile,
      this.email,
      this.city,
      this.pincode,
      this.picture,
      this.password,
      this.device,
      this.device_id,
      this.status});

  factory Data.fromJson(Map<String, dynamic> parsedJson) {
    return Data(
      id: parsedJson['id'],
      first_name: parsedJson['first_name'],
      last_name: parsedJson['last_name'],
      mobile: parsedJson['mobile'],
      email: parsedJson['email'],
      city: parsedJson['city'],
      pincode: parsedJson['pincode'],
      picture: parsedJson['picture'],
      password: parsedJson['password'],
      device: parsedJson['device'],
      device_id: parsedJson['device_id'],
      status: parsedJson['status'],
    );
  }
}
