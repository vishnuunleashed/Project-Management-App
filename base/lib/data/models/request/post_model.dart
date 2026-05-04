
class Post {
  Map<String, dynamic> rawData;
  String urlExtension;

  Post({
    required this.rawData,
    required this.urlExtension
  });


  Map<String, dynamic> toMap() {
    return rawData;
  }
}
