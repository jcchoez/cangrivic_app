import 'dart:io';

HttpClient autoFirmadoTemporal() {
  final client = HttpClient();
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;
  return client;
}
