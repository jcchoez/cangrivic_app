import 'package:cangrivic/app/services/api_service_venta.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import '../../services/auto_firmado_temporal.dart';

class VentasPage extends StatefulWidget {
  final int empresaId;
  const VentasPage({Key? key, required this.empresaId}) : super(key: key);

  @override
  _VentasPageState createState() => _VentasPageState();
}

class _VentasPageState extends State<VentasPage> {
  late ApiServiceVenta apiService;
  List<dynamic> _ventas = [];
  bool _isLoading = false;
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

  @override
  void initState() {
    super.initState();
    apiService = ApiServiceVenta(client: IOClient(autoFirmadoTemporal()));
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

  Future<void> _cargarVentas() async {
    if (_fechaDesde == null || _fechaHasta == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selecciona ambas fechas")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await apiService.getVentasPorRango(
        empresaId: widget.empresaId,
        fechaDesde: _fechaDesde!,
        fechaHasta: _fechaHasta!,
      );

      setState(() {
        _ventas = response['ventas'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar ventas: $e")),
      );
    }
  }
/*
  Widget _buildVentaItem(dynamic venta) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Venta ID: ${venta['ventaId']}", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("Cliente ID: ${venta['clienteId']}"),
            Text("Fecha: ${venta['fechaVenta']}"),
            Text("Total: ${venta['total']}"),
          ],
        ),
        children: venta['items'] != null && venta['items'].isNotEmpty
            ? venta['items'].map<Widget>((item) {
          return ListTile(
            leading: Icon(Icons.shopping_bag, color: Colors.green[700]),
            title: Text("Producto: ${item['productoId']}"),
            subtitle: Text("Cantidad: ${item['cantidad']}  |  Subtotal: ${item['subtotal']}"),
          );
        }).toList()
            : [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("No hay items para esta venta"),
          )
        ],
      ),
    );
  }*/

/*
  Widget _buildVentaItem(dynamic venta) {
    final cliente = venta['cliente'] ?? {};

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Venta #${venta['ventaId']}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              "Cliente: ${cliente['nombre'] ?? 'Desconocido'}",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            Text(
              "Email: ${cliente['email'] ?? '-'}",
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            Text(
              "Tel: ${cliente['telefono'] ?? '-'}",
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            Text(
              "Fecha: ${venta['fechaVenta']}",
              style: TextStyle(fontSize: 13, color: Colors.blueGrey),
            ),
            Text(
              "Total: \$${venta['total']}",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green[700]),
            ),
          ],
        ),
        children: venta['items'] != null && venta['items'].isNotEmpty
            ? venta['items'].map<Widget>((item) {
          return ListTile(
            leading: Icon(Icons.shopping_bag, color: Colors.green[700]),
            title: Text("Producto ID: ${item['productoId']}"),
            subtitle: Text(
              "Cantidad: ${item['cantidad']}  |  Precio: \$${item['precioUnitario']}  |  Subtotal: \$${item['subtotal']}",
            ),
          );
        }).toList()
            : [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("No hay items para esta venta"),
          )
        ],
      ),
    );
  }*/

  Widget _buildVentaItem(dynamic venta) {
    final cliente = venta['cliente'] ?? {};

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Factura #${venta['ventaId']}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              "Cliente: ${cliente['nombre'] ?? 'Desconocido'}",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            Text(
              "Email: ${cliente['email'] ?? '-'}",
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            Text(
              "Tel: ${cliente['telefono'] ?? '-'}",
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            Text(
              "Fecha: ${venta['fechaVenta']}",
              style: TextStyle(fontSize: 13, color: Colors.blueGrey),
            ),
            Text(
              "Total: \$${venta['total']}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
        children: venta['items'] != null && venta['items'].isNotEmpty
            ? venta['items'].map<Widget>((item) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: Icon(Icons.shopping_cart, color: Colors.green[700]),
            ),
            title: Text(
              "${item['nombre']} (${item['codigo']})",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14, // mismo tamaño fijo
                height: 1.2,  // control de altura de línea
              ),
              softWrap: true, // permite que se parta en varias líneas sin cambiar el tamaño
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
            child: Text("No hay items para esta venta"),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
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
            onPressed: _cargarVentas,
            icon: Icon(Icons.search, color: Colors.white),
            label: Text(
              "Buscar Ventas",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
        title: Text("Reporte de Ventas"),
        backgroundColor: Colors.green[700],
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
                  : _ventas.isEmpty
                  ? Center(child: Text("No se encontraron ventas"))
                  : ListView.builder(
                itemCount: _ventas.length,
                itemBuilder: (context, index) {
                  return _buildVentaItem(_ventas[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
