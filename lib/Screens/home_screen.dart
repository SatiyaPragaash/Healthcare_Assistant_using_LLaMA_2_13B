import 'dart:async';

import 'package:chat_bot/Provider/userSession.dart';
import 'package:chat_bot/Utils/Utils.dart';
import 'package:chat_bot/Utils/routes/routes_name.dart';
import 'package:chat_bot/res/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../Provider/chat_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> chatHistory = [];
  var chatId;

  var chatLang;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.startNewChat().then((_) {
      setState(() {
        chatId = chatProvider.chatId;
        Utils.flushBarMessage('New chat Id is $chatId', context);
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    final userPrefernece = Provider.of<UserSession>(context);
    final chatProvider = Provider.of<ChatProvider>(context);


    return Scaffold(
        appBar: AppBar(
          title: const Text('Chat-Bot', style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18),),
          centerTitle: true,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Image.asset(
                  'assets/icons/menu.png',
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            },
          ),

          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'Settings':
                      Navigator.pushNamed(context, RoutesName.settings);
                      break;

                    case 'Logout':
                        userPrefernece.remove().then((value) async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacementNamed(
                            context, RoutesName.login);
                      });

                      break;
                  }
                },
                icon: const Icon(Icons.more_vert, color: Colors.white,),
                itemBuilder: (BuildContext context) {
                  return {'Settings', 'Logout'}.map((String choice) {
                    IconData? icon;
                    String? text;

                    if (choice == 'Logout') {
                      icon = Icons.logout; // Replace with the appropriate icon
                      text = 'Logout';
                    } else if (choice == 'Settings') {
                      icon =
                          Icons.settings; // Replace with the appropriate icon
                      text = 'Settings';
                    }
                    return PopupMenuItem<String>(
                      value: choice,
                      child: ListTile(
                        title: Text(
                          text!, style: const TextStyle(fontSize: 18),),
                        trailing: Icon(icon!, size: 30,),
                      ),
                    );
                  }).toList();
                },
              ),
            )
          ],

        ),

        body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
      return  Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: chatProvider.chatHistory.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person_outline),
                                const SizedBox(width: 10,),
                                Expanded(child: Text(chatProvider.chatHistory[index]['query'] ?? '', )),
                              ],
                            ),
                            const SizedBox(height: 20,),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColor.borderColor),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start,
                                  children: [
                                    Image.asset(
                                      'assets/images/chat-bot.png',
                                      width: 24, height: 24,),
                                    const SizedBox(width: 10,),
                                    Expanded(child: Text(
                                      chatProvider.chatHistory[index]['answer'] ?? '',
                                      softWrap: true,)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  chatProvider.loading ? Center(
                    child: LoadingAnimationWidget.waveDots(
                      color: AppColor.primaryColor,
                      size: 40,
                    ),
                  ) : const Text(''),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 100.0, // Set your desired max height here
                  ),
                  child: TextFormField(
                    controller: _messageController,
                    autofocus: false,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    maxLines: null,
                    onFieldSubmitted: (value) async {
                      if (chatId != null) {
                        _messageController.clear();
                        await fetchSelectedLanguage();

                        await chatProvider.getChatResponse(chatId, value, chatLang, context);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Message',
                      suffixIcon: IconButton(
                        icon: Image.asset(
                          'assets/icons/right-arrow.png', height: 24,
                          width: 24,
                          color: AppColor.primaryColor,),
                        onPressed: () async {
                          if (chatId != null) {
                            var value=_messageController.text;
                            _messageController.clear();
                            print(chatLang);
                            await fetchSelectedLanguage();

                            await chatProvider.getChatResponse(chatId, value, chatLang, context);
                          }
                        },
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColor
                              .borderColor)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColor
                              .borderColor)),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 12.0), // Adjust the padding as needed
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      );},
    ),



    drawer: Drawer(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 50.0, 8.0, 20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: width * 0.6,
                      child: ListTile(
                        onTap: () async{
                          chatProvider.chatHistory.clear();
                          await chatProvider.startNewChat();
                          chatId=chatProvider.chatId;
                          Navigator.of(context).pop();
                           Utils.flushBarMessage('New chat Id is $chatId', context);
                        },
                        title: const Text(
                          'New Chat',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        leading: Image.asset(
                          'assets/images/chat-bot.png',
                          height: 35,
                          width: 35,
                        ),
                      ),
                    ),
                    Builder(builder: (context) {
                      return IconButton(
                        onPressed: () {
                          Scaffold.of(context).closeDrawer();
                        },
                        icon: const Icon(Icons.close),
                      );
                    })
                  ],
                ),
                const Divider(),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        'History',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),

                      // Add your ListView.builder here
                      StreamBuilder(
                        stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('chats').snapshots(),
                        builder: (context, snapshot) {
                          if (ConnectionState.waiting == snapshot.connectionState) {
                            return Center(child: LoadingAnimationWidget.waveDots(color: AppColor.primaryColor, size: 50));
                          }
                          if (snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text('No chat history'));
                          }
                          return ListView(
                            shrinkWrap: true,
                            children: snapshot.data!.docs.map((DocumentSnapshot document) {
                              // Map your document data to a widget here
                              Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                              List<Map<String, String>> history =
                              (data['history'] as List)
                                  .map((entry) => Map<String, String>.from(entry))
                                  .toList();

                              // Sort history based on timestamp
                              history.sort((a, b) {
                                DateTime? timestampA = a['timestamp'] != null ? DateTime.parse(a['timestamp']!) : null;
                                DateTime? timestampB = b['timestamp'] != null ? DateTime.parse(b['timestamp']!) : null;

                                if (timestampA == null && timestampB == null) {
                                  return 0; // Both timestamps are null, consider them equal
                                } else if (timestampA == null) {
                                  return 1; // timestampA is null, consider it smaller
                                } else if (timestampB == null) {
                                  return -1; // timestampB is null, consider it smaller
                                } else {
                                  return timestampB.compareTo(timestampA);
                                }
                              });


                              return ListTile(
                                  title: Text(data['name']),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    chatProvider.selectChat(data, history);
                                    chatId = chatProvider.chatId;
                                  },
                                  trailing: chatId==data['chatId']? IconButton(
                                    onPressed: () async {
                                      chatProvider.deleteChat(chatId);
                                      chatId = chatProvider.chatId;
                                      Navigator.of(context).pop();
                                      Utils.flushBarMessage('New chat id is $chatId', context);

                                    },
                                    icon: const Icon(Icons.close),
                                  ): null
                              );
                            }).toList(),
                          );
                        },
                      )


                    ],
                  ),
                )
              ],
            ),
          ),
        )

    );
  }


  Future<void> fetchSelectedLanguage() async {
    print(FirebaseAuth.instance.currentUser!.uid);

    try {
      DocumentSnapshot documentSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();


      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

        if (data.containsKey('Lang')) {
          setState(() {
            // Fetch the selected language from Firestore
            var selectedLanguage = data['Lang'];
            print('selected language: $selectedLanguage');
               if(selectedLanguage== 'Tamil'){
                 chatLang = 'ta';
               }
               else if(selectedLanguage =='Hindi'){
                 chatLang= 'hi';
               }else{
                 chatLang='en';
               }

               print(chatLang);
          });
        } else {
          print('Language field does not exist in the document.');
        }
    }} catch (e) {
      print('Error fetching selected language: $e');
    }
  }

}
