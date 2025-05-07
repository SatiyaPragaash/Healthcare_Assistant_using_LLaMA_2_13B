import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatProvider extends ChangeNotifier {
  final String base_url = "https://heavy-fans-camp.loca.lt";

  bool loading = false;
  List<Map<String, String>> chatHistory = [];
  String? chatId;


  Future<Map<String, dynamic>> getChatResponse(String chatId, String query, String chatLang, BuildContext context) async {
    loading = true;
    notifyListeners(); // Notify listeners that the state has changed
    final response = await http.post(
      Uri.parse("$base_url/response"),
      body: jsonEncode({'chat_id': chatId, 'query': query, 'lang_code':chatLang}),
      headers: {'Content-Type': 'application/json'},
    ).timeout(Duration(seconds: 120));



// Parse the JSON response
    Map<String, dynamic> responseBody = json.decode(response.body);


    dynamic value = responseBody['response'];


    List<String> triggerWords = ['hospital', 'emergency', 'urgent', 'Chest pain', 'Shortness of Breath', 'Unconsciousness', 'Severe Bleeding', 'Severe Headache', 'Vomiting Blood', 'Chest Tightness', 'High Fever', 'Abdominal Pain', 'Suicidal Thoughts', 'Allergic Reactions'];

    // Check if any trigger word is present in the response
    bool showAlertDialog = triggerWords.any((word) => value.toString().toLowerCase().contains(word.toLowerCase()));

    if (showAlertDialog) {
      // Display dialog box
      showDialog(
        context:  context, // Make sure to have the context available
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Alert'),
            content: Text('The Nearest hospital is being called'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }

    chatHistory.add({
      'query': query,
      'answer': value,
    });

    print(value);
    await saveChatHistory(chatId, chatHistory, query);

    loading = false;
    notifyListeners(); // Notify listeners that the state has changed

    return responseBody;
  }


  Future<void> saveChatHistory(String chatId, List<Map<String, String>> history, String query) async {
    try {
      var userUid = FirebaseAuth.instance.currentUser!.uid;
      final CollectionReference chatHistoryCollection = FirebaseFirestore.instance.collection('users').doc(userUid).collection('chats');

      // Check if the document already exists
      DocumentSnapshot chatDoc = await chatHistoryCollection.doc(chatId).get();

      if (chatDoc.exists) {
        // Document exists, update it
        await chatHistoryCollection.doc(chatId).update({
          'history': history,
        });
      } else {
        // Document does not exist, create a new one
        List<String> queryWords = query.split(' ');
        String truncatedQuery = queryWords.length <= 5 ? query : queryWords.sublist(0, 5).join(' ');

        await chatHistoryCollection.doc(chatId).set({
          'UserId': userUid,
          'chatId': chatId,
          'history': history,
          'timestamp': FieldValue.serverTimestamp(),
          'name': truncatedQuery,
        });
      }
      print('$chatId save successfully');
    } catch (e) {
      print('Error saving chat history: $e');
    }
  }



  Future<void> startNewChat() async {

    try {
      final response = await http.post(Uri.parse("$base_url/newchat"));

      if (response.statusCode == 200) {
        // Parse the JSON content from the response body
        final Map<String, dynamic> responseBody = json.decode(response.body);
        chatId = responseBody['chat_id'];

        notifyListeners();
      } else {
        // Handle error cases, e.g., show an error message
        print('Failed to start a new chat. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error starting a new chat: $e');
    }
  }


  Future<void> deleteChat(String chatId,) async {
    try {
      // Delete chat in the server
      await http.post(
        Uri.parse("$base_url/deletechat"),
        body: jsonEncode({'chat_id': chatId}),
        headers: {'Content-Type': 'application/json'},
      );

      // Delete chat in Firestore
      final CollectionReference collection = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('chats');
      await collection.doc(chatId).delete();
      chatHistory.clear();
      await startNewChat();

      // Notify listeners (if you are using a provider or similar)
      notifyListeners();
    } catch (e) {
      print('Error deleting chat: $e');
    }
  }



  void selectChat(Map<String, dynamic> data, List<Map<String, String>> history) {
    chatHistory.clear();
    chatHistory.addAll(history);
    chatId = data['chatId'];
    notifyListeners(); // Notify listeners to trigger a rebuild
  }


  Future<void> deleteAllChats() async {
    try {
      // Delete all chats in the server
      // You may need to adjust the server endpoint and payload based on your backend implementation
      await http.post(
        Uri.parse("$base_url/deleteAllChats"),
        body: jsonEncode({'user_id': FirebaseAuth.instance.currentUser!.uid}),
        headers: {'Content-Type': 'application/json'},
      );

      // Delete all chats in Firestore
      final CollectionReference collection = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('chats');
      QuerySnapshot querySnapshot = await collection.get();
      List<QueryDocumentSnapshot> docs = querySnapshot.docs;

      for (QueryDocumentSnapshot doc in docs) {
        await doc.reference.delete();
      }

      // Clear local chat history and start a new chat
      chatHistory.clear();
      await startNewChat();

      // Notify listeners (if you are using a provider or similar)
      notifyListeners();
    } catch (e) {
      print('Error deleting all chats: $e');
    }
  }

}
