class AuthModel {
  final int usuarioId;
  final String usuarioNombre;
  final String usuarioEmail;
  final String usuarioTelefono;
  final String usuarioUsername;
  final bool usuarioDisabled;
  final bool usuarioLocked;
  final int empresaId;
  final String token;

  AuthModel({
    required this.usuarioId,
    required this.usuarioNombre,
    required this.usuarioEmail,
    required this.usuarioTelefono,
    required this.usuarioUsername,
    required this.usuarioDisabled,
    required this.usuarioLocked,
    required this.empresaId,
    required this.token,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json, String token) {
    return AuthModel(
      usuarioId: json['usuarioId'],
      usuarioNombre: json['usuarioNombre'],
      usuarioEmail: json['usuarioEmail'],
      usuarioTelefono: json['usuarioTelefono'],
      usuarioUsername: json['usuarioUsername'],
      usuarioDisabled: json['usuarioDisabled'],
      usuarioLocked: json['usuarioLocked'],
      empresaId: json['empresaId'],
      token: token,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'usuarioNombre': usuarioNombre,
      'usuarioEmail': usuarioEmail,
      'usuarioTelefono': usuarioTelefono,
      'usuarioUsername': usuarioUsername,
      'usuarioDisabled': usuarioDisabled,
      'usuarioLocked': usuarioLocked,
      'empresaId': empresaId,
      'token': token,
    };
  }
}
