
class XMLBuilder {
  String tag;
  List<XMLElement> elements;

  XMLBuilder({required this.tag, elements}) : this.elements = elements ?? [];

  /// add one more [XMLElement] to existing xml.
  XMLBuilder addElement({required String key,  String? value}) {
    elements.add(XMLElement(value: value, key: key));
    return this;
  }

  /// return generated xml as [String]
  String buildElement({bool appendFlag = true}) {
    String _flag = "RequestFrom";
    String _flagVal = "Mobile";
    String _appTypeFlag="AppType";
    String _appTypeVale="AgroApp";

    String xml = "";
    xml = "<" + tag + "";
    elements.forEach((element) {
      if (element.value != null && element.value != "null") {
        xml += " ${element.key} = \"${element.value}\"";
      }
    });
    if (appendFlag) xml += " " + _flag + " = \"" + _flagVal + "\"";
    if (appendFlag) xml += " " + _appTypeFlag + " = \"" + _appTypeVale + "\"";
    xml += "> </" + tag + ">";
    return xml;
  }
}

class XMLElement {
  final String? value;
  final String key;

  XMLElement({ this.value, required this.key});
}
