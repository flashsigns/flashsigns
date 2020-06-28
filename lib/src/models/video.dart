class Video {
  final int id;
  final String link;
  final String md5;
  final double size;

  Video({this.id, this.link, this.md5, this.size});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'link': link,
      'md5': md5,
      'size': size,
    };
  }
}