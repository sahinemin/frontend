import 'package:flutter/material.dart';
import 'pages/login-page.dart';
import 'pages/cities-list-page.dart';
void main() =>
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    routes:  {
      '/': (context) => const Login(),
      '/cities': (context) => const CitiesList(),
      '/cityPlaces': (context) => const Text('data'),
      '/placeDetails': (context) => const Text('data'),
    },
  ));


