import '../../models/api_response.model.dart';

abstract class IHttpService {
  String lastError = "";
  Future<bool> isOnline();
  Future<ApiResponse?> get(String url);
  Future<ApiResponse?> post(String url, [Map<String, dynamic> data]);
  Future<ApiResponse?> put(String url, [Map<String, dynamic> data]);
  Future<ApiResponse?> delete(String url);

  String getUrl([String? uri]);
  String getResourceUrl([String? uri]);
}
