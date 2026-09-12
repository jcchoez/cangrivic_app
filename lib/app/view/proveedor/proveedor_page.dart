import 'package:cangrivic/app/services/api_service_proveedor.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:cangrivic/app/view/compra/compra_page.dart';
import '../../services/auto_firmado_temporal.dart';

class ProveedoresPage extends StatefulWidget {
  final int empresaId;
  const ProveedoresPage({Key? key, required this.empresaId}) : super(key: key);

  @override
  _ProveedoresPageState createState() => _ProveedoresPageState();
}

class _ProveedoresPageState extends State<ProveedoresPage> {
  late ApiServiceProveedor apiService;
  List<dynamic> _proveedores = [];
  List<dynamic> _proveedoresFiltrados = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    apiService = ApiServiceProveedor(client: IOClient(autoFirmadoTemporal()));
    _cargarProveedores();
  }

  Future<void> _cargarProveedores() async {
    try {
      setState(() => _isLoading = true);
      final proveedores =
      await apiService.getProveedoresPaginated(empresaId: widget.empresaId);
      setState(() {
        _proveedores = proveedores;
        _proveedoresFiltrados = proveedores;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar proveedores: $e")),
      );
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await _cargarProveedores();
    setState(() => _isRefreshing = false);
  }

  void _filtrarProveedores(String query) {
    if (query.isEmpty) {
      setState(() => _proveedoresFiltrados = _proveedores);
      return;
    }

    final queryLower = query.toLowerCase();
    setState(() {
      _proveedoresFiltrados = _proveedores.where((p) {
        final nombre = p['proveedorNombre']?.toString().toLowerCase() ?? '';
        final identificacion =
            p['proveedorIdentificacion']?.toString().toLowerCase() ?? '';
        return nombre.contains(queryLower) || identificacion.contains(queryLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seleccionar Proveedor"),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Buscar por nombre o identificación...",
                prefixIcon: Icon(Icons.search, color: Colors.purple[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              onChanged: _filtrarProveedores,
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: _onRefresh,
              child: _proveedoresFiltrados.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off,
                        size: 64, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      _searchController.text.isEmpty
                          ? "No hay proveedores disponibles"
                          : "No se encontraron resultados",
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey[600]),
                    ),
                    if (_searchController.text.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          _filtrarProveedores('');
                        },
                        child: Text("Limpiar búsqueda"),
                      ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _proveedoresFiltrados.length,
                itemBuilder: (context, index) {
                  final p = _proveedoresFiltrados[index];
                  return Card(
                    margin: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.purple[50],
                        ),
                        child: Icon(Icons.business,
                            size: 30, color: Colors.purple[700]),
                      ),
                      title: Text(
                        p['proveedorNombre'] ?? 'Sin nombre',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            p['proveedorIdentificacion'] ??
                                'Sin identificación',
                            style: TextStyle(
                                color: Colors.grey[600]),
                          ),
                          if (p['proveedorTelefono'] != null)
                            Text(
                              p['proveedorTelefono'],
                              style: TextStyle(
                                  color: Colors.grey[600]),
                            ),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.purple[700]),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CompraPage(proveedor: p),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}