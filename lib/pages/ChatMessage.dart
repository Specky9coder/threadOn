import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Message_List.dart';
import 'package:threadon/model/Message_UserList.dart';
import 'package:threadon/pages/Message_Screen.dart';
import 'package:threadon/pages/main_screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:flutter/services.dart';

class ChatMessageList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => chatList();
}

class chatList extends State<ChatMessageList> {
  final reference = FirebaseDatabase.instance.reference().child('messages');
  List<Message_UserListModel> message_list;
  List<Message_UserListModel> message_list_final =
      new List<Message_UserListModel>();
  List<Message_UserListModel> message_list_final_last =
      new List<Message_UserListModel>();
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  String attechment = '';
  String Ddate = '';
//  String Receiver_id = '';
  String Sender_id = '';
  int Message_type = 0;
  String profileImage1 = '';
  String Name = '';
  bool _isInAsyncCall = true;
  SharedPreferences sharedPreferences;
  CollectionReference ref;
  var temp;
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  String country = '';
  getCredential() async {
    message_list = new List();

    sharedPreferences = await SharedPreferences.getInstance();
    // Receiver_id = sharedPreferences.getString('seller_id');
    profileImage1 = sharedPreferences.getString('profile_image');
    Name = sharedPreferences.getString('UserName');
    Sender_id = sharedPreferences.getString('user_id');

    QuerySnapshot eventsQuery = await Firestore.instance
        .collection('chat_log_list')
        .where("sender_id", isEqualTo: Sender_id)
        .orderBy('date', descending: true)
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      getReceiver();
    } else {
      eventsQuery.documents.forEach((doc1) async {
        //  if(message_list.length == 0){
        String userid = doc1['receiver_id'];

        CollectionReference ref = Firestore.instance.collection('users');
        QuerySnapshot eventsQuery =
            await ref.where("user_id", isEqualTo: userid).getDocuments();

        if (eventsQuery.documents.isEmpty) {
        } else {
          eventsQuery.documents.forEach((doc) async {
            country = doc['country'];

            if (message_list.length == 0) {
              message_list.add(Message_UserListModel(
                  doc1['date'].toDate(),
                  doc1['sender_id'],
                  doc1['receiver_id'],
                  doc['name'],
                  doc['profile_picture'],
                  country));
            } else {
              message_list.add(Message_UserListModel(
                  doc1['date'].toDate(),
                  doc1['sender_id'],
                  doc1['receiver_id'],
                  doc['name'],
                  doc['profile_picture'],
                  country));
            }

            setState(() {
              this.message_list_final = message_list;
            });
          });
          getReceiver();
        }
      });
    }
  }

  getReceiver() async {
    QuerySnapshot eventsQuery1 = await Firestore.instance
        .collection('chat_log_list')
        .where("receiver_id", isEqualTo: Sender_id)
        .orderBy('date', descending: true)
        .getDocuments();

    if (eventsQuery1.documents.isEmpty) {
      if (this.mounted) {
        setState(() {
          _isInAsyncCall = false;
        });
      }
    } else {
      eventsQuery1.documents.forEach((doc1) async {
        //  if(message_list.length == 0){
        String userid1 = doc1['sender_id'];

        CollectionReference ref = Firestore.instance.collection('users');
        QuerySnapshot eventsQuery =
            await ref.where("user_id", isEqualTo: userid1).getDocuments();

        if (eventsQuery.documents.isEmpty) {
        } else {
          eventsQuery.documents.forEach((doc) async {
            country = doc['country'];

            if (message_list.length == 0) {
              message_list.add(Message_UserListModel(
                  doc1['date'].toDate(),
                  doc1['sender_id'],
                  doc1['receiver_id'],
                  doc['name'],
                  doc['profile_picture'],
                  country));
            } else {
              message_list.add(Message_UserListModel(
                  doc1['date'].toDate(),
                  doc1['sender_id'],
                  doc1['receiver_id'],
                  doc['name'],
                  doc['profile_picture'],
                  country));
            }

            if (this.mounted) {
              setState(() {
                _isInAsyncCall = false;
                this.message_list_final = message_list;
              });
            }
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();

    getCredential();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

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
        setState(() {
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
          content: new Text(
              "We can\'t reach our network right now. Please check your connection."),
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.white70,
        title: Text('Chats'),
      ),
      body: ModalProgressHUD(
        child: message_list_final.isEmpty
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'images/tonlogo.png',
                    color: Colors.black54,
                    height: 50.0,
                    width: 50.0,
                  ),
                  new Container(
                    height: 10.0,
                  ),
                  Text(
                    'You don\'t have any chat ',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ],
              ))
            : ListView.builder(
                itemCount: message_list_final.length,
                itemBuilder: (context, position) {
                  return GestureDetector(
                    child: Card(
                        elevation: 2.0,
                        child: Column(children: <Widget>[
                          Container(
                            height: 80.0,
                            color: Colors.white,
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    flex: 2,
                                    child: new GestureDetector(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: message_list_final[
                                                              position]
                                                          .Sender_image !=
                                                      ""
                                                  ? NetworkImage(
                                                      message_list_final[
                                                              position]
                                                          .Sender_image)
                                                  : AssetImage(
                                                      'images/placeholder_face.png'),
                                            ),
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5))),
                                        margin: EdgeInsets.only(
                                            left: 10,
                                            top: 5,
                                            bottom: 5,
                                            right: 10.0),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                            padding: EdgeInsets.only(
                                                left: 5.0, top: 5.0),
                                            child: Text(
                                              message_list_final[position]
                                                  .Sender_name,
                                              style: TextStyle(
                                                  fontSize: 17.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                              maxLines: 1,
                                            )),
                                        Padding(
                                            padding: EdgeInsets.only(
                                                left: 5.0, top: 5.0),
                                            child: Text(
                                              message_list_final[position]
                                                  .Country,
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black),
                                              maxLines: 1,
                                            ))

                                        /* Container(
                                            margin: EdgeInsets.only(top: 20.0, left: 5.0),
                                            alignment: Alignment.topLeft,
                                            child:
                                        ),
*/
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                        right: 5.0, bottom: 5.0),
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      message_list_final[position]
                                              .Date
                                              .month
                                              .toString() +
                                          "/" +
                                          message_list_final[position]
                                              .Date
                                              .day
                                              .toString() +
                                          "/" +
                                          message_list_final[position]
                                              .Date
                                              .year
                                              .toString(),
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black),
                                      maxLines: 1,
                                    ),
                                  ),
                                ]),
                          ),
                        ])),
                    onTap: () async {
                      if (message_list_final[position].Sender_id == Sender_id) {
                        SharedPreferences sharedPreferences =
                            await SharedPreferences.getInstance();
                        sharedPreferences.setString(
                            'user_id1', message_list_final[position].Sender_id);
                        sharedPreferences.setString('seller_id1',
                            message_list_final[position].Receiver_id);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Messages_Screnn(
                                    message_list_final[position].Sender_name)));
                      } else {
                        SharedPreferences sharedPreferences =
                            await SharedPreferences.getInstance();
                        sharedPreferences.setString('seller_id1',
                            message_list_final[position].Sender_id);
                        sharedPreferences.setString('user_id1',
                            message_list_final[position].Receiver_id);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Messages_Screnn(
                                    message_list_final[position].Sender_name)));
                      }
                    },
                  );
                }),
        inAsyncCall: _isInAsyncCall,
        opacity: 1,
        color: Colors.white,
        progressIndicator: CircularProgressIndicator(),
      ),
    );
  }
}
