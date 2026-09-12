import 'package:cangrivic/app/services/api_service_producto.dart';
import 'package:cangrivic/app/services/api_service_compra.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import '../../services/auto_firmado_temporal.dart';

class CompraPage extends StatefulWidget {
  final Map<String, dynamic> proveedor;
  CompraPage({required this.proveedor});

  @override
  _CompraPageState createState() => _CompraPageState();
}

class _CompraPageState extends State<CompraPage> {
  final List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _productos = [];
  Map<String, dynamic>? _productoSeleccionado;
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();

  bool _loadingProductos = true;
  bool _guardandoCompra = false;
  bool _compraExitosa = false;
  bool _mostrarNotificacion = false;
  int? _compraId;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    setState(() => _loadingProductos = true);
    try {
      final apiProducto = ApiServiceProducto(client: IOClient(autoFirmadoTemporal()));
      final lista = await apiProducto.getProductos();
      setState(() {
        _productos = lista;
        _loadingProductos = false;
      });
    } catch (e) {
      setState(() => _loadingProductos = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar productos: $e'), backgroundColor: Colors.red),
      );
    }
  }

  double get _total => _items.fold(0, (sum, item) => sum + item['subtotal']);

  void _mostrarNotificacionCentrada() {
    setState(() => _mostrarNotificacion = true);
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) setState(() => _mostrarNotificacion = false);
    });
  }

  void _agregarItem() {
    if (_productoSeleccionado != null &&
        _cantidadController.text.isNotEmpty &&
        _precioController.text.isNotEmpty) {
      final cantidad = int.tryParse(_cantidadController.text);
      if (cantidad == null || cantidad <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Ingrese una cantidad válida"),
            backgroundColor: Colors.orange));
        return;
      }
      final precio = double.tryParse(_precioController.text);
      if (precio == null || precio <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Ingrese un precio válido"),
            backgroundColor: Colors.orange));
        return;
      }

      final double subtotal = cantidad * precio;
      setState(() {
        _items.add({
          "producto": _productoSeleccionado!['nombre'],
          "productoId": _productoSeleccionado!['id'],
          "cantidad": cantidad,
          "precio": precio,
          "subtotal": subtotal,
        });
      });
      _cantidadController.clear();
      _mostrarNotificacionCentrada();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Complete todos los campos"),
          backgroundColor: Colors.orange));
    }
  }

  void _guardarCompra() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Agregue al menos un producto"),
          backgroundColor: Colors.orange));
      return;
    }

    setState(() {
      _guardandoCompra = true;
      _compraExitosa = false;
    });

    final compra = {
      "proveedorId": widget.proveedor['proveedorId'].toString(),
      "empresaId": widget.proveedor['empresaId'].toString(),
      "fechaCompra": DateTime.now().toIso8601String(),
      "total": _total,
      "items": _items.map((item) {
        return {
          "productoId": item['productoId'],
          "cantidad": item['cantidad'],
          "precioUnitario": item['precio'],
          "subtotal": item['subtotal'],
        };
      }).toList(),
    };

    try {
      final apiCompra = ApiServiceCompra(client: IOClient(autoFirmadoTemporal()));
      final respuesta = await apiCompra.crearCompra(compra);
      setState(() {
        _guardandoCompra = false;
        _compraExitosa = true;
        _compraId = respuesta['compraId'];
      });
    } catch (e) {
      setState(() => _guardandoCompra = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error al guardar la compra: $e"),
          backgroundColor: Colors.red));
    }
  }

  void _volverAInicio() => Navigator.popUntil(context, (r) => r.isFirst);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Compra - ${widget.proveedor['proveedorNombre']}"),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          _guardandoCompra
              ? _buildLoadingScreen()
              : _compraExitosa
              ? _buildSuccessScreen()
              : _buildCompraForm(),
          if (_mostrarNotificacion)
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.purple[700],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text("✓ Producto agregado",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[700]!)),
          SizedBox(height: 20),
          Text("Procesando compra...",
              style: TextStyle(fontSize: 18, color: Colors.grey[700])),
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
          Text("¡Compra Exitosa!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("ID de Compra: $_compraId", style: TextStyle(fontSize: 18)),
          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _volverAInicio,
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

  Widget _buildCompraForm() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.purple[100],
                child: Icon(Icons.business, color: Colors.purple[700], size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.proveedor['proveedorNombre'],
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    Text(widget.proveedor['proveedorIdentificacion'],
                        style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _loadingProductos
                  ? CircularProgressIndicator()
                  : DropdownButtonFormField<Map<String, dynamic>>(
                value: _productoSeleccionado,
                decoration: InputDecoration(
                  labelText: "Producto",
                  border: OutlineInputBorder(),
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _productos
                    .map((p) => DropdownMenuItem(
                  value: p,
                  child: Text("${p['nombre']}",
                      overflow: TextOverflow.ellipsis),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _productoSeleccionado = value;
                    if (value != null && value['precio'] != null) {
                      _precioController.text = value['precio'].toString();
                    }
                  });
                },
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cantidadController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Cantidad",
                        border: OutlineInputBorder(),
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _precioController,
                      keyboardType:
                      TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Precio",
                        border: OutlineInputBorder(),
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        prefixText: "\$ ",
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _agregarItem,
                  icon: Icon(Icons.add, size: 20),
                  label: Text("Agregar Producto"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1),
        Expanded(
          child: _items.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    size: 64, color: Colors.grey[300]),
                SizedBox(height: 16),
                Text("No hay productos",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                Text("Agregue productos a la compra",
                    style: TextStyle(fontSize: 14, color: Colors.grey[500])),
              ],
            ),
          )
              : ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return ListTile(
                contentPadding:
                EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Colors.purple[50],
                  child: Text("${item['cantidad']}",
                      style: TextStyle(
                          color: Colors.purple[700],
                          fontWeight: FontWeight.bold)),
                ),
                title: Text(item['producto'],
                    style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text("\$${item['precio'].toStringAsFixed(2)} c/u"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("\$${item['subtotal'].toStringAsFixed(2)}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[700])),
                    SizedBox(width: 16),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () =>
                          setState(() => _items.removeAt(index)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (_items.isNotEmpty) ...[
          Divider(height: 1),
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("TOTAL:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("\$${_total.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700])),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _guardarCompra,
                    child: Text("FINALIZAR COMPRA",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}