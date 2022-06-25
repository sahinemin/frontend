import 'package:flutter/material.dart';
import 'package:frontend/pages/city-places-list-page.dart';
import 'package:frontend/pages/place-details-page.dart';
import 'pages/login-page.dart';
import 'pages/cities-list-page.dart';
void main() =>
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    routes:  {
      '/': (context) => const Login(),
      '/cities': (context) =>  CitiesList(accessToken: ''),
      '/cityPlaces': (context) => CityPlacesList(accessToken: '',city: ""),
      '/placeDetails': (context) => PlaceDetails(accessToken: '', city: ""),
    },
  ));


