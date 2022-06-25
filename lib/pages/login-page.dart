
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  @override
  State<Login> createState() => _LoginState();
}


class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _passwordController = TextEditingController();
  bool hasConnection=false;
  @override
  void initState (){
    super.initState();
    _getSharedPreferences(_usernameController, _passwordController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.indigo,
        appBar: AppBar(
          title: const Text('TASK'),
          backgroundColor: Colors.black,
        ),
        body:  Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:  <Widget>[
              const Text('LOGIN',style: TextStyle(color: Colors.white,fontSize: 28.0),),
              Container(
                height: 50,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                decoration:  const BoxDecoration(
                  color: Color(0x60FFFFFF),
                  borderRadius:  BorderRadius.all(Radius.circular(10)),
                ),
                child: TextFormField(
            controller: _usernameController,
            validator: (String? val) {
                if(val!.isEmpty){
                  return "Please enter a username";
                }
                return null;
             },
            decoration: const InputDecoration.collapsed(
                hintStyle: TextStyle(
                    color: Colors.white60,
                    fontSize: 15
                ),
                hintText: 'Username',
                border: InputBorder.none,
            ),
          ),
              ),
              Container(
                height: 50,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                decoration:  const BoxDecoration(
                  color: Color(0x60FFFFFF),
                  borderRadius:  BorderRadius.all(Radius.circular(10)),
                ),
                child: TextFormField(
                  obscureText: true,
                  controller: _passwordController,
                  validator: (String? val) {
                    if(val!.isEmpty){
                      return "Please enter a password";
                    }
                    return null;
                  },
                  decoration: const InputDecoration.collapsed(
                    hintStyle: TextStyle(
                        color: Colors.white60,
                        fontSize: 15
                    ),
                    hintText: 'Password',
                    border: InputBorder.none,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 60),
                decoration:  const BoxDecoration(
                  color:  Color(0xFFE19600),
                  borderRadius:  BorderRadius.all( Radius.circular(10)),
                ),
                child: TextButton(
                  child: const Text('LOG IN',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () async {
                    var resp=await makePostRequest(_usernameController.text,_passwordController.text,hasConnection,context);

                    await Future.delayed(const Duration(seconds: 1));
                    if (!mounted) return;
                    if(resp!=null){
                      if(resp.statusCode==200) {


                        var respData=jsonDecode(resp.body);
                        //print(checkValue.toString()+"loginden önce");
                        await setSharedPreferences( _usernameController.text, _passwordController.text);
                        Navigator.pushReplacementNamed(context, '/cities',arguments: <String, String>{
                          'accessToken': respData["access_token"],
                        },);


                      }
                      else{
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp.body)));
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        )
    );
  }
}

Future<http.Response?> makePostRequest(String username,password, bool hasConnection, BuildContext context) async {
  hasConnection = await InternetConnectionChecker().hasConnection;
  http.Response response;
  if(hasConnection) {
    final url = Uri.parse('http://192.168.1.33:5000/rest/login');
    final headers = {"Content-type": "application/json"};
    var json = '{"username": "$username" , "password": "$password"}';
    response= await http.post(url, headers: headers, body: json);
    return response;
  }

  else {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Network is not available")));
    return null;
  }


}
_getSharedPreferences(TextEditingController usernameController,passwordController) async{
  SharedPreferences preferences = await SharedPreferences.getInstance();
    usernameController.text = preferences.getString("String")??"";
    passwordController.text = preferences.getString("String2")??"";
}

setSharedPreferences(String username,String password) async{
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("String", username);
  await preferences.setString("String2", password);

}