// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cybershield/utils/chat_utils.dart';
// import 'package:cybershield/models/message.dart';
//
// class HRChatScreen extends StatefulWidget {
//   final String orgName;
//   final String adminId;
//   const HRChatScreen({
//     super.key,
//     required this.orgName,
//     required this.adminId,
//   });
//
//   @override
//   State<HRChatScreen> createState() => _HRChatScreenState();
// }
//
// class _HRChatScreenState extends State<HRChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ChatUtils chatUtils = ChatUtils();
//
//   void _sendMessage() {
//     if (_messageController.text.trim().isEmpty) return;
//
//     chatUtils.sendMessage(
//       receiverId: widget.adminId,
//       message: _messageController.text.trim(),
//       orgName: widget.orgName,
//     );
//
//     _messageController.clear();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currentUser = FirebaseAuth.instance.currentUser!;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFFFFFFF),
//
//       appBar: AppBar(title: const Text("Chat with Admin")),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<List<Message>?>(
//       // (StreamBuilder<List<Message>>(
//               stream: chatUtils.getMessages(widget.adminId, widget.orgName),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 final messages = snapshot.data!;
//                 return ListView.builder(
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final msg = messages[index];
//                     final isMe = msg.senderId == currentUser.uid;
//                     return Align(
//                       alignment:
//                       isMe ? Alignment.centerRight : Alignment.centerLeft,
//                       child: Container(
//                         margin:
//                         const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: isMe ? Color(0xFF154699) : Colors.grey[300],
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Text(msg.message),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration:
//                     const InputDecoration(hintText: "Type your message..."),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: _sendMessage,
//                   color: Color(0xFF154688),
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// // }
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cybershield/utils/chat_utils.dart';
// import 'package:cybershield/models/message.dart';
// import 'package:cybershield/themes/app_colors.dart';
// import 'package:cybershield/themes/app_dimensions.dart';
// import 'package:cybershield/themes/app_text_styles.dart';
//
// class HRChatScreen extends StatefulWidget {
//   final String orgName;
//   final String adminId;
//
//   const HRChatScreen({
//     super.key,
//     required this.orgName,
//     required this.adminId,
//   });
//
//   @override
//   State<HRChatScreen> createState() => _HRChatScreenState();
// }
//
// class _HRChatScreenState extends State<HRChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ChatUtils chatUtils = ChatUtils();
//
//   String adminName = "";
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchAdminName();
//   }
//
//   Future<void> _fetchAdminName() async {
//     final adminDoc = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.adminId)
//         .get();
//
//     if (adminDoc.exists && mounted) {
//       setState(() {
//         adminName = adminDoc['name'] ?? "Admin";
//       });
//     } else {
//       setState(() {
//         adminName = "Admin";
//       });
//     }
//   }
//
//   void _sendMessage() {
//     if (_messageController.text.trim().isEmpty) return;
//
//     chatUtils.sendMessage(
//       receiverId: widget.adminId,
//       message: _messageController.text.trim(),
//       orgName: widget.orgName,
//     );
//
//     _messageController.clear();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currentUser = FirebaseAuth.instance.currentUser!;
//
//     return Scaffold(
//       backgroundColor: AppColors.greyLight,
//       appBar: AppBar(
//         backgroundColor: AppColors.primary,
//         elevation: 3,
//         titleSpacing: 0,
//         title: Row(
//           children: [
//             CircleAvatar(
//               radius: 22,
//               backgroundColor: AppColors.white,
//               child: Text(
//                 adminName.isNotEmpty
//                     ? adminName[0].toUpperCase()
//                     : 'A',
//                 style: const TextStyle(
//                   color: AppColors.primary,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               adminName.isNotEmpty ? adminName : "Admin",
//               style: AppTextStyles.heading.copyWith(
//                 color: AppColors.white,
//                 fontSize: 18,
//               ),
//             ),
//           ],
//         ),
//         centerTitle: false,
//       ),
//       body: Column(
//         children: [
//           // Chat messages
//           Expanded(
//             child: StreamBuilder<List<Message>?>(
//               stream: chatUtils.getMessages(widget.adminId, widget.orgName),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 final messages = snapshot.data!;
//                 if (messages.isEmpty) {
//                   return Center(
//                     child: Text(
//                       "No messages yet. Start the conversation!",
//                       style: AppTextStyles.email,
//                     ),
//                   );
//                 }
//
//                 return ListView.builder(
//                   padding: const EdgeInsets.all(AppDimensions.paddingMedium),
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final msg = messages[index];
//                     final isMe = msg.senderId == currentUser.uid;
//
//                     return Align(
//                       alignment: isMe
//                           ? Alignment.centerRight
//                           : Alignment.centerLeft,
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(vertical: 6),
//                         padding: const EdgeInsets.all(12),
//                         constraints: BoxConstraints(
//                           maxWidth:
//                           MediaQuery.of(context).size.width * 0.75,
//                         ),
//                         decoration: BoxDecoration(
//                           color: isMe
//                               ? AppColors.primary
//                               : AppColors.white,
//                           borderRadius: BorderRadius.only(
//                             topLeft: const Radius.circular(
//                                 AppDimensions.borderRadius),
//                             topRight: const Radius.circular(
//                                 AppDimensions.borderRadius),
//                             bottomLeft: Radius.circular(
//                                 isMe ? AppDimensions.borderRadius : 0),
//                             bottomRight: Radius.circular(
//                                 isMe ? 0 : AppDimensions.borderRadius),
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black12,
//                               blurRadius: 4,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Text(
//                           msg.message,
//                           style: TextStyle(
//                             color: isMe
//                                 ? AppColors.white
//                                 : AppColors.black,
//                             fontSize: 15,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//
//           // Message input bar
//           Container(
//             padding: const EdgeInsets.symmetric(
//               horizontal: AppDimensions.paddingMedium,
//               vertical: AppDimensions.paddingSmall,
//             ),
//             color: AppColors.white,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     cursorColor: AppColors.primary,
//                     decoration: InputDecoration(
//                       hintText: "Type your message...",
//                       hintStyle: AppTextStyles.email.copyWith(
//                         color: AppColors.black54,
//                       ),
//                       filled: true,
//                       fillColor: AppColors.greyLight,
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 14,
//                         vertical: 10,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius:
//                         BorderRadius.circular(AppDimensions.borderRadius),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: AppColors.primary,
//                     borderRadius:
//                     BorderRadius.circular(AppDimensions.borderRadius),
//                   ),
//                   child: IconButton(
//                     icon: const Icon(Icons.send, color: Colors.white),
//                     onPressed: _sendMessage,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cybershield/utils/chat_utils.dart';
import 'package:cybershield/models/message.dart';
import 'package:cybershield/themes/app_colors.dart';
import 'package:cybershield/themes/app_dimensions.dart';
import 'package:cybershield/themes/app_text_styles.dart';
import 'package:intl/intl.dart';

