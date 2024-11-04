class BaseDto {
  int id;
  String createdBy;
  String updatedBy;
  DateTime createdAt;
  DateTime updatedAt;

  BaseDto({
    required this.id,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  // Phương thức fromJson để khởi tạo từ JSON
  factory BaseDto.fromJson(Map<String, dynamic> json) {
    return BaseDto(
      id: json['id'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Phương thức toJson để chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}