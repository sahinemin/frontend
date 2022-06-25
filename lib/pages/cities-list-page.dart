
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CitiesList extends StatefulWidget {
  String accessToken;
  CitiesList({Key? key,  required this.accessToken}) : super(key: key);

  @override
  State<CitiesList> createState() => _CitiesListState();
}

class _CitiesListState extends State<CitiesList> {
  @override
  Widget build(BuildContext context) {
    var data=ModalRoute.of(context)?.settings.arguments;
    widget.accessToken=data.toString().substring(14,data.toString().length-1);

    return Scaffold(
      appBar: AppBar(title: const Text("Cities")),
      body:  FutureBuilder<List<dynamic>>(initialData:const [],builder: (ctx,snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If we got an error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${snapshot.error} occurred',
                style: const TextStyle(fontSize: 18),
              ),
            );

            // if we got our data
          } else if (snapshot.hasData) {
            // Extracting data from snapshot object
            return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                      leading: const Icon(Icons.location_city_rounded),
                      trailing: Text(
                        snapshot.data![index]["code"],
                        style: const TextStyle(color: Colors.green, fontSize: 15),
                      ),
                      title: Text(snapshot.data![index]["name"]),
                      onTap: (){
                        Navigator.pushReplacementNamed(context, '/cityPlaces',arguments: <String, String>{
                          'accessToken': widget.accessToken,
                          'city':snapshot.data![index]["code"]
                        },);
                      },
                  );
                });
          }
        }
        return const Center(
          child: CircularProgressIndicator(),
        );




        },
      future: fetchData(widget.accessToken),



      )

    );
  }
}
// ignore: prefer_typing_uninitialized_variables
Future<List<dynamic>> fetchData(String token) async {
  final url = Uri.parse('http://192.168.1.33:5000/rest/cities');
  final headers = {"Content-type": "application/json", "Accept": "application/json","Authorization":"Bearer $token"};
  var response = await http.post(url, headers: headers, body: '{}');
  var decoded = json.decode(response.body);
  return decoded["data"];
}
/*
var resp=await fetchData(widget.accessToken);

 */