class HRChatScreen extends StatefulWidget {
  final String orgName;
  final String adminId;

  const HRChatScreen({
    super.key,
    required this.orgName,
    required this.adminId,
  });

  @override
  State<HRChatScreen> createState() => _HRChatScreenState();
}

class _HRChatScreenState extends State<HRChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatUtils chatUtils = ChatUtils();

  String adminName = "";

  @override
  void initState() {
    super.initState();
    _fetchAdminName();
  }

  // Future<void> _fetchAdminName() async {
  //   final adminDoc = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(widget.adminId)
  //       .get();
  //
  //   if (adminDoc.exists && mounted) {
  //     setState(() {
  //       adminName = adminDoc['name'] ?? "Admin";
  //     });
  //   } else {
  //     setState(() {
  //       adminName = "Admin";
  //     });
  //   }
  // }
  Future<void> _fetchAdminName() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .where('organizationName', isEqualTo: widget.orgName)
          .limit(1) // only one admin per organization
          .get();

      if (querySnapshot.docs.isNotEmpty && mounted) {
        setState(() {
          adminName = querySnapshot.docs.first['organizationName'] ?? "Admin";
        });
      } else if (mounted) {
        setState(() {
          adminName = "Admin";
        });
      }
    } catch (e) {
      print("Error fetching admin: $e");
      if (mounted) {
        setState(() {
          adminName = "Admin";
        });
      }
    }
  }


  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    chatUtils.sendMessage(
      receiverId: widget.adminId,
      message: _messageController.text.trim(),
      orgName: widget.orgName,
    );

    _messageController.clear();
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "";
    try {
      final dateTime = (timestamp is Timestamp)
          ? timestamp.toDate()
          : DateTime.tryParse(timestamp.toString());
      if (dateTime == null) return "";
      return DateFormat('hh:mm a · MMM d').format(dateTime);
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: AppColors.greyLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 3,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.white,
              child: Text(
                adminName.isNotEmpty ? adminName[0].toUpperCase() : 'A',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              adminName.isNotEmpty ? adminName : "Admin",
              style: AppTextStyles.heading.copyWith(
                color: AppColors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: StreamBuilder<List<Message>?>(
              stream: chatUtils.getMessages(widget.adminId, widget.orgName),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      "No messages yet. Start the conversation!",
                      style: AppTextStyles.email,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUser.uid;

                    return Align(
                      alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                          maxWidth:
                          MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.primary : AppColors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(
                                AppDimensions.borderRadius),
                            topRight: const Radius.circular(
                                AppDimensions.borderRadius),
                            bottomLeft: Radius.circular(
                                isMe ? AppDimensions.borderRadius : 0),
                            bottomRight: Radius.circular(
                                isMe ? 0 : AppDimensions.borderRadius),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.message,
                              style: TextStyle(
                                color:
                                isMe ? AppColors.white : AppColors.black,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTimestamp(msg.timestamp),
                              style: TextStyle(
                                fontSize: 11,
                                color: isMe
                                    ? AppColors.white70
                                    : AppColors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message input bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingSmall,
            ),
            color: AppColors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      hintStyle: AppTextStyles.email.copyWith(
                        color: AppColors.black54,
                      ),
                      filled: true,
                      fillColor: AppColors.greyLight,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadius),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadius),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

