import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../utils/constants.dart';
import 'api_service_base.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiServiceProducto extends ApiServiceBase {
  //ApiServiceProducto({required http.Client client}) : super(client: client);

  ApiServiceProducto({required IOClient client}) : super(client: client);

  /// 🔐 Obtener token JWT desde SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  /// ✅ Obtener lista de productos activos
  Future<List<Map<String, dynamic>>> getProductos({int empresaId = 1}) async {
    try {
      final token = await _getToken();
      final endpoint = 'producto/empresa/$empresaId';
      print(endpoint);
      final response = await get(endpoint, token: token);

      // Filtrar productos activos y no deshabilitados
      final productos = (response['clientes'] as List)
          .where((p) => p['productoEstado'] == true && p['productoDisabled'] == false)
          .map<Map<String, dynamic>>((p) => {
        'id': p['productoId'],
        'nombre': p['productoNombre'],
        'codigo': p['productoCodigo'],
        'descripcion': p['productoDescripcion'],
        'precio': p['productoPrecio'] ?? 0.0,
      })
          .toList();

      return productos;
    } catch (e) {
      throw Exception('Error al obtener lista de productos: $e');
    }
  }
}
