
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:search_page/search_page.dart';
class CitiesList extends StatefulWidget {
  String accessToken;
  CitiesList({Key? key,  required this.accessToken}) : super(key: key);

  @override
  State<CitiesList> createState() => _CitiesListState();
}
List cities=[];
class _CitiesListState extends State<CitiesList> {
  @override
  Widget build(BuildContext context) {
    var data=ModalRoute.of(context)?.settings.arguments;
    widget.accessToken=data.toString().substring(14,data.toString().length-1);
    bool hasConnection=false;
    return Scaffold(
      appBar: AppBar(title: const Text("Cities"),actions: <Widget>[
        IconButton(
          icon: const Icon(
            Icons.logout,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed("/");
            // do something
          },
        )
      ],),
      body:  FutureBuilder<List<dynamic>?>(initialData:const [],builder: (ctx,snapshot) {
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
            cities=[];
            for(int i=0; i<snapshot.data!.length; i++){
              cities.add(snapshot.data![i]);
            }
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
      future: fetchData(widget.accessToken,hasConnection,context),



      ),

    floatingActionButton:FloatingActionButton(
      tooltip: 'Search city',
      onPressed: () => showSearch(
        context: context,
        delegate: SearchPage(
          items: cities,
          searchLabel: 'Search city',
          suggestion: const Center(
            child: Text('Filter cities'),
          ),
          failure: const Center(
            child: Text('No city found :('),
          ),
          filter: (city) => [
            city.toString().substring(15,city.toString().length-1)
          ],
          builder: (city) => GestureDetector(
            onTap: (){
              Navigator.pushReplacementNamed(context, '/cityPlaces',arguments: <String, String>{
                'accessToken': widget.accessToken,
                'city':city.toString().substring(7,10)
              },);
            },
            child: ListTile(
              title: Text(city.toString().substring(17,city.toString().length-1)),
            ),
          ),
        ),
      ),
      child: const Icon(Icons.search),
    ),
    );
  }
}
// ignore: prefer_typing_uninitialized_variables
Future<List<dynamic>?> fetchData(String token,bool hasConnection,BuildContext context) async {
  hasConnection = await InternetConnectionChecker().hasConnection;
  var response;
  if(hasConnection){
    final url = Uri.parse('http://192.168.1.33:5000/rest/cities');
    final headers = {"Content-type": "application/json", "Accept": "application/json","Authorization":"Bearer $token"};
    response = await http.post(url, headers: headers, body: '{}');
    var decoded = json.decode(response.body);
    return decoded["data"];
  }
  else{
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Network is not available")));
    return null;
  }



}
/*
var resp=await fetchData(widget.accessToken);

 */
