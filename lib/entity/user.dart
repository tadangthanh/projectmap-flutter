


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
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      map['name'],
      map['googleId'],
      map['email'],
      map['avatarUrl'],
      map['isLocationSharing'] ==1?true:false ,
      id: map['id'],
    );
  }
}
