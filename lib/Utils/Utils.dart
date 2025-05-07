
import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_route.dart';
import 'package:flutter/cupertino.dart';

class Utils{
  static void flushBarMessage(String message, BuildContext context){
    showFlushbar(context: context, flushbar: Flushbar(
      message: message,
      forwardAnimationCurve: Curves.decelerate,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(15),
      duration: Duration(seconds: 3),
      reverseAnimationCurve: Curves.easeInOut,
      positionOffset: 20,
      borderRadius: BorderRadius.all(Radius.circular(8)),
      flushbarPosition: FlushbarPosition.TOP,


    )..show(context)
    );

  }
}