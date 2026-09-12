import 'package:cangrivic/app/services/api_service_compra.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import '../../services/auto_firmado_temporal.dart';

class ComprasPage extends StatefulWidget {
  final int empresaId;
  const ComprasPage({Key? key, required this.empresaId}) : super(key: key);

  @override
  _ComprasPageState createState() => _ComprasPageState();
}

class _ComprasPageState extends State<ComprasPage> {
  late ApiServiceCompra apiService;
  List<dynamic> _compras = [];
  bool _isLoading = false;
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

  @override
  void initState() {
    super.initState();
    apiService = ApiServiceCompra(client: IOClient(autoFirmadoTemporal()));
  }

  Future<void> _seleccionarFechaDesde() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaDesde ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (fecha != null) setState(() => _fechaDesde = fecha);
  }

  Future<void> _seleccionarFechaHasta() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaHasta ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (fecha != null) setState(() => _fechaHasta = fecha);
  }

  Future<void> _cargarCompras() async {
    if (_fechaDesde == null || _fechaHasta == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selecciona ambas fechas")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await apiService.getComprasPorRango(
        empresaId: widget.empresaId,
        fechaDesde: _fechaDesde!,
        fechaHasta: _fechaHasta!,
      );

      setState(() {
        _compras = response['compras'] ?? response['ventas'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar compras: $e")),
      );
    }
  }

  Widget _buildCompraItem(dynamic compra) {
    final proveedor = compra['proveedor'] ?? {};

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Compra #${compra['compraId']}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text("Proveedor: ${proveedor['nombre'] ?? 'Desconocido'}",
                style: TextStyle(fontSize: 14, color: Colors.black87)),
            Text("Email: ${proveedor['email'] ?? '-'}",
                style: TextStyle(fontSize: 13, color: Colors.grey[700])),
            Text("Tel: ${proveedor['telefono'] ?? '-'}",
                style: TextStyle(fontSize: 13, color: Colors.grey[700])),
            Text("Fecha: ${compra['fechaCompra'] ?? compra['fechaVenta']}",
                style: TextStyle(fontSize: 13, color: Colors.blueGrey)),
            Text("Total: \$${compra['total']}",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple[700])),
          ],
        ),
        children: compra['items'] != null && compra['items'].isNotEmpty
            ? compra['items'].map<Widget>((item) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple[100],
              child: Icon(Icons.shopping_cart, color: Colors.purple[700]),
            ),
            title: Text(
              "${item['nombre']} (${item['codigo']})",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.2,
              ),
              softWrap: true,
            ),
            subtitle: Text(
              "Cantidad: ${item['cantidad']} | Precio: \$${item['precioUnitario']} | Subtotal: \$${item['subtotal']}",
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          );
        }).toList()
            : [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("No hay items para esta compra"),
          )
        ],
      ),
    );
  }

  Widget _buildFechaYBuscar() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _seleccionarFechaDesde,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: "Fecha Desde",
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    controller: TextEditingController(
                      text: _fechaDesde == null
                          ? ''
                          : "${_fechaDesde!.toLocal()}".split(' ')[0],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _seleccionarFechaHasta,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: "Fecha Hasta",
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    controller: TextEditingController(
                      text: _fechaHasta == null
                          ? ''
                          : "${_fechaHasta!.toLocal()}".split(' ')[0],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _cargarCompras,
            icon: Icon(Icons.search, color: Colors.white),
            label: Text("Buscar Compras",
                style: TextStyle(color: Colors.white, fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[700],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reporte de Compras"),
        backgroundColor: Colors.purple[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildFechaYBuscar(),
            SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _compras.isEmpty
                  ? Center(child: Text("No se encontraron compras"))
                  : ListView.builder(
                itemCount: _compras.length,
                itemBuilder: (context, index) =>
                    _buildCompraItem(_compras[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}