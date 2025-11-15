// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/message.dart';
//
// class ChatUtils {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   Future<void> sendMessage({
//     required String receiverId,
//     required String message,
//     required String orgName,
//   }) async {
//     final senderId = _auth.currentUser!.uid;
//     final msg = Message(
//       senderId: senderId,
//       receiverId: receiverId,
//       message: message,
//       timestamp: DateTime.now(),
//       orgName: orgName,
//     );
//
//     await _firestore.collection('chats').add(msg.toMap());
//
//   }
//
//   Stream<List<Message>> getMessages(String receiverId, String orgName) {
//     final senderId = _auth.currentUser!.uid;
//
//     return _firestore
//         .collection('chats')
//         .where('orgName', isEqualTo: orgName)
//         .where('senderId', whereIn: [senderId, receiverId])
//         .where('receiverId', whereIn: [senderId, receiverId])
//         .orderBy('timestamp', descending: false)
//         .snapshots()
//         .map((snapshot) =>
//         snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList());
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message.dart';

class ChatUtils {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Send a message and include participants
  Future<void> sendMessage({
    required String receiverId,
    required String message,
    required String orgName,
  }) async {
    final senderId = _auth.currentUser!.uid;
    final msg = Message(
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      timestamp: DateTime.now(),
      orgName: orgName,
      participants: [senderId, receiverId], // Add participants here
    );

    await _firestore.collection('chats').add(msg.toMap());
  }

  /// Get messages using participants array
  Stream<List<Message>> getMessages(String receiverId, String orgName) {
    final senderId = _auth.currentUser!.uid;

    return _firestore
        .collection('chats')
        .where('orgName', isEqualTo: orgName)
        .where('participants', arrayContains: senderId,) // Query by participants
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList());
  }
}
