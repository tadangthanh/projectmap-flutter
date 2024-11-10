import 'package:map/dto/base_dto.dart';

class SharedLocationDto extends BaseDto {
  double latitude;
  double longitude;
  int receiverId;
  String? receiverName;
  int? senderId;
  String? senderName;
  String? note;

  SharedLocationDto({
    int? id,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.latitude,
    required this.longitude,
    required this.receiverId,
    this.receiverName,
    this.senderId,
    this.senderName,
    this.note,
  }) : super(
    id: id,
    createdBy: createdBy,
    updatedBy: updatedBy,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory SharedLocationDto.fromMap(Map<String, dynamic> map) {
    return SharedLocationDto(
      id: map['id'],
      createdBy: map['createdBy'],
      updatedBy: map['updatedBy'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      receiverId: map['receiverId'] ?? 0,
      receiverName: map['receiverName'],
      senderId: map['senderId'],
      senderName: map['senderName'],
      note: map['note'],
    );
  }

  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'latitude': latitude,
      'longitude': longitude,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'senderId': senderId,
      'senderName': senderName,
      'note': note,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'senderId': senderId,
      'senderName': senderName,
      'note': note,
    };
  }
}