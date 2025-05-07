import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Utils/Utils.dart';
import '../Utils/routes/routes_name.dart';
import '../res/colors.dart';
import '../res/component/button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;


  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(children: [
            Center(
                child: Container(
                  width: width*.5,
                  height: height*.4,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                            'assets/images/chat-bot.png',
                          )
                      )
                  ),
                )),

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
                  contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0), // Adjust the padding as needed
                )
            ),

            SizedBox(
              height: height * .03,
            ),


            Button(title: 'Reset Password', onPress: (){
              if(_emailController.text.isEmpty){
                Utils.flushBarMessage('Please enter email', context);
              } else{
                forgotPassword(_emailController.text);
              }
            }),

            SizedBox(height: height*.05,),
            TextButton.icon(onPressed: (){
              Navigator.pushNamed(context, RoutesName.login);
            }, label: Text('Back to login'),
            icon: Icon(Icons.arrow_back),)



          ]),
        ),
      ),
    );
  }

  forgotPassword(String email){
    FocusManager.instance.primaryFocus?.unfocus();

    _auth.sendPasswordResetEmail(email: email).then((_) {
      Utils.flushBarMessage('Reset email has been sent', context);
    }).onError((error, stackTrace) {
      Utils.flushBarMessage('Faield to send reset email', context);
    });
  }
}
