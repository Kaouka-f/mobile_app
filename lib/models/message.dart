class CustomMessage {
  final bool isSentByUser;
  final String message;
  final String filepath;
  final String timestamp;
  final String personId;
  final bool read;

  CustomMessage(
      {required this.isSentByUser,
      required this.message,
      required this.timestamp,
      required this.personId,
      required this.read,
      required this.filepath});
}
