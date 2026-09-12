import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../utils/constants.dart';
import 'api_service_base.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiServiceCompra extends ApiServiceBase {
  ApiServiceCompra({required IOClient client}) : super(client: client);

  /// 🔐 Obtener token JWT desde SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  /// ✅ Crear una nueva compra
  /// Estructura esperada:
  /// {
  ///   "proveedorId": 1,
  ///   "empresaId": 1,
  ///   "fechaCompra": "2026-09-08T10:30:00",
  ///   "total": 1575.50,
  ///   "items": [
  ///     { "productoId": 1, "cantidad": 2, "precioUnitario": 120.00, "subtotal": 600.00 }
  ///   ]
  /// }
  Future<Map<String, dynamic>> crearCompra(Map<String, dynamic> compra) async {
    try {
      final token = await _getToken();
      final endpoint = 'compras';
      final response = await post(endpoint, compra, token: token);
      return response;
    } catch (e) {
      throw Exception('Error al crear la compra: $e');
    }
  }

  /// ✅ Obtener compras paginadas por rango de fechas
  Future<Map<String, dynamic>> getComprasPorRango({
    required int empresaId,
    required DateTime fechaDesde,
    required DateTime fechaHasta,
  }) async {
    try {
      final token = await _getToken();
      final fechaDesdeStr = fechaDesde.toIso8601String().split('T')[0];
      final fechaHastaStr = fechaHasta.toIso8601String().split('T')[0];

      final endpoint =
          "compras/empresa/$empresaId/rango?fechaDesde=$fechaDesdeStr&fechaHasta=$fechaHastaStr&page=0&size=1000";

      final response = await get(endpoint, token: token);
      return response;
    } catch (e) {
      throw Exception('Error al obtener compras: $e');
    }
  }
}