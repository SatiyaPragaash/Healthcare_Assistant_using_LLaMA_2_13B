import 'package:chat_bot/Provider/chat_provider.dart';
import 'package:chat_bot/Provider/theme_changer_provider.dart';
import 'package:chat_bot/Provider/userSession.dart';
import 'package:chat_bot/Utils/routes/routes_name.dart';
import 'package:chat_bot/res/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Utils/routes/routes.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeChanger()),
          ChangeNotifierProvider(create: (_) => UserSession()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child: Builder(
          builder: (BuildContext context) {
            final themeChanger= Provider.of<ThemeChanger>(context);
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              themeMode: themeChanger.themeMode,
              theme: ThemeData(
                brightness: Brightness.light,
                primaryColor: AppColor.primaryColor,
                appBarTheme: AppBarTheme(
                    backgroundColor: AppColor.primaryColor
                ),
                useMaterial3: true,
              ),


              darkTheme: ThemeData(
                brightness: Brightness.dark,
                useMaterial3: true,
                appBarTheme: AppBarTheme(
                  backgroundColor: Color(0xff211F26),
                ),


              ),
              initialRoute: RoutesName.splashScreen,
              onGenerateRoute: Routes.generateRoute,
            );
          },
        ));
  }
}
