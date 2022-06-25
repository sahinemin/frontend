
import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:geolocator/geolocator.dart';


class PlaceDetails extends StatefulWidget {
  String accessToken;
  String city;
  PlaceDetails({Key? key,required this.accessToken,required this.city}) : super(key: key);
  @override
  State<PlaceDetails> createState() => _PlaceDetailsState();
}

class _PlaceDetailsState extends State<PlaceDetails> {
  @override
  Widget build(BuildContext context) {
    var data=ModalRoute.of(context)?.settings.arguments;
    widget.accessToken=data.toString().substring(14,data.toString().length-1);
    widget.city=data.toString().substring(data.toString().length-4,data.toString().length-1);
    bool hasConnection=false;
    return Scaffold(
        extendBody: true,
        appBar: AppBar(title: const Text("PlaceDetails"),leading:  BackButton(
          onPressed: ()=>Navigator.pushReplacementNamed(context, '/cityPlaces',arguments: <String, String>{
            'accessToken': widget.accessToken,
            'city':widget.city
          },
            ),
        ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed("/");
                  // do something
                },
              )
            ]
        ),
        body:  FutureBuilder<List<dynamic>?>(initialData:const [],builder: (ctx,snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If we got an error
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '${snapshot.error} occurred',
                  style: const TextStyle(fontSize: 24),
                ),
              );

              // if we got our data
            } else if (snapshot.hasData) {
              // Extracting data from snapshot object
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 300,
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: list.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(margin: const EdgeInsets.only(bottom: 10),child: CachedNetworkImage(imageUrl:list[index].toString(),placeholder: (context, url) => CircularProgressIndicator(),
                              errorWidget: (context, url, error) => const Icon(Icons.error),));
                          }),
                    ),
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(snapshot.data![0]["full"], style: const TextStyle(color: Colors.black, fontSize: 18,)
                        ),
                      ),
                    Text("Distance: $distance km",style:const TextStyle(fontSize: 18),)
                  ],
                ),
              );
            }
          }
          return const Center(
            child: CircularProgressIndicator(),
          );

        },
          future: fetchData(widget.accessToken,widget.city,hasConnection,context),
        )
        
    );
  }
}
List<String> list=[];
double latitude=0.0;
double longitude=0.0;
double distance=0.0;
Future<List<dynamic>?> fetchData(String token,city,bool hasConnection,BuildContext context) async {
  hasConnection = await InternetConnectionChecker().hasConnection;
  if(hasConnection) {
    final url = Uri.parse('http://192.168.1.33:5000/rest/places');
    final headers = {
      "Content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token"
    };
    var response = await http.post(
        url, headers: headers, body: '{"city":"$city"}');
    var decoded = json.decode(response.body);
    latitude=decoded[0]["latitude"];
    longitude=decoded[0]["longitude"];


    //print(decoded[0]["landing"]);
    //print(decoded[0]["alternative"].toString().substring(1,decoded[0]["alternative"].toString().length-1).split(",").length);
    list = [];
    list.add(decoded[0]["landing"]);
    //print(decoded[0]["alternative"].toString());
    if (decoded[0]["alternative"]
        .toString()
        .length > 3) {
      for (int i = 0; i < decoded[0]["alternative"]
          .toString()
          .substring(1, decoded[0]["alternative"]
          .toString()
          .length - 1)
          .split(",")
          .length; i++) {
        list.add(decoded[0]["alternative"].toString().substring(
            1, decoded[0]["alternative"]
            .toString()
            .length - 1).split(",")[i].trim());
      }
    }
    Position position= await _determinePosition();
    distance = Geolocator.distanceBetween(position.latitude, position.longitude, decoded[0]["latitude"],decoded[0]["longitude"]).ceil()/1000;

    return decoded;
  }
  else{
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Network is not available")));
    return null;
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.

  return await Geolocator.getCurrentPosition();
}