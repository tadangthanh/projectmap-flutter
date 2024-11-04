class GroupRequestDto {
  String? name;
  String? description;
  List<int> userIds;

  GroupRequestDto({this.name, this.description, required this.userIds});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'userIds': userIds,
    };
  }
}
