class ClientModel {
  final int clienteId;
  final String clienteNombre;
  final String clienteIdentificacion;
  final String clienteTelefono;
  final String clienteDireccion;
  final bool clienteDisabled;
  final int empresaId;

  ClientModel({
    required this.clienteId,
    required this.clienteNombre,
    required this.clienteIdentificacion,
    required this.clienteTelefono,
    required this.clienteDireccion,
    required this.clienteDisabled,
    required this.empresaId,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      clienteId: json['clienteId'],
      clienteNombre: json['clienteNombre'],
      clienteIdentificacion: json['clienteIdentificacion'],
      clienteTelefono: json['clienteTelefono'],
      clienteDireccion: json['clienteDireccion'],
      clienteDisabled: json['clienteDisabled'],
      empresaId: json['empresaId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clienteId': clienteId,
      'clienteNombre': clienteNombre,
      'clienteIdentificacion': clienteIdentificacion,
      'clienteTelefono': clienteTelefono,
      'clienteDireccion': clienteDireccion,
      'clienteDisabled': clienteDisabled,
      'empresaId': empresaId,
    };
  }
}
