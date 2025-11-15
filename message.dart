// class Message {
//   final String senderId;
//   final String receiverId;
//   final String message;
//   final DateTime timestamp;
//   final String orgName;
//   final List<String> participants; // new
//
//
//   Message({
//     required this.senderId,
//     required this.receiverId,
//     required this.message,
//     required this.timestamp,
//     required this.orgName,
//     required this.participants,
//
//   });
//
//   Map<String, dynamic> toMap() {
//     return {
//       'senderId': senderId,
//       'receiverId': receiverId,
//       'message': message,
//       'timestamp': timestamp,
//       'orgName': orgName,
//       'participants': participants,
//
//     };
//   }
//
//   factory Message.fromMap(Map<String, dynamic> map) {
//     return Message(
//       senderId: map['senderId'],
//       receiverId: map['receiverId'],
//       message: map['message'],
//       timestamp: DateTime.parse(map['timestamp']),
//       orgName: map['orgName'],
//       participants: List<String>.from(map['participants'] ?? []),
//
//     );
//   }
// }
//
class Message {
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final String orgName;
    final List<String> participants; // new


  Message({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    required this.orgName,
    required this.participants,

  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'orgName': orgName,
      'participants': participants,

    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      message: map['message'],
      timestamp: DateTime.parse(map['timestamp']),
      orgName: map['orgName'],
      participants: List<String>.from(map['participants'] ?? []),

    );
  }
}