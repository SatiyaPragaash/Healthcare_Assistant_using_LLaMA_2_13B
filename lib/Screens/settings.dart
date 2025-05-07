import 'package:chat_bot/res/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/chat_provider.dart';
import '../Provider/theme_changer_provider.dart';
import '../Utils/Utils.dart';
import '../Utils/routes/routes_name.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  ValueNotifier<bool> _obsecurePassword = ValueNotifier<bool>(true);
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  var selectedLanguage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchSelectedLanguage();
  }

  @override
  Widget build(BuildContext context) {
    final themeChanger = Provider.of<ThemeChanger>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context);


    return  Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),),
        backgroundColor: AppColor.primaryColor,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white
        )

      ),
      body:  Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween,
              children: [
                Text('Theme'),

                IconButton(onPressed: () {
                  themeChanger.setTheme(
                    themeChanger.themeMode ==
                        ThemeMode.light
                        ? ThemeMode.dark
                        : ThemeMode.light,
                  );
                },
                  icon: themeChanger.themeMode ==
                      ThemeMode.light
                      ? const Icon(Icons.light_mode)
                      : const Icon(Icons.dark_mode),)
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween,
              children: [
                const Text('Clear all chat'),
                ElevatedButton(onPressed: () {
                  chatProvider.deleteAllChats();
                  Navigator.of(context).pop();
                },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor
                          .primaryColor),
                  child: const Text('Clear', style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),),)
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween,
              children: [
                const Text('Delete Account'),
                ElevatedButton(onPressed: () {
                  _showConfirmationDialog();
                },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor
                          .primaryColor),
                  child: const Text('Delete',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),),)
              ],
            ),
            const Divider(),
            Text('Change Language'),
            SizedBox(height: 20,),
            DropdownButtonFormField<String>(

              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.borderColor),
                ),
              ),

              value: selectedLanguage,
              items: <String>[
                'Englsih',
                'Hindi',
                'Tamil'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value,),
                );
              }).toList(),

              onChanged: (String? value) async{
                setState(() {
                  selectedLanguage = value!;
                });

                try{
                  await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
                    'Lang': value,
                  });
                  Utils.flushBarMessage('Language Updated.', context);
                } catch (e) {
                  print('Error updating language in Firestore: $e');
                }
              },
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _showConfirmationDialog() async {

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColor.borderColor)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColor.borderColor)),
                    contentPadding: EdgeInsets.symmetric(vertical: 16.0,
                        horizontal: 12.0), // Adjust the padding as needed
                  )
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height * .03,
              ),

              ValueListenableBuilder(
                  valueListenable: _obsecurePassword,
                  builder: (context, value, child) {
                    return TextFormField(
                      controller: _passwordController,
                      obscureText: _obsecurePassword.value,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: Icon(Icons.password),
                        suffixIcon: InkWell(
                          onTap: () {
                            _obsecurePassword.value = !_obsecurePassword.value;
                          },
                          child: Icon(_obsecurePassword.value
                              ? Icons.visibility_off
                              : Icons.visibility),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColor.borderColor)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColor.borderColor)),
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0,
                            horizontal: 12.0), // Adjust the padding as needed

                      ),
                    );
                  }),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),

        TextButton(
        onPressed: () {

          if (_emailController.text.isEmpty) {
            Utils.flushBarMessage('Please enter email.', context);
          } else if (_passwordController.text.isEmpty) {
            Utils.flushBarMessage('Please enter password.', context);
          }
          else if (_passwordController.text.length < 8) {
            Utils.flushBarMessage(
                'Password length should be greater than 8 character.',
                context);
          } else {
            Navigator.of(context).pop();
            _deleteUser(_emailController.text, _passwordController.text);
          }

        },
        child: Text('Reauthenticate'),
        )
          ],
        );
      },
    );
  }


  void _deleteUser(String email, String password) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        AuthCredential credential;

        credential = EmailAuthProvider.credential(email: email, password: password);

        await user.reauthenticateWithCredential(credential);

        await FirebaseFirestore.instance.collection('Users').doc(user.uid).delete();

        // Reload user to reflect the changes
        await user.reload();

        // Delete the user account
        await user.delete();

        Utils.flushBarMessage('Account deleted successfully', context);
        Navigator.pushReplacementNamed(context, RoutesName.login);
      } catch (e) {
        // Handle reauthentication error
        Utils.flushBarMessage('Reauthentication failed', context);
      }
    } else {
      Utils.flushBarMessage('No current user', context);
    }
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
            selectedLanguage = data['Lang'];
            print('selected language: $selectedLanguage');
          });
        } else {
          print('Language field does not exist in the document.');
        }
      }} catch (e) {
      print('Error fetching selected language: $e');
    }
  }
}
