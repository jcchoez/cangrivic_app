import 'package:cangrivic/app/services/api_service_proveedor.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auto_firmado_temporal.dart';

class AddProveedorPage extends StatefulWidget {
  @override
  _AddProveedorPageState createState() => _AddProveedorPageState();
}

class _AddProveedorPageState extends State<AddProveedorPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _identificacionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();

  bool _guardandoProveedor = false;
  bool _proveedorGuardado = false;
  Map<String, dynamic>? _proveedorCreado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Agregar Nuevo Proveedor",
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.purple[700],
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple[700]!, Colors.purple[800]!],
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: _guardandoProveedor
          ? _buildLoadingScreen()
          : _proveedorGuardado
          ? _buildSuccessScreen()
          : _buildForm(),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[700]!),
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text("Guardando proveedor...",
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
          colors: [Colors.purple[50]!, Colors.white],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 80),
          SizedBox(height: 24),
          Text("¡Proveedor Creado Exitosamente!",
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
                _buildInfoRow("ID:", _proveedorCreado?['proveedorId'].toString()),
                SizedBox(height: 12),
                _buildInfoRow("Nombre:", _proveedorCreado?['proveedorNombre']),
                SizedBox(height: 12),
                _buildInfoRow("Correo:", _proveedorCreado?['proveedorCorreo']),
              ],
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
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
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(width: 10),
        Expanded(child: Text(value ?? 'N/A', style: TextStyle(fontSize: 16))),
      ],
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple[100]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.purple[700], size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Todos los campos son obligatorios",
                      style: TextStyle(color: Colors.purple[700], fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            _buildTextField(
              controller: _nombreController,
              label: "Nombres",
              icon: Icons.business,
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Por favor ingrese los nombres'
                  : null,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _identificacionController,
              label: "Identificación/RUC",
              icon: Icons.badge_outlined,
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Por favor ingrese la identificación'
                  : null,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _telefonoController,
              label: "Teléfono",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Por favor ingrese el teléfono'
                  : null,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _correoController,
              label: "Correo Electrónico",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Por favor ingrese el correo electrónico';
                }
                if (!v.contains('@')) return 'Ingrese un correo válido';
                return null;
              },
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _direccionController,
              label: "Dirección",
              icon: Icons.location_on_outlined,
              maxLines: 2,
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Por favor ingrese la dirección'
                  : null,
            ),
            SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _guardarProveedor,
                child: Text("Guardar Proveedor",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
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
          borderSide: BorderSide(color: Colors.purple[700]!, width: 1.5),
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

  Future<void> _guardarProveedor() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _guardandoProveedor = true);

      try {
        final prefs = await SharedPreferences.getInstance();
        final empresaId = prefs.getInt('empresaId') ?? 0;

        final proveedorData = {
          "proveedorNombre": _nombreController.text,
          "proveedorIdentificacion": _identificacionController.text,
          "proveedorCorreo": _correoController.text,
          "proveedorTelefono": _telefonoController.text,
          "proveedorDireccion": _direccionController.text,
          "proveedorDisabled": false,
          "empresaId": empresaId,
        };

        final api = ApiServiceProveedor(client: IOClient(autoFirmadoTemporal()));
        final respuesta = await api.crearProveedor(proveedorData);

        setState(() {
          _guardandoProveedor = false;
          _proveedorGuardado = true;
          _proveedorCreado = respuesta;
        });
      } catch (e) {
        setState(() => _guardandoProveedor = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al guardar proveedor: $e"),
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