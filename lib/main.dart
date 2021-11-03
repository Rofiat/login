import 'package:flutter/material.dart';
import 'package:loginapi_app/providers/auth_provider.dart';
import 'package:loginapi_app/providers/user_provider.dart';
import 'package:loginapi_app/screens/dashboard.dart';
import 'package:loginapi_app/screens/register.dart';
import 'package:loginapi_app/utility/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'domain/user.dart';
import 'screens/login.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<User> getUserData () => UserPreferences().getUser();
    return MultiProvider(
      providers:[
        ChangeNotifierProvider(create:(_)=> AuthProvider()),
        ChangeNotifierProvider(create:(_)=> UserProvider()),
      ],
      child:MaterialApp(
          title:'Login Registration',
          home:FutureBuilder(
              future: getUserData(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  default:
                    if (snapshot.hasError)
                      return Text('Error: ${snapshot.error}');
                    else if (snapshot.data.token == null)
                      return LogIn();
                    else
                      Provider.of<UserProvider>(context).setUser(snapshot.data);
                    return DashBoard();

                }
              }),
          routes: {
            '/login': (context) => LogIn(),
            '/register': (context) => Register(),
            '/dashboard':(context) => DashBoard(),
          }
      ),
    );


  }
}


