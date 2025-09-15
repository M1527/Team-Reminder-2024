import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/chat_message.dart';

class ChatService {
  final CollectionReference chatCollection =
      FirebaseFirestore.instance.collection('chats');

  Stream<List<ChatMessage>> getChatMessagesStream(String taskId) {
    return chatCollection
        .doc(taskId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data()))
            .toList());
  }

  Future<void> sendMessage(String taskId, ChatMessage message) async {
    try {
      await chatCollection
          .doc(taskId)
          .collection('messages')
          .add(message.toMap());
    } catch (e) {
      log(e.toString());
    }
  }
}