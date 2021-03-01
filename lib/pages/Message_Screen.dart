import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Message.dart';
import 'package:threadon/model/Message_List.dart';
// import 'package:speech_bubble/speech_bubble.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class Messages_Screnn extends StatefulWidget {
  String Receiver_id = '';
  String Sender_id = '';
  String name = '';

  Messages_Screnn(this.name);

  @override
  State<StatefulWidget> createState() => messages_screnn(name);
}

class messages_screnn extends State<Messages_Screnn> {
  String name = '';

  messages_screnn(this.name);

  final TextEditingController _chatController = new TextEditingController();
  bool _isComposingMessage = false;
  final reference = FirebaseDatabase.instance.reference().child('messages');
  List<MessageModel> message_list = [];
  final postUrl = 'https://fcm.googleapis.com/fcm/send';

  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  String attechment = '';
  String Ddate = '';
  String Receiver_id = '';
  String Sender_id = '';
  int Message_type = 0;
  String profileImage1 = '';
  String Name = '';
  String token = '';

  SharedPreferences sharedPreferences;
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  getCredential() async {
    sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      Receiver_id = sharedPreferences.getString('seller_id1');
      //token = sharedPreferences.getString('token_id');
      profileImage1 = sharedPreferences.getString('profile_image');
      Name = sharedPreferences.getString('UserName');
      var now = new DateTime.now();
      var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss a');
      Ddate = formatter.format(now);
      Ddate = formatter.format(now);
      Sender_id = sharedPreferences.getString('user_id1');
    });

    CollectionReference ref = Firestore.instance.collection('users');
    QuerySnapshot eventsQuery =
        await ref.where("user_id", isEqualTo: Receiver_id).getDocuments();

    if (eventsQuery.documents.isEmpty) {
    } else {
      eventsQuery.documents.forEach((doc) async {
        token = doc['token_id'];

        setState(() {
          //   this.message_list_final = message_list;
        });
      });
      // getReceiver();
    }
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    getCredential();

    noteSub?.cancel();
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

  Widget _buildTextComposer() {
    return new IconTheme(
        data: new IconThemeData(
          color: _isComposingMessage
              ? Theme.of(context).accentColor
              : Theme.of(context).disabledColor,
        ),
        child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: new Row(
            children: <Widget>[
              new Flexible(
                child: new TextField(
                  controller: _chatController,
                  onChanged: (String messageText) {
                    setState(() {
                      _isComposingMessage = messageText.length > 0;
                    });
                  },
                  onSubmitted: _handleSubmit,
                  decoration:
                      new InputDecoration.collapsed(hintText: "Send a message"),
                ),
              ),
              new Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? getIOSSendButton()
                    : getDefaultSendButton(),
              ),
            ],
          ),
        ));
  }

  CupertinoButton getIOSSendButton() {
    return new CupertinoButton(
      child: new Text("Send"),
      onPressed: _isComposingMessage
          ? () => _handleSubmit(_chatController.text)
          : null,
    );
  }

  IconButton getDefaultSendButton() {
    return new IconButton(
      icon: new Icon(Icons.send),
      onPressed: _isComposingMessage
          ? () => _handleSubmit(_chatController.text)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(name),
      ),
      body: new Column(
        children: <Widget>[
          new Flexible(
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection("messages")
                  .orderBy("message_date", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Container();
                return ListView.builder(
                  padding: new EdgeInsets.all(8.0),
                  reverse: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = snapshot.data.documents[index];

                    bool isOwnMessage = false;
                    if (document['sender_id'] == Sender_id &&
                        document['receiver_id'] == Receiver_id) {
                      isOwnMessage = true;

                      return getSentMessageLayout(
                          document['sender_name'],
                          document['sender_image'],
                          document['attachment'],
                          document['message'],
                          document['sender_id'],
                          document['receiver_id']);
                    } else if (document['receiver_id'] == Sender_id &&
                        document['sender_id'] == Receiver_id) {
                      return getReceivedMessageLayout(
                          document['sender_name'],
                          document['sender_image'],
                          document['attachment'],
                          document['message'],
                          document['sender_id'],
                          document['receiver_id']);
                    }

                    return Container();
                  },
                  itemCount: snapshot.data.documents.length,
                );
              },
            ),
          ),
          new Divider(
            height: 1.0,
          ),
          new Container(
            decoration: new BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: _buildTextComposer(),
          )
        ],
      ),
    );
  }

  Future getData() async {
    CollectionReference ref = Firestore.instance.collection('chat_log_list');
    QuerySnapshot eventsQuery = await ref
        .where("sender_id", isEqualTo: Sender_id)
        .where("receiver_id", isEqualTo: Receiver_id)
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      QuerySnapshot eventsQuery = await ref
          .where("receiver_id", isEqualTo: Sender_id)
          .where("sender_id", isEqualTo: Receiver_id)
          .getDocuments();

      if (eventsQuery.documents.isEmpty) {
        db
            .and_Messagelist('', DateTime.now(), Receiver_id, Sender_id)
            .then((_) {});
      } else {
        eventsQuery.documents.forEach((doc) async {
          db
              .updateMessagelist(MessageListModel(
                  doc['chat_id'], DateTime.now(), Receiver_id, Sender_id))
              .then((_) async {
            // showInSnackBar('Profile data update successfully');
          });
        });
      }

      /*   db.and_Messagelist('',DateTime.now(), Receiver_id, Sender_id)
          .then((_) {



      });*/
    } else {
      eventsQuery.documents.forEach((doc) async {
        db
            .updateMessagelist(MessageListModel(
                doc['chat_id'], DateTime.now(), Receiver_id, Sender_id))
            .then((_) async {
          // showInSnackBar('Profile data update successfully');
        });
      });
    }
  }

  _handleSubmit(String message) {
    getData();
    _chatController.text = "";
    var db = Firestore.instance;
    db.collection("messages").add({
      "sender_name": Name,
      "sender_image": profileImage1,
      "attachment": attechment,
      "date": DateTime.now(),
      "message": message,
      'message_date': DateTime.now(),
      'message_type': 0,
      'receiver_id': Receiver_id,
      'sender_id': Sender_id,
    }).then((val) {
      makeCall();
      print("sucess");
    }).catchError((err) {
      print(err);
    });
  }

  Future<bool> makeCall() async {
    final data = {
      "notification": {"body": Name + " message you", "title": "Message"},
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "sound": "default",
        "id": "1",
        "status": "done",
        "nt": "3",
      },
      "to": token
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAAqfgKAe8:APA91bEEwkEhKzOBxsxQMjxF6HJ1g5U7lY7x363dqrSQqfv9CxRV8wxA-m4U9xD77Og423_seN-gyhFtB0uc4Ilw10bwcPv9HzrMlZVh8tb-tbL4QCYOx0Ad5WPawh0BBNbOfLIYGwjL'
    };

    final response = await http.post(postUrl,
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      // on success do sth
      return true;
    } else {
      // on failure do sth
      return false;
    }
  }

  Widget getSentMessageLayout(String sender_name, String sender_image,
      String attechment, String message, String sender_id, String receiver_id) {
    //if(Sender_id == sender_id){

    // if(Receiver_id == sender_id){
    return Padding(
        padding: EdgeInsets.only(left: 30.0, right: 10.0),
        child: Container(
            child: Row(
          children: <Widget>[
            new Expanded(
                child: Container(
              padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8.0)),
              margin: EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  new Text(sender_name,
                      style: new TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                  new Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: attechment != ""
                        ? new Image.network(
                            attechment,
                            width: 250.0,
                          )
                        : new Text(message),
                  ),
                ],
              ),
            )),
            new Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                new Container(
                    margin: const EdgeInsets.only(left: 8.0),
                    child: sender_image == ""
                        ? new CircleAvatar(
                            backgroundImage: new NetworkImage(sender_image),
                          )
                        : new CircleAvatar(
                            backgroundImage:
                                new AssetImage('images/placeholder_face.png'),
                          )),
              ],
            ),
          ],
        )));
    //  }else{
    //     return Container();
    //  }

    // }
    // else{
    //    return Container();
    //  }
  }

  Widget getReceivedMessageLayout(String sender_name, String sender_image,
      String attechment, String message, String sender_id, String receiver_id) {
    // if(Receiver_id == receiver_id) {
    //  if(Sender_id == receiver_id){

    return Padding(
        padding: EdgeInsets.only(right: 30.0, left: 10.0),
        child: Container(
            margin: EdgeInsets.only(top: 5.0),
            child: Row(
              children: <Widget>[
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Container(
                        margin: const EdgeInsets.only(right: 8.0),
                        child: new CircleAvatar(
                          backgroundImage: new NetworkImage(sender_image),
                        )),
                  ],
                ),
                new Expanded(
                    child: Container(
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(sender_name,
                          style: new TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      new Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: attechment != ""
                            ? new Image.network(
                                attechment,
                                width: 250.0,
                              )
                            : new Text(message),
                      ),
                    ],
                  ),
                )),
              ],
            )));
    //     }else{
    //     return Container();
    // }
    //  }
    //  else{
    //    return Container();
    //  }
  }

  Widget _ownMessage(String message, String userName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            Text(userName),
            Text(message),
          ],
        ),
        Icon(Icons.person),
      ],
    );
  }

  Widget _message(String message, String userName) {
    return Row(
      children: <Widget>[
        Icon(Icons.person),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            Text(userName),
            Text(message),
          ],
        )
      ],
    );
  }
}
