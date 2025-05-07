 import 'package:chat_bot/model/userModel.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSession with ChangeNotifier{

  Future<bool> saveUser(UserModel user) async{

    final SharedPreferences sp= await SharedPreferences.getInstance();
    sp.setString('Uid', user.uId.toString());

    notifyListeners();

    return true;
  }

  Future<UserModel> getUser()async{
    final SharedPreferences sp= await SharedPreferences.getInstance();

    final String? Uid= sp.getString('Uid');
    final String? name= sp.getString('Name');
    final String? email= sp.getString('Email');
    final String? lang= sp.getString('Lang');
    return UserModel(
      uId: Uid.toString(),
      name: name.toString(),
      email: email.toString(),
      lang: lang.toString()
    );
  }

  Future<bool> remove()async{
    final SharedPreferences sp= await SharedPreferences.getInstance();
    sp.remove('Uid');
    sp.remove('Name');
    sp.remove('Email');
    sp.remove('Lang');

    return true;
  }
}