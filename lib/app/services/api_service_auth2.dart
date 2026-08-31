// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../utils/constants.dart';
import 'api_service_base.dart'; // ✔ Herencia correcta

class ApiServiceAuth2 extends ApiServiceBase {
  /*ApiServiceAuth2({required http.Client client}) : super(client: client);*/

  ApiServiceAuth2({required IOClient client}) : super(client: client);

  /// ✅ Obtener el token JWT desde /auth/login
  Future<String> getToken(String username, String password) async {
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}/auth/login');
      print("Solicitando token para $username");


      print("url $url");

      print("usuarioUsername':"+ username + "usuarioPassword "+  password);

      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.headers['authorization'];
        print('Token recibido: $token');
        if (token != null && token.isNotEmpty) {
          return token;
        } else {
          throw Exception('El token no fue proporcionado en el header Authorization.');
        }
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Error al autenticar usuario');
      }
    } catch (e) {
      throw Exception('Error al obtener token: $e');
    }
  }

  /// ✅ Obtener información del usuario autenticado usando token
  Future<dynamic> getUser(String username, String password, String? token) async {
    try {
      print('Llamada a usuario/getUser con token');

      final body = {
        'usuarioUsername': username,
        'usuarioPassword': password,
      };

      // ✔ Llama a post() desde ApiServiceBase, usando headers con el token
      final response = await post('usuario/login', body, token: token);

      print("Respuesta recibida usuario/login");
      return response;
    } catch (e) {
      throw Exception('Error de conexión en getUser: $e');
    }
  }
}
