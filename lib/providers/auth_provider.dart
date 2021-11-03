import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:loginapi_app/domain/user.dart';
import 'package:loginapi_app/utility/app_url.dart';
import 'package:loginapi_app/utility/shared_preferences.dart';
import 'package:http/http.dart';


    enum Status{
    NotLoggedIn,
    NotRegistered,
    LoggedIn,
    Registered,
    Authenticating,
    Registering,
    LoggedOut
  }

class AuthProvider extends ChangeNotifier{
  Status _loggedInStatus = Status.NotLoggedIn;
  Status _registeredInStatus = Status.NotRegistered;

  Status get loggedInStatus => _loggedInStatus;

  set loggedInStatus(Status value) {
    _loggedInStatus = value;
  }

  Status get registeredInStatus => _registeredInStatus;

  set registeredInStatus(Status value) {
    _registeredInStatus = value;
  }

  Future<Map<String,dynamic>>register(String email,String password) async{
    final Map<String,dynamic> apiBodyData = {
      'email':email,
      'password':password,
    };
    return await post(
        AppUrl.register,
        body:json.encode(apiBodyData),
        headers:{'Content-Type':'application/json'}
    ).then(onValue).catchError(onError);
  }
  notify(){
    notifyListeners();
  }

  static Future<FutureOr> onValue (Response response) async{
    var result;

    final Map<String,dynamic> responseData = json.decode(response.body);
    print(responseData);

    if(response.statusCode==200){
      var userData=responseData['data'];

      User authUser = User.fromJson(responseData);

      UserPreferences().saveUser(authUser);

      result= {
        'status':true,
        'message':"Successfully Registered!",
        'data':authUser,
      };
    }
    else{
      result= {
        'status':false,
        'message':"Successfully Registered!",
        'data':responseData,
      };
    }
    return result;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {

    var result;

    final Map<String, dynamic> loginData = {
      'UserName': email,
      'Password': password
    };

    _loggedInStatus = Status.Authenticating;
    notifyListeners();

    Response response = await post(
      AppUrl.Login,
      body: json.encode(loginData),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic ZGlzYXBpdXNlcjpkaXMjMTIz',
        'X-ApiKey' : 'ZGlzIzEyMw=='
      },
    );

    if (response.statusCode == 200) {

      final Map<String, dynamic> responseData = json.decode(response.body);

      print(responseData);

      var userData = responseData['Content'];

      User authUser = User.fromJson(userData);

      UserPreferences().saveUser(authUser);

      _loggedInStatus = Status.LoggedIn;
      notifyListeners();

      result = {'status': true, 'message': 'Successful', 'user': authUser};

    } else {
      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();
      result = {
        'status': false,
        'message': json.decode(response.body)['error']
      };
    }

    return result;

  }

  static onError(error){
    print('the error is ${error.detail}');
    return {
      'status':false,
      'message':"Unsuccessful Request!",
      'data':error,
    };
  }
}