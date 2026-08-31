import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../utils/constants.dart';
import 'api_service_base.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiServiceClient extends ApiServiceBase {
  //ApiServiceClient({required http.Client client}) : super(client: client);

  ApiServiceClient({required IOClient client}) : super(client: client);

  /// 🔐 Obtener token JWT desde SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  /// ✅ Obtener lista paginada de clientes por empresaId
  Future<List<dynamic>> getClientsPaginated({
    required int empresaId,
    int page = 0,
    int elements = 100,
    String sortBy = 'clienteNombre',
    String sortDirection = 'ASC',
  }) async {
    try {
      final token = await _getToken();
      final endpoint =
          'cliente/empresa/$empresaId?page=$page&elements=$elements&sortBy=$sortBy&sortDirection=$sortDirection';

      final response = await get(endpoint, token: token);

      return response['clientes'] ?? [];
    } catch (e) {
      throw Exception('Error al obtener lista de clientes: $e');
    }
  }

  /// ✅ Obtener cliente individual por ID
  Future<Map<String, dynamic>> getClientById(int clienteId) async {
    try {
      final token = await _getToken();
      final endpoint = 'cliente/$clienteId';

      final response = await get(endpoint, token: token);

      return response;
    } catch (e) {
      throw Exception('Error al obtener cliente por ID: $e');
    }
  }










  /// ✅ Crear nuevo cliente
  Future<Map<String, dynamic>> crearCliente(Map<String, dynamic> clienteData) async {
    try {
      final token = await _getToken();
      final endpoint = 'cliente';

      final response = await post(endpoint, clienteData, token: token);
      return response;
    } catch (e) {
      throw Exception('Error al crear cliente: $e');
    }
  }


}
