class TokenResponse {
  int? _id;
  String _accessToken;
  String _refreshToken;

  TokenResponse(this._accessToken, this._refreshToken, {int? id}) : _id = id;

  String get refreshToken => _refreshToken;

  set refreshToken(String value) {
    _refreshToken = value;
  }

  String get accessToken => _accessToken;

  set accessToken(String value) {
    _accessToken = value;
  }

  factory TokenResponse.fromMap(Map<String, dynamic> map) {
    return TokenResponse(
      map['accessToken'] ?? '', // Nếu map['accessToken'] là null, đặt thành ''
      map['refreshToken'] ?? '',
      // Nếu map['refreshToken'] là null, đặt thành ''
      id: map['id'] ?? 0, // Nếu map['id'] là null, đặt thành 0
    );
  }

  int? get id => _id;

  set id(int? value) {
    _id = value;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'accessToken': _accessToken,
      'refreshToken': _refreshToken,
    };
  }
}
