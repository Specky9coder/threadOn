import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class Transaction_History extends StatefulWidget {
  String av_amount;

  Transaction_History(this.av_amount);

  @override
  State<StatefulWidget> createState() => transaction_history(av_amount);
}

class transaction_history extends State<Transaction_History> {
  String av_amount = '';
  String user_id='';

  transaction_history(this.av_amount);
  SharedPreferences sharedPreferences;



  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  getCredential() async {
   sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      user_id = sharedPreferences.getString('user_id');
    });

    }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    getCredential();
    // tabController = new TabController(length: 2, vsync: this);
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


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
        child: Scaffold(
            appBar: new AppBar(
              backgroundColor: Colors.white70,
              title: new Text('Transaction History'),
              leading: GestureDetector(
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                    padding: EdgeInsets.all(5.0),
                    height: 130,
                    child: Card(
                      elevation: 4.0,
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[

                          new Container(
                            height: 20.0,
                          ),

                          new Text(
                            '\$' + av_amount,
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 35.0,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),

                          new Container(
                            height: 5.0,
                          ),
                          new Text(

                            'Available amount',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.normal),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )),


                Container(
                  padding: EdgeInsets.all(10.0),
                  alignment: Alignment.centerLeft,
                  child:new Text('TRANSACTION',textAlign: TextAlign.start,style: TextStyle(fontSize: 17.0,color: Colors.black54),),
    ),

                new Flexible(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance
                        .collection("payment_transaction")
                        .where('user_id',isEqualTo: user_id )
                        .orderBy('date',descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Container();  /*Center(

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Image.asset('images/tonlogo.png', color: Colors.black54,
                                height: 50.0,
                                width: 50.0,),

                              new Container(height: 10.0,),

                              Text('Transaction history not available ', style: TextStyle(fontSize: 20.0),),

                            ],


                          )
                      );*/
                      return ListView.builder(
                        padding: new EdgeInsets.only(left:5.0,right: 5.0),
                        itemBuilder: (context, index) {
                          DocumentSnapshot document =
                          snapshot.data.documents[index];

                          if (document['status'] == "0") {

                            return WithdrawamountLayout(
                                document['amount'],
                                document['payment_status']
                            );
                          } else if (document['status'] == "1") {
                            return PendingwithdrawamountLayout(
                                document['amount'],
                                document['payment_status']
                            );
                          }

                          return Container();
                        },
                        itemCount: snapshot.data.documents.length,
                      );
                    },
                  ),
                ),

              ],

            ) ));
  }

  Widget WithdrawamountLayout(String amount,String payment_status) {
    // if(Receiver_id == receiver_id) {
    //  if(Sender_id == receiver_id){
    String comment = '';

    if(payment_status == '0'){
      comment = 'Pending';
    }
   else if(payment_status == '1'){
      comment = 'Approved';
    }
    else if(payment_status == '2'){
      comment = 'Request';
    }

    return Container(
      height: 80,
        margin: EdgeInsets.only(top: 5.0),
        child: Card(
          elevation: 2,
            child: Row(
          children: <Widget>[
            Expanded(
                flex: 2,

                    child: Icon(
                    Icons.add_circle_outline,
                    size: 30,
                    color: Colors.green,

                ) ),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  Text('\$'+amount,style: TextStyle(fontSize: 23.0,color: Colors.green),),
                  new Container(height: 2,),
                  Text('Credit '),



                ],
              ),
            ),
            Expanded(flex: 4, child: Padding(padding: EdgeInsets.only(right: 8.0),child:Text(comment,maxLines: 1,style: TextStyle(fontSize: 15),textAlign: TextAlign.right,)),
            )
          ],
        )));
  }

  Widget PendingwithdrawamountLayout(String amount,String payment_status) {

    String comment = '';

    if(payment_status == '0'){
      comment = 'Pending';
    }
    else if(payment_status == '1'){
      comment = 'Approved';
    }
    else if(payment_status == '2'){
      comment = 'Request';
    }

    return Container(
      height: 80,
        margin: EdgeInsets.only(top: 5.0),
        child: Card(
          elevation: 2,
            child: Row(
          children: <Widget>[
            Expanded(
                flex: 2,
                child: Icon(
                  Icons.remove_circle_outline,
                  size: 30,
                  color: Colors.red,
                )),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  
                  Text('\$'+amount,style: TextStyle(fontSize: 23.0,color: Colors.red),),
                  new Container(height: 2,),

                  Text('Withdraw ',style: TextStyle(),),

                ],
              ),
            ),
            Expanded(flex: 4, child: Padding(padding: EdgeInsets.only(right: 8.0),child:Text(comment,maxLines: 1,style: TextStyle(fontSize: 15),textAlign: TextAlign.right,)),
            )],
        )));
  }
}
