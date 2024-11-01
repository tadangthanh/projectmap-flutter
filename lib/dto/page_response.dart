class PageResponse<T> {
  final int pageNo;
  final int pageSize;
  final int totalPage;
  final int totalItems;
  final bool hasNext;
  final List<T> items;

  PageResponse({
    required this.pageNo,
    required this.pageSize,
    required this.totalPage,
    required this.totalItems,
    required this.hasNext,
    required this.items,
  });

  factory PageResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    var itemsJson = json['items'] as List;
    List<T> itemsList = itemsJson.map((item) => fromJsonT(item)).toList();

    return PageResponse(
      pageNo: json['pageNo'] as int,
      pageSize: json['pageSize'] as int,
      totalPage: json['totalPage'] as int,
      totalItems: json['totalItems'] as int,
      hasNext: json['hasNext'] as bool,
      items: itemsList,
    );
  }

  factory PageResponse.fromMap(Map<String, dynamic> map, T Function(dynamic) fromMapT) {
    var itemsMap = map['items'] as List;
    List<T> itemsList = itemsMap.map((item) => fromMapT(item)).toList();

    return PageResponse(
      pageNo: map['pageNo'] as int,
      pageSize: map['pageSize'] as int,
      totalPage: map['totalPage'] as int,
      totalItems: map['totalItems'] as int,
      hasNext: map['hasNext'] as bool,
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson(Object Function(T) toJsonT) {
    return {
      'pageNo': pageNo,
      'pageSize': pageSize,
      'totalPage': totalPage,
      'totalItems': totalItems,
      'hasNext': hasNext,
      'items': items.map((item) => toJsonT(item)).toList(),
    };
  }
}
