import 'package:cangrivic/app/services/api_service_client.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cangrivic/app/view/venta/venta_page.dart';
import 'package:http/io_client.dart';

import '../../services/auto_firmado_temporal.dart';

class ClientesPage extends StatefulWidget {
  final int empresaId;
  const ClientesPage({Key? key, required this.empresaId}) : super(key: key);

  @override
  _ClientesPageState createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  late ApiServiceClient apiService;
  List<dynamic> _clientes = [];
  List<dynamic> _clientesFiltrados = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    //apiService = ApiServiceClient(client: http.Client());
    apiService = ApiServiceClient(client: IOClient(autoFirmadoTemporal()));

    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    try {
      setState(() => _isLoading = true);
      final clientes = await apiService.getClientsPaginated(empresaId: widget.empresaId);
      setState(() {
        _clientes = clientes;
        _clientesFiltrados = clientes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar clientes: $e")),
      );
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await _cargarClientes();
    setState(() => _isRefreshing = false);
  }

  void _filtrarClientes(String query) {
    if (query.isEmpty) {
      setState(() => _clientesFiltrados = _clientes);
      return;
    }

    final queryLower = query.toLowerCase();
    setState(() {
      _clientesFiltrados = _clientes.where((cliente) {
        final nombre = cliente['clienteNombre']?.toString().toLowerCase() ?? '';
        final identificacion = cliente['clienteIdentificacion']?.toString().toLowerCase() ?? '';
        return nombre.contains(queryLower) || identificacion.contains(queryLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seleccionar Cliente"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Buscar por nombre o identificación...",
                prefixIcon: Icon(Icons.search, color: Colors.blue[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              onChanged: _filtrarClientes,
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: _onRefresh,
              child: _clientesFiltrados.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      _searchController.text.isEmpty
                          ? "No hay clientes disponibles"
                          : "No se encontraron resultados",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    if (_searchController.text.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          _filtrarClientes('');
                        },
                        child: Text("Limpiar búsqueda"),
                      ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _clientesFiltrados.length,
                itemBuilder: (context, index) {
                  final cliente = _clientesFiltrados[index];
                  final imgUrl = cliente['img'] ?? '';

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue[50],
                        ),
                        child: ClipOval(
                          child: imgUrl.isNotEmpty
                              ? FadeInImage.assetNetwork(
                            placeholder: 'assets/images/default_avatar.png',
                            image: imgUrl,
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                            imageErrorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar();
                            },
                          )
                              : _buildDefaultAvatar(),
                        ),
                      ),
                      title: Text(
                        cliente['clienteNombre'] ?? 'Sin nombre',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            cliente['clienteIdentificacion'] ?? 'Sin identificación',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          if (cliente['clienteTelefono'] != null)
                            Text(
                              cliente['clienteTelefono'],
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue[700]),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VentaPage(cliente: cliente),
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

  Widget _buildDefaultAvatar() {
    return Icon(Icons.person, size: 30, color: Colors.blue[700]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
