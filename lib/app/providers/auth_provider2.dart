import 'dart:convert';

import 'package:cangrivic/app/services/api_service_auth2.dart';
import 'package:flutter/foundation.dart';
import '../models/auth_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider2 with ChangeNotifier {
  final ApiServiceAuth2 apiServiceAuth2;

  AuthProvider2({required this.apiServiceAuth2});

  bool _isLoading = false;
  String? _errorMessage;
  AuthModel? _authData;
  String? _jwtToken; // Nuevo campo para guardar el token

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthModel? get authData => _authData;
  String? get jwtToken => _jwtToken;

  // Método para obtener token guardado
  Future<String?> getTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  /// Login que primero obtiene el token JWT desde /api/auth/login
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Paso 1: Obtener el token JWT desde headers
      final token = await apiServiceAuth2.getToken(email, password);
      _jwtToken = token;
      print('🔐 Token recibido: $_jwtToken');

      // Paso 2: Obtener los datos del usuario con el token
      final response = await apiServiceAuth2.getUser(
       // 'usuario/login',
        //{
        email,
     password,
        //},
        _jwtToken?.trim(),
      );

      print("Datos de usuario recibidos sin problema");
      _authData = AuthModel.fromJson(response, _jwtToken ?? '');

      print(response);

      // Guardar modelo completo como JSON en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_data', jsonEncode(_authData!.toJson()));
      await prefs.setString('jwt_token', _jwtToken!);

      // GUARDAR DATOS ESPECÍFICOS DEL USUARIO PARA EL DASHBOARD
      await prefs.setString('usuarioNombre', _authData!.usuarioNombre ?? 'Usuario');
      await prefs.setString('usuarioUsername', _authData!.usuarioUsername ?? email);
      await prefs.setString('usuarioTelefono', _authData!.usuarioTelefono ?? 'Sin teléfono');
      await prefs.setInt('empresaId', _authData!.empresaId ?? 0);

      _errorMessage = null;
    } catch (e) {
      _authData = null;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga datos de autenticación guardados al iniciar la app
  Future<void> loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final authDataString = prefs.getString('auth_data');
    final token = prefs.getString('jwt_token');

    if (authDataString != null && authDataString.isNotEmpty) {
      final jsonMap = jsonDecode(authDataString);
      _authData = AuthModel.fromJson(jsonMap, token ?? '');
      _jwtToken = token;
    } else {
      _authData = null;
      _jwtToken = null;
    }

    notifyListeners();
  }

  /// Limpia token y datos al cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_data');
    await prefs.remove('jwt_token');
    _authData = null;
    _jwtToken = null;
    notifyListeners();
  }

  /// Limpia cualquier error registrado
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
