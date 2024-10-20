class PlacePrediction {
   int? id;
   String description;
   String placeId;
   String mainText;
   String secondaryText;
   DateTime createdAt;
  // final List<String> types;

  PlacePrediction(this.description, this.placeId, this.mainText, this.secondaryText,this.createdAt,{int? id}) : id = id;

  // Factory method to create an instance from a JSON object
  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
     json['description'] as String,
      json['place_id'] as String,
      json['structured_formatting']['main_text'] as String,
      json['structured_formatting']?['secondary_text'] as String? ?? '',
      DateTime.now(),
      // types: List<String>.from(json['types'] as List<dynamic>),
    );
  }
  factory PlacePrediction.fromMap(Map<String, dynamic> map) {
    return PlacePrediction(
      map['description'] as String,
      map['placeId'] as String,
      map['mainText'] as String,
      map['secondaryText'] as String,
      DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      id: map['id'] as int,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'placeId': placeId,
      'mainText': mainText,
      'secondaryText': secondaryText,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
