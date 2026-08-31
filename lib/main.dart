import 'package:cangrivic/app/app.dart'; // Importa el widget raíz de la app
import 'package:cangrivic/app/providers/auth_provider2.dart';
import 'package:cangrivic/app/services/api_service_auth2.dart';
import 'package:http/http.dart' as http; // Importa el paquete HTTP con alias 'http'
import 'package:flutter/material.dart';// Importa Flutter framework para UI
import 'package:http/io_client.dart';
import 'package:provider/provider.dart';

import 'app/services/auto_firmado_temporal.dart'; // Importa Provider para gestión de estado



void main() {
  runApp(
    MultiProvider(
      providers: [
        // Proveedor para ApiService, que necesita un cliente HTTP para hacer peticiones
        Provider<ApiServiceAuth2>(
          //create: (_) => ApiServiceAuth2(client: http.Client()),
            create: (_) => ApiServiceAuth2 (client: IOClient(autoFirmadoTemporal())),


        ),
        // Proveedor para AuthProvider, que depende de ApiService
        ChangeNotifierProvider<AuthProvider2>(
          create: (context) => AuthProvider2(
            // Obtiene ApiService del árbol Provider sin escuchar cambios
            apiServiceAuth2: Provider.of<ApiServiceAuth2>(context, listen: false),
          ),
        ),
      ],
      // El widget raíz de la app que se renderizará
      child: const MyApp(),
    ),
  );
}