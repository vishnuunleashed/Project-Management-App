class Connections {
  static final Connections _instance = Connections._creator();

  Connections._creator();

  factory Connections() => _instance;

  final String _applicationName = "api";
  final String _serverIp = "192.168.10.50:5000";
  // final String _clientId = "PIS";
  final String _clientId = "KEDQ";
  // final String _clientId = "PIS";

  String get serverIp => "http://$_serverIp";

  String generateUri() {
    return "${generateWebUrl()}";
  }

  String generateWebUrl() {
    return "http://$_serverIp/$_applicationName/";
  }

  get applicationName => _applicationName;
  get clientId => _clientId;
}
