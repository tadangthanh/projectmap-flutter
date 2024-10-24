import 'package:map/entity/user.dart';

class UserDto{
  String _googleId;
  String _name;
  String _email;
  String _isLocationSharing;
  String _batteryLevel;
  double _latitude;
  double _longitude;

  UserDto(this._googleId, this._name, this._email, this._isLocationSharing, this._batteryLevel, this._latitude, this._longitude);
  Map<String, dynamic> toJson() {
    return {
      'googleId': _googleId,
      'name': _name,
      'email': _email,
      'isLocationSharing': _isLocationSharing,
      'batteryLevel': _batteryLevel,
      'latitude': _latitude,
      'longitude': _longitude,
    };
  }


  Map<String, dynamic> toMap() {
    return {
      'googleId': _googleId,
      'name': _name,
      'email': _email,
      'isLocationSharing': _isLocationSharing,
      'batteryLevel': _batteryLevel,
      'latitude': _latitude,
      'longitude': _longitude,
    };
  }
  factory UserDto.fromUser(User user, String batteryLevel, double latitude, double longitude) {
    return UserDto(
        user.googleId,
        user.name,
        user.email,
        user.isLocationSharing ? 'true' : 'false', // Chuyển đổi bool thành String
        batteryLevel,  // Thông tin mức pin
        latitude,      // Kinh độ của người dùng
        longitude      // Vĩ độ của người dùng
    );
  }


  double get longitude => _longitude;

  set longitude(double value) {
    _longitude = value;
  }

  double get latitude => _latitude;

  set latitude(double value) {
    _latitude = value;
  }

  String get batteryLevel => _batteryLevel;

  set batteryLevel(String value) {
    _batteryLevel = value;
  }

  String get isLocationSharing => _isLocationSharing;

  set isLocationSharing(String value) {
    _isLocationSharing = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get googleId => _googleId;

  set googleId(String value) {
    _googleId = value;
  }
}