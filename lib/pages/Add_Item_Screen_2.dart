import 'dart:convert';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Open_Sale.dart';
import 'package:threadon/model/Sub_Category.dart';
import 'package:threadon/pages/Constant.dart';
// ignore: uri_does_not_exist
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/SharedPreferencesHelper.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'package:flutter/services.dart';


class Add_Item_2 extends StatefulWidget{

  String appbar_name;

  Add_Item_2({Key key, this.appbar_name}) : super(key: key);
  @override
  State<StatefulWidget> createState() =>add_item_2(appbar_name);

}


class add_item_2 extends State<Add_Item_2>{

  String name_type;

  List<Sub_CategoryModel> sub_categoryList;

  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  String Is_Sub_Cat_id='';
  String Cat_Id = '';
  String is_sub_category ;
  bool _isInAsyncCall = false;
  add_item_2(this.name_type);


  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;




  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    _updateConnectionStatus(result);
  }


  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        String wifiName, wifiBSSID, wifiIP;

        try {
          wifiName = await _connectivity.getWifiName();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiName = "Failed to get Wifi Name";
        }

        try {
          wifiBSSID = await _connectivity.getWifiIP();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiBSSID = "Failed to get Wifi BSSID";
        }

        try {
          wifiIP = await _connectivity.getWifiIP();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiIP = "Failed to get Wifi IP";
        }

        setState(() {
          _connectionStatus = '$result\n'
              'Wifi Name: $wifiName\n'
              'Wifi BSSID: $wifiBSSID\n'
              'Wifi IP: $wifiIP\n';
        });
        break;
      case ConnectivityResult.mobile:

        break;
      case ConnectivityResult.none:
        setState((){
          _showDialog1();
        });
        break;
      default:

        break;
    }
  }

  void _showDialog1() {
    // flutter defined function
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(

          title: new Text("No Internet connection"),
          content: new Text("We can\'t reach our network right now. Please check your connection."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog

            new FlatButton(
              child: new Text("Retry"),
              onPressed: () {
                setState(() {
                  initConnectivity();
                  Navigator.pop(context);
                });

              },
            ),
          ],
        );
      },
    );
  }


  getCredential() async {
    // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sub_categoryList = new List();
    Cat_Id = await SharedPreferencesHelper.getcat_id();




    CollectionReference ref = Firestore.instance.collection('sub_category');
    QuerySnapshot eventsQuery =
    await ref.where("is_sub_category_id", isEqualTo: Cat_Id).getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        _isInAsyncCall = false;

      });
    } else {
      eventsQuery.documents.forEach((doc) async {


        sub_categoryList.add(Sub_CategoryModel(doc['category_id'],
          doc['is_sub_category'],
          doc['is_sub_category_id'] ,
          doc['polybag'].toList(),
          doc['premium_box'].toList(),
          doc['sub_category_id'],
          doc['sub_category_image'],
          doc['sub_category_name'],



        ));
      });

      setState(() {

        _isInAsyncCall = false;
        sub_categoryList = this.sub_categoryList;
      });
    }


  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    sub_categoryList = new List();
    sub_categoryList.clear();
    setState(() {
      _isInAsyncCall = true;
    });
    getCredential();



  }

  @override
  void dispose() {
    noteSub?.cancel();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: new AppBar(
        backgroundColor: Colors.white70,
        elevation: 0.0,
        leading: GestureDetector(
          child: Icon(Icons.arrow_back,color: Colors.black,),
          onTap: (){
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110.0),

          child:Container(
            padding: EdgeInsets.only(left:20.0,top: 10.0),

            alignment: Alignment.topCenter,

            child:  Text(
              'What kind of '+name_type+'?',
              style: TextStyle(
                  fontSize: 40.0,
                  fontWeight: FontWeight.w300,
                  color: Colors.grey),
              maxLines: 2,
            ),

          ),
        ),
      ),


      body: ModalProgressHUD(

        child: sub_categoryList.length == 0 ?Showmsg(): ListView.builder(
            itemCount: sub_categoryList.length,
            itemBuilder: (context, position) {
              return  GestureDetector(
                  child: Container(
                      height: 80.0,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(left: 30.0),
                      color: Colors.white,

                      child: Row(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: sub_categoryList[position].Sub_category_image != ""? NetworkImage('${sub_categoryList[position].Sub_category_image}'):Image.asset('images/tonlogo.png'),


                                ),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.all(Radius.circular(5))),
                            margin: EdgeInsets.only(left: 5, top: 5, right: 5, bottom: 5),
                            height: 70,
                            width: 70,
                          ),
                          /*
                        Container(
                          width: 70.0,
                          height:70.0,
                          child:FadeInImage.assetNetwork(
                            placeholder: 'images/t.png',
                            image:'${sub_categoryList[position].Sub_category_image}',
                            fit: BoxFit.scaleDown,
                          ),
                        ),*/

                          Container(

                            padding: EdgeInsets.only(left: 20.0),
                            child:  Text('${sub_categoryList[position].Sub_category_name}', style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.normal,
                                color: Colors.black87), maxLines: 1,),
                          ),
                        ],
                      )
                    // photo and title


                  ),

                  onTap: () async {
                    is_sub_category = '${sub_categoryList[position].Is_sub_category}';
                    Is_Sub_Cat_id = '${sub_categoryList[position].Is_sub_category_id}';

                    if(is_sub_category == '1'){

                      String  Sub_Cat_Id = '${sub_categoryList[position].Sub_category_id}';
                      await SharedPreferencesHelper.setsub_cat_id(Sub_Cat_Id);
                      await SharedPreferencesHelper.setsub_cat_name('${sub_categoryList[position].Sub_category_name}');
                      MyNavigator.gotoAdd_item_3Screen(context, '${sub_categoryList[position].Sub_category_name}');

                    }else{

                      String  Sub_Cat_Id = '${sub_categoryList[position].Sub_category_id}';
                      await SharedPreferencesHelper.setsub_cat_id(Sub_Cat_Id);
                      await SharedPreferencesHelper.setsub_cat_name('${sub_categoryList[position].Sub_category_name}');
                      Navigator.of(context).pushNamed(CAMERA_SCREEN);
                    }
                    //     MyNavigator.gotoAdd_item_2Screen(context, 'Cloting');
                  }
              );

            }

        ),
        inAsyncCall: _isInAsyncCall,
        opacity: 1,
        color: Colors.white,
        progressIndicator: CircularProgressIndicator(),
      ),


    );

  }

  Widget Showmsg() {
    return Center(

      /* child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset('images/tonlogo.png', color: Colors.black54,
              height: 50.0,
              width: 50.0,),

            new Container(height: 10.0,),

            Text('No category ', style: TextStyle(fontSize: 20.0),),

          ],


        )*/
    );
  }



}



