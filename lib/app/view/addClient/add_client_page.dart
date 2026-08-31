/*import 'package:cangrivic/app/services/api_service_client.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auto_firmado_temporal.dart';

class AddClientPage extends StatefulWidget {
  @override
  _AddClientPageState createState() => _AddClientPageState();
}

class _AddClientPageState extends State<AddClientPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _identificacionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();

  bool _guardandoCliente = false;
  bool _clienteGuardado = false;
  Map<String, dynamic>? _clienteCreado;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Agregar Nuevo Cliente"),
        backgroundColor: Colors.blue[700],
      ),
      body: _guardandoCliente
          ? _buildLoadingScreen()
          : _clienteGuardado
          ? _buildSuccessScreen()
          : _buildClientForm(),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text("Guardando cliente...", style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 80),
          SizedBox(height: 20),
          Text("¡Cliente Creado Exitosamente!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,),
          SizedBox(height: 10),
          Text("ID: ${_clienteCreado?['clienteId']}", style: TextStyle(fontSize: 18)),
          Text("Nombre: ${_clienteCreado?['clienteNombre']}", style: TextStyle(fontSize: 16)),
          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: Icon(Icons.home),
            label: Text("Volver al Inicio"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Campo Nombres
            TextFormField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: "Nombres *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese los nombres';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Campo Identificación/RUC
            TextFormField(
              controller: _identificacionController,
              decoration: InputDecoration(
                labelText: "Identificación/RUC *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese la identificación';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Campo Teléfono
            TextFormField(
              controller: _telefonoController,
              decoration: InputDecoration(
                labelText: "Teléfono *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el teléfono';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Campo Correo
            TextFormField(
              controller: _correoController,
              decoration: InputDecoration(
                labelText: "Correo Electrónico",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty && !value.contains('@')) {
                  return 'Ingrese un correo válido';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Campo Dirección
            TextFormField(
              controller: _direccionController,
              decoration: InputDecoration(
                labelText: "Dirección *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese la dirección';
                }
                return null;
              },
            ),
            SizedBox(height: 30),

            // Botón Guardar
            ElevatedButton(
              onPressed: _guardarCliente,
              child: Text("Guardar Cliente", style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarCliente() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _guardandoCliente = true;
      });

      try {
        // Obtener empresaId de SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final empresaId = prefs.getInt('empresaId') ?? 0; // Valor por defecto

        print(empresaId);


        final clienteData = {
          "clienteNombre": _nombreController.text,
          "clienteIdentificacion": _identificacionController.text,
          "clienteCorreo": _correoController.text,
          "clienteTelefono": _telefonoController.text,
          "clienteDireccion": _direccionController.text,
          "clienteDisabled": false,
          "empresaId": empresaId,
        };

        //final apiClient = ApiServiceClient(client: http.Client());
        final apiClient = ApiServiceClient(client: IOClient(autoFirmadoTemporal()));

        print(clienteData);

        final respuesta = await apiClient.crearCliente(clienteData);

        setState(() {
          _guardandoCliente = false;
          _clienteGuardado = true;
          _clienteCreado = respuesta;
        });

      } catch (e) {
        setState(() {
          _guardandoCliente = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar cliente: $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _identificacionController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }
}
*/



import 'package:cangrivic/app/services/api_service_client.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auto_firmado_temporal.dart';

class AddClientPage extends StatefulWidget {
  @override
  _AddClientPageState createState() => _AddClientPageState();
}

class _AddClientPageState extends State<AddClientPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _identificacionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();

  bool _guardandoCliente = false;
  bool _clienteGuardado = false;
  Map<String, dynamic>? _clienteCreado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Agregar Nuevo Cliente",
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue[700]!, Colors.blue[800]!],
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: _guardandoCliente
          ? _buildLoadingScreen()
          : _clienteGuardado
          ? _buildSuccessScreen()
          : _buildClientForm(),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text("Guardando cliente...",
              style: TextStyle(fontSize: 18, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue[50]!, Colors.white],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 80),
          SizedBox(height: 24),
          Text("¡Cliente Creado Exitosamente!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                _buildInfoRow("ID:", _clienteCreado?['clienteId'].toString()),
                SizedBox(height: 12),
                _buildInfoRow("Nombre:", _clienteCreado?['clienteNombre']),
                SizedBox(height: 12),
                _buildInfoRow("Correo:", _clienteCreado?['clienteCorreo']),
              ],
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: Icon(Icons.home, size: 20),
            label: Text("Volver al Inicio",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            value ?? 'N/A',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildClientForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header informativo
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Todos los campos son obligatorios",
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Campo Nombres
            _buildTextField(
              controller: _nombreController,
              label: "Nombres",
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese los nombres';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Campo Identificación/RUC
            _buildTextField(
              controller: _identificacionController,
              label: "Identificación/RUC",
              icon: Icons.badge_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese la identificación';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Campo Teléfono
            _buildTextField(
              controller: _telefonoController,
              label: "Teléfono",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el teléfono';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Campo Correo (ahora obligatorio)
            _buildTextField(
              controller: _correoController,
              label: "Correo Electrónico",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el correo electrónico';
                }
                if (!value.contains('@')) {
                  return 'Ingrese un correo electrónico válido';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Campo Dirección
            _buildTextField(
              controller: _direccionController,
              label: "Dirección",
              icon: Icons.location_on_outlined,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese la dirección';
                }
                return null;
              },
            ),
            SizedBox(height: 32),

            // Botón Guardar
            Container(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _guardarCliente,
                child: Text("Guardar Cliente",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 1.5),
        ),
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Future<void> _guardarCliente() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _guardandoCliente = true;
      });

      try {
        // Obtener empresaId de SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final empresaId = prefs.getInt('empresaId') ?? 0;

        final clienteData = {
          "clienteNombre": _nombreController.text,
          "clienteIdentificacion": _identificacionController.text,
          "clienteCorreo": _correoController.text,
          "clienteTelefono": _telefonoController.text,
          "clienteDireccion": _direccionController.text,
          "clienteDisabled": false,
          "empresaId": empresaId,
        };

        final apiClient = ApiServiceClient(client: IOClient(autoFirmadoTemporal()));
        final respuesta = await apiClient.crearCliente(clienteData);

        setState(() {
          _guardandoCliente = false;
          _clienteGuardado = true;
          _clienteCreado = respuesta;
        });

      } catch (e) {
        setState(() {
          _guardandoCliente = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al guardar cliente: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _identificacionController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }
}