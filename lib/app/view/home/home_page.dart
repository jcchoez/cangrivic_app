/*import 'package:cangrivic/app/view/addClient/add_client_page.dart';
import 'package:cangrivic/app/view/client/client_page.dart';
import 'package:cangrivic/app/view/login/login.dart';
import 'package:cangrivic/app/view/ventas/ventas_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String usuarioNombre = '';
  String usuarioUsername = '';
  String usuarioTelefono = '';
  int empresaId = 0;
  bool _datosCargados = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usuarioNombre = prefs.getString('usuarioNombre') ?? 'Usuario';
      usuarioUsername = prefs.getString('usuarioUsername') ?? '@usuario';
      usuarioTelefono = prefs.getString('usuarioTelefono') ?? 'Sin teléfono';
      empresaId = prefs.getInt('empresaId') ?? 0;
      _datosCargados = true;
    });

    if (empresaId == 0) {
      _mostrarErrorEmpresaId();
    }
  }

  void _mostrarErrorEmpresaId() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            icon: Icon(Icons.error_outline, color: Colors.red, size: 40),
            title: Text("Usuario sin empresa"),
            content: Text("No está asociado a ninguna empresa. Será redirigido al login."),
            actions: [
              TextButton(
                onPressed: () => _limpiarYSalir(),
                child: Text("Entendido"),
              ),
            ],
          );
        },
      );
    });
  }

  Future<void> _limpiarYSalir() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_datosCargados) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Cangrivic"),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            onPressed: () => _confirmarCerrarSesion(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildDashboardBienvenida(),
            SizedBox(height: 30),
            _buildMenuButton(
              context,
              "Nueva Venta",
              "assets/images/venta.png",
              Colors.green,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClientesPage(empresaId: empresaId)),
                );
              },
            ),
            SizedBox(height: 20),
            _buildMenuButton(
              context,
              "Agregar Cliente",
              "assets/images/cliente.png",
              Colors.blue,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddClientPage()),
                );
              },
            ),
            SizedBox(height: 20),
            _buildMenuButton(
              context,
              "Reporte de ventas",
              "assets/images/reporte.png",
              Colors.orange,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VentasPage(empresaId: empresaId)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardBienvenida() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, size: 24, color: Colors.blue[700]),
              SizedBox(width: 10),
              Text(
                "Bienvenido/a",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          _buildInfoItem("Nombre:", usuarioNombre, Icons.person_outline),
          SizedBox(height: 10),
          _buildInfoItem("Usuario:", usuarioUsername, Icons.alternate_email),
          SizedBox(height: 10),
          _buildInfoItem("Teléfono:", usuarioTelefono, Icons.phone),
          SizedBox(height: 15),
          Divider(color: Colors.blue[200]),
          SizedBox(height: 10),
          Text(
            "¿Qué deseas hacer hoy?",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue[600]),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[900],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmarCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Cerrar Sesión"),
          content: Text("¿Estás seguro de que quieres cerrar sesión? Se eliminarán todos los datos."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cerrarSesion(context);
              },
              child: Text("Cerrar Sesión", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sesión cerrada - Todos los datos eliminados"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => Login()),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al cerrar sesión: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildMenuButton(
      BuildContext context, String title, String imagePath, Color color, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                imagePath,
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.shopping_cart, size: 40);
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 20),
          ],
        ),
      ),
    );
  }
}*/

