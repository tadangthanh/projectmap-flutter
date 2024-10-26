import 'package:map/dto/user_search_response.dart';

class UserSearchResponsePage{
  int pageNo;
  int pageSize;
  int totalPage;
  int totalItems;
  bool hasNext;
  List<UserSearchResponse> items;

  UserSearchResponsePage({
    required this.pageNo,
    required this.pageSize,
    required this.totalPage,
    required this.totalItems,
    required this.hasNext,
    required this.items,
  });

  factory UserSearchResponsePage.fromMap(Map<String, dynamic> map){
    return UserSearchResponsePage(
      pageNo: map['pageNo'],
      pageSize: map['pageSize'],
      totalPage: map['totalPage'],
      totalItems: map['totalItems'],
      hasNext: map['hasNext'],
      items: List<UserSearchResponse>.from(map['items'].map((e) => UserSearchResponse.fromMap(e))),
    );
  }
}