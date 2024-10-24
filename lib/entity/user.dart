
import 'dart:convert';

class User {
  int? _id;
  String _name;
  String _googleId;
  String _email;
  String _avatarUrl;
  bool _isLocationSharing;

  User(this._name, this._googleId, this._email, this._avatarUrl, this._isLocationSharing, {int? id}) : _id = id;


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
      id: map['id'],                  // Trường id có thể là null hoặc int
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
}
