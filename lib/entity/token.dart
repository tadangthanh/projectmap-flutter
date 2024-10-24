class Token{
  int? _id;
  String _access_token;
  String _refresh_token;

  Token( this._access_token, this._refresh_token, {int? id}) : _id = id;
  factory Token.fromMap(Map<String, dynamic> map) {
    return Token(
      map['access_token'],
      map['refresh_token'],
      id: map['id'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'access_token': _access_token,
      'refresh_token': _refresh_token,
    };
  }

  String get refresh_token => _refresh_token;

  set refresh_token(String value) {
    _refresh_token = value;
  }

  String get access_token => _access_token;

  set access_token(String value) {
    _access_token = value;
  }

  int? get id => _id;

  set id(int? value) {
    _id = value;
  }
}