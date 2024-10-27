
import 'dart:convert';

import 'package:map/entity/user.dart';

class UserMove {
  int? _id;
  String _name;
  String _googleId;
  String _email;
  String _avatarUrl;
  bool _isLocationSharing;
  int _batteryLevel;
  double _latitude;
  double _longitude;

  UserMove(this._name, this._googleId, this._email, this._avatarUrl, this._isLocationSharing,this._batteryLevel,this._latitude,this._longitude ,{int? id}) : _id = id;


  bool get isLocationSharing => _isLocationSharing;

  set isLocationSharing(bool value) {
    _isLocationSharing = value;
  }

  String get avatarUrl => _avatarUrl;

  set avatarUrl(String value) {
    _avatarUrl = value;
  }

  String get email => _email;


  set email(String value) {
    _email = value;
  }

  String get googleId => _googleId;

  set googleId(String value) {
    _googleId = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  int? get id => _id;

  set id(int? value) {
    _id = value;
  }
  // Factory constructor để tạo đối tượng User từ một Map
  factory UserMove.fromMap(Map<String, dynamic> map) {
    return UserMove(
        map['name'] ?? '',              // Nếu map['name'] là null, đặt thành ''
        map['googleId'] ?? '',          // Nếu map['googleId'] là null, đặt thành ''
        map['email'] ?? '',             // Nếu map['email'] là null, đặt thành ''
        map['avatarUrl'] ?? '',         // Nếu map['avatarUrl'] là null, đặt thành ''
        map['isLocationSharing'] == 1 ? true : false, // Kiểm tra isLocationSharing
        map['batteryLevel'] ?? 0,      // Nếu map['batteryLevel'] là null, đặt thành ''
        map['latitude'] ?? 0.0,         // Nếu map['latitude'] là null, đặt thành 0.0
        map['longitude'] ?? 0.0,        // Nếu map['longitude'] là null, đặt thành 0.0
        id: map['id']                  // Trường id có thể là null hoặc int
    );
  }
  factory UserMove.fromUser(User user){
    return UserMove(
        user.name,
        user.googleId,
        user.email,
        user.avatarUrl,
        user.isLocationSharing,
        user.batteryLevel,
        user.latitude,
        user.longitude,
        id: user.id
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'name': _name,
      'googleId': _googleId,
      'email': _email,
      'avatarUrl': _avatarUrl,
      'isLocationSharing': _isLocationSharing,
      'batteryLevel': _batteryLevel,
      'latitude': _latitude,
      'longitude': _longitude
    };
  }

  // Tạo đối tượng User từ chuỗi JSON
  factory UserMove.fromJson(String source) {
    return UserMove.fromMap(jsonDecode(source)); // Sử dụng jsonDecode để chuyển chuỗi JSON thành Map
  }





  int get batteryLevel => _batteryLevel;
  set batteryLevel(int value){ _batteryLevel = value;
  }double get latitude => _latitude;
  set latitude(double value){ _latitude = value; }
  double get longitude => _longitude;
  set longitude(double value){ _longitude = value; }


}
