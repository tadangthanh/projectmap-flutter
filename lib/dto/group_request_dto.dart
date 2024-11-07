class GroupRequestDto {
  String name;
  String description;
  List<int> userIds;

  GroupRequestDto({required this.name,required this.description, required this.userIds});

  Map<String, dynamic> toMap() {
    return {
      'name': name??'',
      'description': description??'',
      'userIds': userIds??[],
    };
  }
}
