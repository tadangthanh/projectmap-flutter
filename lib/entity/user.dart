
import 'dart:convert';

class User {
  int? _id;
  String _name;
  String _googleId;
  String _email;
  String _avatarUrl;
  bool _isLocationSharing;
  int _batteryLevel;
  double _latitude;
  double _longitude;

  User(this._name, this._googleId, this._email, this._avatarUrl, this._isLocationSharing,this._batteryLevel,this._latitude,this._longitude ,{int? id}) : _id = id;


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
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
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

  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'name': _name,
      'googleId': _googleId,
      'email': _email,
      'avatarUrl': _avatarUrl,
      'isLocationSharing': _isLocationSharing? 1 : 0,
      'batteryLevel': _batteryLevel,
      'latitude': _latitude,
      'longitude': _longitude
    };
  }



  // Chuyển đối tượng User thành chuỗi JSON
  String toJson() {
    return jsonEncode(toMap()); // Sử dụng jsonEncode để chuyển đổi Map thành chuỗi JSON
  }
  // Tạo đối tượng User từ chuỗi JSON
  factory User.fromJson(String source) {
    return User.fromMap(jsonDecode(source)); // Sử dụng jsonDecode để chuyển chuỗi JSON thành Map
  }





  int get batteryLevel => _batteryLevel;
  set batteryLevel(int value){ _batteryLevel = value;
  }double get latitude => _latitude;
  set latitude(double value){ _latitude = value; }
  double get longitude => _longitude;
  set longitude(double value){ _longitude = value; }


}
