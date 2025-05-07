import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeChanger with ChangeNotifier{

  var _themeMode= ThemeMode.light;
  ThemeMode get themeMode=> _themeMode;

  ThemeChanger() {
    _loadTheme();
  }


  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ThemeMode savedTheme = ThemeMode.values[prefs.getInt('Theme_mode') ?? 0];
    setTheme(savedTheme);
  }


  void setTheme(themeMode)async{

    _themeMode= themeMode;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('Theme_mode', _themeMode.index);

    notifyListeners();
  }
}