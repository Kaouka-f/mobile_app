class Contact {
  final String id;
  final String name;
  final String img;
  final double scale;
  final double offsetX;
  final double offsetY;
  final String dist;
  final bool connected;
  Contact(
      {required this.id,
      required this.name,
      this.img = "https://elaborium.site/proxy/stream/default/profile.jpg",
      this.scale = 1,
      required this.offsetX,
      required this.offsetY,
      required this.dist,
      required this.connected});
}
