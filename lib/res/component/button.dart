import 'package:chat_bot/res/colors.dart';
import 'package:flutter/material.dart';


class Button extends StatelessWidget {
  final title;
  final VoidCallback onPress;
  const Button({super.key, required this.title, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 43,
      child: ElevatedButton(onPressed: onPress,
          style: ElevatedButton.styleFrom(backgroundColor: AppColor.primaryColor, elevation: 4)
          ,child: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),)),
    );
  }
}
