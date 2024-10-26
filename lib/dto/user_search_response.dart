import 'package:map/dto/friend_ship_status.dart';

class UserSearchResponse{
   final String googleId;
   final String name;
   final String email;
   final String avatarUrl;
   final bool friend;
   final FriendShipStatus friendShipStatus;

    UserSearchResponse(this.googleId, this.name, this.email, this.avatarUrl,this.friend, this.friendShipStatus);


    factory UserSearchResponse.fromMap(Map<String, dynamic> map) {
    return UserSearchResponse(
      map['googleId'] ?? '',          // Nếu map['googleId'] là null, đặt thành ''
      map['name'] ?? '',              // Nếu map['name'] là null, đặt thành ''
      map['email'] ?? '',             // Nếu map['email'] là null, đặt thành ''
      map['avatarUrl'] ?? '',         // Nếu map['avatarUrl'] là null, đặt thành ''
      map['friend'] ?? false,       // Nếu map['isFriend'] là null, đặt thành false
      _getFriendShipStatus(map['friendShipStatus']), // Ánh xạ status an toàn hơn
    );
    }
   static FriendShipStatus _getFriendShipStatus(String? status) {
     if (status == null) {
       return FriendShipStatus.NONE; // Giá trị mặc định nếu không tìm thấy
     }
     try {
       return FriendShipStatus.values.firstWhere(
             (element) => element.toString().split('.').last == status,
       );
     } catch (e) {
       return FriendShipStatus.NONE; // Trả về giá trị an toàn nếu không khớp
     }
   }
}