import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../utils/constants.dart';
import 'api_service_base.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiServiceVenta extends ApiServiceBase {
  //ApiServiceVenta({required http.Client client}) : super(client: client);

  ApiServiceVenta({required IOClient client}) : super(client: client);


  /// 🔐 Obtener token JWT desde SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  /// ✅ Crear una nueva venta
  /// El objeto venta debe tener la estructura:
  /// {
  ///   "clienteId": 123,
  ///   "fechaVenta": "2025-08-22T14:30:00Z",
  ///   "total": 150.50,
  ///   "items": [
  ///     {
  ///       "productoId": 1,
  ///       "cantidad": 2,
  ///       "precioUnitario": 50.0,
  ///       "subtotal": 100.0
  ///     }
  ///   ]
  /// }
  Future<Map<String, dynamic>> crearVenta(Map<String, dynamic> venta) async {
    try {
      final token = await _getToken();
      final endpoint = 'ventas'; // Ajusta según tu endpoint real
      final response = await post(endpoint, venta, token: token);
      return response;
    } catch (e) {
      throw Exception('Error al crear la venta: $e');
    }
  }

  /// ✅ Obtener ventas (opcional)
  Future<List<Map<String, dynamic>>> getVentas({
    int page = 0,
    int elements = 10,
    String sortBy = 'fechaVenta',
    String sortDirection = 'DESC',
  }) async {
    try {
      final token = await _getToken();
      final endpoint =
          'venta?page=$page&elements=$elements&sortBy=$sortBy&sortDirection=$sortDirection';
      final response = await get(endpoint, token: token);
      return (response['ventas'] as List)
          .map<Map<String, dynamic>>((v) => v as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Error al obtener las ventas: $e');
    }
  }

  /// ✅ Obtener ventas paginadas por rango de fechas
  Future<Map<String, dynamic>> getVentasPorRango({
    required int empresaId,
    required DateTime fechaDesde,
    required DateTime fechaHasta,
  }) async {
    try {
      final token = await _getToken(); // Obtener token JWT
      // Convertir fechas a formato yyyy-MM-dd
      final fechaDesdeStr = fechaDesde.toIso8601String().split('T')[0];
      final fechaHastaStr = fechaHasta.toIso8601String().split('T')[0];

      // Endpoint de la API
      final endpoint =
          "ventas/empresa/$empresaId/rango?fechaDesde=$fechaDesdeStr&fechaHasta=$fechaHastaStr&page=0&size=1000";

      // Hacer la petición GET usando el método de la base
      final response = await get(endpoint, token: token);

      // Retornar la respuesta como mapa
      return response;
    } catch (e) {
      throw Exception('Error al obtener ventas: $e');
    }
  }
}
