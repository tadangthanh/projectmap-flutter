import 'package:map/dto/relation_ship_role.dart';

class UserSearchResponse{
   final String googleId;
   final String name;
   final String email;
   final String avatarUrl;
   final bool friend;
   final RelationshipRole relationshipRole;

    UserSearchResponse(this.googleId, this.name, this.email, this.avatarUrl,this.friend,this.relationshipRole);


    factory UserSearchResponse.fromMap(Map<String, dynamic> map) {
    return UserSearchResponse(
      map['googleId'] ?? '',          // Nếu map['googleId'] là null, đặt thành ''
      map['name'] ?? '',              // Nếu map['name'] là null, đặt thành ''
      map['email'] ?? '',             // Nếu map['email'] là null, đặt thành ''
      map['avatarUrl'] ?? '',         // Nếu map['avatarUrl'] là null, đặt thành ''
      map['friend'] ?? false,       // Nếu map['isFriend'] là null, đặt thành fals
      _getRelationShipRole(map['relationshipRole']), // Nếu map['relationshipRole'] là null, đặt thành ''
    );
    }
   static RelationshipRole _getRelationShipRole(String? role) {
     if (role == null) {
       return RelationshipRole.NONE; // Giá trị mặc định nếu không tìm thấy
     }
     try {
       return RelationshipRole.values.firstWhere(
             (element) => element.toString().split('.').last == role,
       );
     } catch (e) {
       return RelationshipRole.NONE; // Trả về giá trị an toàn nếu không khớp
     }
   }
}