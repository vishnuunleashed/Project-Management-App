class Connections {
  static final Connections _instance = Connections._creator();

  Connections._creator();

  factory Connections() => _instance;

  final String _applicationName = "";
  final String _serverIp = "";
  final String _clientId = "";


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
