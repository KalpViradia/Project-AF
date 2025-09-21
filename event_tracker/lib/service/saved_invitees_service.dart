import '../utils/import_export.dart';
import '../utils/api_constants.dart';

class SavedInviteesService {
  final Dio _dio = Get.find<Dio>();
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<UserModel>> getSavedInvitees(String ownerUserId) async {
    final response = await _dio.get('$baseUrl/saved-invitees/$ownerUserId');
    final data = response.data;
    if (data is List) {
      return data.map((e) => UserModel(
        userId: e['UserId'] ?? e['userId'] ?? '',
        name: e['Name'] ?? e['name'] ?? '',
        email: e['Email'] ?? e['email'] ?? '',
        phone: e['Phone'] ?? e['phone'],
        address: e['Address'] ?? e['address'],
        dateOfBirth: e['DateOfBirth']?.toString(),
        isActive: (e['IsActive'] ?? e['isActive']) == 1 || (e['IsActive'] ?? e['isActive']) == true,
        createdAt: DateTime.now(),
      )).toList();
    }
    return <UserModel>[];
  }

  Future<bool> addSavedInvitee(String ownerUserId, String savedUserId) async {
    final response = await _dio.post(
      '$baseUrl/saved-invitees',
      data: {
        'ownerUserId': ownerUserId,
        'savedUserId': savedUserId,
      },
    );
    return response.statusCode == 200;
  }

  Future<bool> removeSavedInvitee(String ownerUserId, String savedUserId) async {
    final response = await _dio.delete('$baseUrl/saved-invitees/$ownerUserId/$savedUserId');
    return response.statusCode == 204;
  }
}
