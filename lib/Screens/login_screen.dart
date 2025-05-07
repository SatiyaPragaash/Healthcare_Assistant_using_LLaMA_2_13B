import 'package:chat_bot/Provider/userSession.dart';
import 'package:chat_bot/Utils/Utils.dart';
import 'package:chat_bot/Utils/routes/routes_name.dart';
import 'package:chat_bot/res/colors.dart';
import 'package:chat_bot/res/component/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/userModel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  ValueNotifier<bool> _obsecurePassword = ValueNotifier<bool>(true);
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  String? errorMessage;


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _obsecurePassword.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery
        .of(context)
        .size
        .height;
    var width = MediaQuery
        .of(context)
        .size
        .width;




    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(children: [
            Center(
                child: Container(
                  width: width * .5,
                  height: height * .4,
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
                  contentPadding: EdgeInsets.symmetric(vertical: 16.0,
                      horizontal: 12.0), // Adjust the padding as needed
                )
            ),

            SizedBox(
              height: height * .03,
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


            Align(alignment: Alignment.centerRight,
                child: TextButton(onPressed: () {
                  Navigator.pushNamed(context, RoutesName.forgotPassword);
                },
                    child: Text('Forget Password?', style: TextStyle(
                        color: CupertinoColors.link,
                        fontWeight: FontWeight.w500,
                        fontSize: 14),))),

            SizedBox(height: height * .06,),

            Button(title: 'Login', onPress: () {
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
                Login(_emailController.text, _passwordController.text);
              }
            }),

            SizedBox(height: height * .05,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have account?",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),
                TextButton(onPressed: () {
                  Navigator.pushNamed(context, RoutesName.signUp);
                },
                    child: Text("Sign up", style: TextStyle(
                        color: CupertinoColors.link,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),)),
              ],
            )

          ]),
        ),
      ),
    );
  }


  void Login(String email, String password) async {
    FocusManager.instance.primaryFocus?.unfocus();

    await _auth.signInWithEmailAndPassword(email: email, password: password)
        .then((_) {

          User? user= _auth.currentUser;

          final userPreference = Provider.of<UserSession>(context , listen: false);
          userPreference.saveUser(
            UserModel(
              uId: user?.uid.toString(),
            )
          );
          Navigator.pushReplacementNamed(context, RoutesName.home);
          Utils.flushBarMessage('Login successfully', context);
    }).catchError((e) {
      switch (e.code){
        case 'invalid-credential':
          errorMessage = 'Email or password is incorrect.';
        case 'user-disabled':
          errorMessage = 'User with this email has been disabled.';
        default:
          errorMessage = 'An undefined error occurred';
      }
      Utils.flushBarMessage(errorMessage!, context);
    });
  }
}
