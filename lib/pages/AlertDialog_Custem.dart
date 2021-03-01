import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:threadon/model/Open_Sale.dart';


class AlertDailog_Custom extends StatefulWidget{

  @override
  State<StatefulWidget> createState() =>alert_dailog();

}


class alert_dailog extends State<AlertDailog_Custom>{


  double width ;
  double height;


  Future<List<Open_Sale>> fetchPhotos(http.Client client) async {
    final response =
    await client.get('https://jsonplaceholder.typicode.com/photos');

    return parsePhotos(response.body);
  }

  List<Open_Sale> parsePhotos(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<Open_Sale>((json) => Open_Sale.fromJson(json)).toList();
  }

  Widget OpenDailog(){


    return new SimpleDialog(
      children: <Widget>[
        new Container(
          height:height,
          width: width,


          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              title: new Text('Add Item to your',style: TextStyle(color: Colors.black),) ,
              elevation: 0.0,
              centerTitle: true,
            ),

            body:  FutureBuilder<List<Open_Sale>>(
              future: fetchPhotos(http.Client()),
              builder: (context, snapshot) {
                if (snapshot.hasError) print(snapshot.error);

                return snapshot.hasData
                    ? OderList(photos: snapshot.data)
                    : Center(child: CircularProgressIndicator());
              },
            ),

            bottomNavigationBar: Container(
              height: 45.0,
              color: Colors.black,
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Add Item to new Share List',
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
                maxLines: 2,
              ),
            ),

          ),
          /*
          child: new ListView(
            children: <Widget>[
              new Text("one"),
              new Text("two"),
            ],
          ),*/
        )
      ],
    );
  }
  @override
  Widget build(BuildContext context) {

     width = MediaQuery.of(context).size.width;
     height = MediaQuery.of(context).size.height-150;
    // TODO: implement build
    return Scaffold(

      body:  OpenDailog(),

    );
  }



}




class OderList extends StatelessWidget {

  final List<Open_Sale> photos;


  OderList({Key key, this.photos}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: photos.length,
        itemBuilder: (context, position) {
          return GestureDetector(

            child: Container(
                height: 80.0,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0, left: 30.0),
                color: Colors.white,

                child: Row(
                  children: <Widget>[

                    Container(
                      child: Image.network(photos[position].imageUrl),
                    ),
                    Container(

                      padding: EdgeInsets.only(left: 20.0),
                      child: Text('Cloting', style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.black87), maxLines: 1,),
                    ),
                  ],
                )
              // photo and title


            ),

            // onTap: ()=> MyNavigator.gotoAdd_item_2Screen(context, 'Cloting'),
          );
        }
    );
  }
}