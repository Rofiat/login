import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:loginapi_app/domain/user.dart';
import 'package:loginapi_app/providers/auth_provider.dart';
import 'package:loginapi_app/providers/user_provider.dart';
import 'package:loginapi_app/utility/validator.dart';
import 'package:loginapi_app/utility/widgets.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);
  final formKey = GlobalKey<FormState>();
  String _userName,_password,_confirmPassword;

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);

    var doRegister = (){
      final form= formKey.currentState;
      if(form.validate()){
        form.save();
        if(_password.endsWith(_confirmPassword)){
          //auth.loggedInStatus = Status.Authenticating;
          //auth.notify();
          auth.register(_userName, _password).then((response) {
            if(response['status']){
              User user = response['data'];
              Provider.of<UserProvider>(context,listen: false).setUser(user);
             /* Future.delayed(loginTime).then((_) {
                Navigator.pushReplacementNamed(context, '/login');
                auth.loggedInStatus = Status.LoggedIn;
                auth.notify();
              } );*/
              Navigator.pushReplacementNamed(context, '/login');
            }else{
              Flushbar(
                title: 'Registration fail',
                message: response.toString(),
                duration: Duration(seconds: 10),
              ).show(context);
            }
          });
        }
        else{
          Flushbar(
            title:"Mismatch password",
            message:"Please enter valid confirm password",
            duration:Duration(seconds:10),
          ).show(context);
        }
      }
      else{
        Flushbar(
          title:"Invalid Form",
          message:"Please complete the form properly",
          duration:Duration(seconds:10),
        ).show(context);
      }
    };

    var loading  = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        Text(" Registering ... Please wait")
      ],
    );


    return Scaffold(
      appBar: AppBar(title:Text('Registration')),
      body:SingleChildScrollView(
        child:Container(
    padding:EdgeInsets.all(40.0),
    child:Form(
      key:formKey,
    child:Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    SizedBox(height: 15.0),
    Text("Email"),
    SizedBox(height:5.0),
    TextFormField(
    autofocus: false,
    validator: validateEmail,
    onSaved:(value)=>_userName=value,
    decoration:buildInputDecoration("", Icons.email)
    ),
    SizedBox(height:20.0),
    Text("Password"),
    SizedBox(height:5.0),
    TextFormField(
    autofocus: false,
    obscureText: true,
    validator:(value) =>value.isEmpty?"Please enter password":null,
    onSaved:(value)=>_password=value,
    decoration:buildInputDecoration("",Icons.lock),
    ),
    SizedBox(height:20.0),
    Text("Confirm Password"),
    //SizedBox(height:5.0),
    TextFormField(
    autofocus: false,
    obscureText: true,
    validator:(value) =>value.isEmpty?"Your password is required":null,
    onSaved:(value)=>_confirmPassword=value,
    decoration:buildInputDecoration("",Icons.lock),
    ),
      SizedBox(height:20.0),
      auth.loggedInStatus == Status.Authenticating
          ?loading
          : longButtons('Register',doRegister)

    ],
    ),
    ),
    ),
      ),
    );
  }
}
