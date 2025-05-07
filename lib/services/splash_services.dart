import 'package:chat_bot/Provider/userSession.dart';
import 'package:chat_bot/Utils/routes/routes_name.dart';
import 'package:flutter/material.dart';

import '../model/userModel.dart';

class SplashServices{

  Future<UserModel> getUserData()=> UserSession().getUser();

  void checkAuthentication(BuildContext context) async{
    getUserData().then((value) async {
      if(value.uId== 'null' || value.uId== '' ){
       await Future.delayed(Duration(seconds: 3));
        Navigator.pushReplacementNamed(context, RoutesName.login);
      } else{
        await Future.delayed(Duration(seconds: 3));
        Navigator.pushReplacementNamed(context, RoutesName.home);

      }
    });
  }
}