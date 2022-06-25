
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;

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
    return Scaffold(
        extendBody: true,
        appBar: AppBar(title: const Text("PlaceDetails"),leading:  BackButton(
          onPressed: ()=>Navigator.pushReplacementNamed(context, '/cityPlaces',arguments: <String, String>{
            'accessToken': widget.accessToken,
            'city':widget.city
          }
            ,),
        )),
        body:  FutureBuilder<List<dynamic>>(initialData:const [],builder: (ctx,snapshot) {
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
                      )
                  ],
                ),
              );
            }
          }
          return const Center(
            child: CircularProgressIndicator(),
          );




        },
          future: fetchData(widget.accessToken,widget.city),



        )
        
    );
  }
}
List<String> list=[];
Future<List<dynamic>> fetchData(String token,city) async {
  final url = Uri.parse('http://192.168.1.33:5000/rest/places');
  final headers = {"Content-type": "application/json", "Accept": "application/json","Authorization":"Bearer $token"};
  var response = await http.post(url, headers: headers, body: '{"city":"$city"}');
  var decoded = json.decode(response.body);
  //print(decoded[0]["landing"]);
  //print(decoded[0]["alternative"].toString().substring(1,decoded[0]["alternative"].toString().length-1).split(",").length);
  list=[];
  list.add(decoded[0]["landing"]);
  //print(decoded[0]["alternative"].toString());
  if(decoded[0]["alternative"].toString().length>3)
  {
    for(int i=0; i<decoded[0]["alternative"].toString().substring(1,decoded[0]["alternative"].toString().length-1).split(",").length; i++)
  {
    list.add(decoded[0]["alternative"].toString().substring(1,decoded[0]["alternative"].toString().length-1).split(",")[i].trim());

  }
  }

 // print(list);

  return decoded;
}