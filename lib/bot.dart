class Bot {
  final String id1;
  final String id2;
  late String name;
  late String pp;

  Bot({required this.id1, required this.id2, name, pp});

  factory Bot.fromMap(Map<String, dynamic> map) {
    return Bot(id1: map['id1'], id2: map['id2']);
  }
}
