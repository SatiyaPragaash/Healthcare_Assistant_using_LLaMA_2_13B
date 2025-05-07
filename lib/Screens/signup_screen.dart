import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/userSession.dart';
import '../Utils/Utils.dart';
import '../Utils/routes/routes_name.dart';
import '../model/userModel.dart';
import '../res/colors.dart';
import '../res/component/button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final ValueNotifier<bool> _obsecurePassword = ValueNotifier<bool>(true);
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? selectedLanguage;

  final _auth = FirebaseAuth.instance;
  String? errorMessage;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _obsecurePassword.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return  Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(children: [
            Center(
                child: Container(
                  width: width*.4,
                  height: height*.3,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                            'assets/images/chat-bot.png',
                          )
                      )
                  ),
                )),

            TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    hintText: 'Name',
                    prefixIcon: const Icon(Icons.person_outlined),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColor.borderColor)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColor.borderColor)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0), // Adjust the padding as needed

                )),

            SizedBox(
              height: height * .03,
            ),

            TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColor.borderColor)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColor.borderColor)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0), // Adjust the padding as needed
                ),),

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
                        prefixIcon: const Icon(Icons.password),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColor.borderColor)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColor.borderColor)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0), // Adjust the padding as needed
                    ),
                  );
                }),

            SizedBox(
              height: height * .03,
            ),

            ValueListenableBuilder(
                valueListenable: _obsecurePassword,
                builder: (context, value, child) {
                  return TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obsecurePassword.value,
                    decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.password),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColor.borderColor)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColor.borderColor)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0), // Adjust the padding as needed
                    ),
                  );
                }),


          CheckboxListTile(
            autofocus: false,
            title: const Text('Show password'),
            value: !_obsecurePassword.value, // Negate the value here
            onChanged: (bool? value) {
              setState(() {
                _obsecurePassword.value = !value!; // Negate the value here as well
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
        SizedBox(height: height*.02,),

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
              hint:Text(
                "Please choose chat langauage",),
              onChanged: (String? value) {
                setState(() {
                  selectedLanguage = value!;
                });
              },
            ),

        SizedBox(height: height*.02,),

        Button(title: 'Sign Up',
            onPress: (){
               if(_nameController.text.isEmpty){
                Utils.flushBarMessage('Please enter name', context);
              }
               else if(_emailController.text.isEmpty){
                 Utils.flushBarMessage('Please enter email.', context);
               }
               else if(_passwordController.text.isEmpty){
                Utils.flushBarMessage('Please enter password.', context);
              }
              else if(_passwordController.text.length<8){
                Utils.flushBarMessage('Password length should be greater than 8 character.', context);
              }else if(_passwordController.text != _confirmPasswordController.text){
                Utils.flushBarMessage('Password and confirm password should be same.', context);
              } else if(selectedLanguage ==null ){
                Utils.flushBarMessage('Please select chat language', context);
               }
            else{
                signUp(_emailController.text, _passwordController.text);

              }
            }),

            SizedBox(height: height*.04,),


            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have account?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),
                TextButton(onPressed: (){
                  Navigator.pushNamed(context, RoutesName.login);
                },child: const Text("Login", style: TextStyle(color: CupertinoColors.link,fontSize: 14, fontWeight: FontWeight.w500),)),
              ],
            )

          ]),
        ),
      ),
    );
  }

  void signUp (String email, String password) async{
    FocusManager.instance.primaryFocus?.unfocus();

    await _auth.createUserWithEmailAndPassword(email: email, password: password).then((_) {
      postDetailstoFirestore();
      User? user= _auth.currentUser;

      final userPreference = Provider.of<UserSession>(context , listen: false);
      userPreference.saveUser(
          UserModel(
            uId: user?.uid.toString(),
          )
      );
      Navigator.pushReplacementNamed(context, RoutesName.home);
      Utils.flushBarMessage('Account created successfully.', context);
    }).catchError((e){
      switch(e.code){
        case 'email-already-in-use':
          errorMessage = 'Email is already in use.';
        default:
          errorMessage = 'An undefined error occurred';
      }
      Utils.flushBarMessage(errorMessage!, context);
    });
  }

  postDetailstoFirestore() async {
    User? user= _auth.currentUser;
    UserModel userModel = UserModel();
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    userModel.uId= user!.uid;
    userModel.name = _nameController.text.trim();
    userModel.email = _emailController.text.trim();
    userModel.lang = selectedLanguage;

    await firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toMap());
  }

}
