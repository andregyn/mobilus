import 'dart:async';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:mobifront/utils/utl.dart';
import '../../models/api_response.model.dart';

import 'http_service_interface.dart';

class HttpService implements IHttpService {
  static const FILE_LIMIT = 100;
  static const LOG_RESPONSE = false;

  HttpService();

  @override
  String lastError = "";

  @override
  Future<bool> isOnline() async {
    return true;
    // var de retorno, tomando por padrão pessimista.
    // bool res = false;

    // try {
    //   res = await Utl.checkConnection("cerrado.uperinfo.com.br");
    //   _lastOnline = res;
    // } catch (e) {
    //   Utl.log("Falha ao verificar conectividade", e);
    // }
    // return res;
  }

  final _headers = {
    "X-Requested-With": "XMLHttpRequest",
    "Connection": "Keep-Alive",
    "Accept": "application/json",
  };

  @override
  Future<ApiResponse?> post(String uri, [Map<String, dynamic>? data]) async {
    String url = (uri.startsWith("http"))
        ? uri
        : Uri.encodeFull(getUrl() + (uri.startsWith('/') ? '' : '/') + uri);
    if (await isOnline()) {
      return getDio('POST', url, data);
    }

    return ApiResponse.offline();
  }

  @override
  Future<ApiResponse?> get(String uri) async {
    String url =
        Uri.encodeFull(getUrl() + (uri.startsWith('/') ? '' : '/') + uri);
    if (await isOnline()) {
      return getDio('GET', url);
    }

    return ApiResponse.offline();
  }

  @override
  String getUrl([String? uri]) {
    return "https://mobilus.uperinfo.com.br/api" +
        (uri == null ? "" : (uri.startsWith('/') ? '' : '/') + uri);
  }

  @override
  String getResourceUrl([String? uri]) {
    return "https://mobilus.uperinfo.com.br/storage" +
        (uri == null ? "" : (uri.startsWith('/') ? '' : '/') + uri);
  }

  Future<ApiResponse> getDio(String method, String uri,
      [Map<String, dynamic>? data]) async {
    var dio = Dio();
    if (!Utl.isWeb) {
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }
    var headers = _headers;
    // try {
    //   if (!Utl.emptyOrNull(MainController().token)) {
    //     headers['Authorization'] = "Bearer " + MainController().token;
    //   } else if (!Utl.emptyOrNull(MainController().auth?.accessToken ?? "")) {
    //     headers['Authorization'] =
    //         "Bearer " + MainController().auth!.accessToken;
    //   }
    // } catch (e) {
    //   //só pula
    // }
    Options options = Options(
      method: method,
      sendTimeout: 2000,
      receiveTimeout: 300000,
      followRedirects: false,
      validateStatus: (status) {
        return (status ?? 0) < 500;
      },
      headers: headers,
    );

    int ntries = 0;
    ApiResponse? result;
    String error = "";

    while (ntries < 3) {
      try {
        Utl.startCron();

        var d = await dio
            .request(uri, data: data, options: options)
            .whenComplete(() {
          ntries = 4;
        });
        Utl.stopCron(method + ' ' + uri);
        if (LOG_RESPONSE) Utl.log('RESPONSE', d.data);
        if (d.data.toString().startsWith("<html>") ||
            d.data.toString().startsWith("<!DOCTYPE")) {
          result = ApiResponse(message: "HTML", data: [
            {"document": d.data}
          ]);
        } else if (d.data is Map<String, dynamic>) {
          result = ApiResponse.fromJson(d.data);
        } else {
          result = ApiResponse(message: 'resposta inesperada: ' + d.data);
        }
        return result;
      } on DioError catch (e) {
        if (e.type == DioErrorType.connectTimeout) {
          Utl.log("Erro no $method: TIMEOUT", e.message);
          ntries++;
        } else if ((e.response?.statusCode ?? 0) != 404) {
          Utl.log("Erro no $method ${e.response?.statusCode ?? 0}", e.message);
          ntries = 4;
        }
      } catch (e) {
        Utl.stopCron("Falhou");
        Utl.log("Erro no $method ", e);
        error = e.toString();
        ntries = 4;
      }
    }

    return result ?? ApiResponse(message: 'Erro $method: ' + error);
  }

  @override
  Future<ApiResponse> delete(String uri) async {
    String url =
        Uri.encodeFull(getUrl() + (uri.startsWith('/') ? '' : '/') + uri);
    if (await isOnline()) {
      return getDio('DELETE', url);
    }

    return ApiResponse.offline();
  }

  @override
  Future<ApiResponse> put(String uri, [Map<String, dynamic>? data]) async {
    String url =
        Uri.encodeFull(getUrl() + (uri.startsWith('/') ? '' : '/') + uri);
    if (await isOnline()) {
      return getDio('PUT', url, data);
    }

    return ApiResponse.offline();
  }
}
