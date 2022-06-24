
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool checkValue = false;
  final TextEditingController _usernameController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _passwordController = TextEditingController();
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
                  return "Please enter a mail";
                }
                return null;
             },
            decoration: const InputDecoration.collapsed(
                hintStyle: TextStyle(
                    color: Colors.white60,
                    fontSize: 15
                ),
                hintText: 'Email',
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
                margin: const EdgeInsets.only(left: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,

                  children: [
                    Checkbox(
                      value : checkValue,
                      onChanged: (bool? value){
                        setState(() {
                          checkValue = value!;
                        });
                      },
                    ),
                    const Text(
                      'Remember Me',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ]
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
                    var statusCode=await makePostRequest(_usernameController.text,_passwordController.text);
                    await Future.delayed(const Duration(seconds: 1));
                    if (!mounted) return;
                  if(statusCode==200) {
                    Navigator.pushNamed(context, '/cities');
                  }
                  else{
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${response.body}')));
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

// ignore: prefer_typing_uninitialized_variables
var response;
Future<int> makePostRequest(String username,password) async {
  final url = Uri.parse('http://192.168.1.42:5000/rest/login');
  final headers = {"Content-type": "application/json"};
  var json = '{"username": "$username" , "password": "$password"}';
  response = await post(url, headers: headers, body: json);
  return response.statusCode;
}