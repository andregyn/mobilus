import 'package:mobifront/utils/utl.dart';

class ApiResponse {
  String message = "";
  int recordsTotal = 0;
  List<Map<String, dynamic>> data = [];

  ApiResponse({message = "", recordsTotal = 0, data = const []});

  ApiResponse.fromJson(Map<String, dynamic> json) {
    message = Utl.asString(json['message']);
    recordsTotal = Utl.asInt(json['recordsTotal']);
    if (json['data'] != null) {
      if (json['data'] is List) {
        data = (json['data'] as Iterable)
            .map((m) => m as Map<String, dynamic>)
            .toList();
      } else {
        data = [json['data']];
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['recordsTotal'] = recordsTotal;
    data['data'] = data;
    return data;
  }

  ApiResponse.offline() {
    message =
        "ERRO: Sem internet ou sistema fora do ar. Tente novamente mais tarde";
    data = [];
  }

  bool get ok => (message).toUpperCase() == "OK";
}
