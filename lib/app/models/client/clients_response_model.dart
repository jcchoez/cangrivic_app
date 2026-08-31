

import 'package:cangrivic/app/models/client/client_model.dart';

class ClientsResponseModel {
  final int totalItems;
  final int totalPages;
  final bool hasPrevious;
  final bool hasNext;
  final List<ClientModel> clientes;
  final int currentPage;

  ClientsResponseModel({
    required this.totalItems,
    required this.totalPages,
    required this.hasPrevious,
    required this.hasNext,
    required this.clientes,
    required this.currentPage,
  });

  factory ClientsResponseModel.fromJson(Map<String, dynamic> json) {
    var clientesList = (json['clientes'] as List)
        .map((cliente) => ClientModel.fromJson(cliente))
        .toList();

    return ClientsResponseModel(
      totalItems: json['totalItems'],
      totalPages: json['totalPages'],
      hasPrevious: json['hasPrevious'],
      hasNext: json['hasNext'],
      clientes: clientesList,
      currentPage: json['currentPage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalItems': totalItems,
      'totalPages': totalPages,
      'hasPrevious': hasPrevious,
      'hasNext': hasNext,
      'clientes': clientes.map((c) => c.toJson()).toList(),
      'currentPage': currentPage,
    };
  }
}
