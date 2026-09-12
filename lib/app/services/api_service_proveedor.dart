import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../utils/constants.dart';
import 'api_service_base.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiServiceProveedor extends ApiServiceBase {
  ApiServiceProveedor({required IOClient client}) : super(client: client);

  /// 🔐 Obtener token JWT desde SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  /// ✅ Obtener lista paginada de proveedores por empresaId
  Future<List<dynamic>> getProveedoresPaginated({
    required int empresaId,
    int page = 0,
    int elements = 100,
    String sortBy = 'proveedorNombre',
    String sortDirection = 'ASC',
  }) async {
    try {
      final token = await _getToken();
      final endpoint =
          'proveedor/empresa/$empresaId?page=$page&elements=$elements&sortBy=$sortBy&sortDirection=$sortDirection';

      final response = await get(endpoint, token: token);
      return response['proveedores'] ?? [];
    } catch (e) {
      throw Exception('Error al obtener lista de proveedores: $e');
    }
  }

  /// ✅ Obtener proveedor individual por ID
  Future<Map<String, dynamic>> getProveedorById(int proveedorId) async {
    try {
      final token = await _getToken();
      final endpoint = 'proveedor/$proveedorId';
      final response = await get(endpoint, token: token);
      return response;
    } catch (e) {
      throw Exception('Error al obtener proveedor por ID: $e');
    }
  }

  /// ✅ Crear nuevo proveedor
  Future<Map<String, dynamic>> crearProveedor(
      Map<String, dynamic> proveedorData) async {
    try {
      final token = await _getToken();
      final endpoint = 'proveedor';
      final response = await post(endpoint, proveedorData, token: token);
      return response;
    } catch (e) {
      throw Exception('Error al crear proveedor: $e');
    }
  }
}