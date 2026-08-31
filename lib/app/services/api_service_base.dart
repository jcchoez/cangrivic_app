import 'dart:convert';
import 'package:cangrivic/app/services/auto_firmado_temporal.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../utils/constants.dart';

class ApiServiceBase {
  /*final http.Client client;

  ApiServiceBase({required this.client});*/

  final IOClient client;

  ApiServiceBase({IOClient? client})
      : client = client ?? IOClient(autoFirmadoTemporal());




  Future<dynamic> get(String endpoint, {String? token}) async {
    final headers = {
      /*'Content-Type': 'application/json',*/
      'Content-Type': 'application/json; charset=utf-8', // ✅ Agregar charset
      'Accept': 'application/json; charset=utf-8',       // ✅ Agregar accept charset
      if (token != null) 'Authorization': 'Bearer ${token.trim()}',
    };

    final response = await client
        .get(Uri.parse('${AppConstants.apiBaseUrl}/$endpoint'), headers: headers)
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body, {String? token}) async {
    final headers = {
      /*'Content-Type': 'application/json',*/
      'Content-Type': 'application/json; charset=utf-8', // ✅ Agregar charset
      'Accept': 'application/json; charset=utf-8',       // ✅ Agregar accept charset
      if (token != null) 'Authorization': 'Bearer ${token.trim()}',
    };

    print(headers);

    print('${AppConstants.apiBaseUrl}/$endpoint');
    final response = await client
        .post(
           Uri.parse('${AppConstants.apiBaseUrl}/$endpoint'),
           headers: headers,
           body: jsonEncode(body),
           encoding: Encoding.getByName('utf-8'),
        )
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }


  /*
  dynamic _handleResponse(http.Response response) {
    final responseBody = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      throw Exception(responseBody['message'] ?? 'Error en la solicitud: ${response.statusCode}');
    }
  }*/

  dynamic _handleResponse(http.Response response) {
    // Forzar decodificación UTF-8 desde los bytes
    final String responseBodyUtf8 = utf8.decode(response.bodyBytes);
    final Map<String, dynamic> responseBody = jsonDecode(responseBodyUtf8);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Éxito
      return responseBody;
    } else {
      // Construir un mensaje más completo para Flutter
      String errorMessage = responseBody['message'] ?? 'Error en la solicitud: ${response.statusCode}';

      // Si existe un objeto 'errors', anexarlo al mensaje
      if (responseBody.containsKey('errors') && responseBody['errors'] is Map) {
        final fieldErrors = responseBody['errors'] as Map<String, dynamic>;
        if (fieldErrors.isNotEmpty) {
          final fieldMessages = fieldErrors.entries.map((e) => '${e.key}: ${e.value}').join(', ');
          errorMessage = '$errorMessage ($fieldMessages)';
        }
      }

      throw Exception(errorMessage);
    }
  }



}
