
import 'package:chat_bot/Screens/forgot_password.dart';
import 'package:chat_bot/Screens/home_screen.dart';
import 'package:chat_bot/Screens/login_screen.dart';
import 'package:chat_bot/Screens/settings.dart';
import 'package:chat_bot/Screens/signup_screen.dart';
import 'package:chat_bot/Screens/splash_screen.dart';
import 'package:chat_bot/Utils/routes/routes_name.dart';
import 'package:flutter/material.dart';


class Routes{
  static Route<dynamic> generateRoute(RouteSettings settings){
    final argume =settings.arguments;

    switch(settings.name){
      case RoutesName.splashScreen:
        return MaterialPageRoute(builder: (BuildContext context)=> const SplashScreen());
      case RoutesName.login:
        return MaterialPageRoute(builder: (BuildContext context)=> const LoginScreen());

      case RoutesName.signUp:
        return MaterialPageRoute(builder: (BuildContext context)=> const SignUpScreen());

      case RoutesName.forgotPassword:
        return MaterialPageRoute(builder: (BuildContext context)=> const ForgotPasswordScreen());

      case RoutesName.home:
        return MaterialPageRoute(builder: (BuildContext context)=> const HomeScreen());

      case RoutesName.settings:
        return MaterialPageRoute(builder: (BuildContext context)=> const SettingsScreen());
      default:
        return MaterialPageRoute(builder: (_){
          return const Scaffold(

            body: Center(
              child: Text('No route defined'),
            ),
          );
        });
    }
  }
}