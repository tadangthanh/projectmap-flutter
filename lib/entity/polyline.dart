class PolylineResponse{
  final String encodedPolyline;
  PolylineResponse(this.encodedPolyline);
  factory PolylineResponse.fromJson(Map<String, dynamic> json){
    return PolylineResponse(json['encodedPolyline']);
  }
}