import 'package:cangrivic/app/view/addClient/add_client_page.dart';
import 'package:cangrivic/app/view/client/client_page.dart';
import 'package:cangrivic/app/view/login/login.dart';
import 'package:cangrivic/app/view/ventas/ventas_page.dart';
import 'package:cangrivic/app/view/proveedor/proveedor_page.dart';
import 'package:cangrivic/app/view/addProveedor/add_proveedor_page.dart';
import 'package:cangrivic/app/view/compras/compras_page.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String usuarioNombre = '';
  String usuarioUsername = '';
  String usuarioTelefono = '';
  int empresaId = 0;
  bool _datosCargados = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usuarioNombre = prefs.getString('usuarioNombre') ?? 'Usuario';
      usuarioUsername = prefs.getString('usuarioUsername') ?? '@usuario';
      usuarioTelefono = prefs.getString('usuarioTelefono') ?? 'Sin teléfono';
      empresaId = prefs.getInt('empresaId') ?? 0;
      _datosCargados = true;
    });

    if (empresaId == 0) {
      _mostrarErrorEmpresaId();
    }
  }

  void _mostrarErrorEmpresaId() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            icon: Icon(Icons.error_outline, color: Colors.red, size: 40),
            title: Text("Usuario sin empresa"),
            content: Text(
                "No está asociado a ninguna empresa. Será redirigido al login."),
            actions: [
              TextButton(
                onPressed: () => _limpiarYSalir(),
                child: Text("Entendido"),
              ),
            ],
          );
        },
      );
    });
  }

  Future<void> _limpiarYSalir() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_datosCargados) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Cangrivic"),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            onPressed: () => _confirmarCerrarSesion(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          children: [
            _buildDashboardBienvenida(),
            SizedBox(height: 16),

            // ============ DOS COLUMNAS: VENTAS | COMPRAS ============
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============ COLUMNA IZQUIERDA: VENTAS ============
                Expanded(
                  child: _buildSectionColumn(
                    title: "VENTAS",
                    icon: Icons.trending_up,
                    color: Colors.black,
                    actions: [
                      _MiniAction(
                        label: "Nueva\nVenta",
                        icon: Icons.shopping_cart,
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ClientesPage(empresaId: empresaId),
                            ),
                          );
                        },
                      ),
                      _MiniAction(
                        label: "Agregar\nCliente",
                        icon: Icons.person_add,
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddClientPage()),
                          );
                        },
                      ),
                      _MiniAction(
                        label: "Reporte\nde Ventas",
                        icon: Icons.assessment,
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VentasPage(empresaId: empresaId),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),

                // ============ COLUMNA DERECHA: COMPRAS ============
                Expanded(
                  child: _buildSectionColumn(
                    title: "COMPRAS",
                    icon: Icons.local_shipping,
                    color: Colors.black,
                    actions: [
                      _MiniAction(
                        label: "Nueva\nCompra",
                        icon: Icons.add_shopping_cart,
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProveedoresPage(empresaId: empresaId),
                            ),
                          );
                        },
                      ),
                      _MiniAction(
                        label: "Agregar\nProveedor",
                        icon: Icons.business_center,
                        color: Colors.indigo,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddProveedorPage()),
                          );
                        },
                      ),
                      _MiniAction(
                        label: "Reporte\nde Compras",
                        icon: Icons.receipt_long,
                        color: Colors.deepOrange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ComprasPage(empresaId: empresaId),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Columna con encabezado de sección y 3 botones compactos
  Widget _buildSectionColumn({
    required String title,
    required IconData icon,
    required Color color,
    required List<_MiniAction> actions,
  }) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          // Encabezado
          Container(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),

          // Botones
          ...actions.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildMiniButton(a),
          )),
        ],
      ),
    );
  }

  Widget _buildMiniButton(_MiniAction action) {
    return Material(
      color: action.color,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(action.icon, color: Colors.white, size: 24),
              ),
              SizedBox(height: 8),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardBienvenida() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, size: 22, color: Colors.blue[700]),
              SizedBox(width: 10),
              Text(
                "Bienvenido/a",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildInfoItem("Nombre:", usuarioNombre, Icons.person_outline),
          SizedBox(height: 8),
          _buildInfoItem("Usuario:", usuarioUsername, Icons.alternate_email),
          SizedBox(height: 8),
          _buildInfoItem("Teléfono:", usuarioTelefono, Icons.phone),
          SizedBox(height: 12),
          Divider(color: Colors.blue[200], height: 1),
          SizedBox(height: 10),
          Text(
            "¿Qué deseas hacer hoy?",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue[600]),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue[900],
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _confirmarCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Cerrar Sesión"),
          content: Text(
              "¿Estás seguro de que quieres cerrar sesión? Se eliminarán todos los datos."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cerrarSesion(context);
              },
              child: Text("Cerrar Sesión", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sesión cerrada - Todos los datos eliminados"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => Login()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al cerrar sesión: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Modelo auxiliar para los botones compactos
class _MiniAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _MiniAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}