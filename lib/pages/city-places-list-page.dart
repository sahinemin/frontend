
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class CityPlacesList extends StatefulWidget {
   String accessToken;
   String city;
   CityPlacesList({Key? key,required this.accessToken,required this.city}) : super(key: key);

  @override
  State<CityPlacesList> createState() => _CityPlacesListState();
}

class _CityPlacesListState extends State<CityPlacesList> {
  @override
  Widget build(BuildContext context) {
    var data=ModalRoute.of(context)?.settings.arguments;
    widget.accessToken=data.toString().substring(14,data.toString().length-1);
    widget.city=data.toString().substring(data.toString().length-4,data.toString().length-1);
    bool hasConnection=false;
    return Scaffold(
        appBar: AppBar(title: const Text("City Places"),leading:  BackButton(
          onPressed: ()=>Navigator.pushReplacementNamed(context, '/cities',arguments: <String, String>{
            'accessToken': widget.accessToken,
            'city':widget.city
          }
          ,),
        ),actions: <Widget>[
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
        ]),
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
              return Column(
                children: <Widget>[
                  SizedBox(
                      height: 300,
                      child: GestureDetector(onTap:(){Navigator.pushReplacementNamed(context, '/placeDetails',arguments: <String, String>{
                        'accessToken': widget.accessToken,
                        'city':widget.city
                      },);

                        },child: CachedNetworkImage(imageUrl:snapshot.data![0]["landing"].toString(),placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),)),
                  ),
                  Expanded(
                    child: GestureDetector(onTap:(){Navigator.pushReplacementNamed(context, '/placeDetails',arguments: <String, String>{
                      'accessToken': widget.accessToken,
                      'city':widget.city
                    },
                    );
                      }, child: Text(snapshot.data![0]["intro"], style: const TextStyle(color: Colors.black, fontSize: 18,)
                      ),
                    ),
                  ),

                ],
              );
            }
          }
          return const Center(
            child: CircularProgressIndicator(),
          );




        },
          future: fetchData(widget.accessToken,widget.city,hasConnection,context),



        )

      //body: const Text('deneme'),
      //floatingActionButton: FloatingActionButton(onPressed: () async {await fetchData(widget.accessToken, widget.city);  },),
    );
  }
}
Future<List<dynamic>?> fetchData(String token,city,bool hasConnection,BuildContext context) async {
  hasConnection = await InternetConnectionChecker().hasConnection;
  var response;
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
    //print(decoded[0]);
    return decoded;
  }
  else{
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Network is not available")));
    return null;
  }
}

