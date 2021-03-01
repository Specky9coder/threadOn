import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Wallet.dart';
import 'package:threadon/pages/TransactionHistory_Screen.dart';
import 'package:threadon/pages/splesh_screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'package:flutter/services.dart';


class PayOut_Screen extends StatefulWidget {
  String appbar_name;

  PayOut_Screen({Key key, this.appbar_name}) : super(key: key);

  @override
  State<StatefulWidget> createState() => payout_screen(appbar_name);
}

class payout_screen extends State<PayOut_Screen> {
  String tool_name1;
  AlertDialog dialog;
  payout_screen(this.tool_name1);

  List<Wallet_Model> item_list;
  List<Wallet_Model> final_item_list = new List<Wallet_Model>();
  List<Wallet_Model> Sold_final_item_list = new List<Wallet_Model>();

  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;

  String available_amount="",lifetime_earning="",pending_amount="", site_credit="",user_id1="",wallet_id="";
  DateTime date;

  String Name="",email_id="",profile_image="",facebook_id="",user_id="",about_me="",country="",cover_picture="",password="",username="@",followers ="",following="",device_id="";


  TextEditingController brand_name = new TextEditingController();
  bool _isInAsyncCall = false;

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;




  getCredential() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Name = sharedPreferences.getString('UserName');
    email_id = sharedPreferences.getString('loginname');
    profile_image = sharedPreferences.getString('profile_image');
    country = sharedPreferences.getString('country');
    about_me = sharedPreferences.getString('about_me');
    password = sharedPreferences.getString('password');
    username = sharedPreferences.getString('username');
    user_id = sharedPreferences.getString('user_id');
    following = sharedPreferences.getString('following');
    followers = sharedPreferences.getString('followers');
    device_id = sharedPreferences.getString('device_id');
    cover_picture = sharedPreferences.getString("cover_picture");
    item_list = new List();



    Firestore.instance
        .collection('wallet')
        .where("user_id", isEqualTo: user_id)
        .snapshots()
        .listen((data) {
      data.documents.forEach((doc) async {
        if(doc.exists){
          setState(() {
            //      _isInAsyncCall = false;
            available_amount = doc['available_amount'];
            date = doc['date'];
            lifetime_earning = doc['lifetime_earning'];

            pending_amount = doc['pending_amount'];
            site_credit = doc['site_credit'];
            user_id1 = doc['user_id'];
            wallet_id = doc['wallet_id'];

          });
        }
        else{

          showInSnackBar('No payoutd data found!');

        }


      });

    });


  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCredential();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);


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

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(tool_name1),
        backgroundColor: Colors.white70,
//        automaticallyImplyLeading: false,
      ),
      body:ModalProgressHUD(
    child:Container(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            child: Column(
              children: <Widget>[
                Container(
                  padding:
                  const EdgeInsets.only(top: 20.0, left: 10.0, bottom: 5.0),
                  child: new Row(
                    children: <Widget>[
                      Text(
                        "Manage Payouts",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 2.0,
                  color: Colors.grey,
                ),
                new Container(
                  width: MediaQuery.of(context).size.width,
                  margin:
                  const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                  alignment: Alignment.center,
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        child: new FlatButton(
                          shape: new RoundedRectangleBorder(
                              side: BorderSide(color: Colors.black54)),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>Transaction_History(available_amount))),
                          child: new Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 15.0,
                              horizontal: 15.0,
                            ),
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Expanded(
                                  child: Text(
                                    "View Transaction History",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                new Container(
                  width: MediaQuery.of(context).size.width,
                  margin:
                  const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0,bottom: 20.0),
                  alignment: Alignment.center,
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        child: new FlatButton(
                          shape: new RoundedRectangleBorder(
                              side: BorderSide(color: Colors.black54)),

                          //   onPressed: () => MyNavigator.goToMain(context),
                          child: new Container(
                            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Expanded(
                                    child: Column(children: <Widget>[

                                      Container(
                                        margin: EdgeInsets.only(top: 10.0,bottom: 10.0),
                                        child: Column(
                                          children: <Widget>[
                                            Text(
                                              "LIFETIME EARNING",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.normal),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 5.0),
                                              child: Text(
                                                lifetime_earning == "" ?'\$00.00': '\$'+lifetime_earning,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 5.0),
                                              child: Text(
                                                "See your all earning",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.normal),
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),
                                      Divider(
                                        height: 30.0,
                                        color: Colors.black54,
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 10.0,bottom: 10.0),
                                        child: Column(
                                          children: <Widget>[
                                            Text(
                                              "SITE CREDIT",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.normal),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 5.0),
                                              child: Text(
                                                site_credit == "" ?'\$00.00': '\$'+site_credit,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 5.0),
                                              child: Text(
                                                "Site credit can only be used to buy on ThradOn",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.normal),
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),
                                      Divider(
                                        height: 30.0,
                                        color: Colors.black54,
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 10.0,bottom: 10.0),
                                        child: Column(
                                          children: <Widget>[
                                            Text(
                                              "PENDING EARNINGS",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.normal),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 5.0),
                                              child: Text(
                                                pending_amount == "" ?'\$00.00': '\$'+pending_amount,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 17.0,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 5.0),
                                              child: Text(
                                                "See history below details on fund availability",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.normal),
                                              ),
                                            ),

                                            Container(
                                              margin: EdgeInsets.only(top: 10.0),
                                              child: Text(
                                                "Learn More",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.redAccent,
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.normal),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider(
                                        height: 30.0,
                                        color: Colors.black54,
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 10.0,bottom: 10.0),
                                        child: Column(
                                          children: <Widget>[
                                            Text(
                                              "AVAILABLE",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.normal),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 5.0),
                                              child: Text(
                                                available_amount == "" ?'\$00.00': '\$'+available_amount,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 5.0),
                                              child: Text(
                                                "May be used immediately to Complete a",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.normal),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 5.0),
                                              child: Text(
                                                "purchase on ThreadOn or withdraw",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.normal),
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),


                                      Divider(
                                        height: 30.0,
                                        color: Colors.black54,
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 10.0,bottom: 10.0),
                                        child: Column(
                                          children: <Widget>[
                                            Text(
                                              "TRANSFER FUNDS",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 17.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  top: 20.0, left: 10.0, right: 10.0, bottom: 10.0),
                                              color: Colors.black,
                                              alignment: Alignment.bottomCenter,
                                              child: Card(
                                                elevation: 3.0,
                                                child: Column(
                                                  children: <Widget>[
                                                    GestureDetector(
                                                      child: Container(
                                                          color: Colors.black,
                                                          padding: EdgeInsets.all(10.0),
                                                        child: new Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: <Widget>[
                                                                Text(
                                                                  "Withdraw",
                                                                  style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: 15.0,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                      onTap:() {
                                                        _openAddUserDialog(available_amount);
                                                      } ,
                                                    )

                                                  ],
                                                ),
                                              ),
                                            ),



                                          ],
                                        ),
                                      )


                                    ])),
                              ],
                            ),
                          ), onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
        inAsyncCall: _isInAsyncCall,
        opacity: 0.7,
        color: Colors.white,
        progressIndicator: CircularProgressIndicator(),
      )
    );
  }




  void _openAddUserDialog(String avi) {
    dialog = new AlertDialog(
      content: new Container(

        height: 250.0,
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
        ),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // dialog top
         /*   new Expanded(
              child: new Row(
                children: <Widget>[
                  new Container(

                    // padding: new EdgeInsets.all(10.0),
                    decoration: new BoxDecoration(
                      color: Colors.white,
                    ),
                    child: new Text(
                      'Withdraw',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),*/

            new Column(
              children: <Widget>[

                new Text(
                  'Available amount',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.normal
                  ),
                  textAlign: TextAlign.center,
                ),

                new Container(height: 10.0,),
                new Text(
                  '\$'+avi,
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),


              ],
            ),

            TextFormField(
              controller: brand_name,
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87,style: BorderStyle.solid),
                  ),
                  focusedBorder:  UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87,style: BorderStyle.solid),
                  ),
                  hintText: 'Withdraw amount',
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: Colors.black54)
              ),
              keyboardType: TextInputType.number,
              /* validator: (val) =>
              !val.contains('@') ? 'Not a valid email.' : null,
              onSaved: (val) => _email= val,*/
            ),

            SizedBox(height: 40.0),
            new RaisedButton(
              padding: const EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 10.0,
              ),
              child: const Text('Withdraw request',style: TextStyle(color: Colors.white,fontSize: 15.0),),
              color: Colors.black,
              elevation: 4.0,
              splashColor: Colors.blueGrey,
              onPressed: () {

                if(brand_name.text != null){
                  int avilAmount = int.parse(avi);
                  int withdraw_amount = int.parse(brand_name.text);
                  if(avilAmount >= withdraw_amount){


                    Navigator.of(context).pop();
                    setState(() {
                      _isInAsyncCall = true;
                    });

                    var db = Firestore.instance;
                    db.collection("payment_transaction").add({
                      "amount": brand_name.text,
                      "date": DateTime.now(),
                      "payment_status":"0" ,
                      'status':"1",
                      'user_id':user_id
                    }).then((val) {

                      var docId = val.documentID;
                      var updateId = {"pay_id":docId};

                      db.collection("payment_transaction")
                          .document(docId)
                          .updateData(updateId)
                          .then((val) {

                        _onAlertWithStylePressed(context);

                        print("sucess");
                      }).catchError((err) {
                        print(err);
                        _onAlertWithStyleError(context);
                        setState(() {
                          _isInAsyncCall = false;
                        });
                       // _isInAsyncCall = false;
                      });
                      print("sucess");
                    }).catchError((err) {
                      print(err);
                      _onAlertWithStyleError(context);
                      setState(() {
                        _isInAsyncCall = false;
                      });
                      //_isInAsyncCall = false;
                    });



                                      }
                  else{

                    showInSnackBar("You have only " +"\$"  + avi + " creadits ");

                  }


                }
                else{
                  showInSnackBar('Withdraw amount is required.');
                }
                // Perform some action
              },
            ),

          ],
        ),
      ),
    );

    showDialog(context: context, child: dialog);
  }





  _onAlertWithStylePressed(context) async{






    CollectionReference ref = Firestore.instance.collection('wallet');
    QuerySnapshot eventsQuery =
        await ref
        .where("user_id",isEqualTo: user_id)
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        _isInAsyncCall = false;
      });
      _onAlertWithStyleError(context);

    } else {

      eventsQuery.documents.forEach((doc) async {

        String docId = doc['wallet_id'];
        String available_amount =doc['available_amount'];
        String lifetime_earning =doc['lifetime_earning'];
        String pending_amount =doc['pending_amount'];


        var payamount = int.parse(brand_name.text);

        var value_available = int.tryParse(available_amount);
        value_available = value_available  - payamount;
        var total_available_amount =  value_available.toString();

        var value_lifetime = int.tryParse(pending_amount);
        value_lifetime = value_lifetime + payamount;
        var total_lifetime_amount =  value_lifetime.toString();


        var up1 = {'available_amount': total_available_amount,'pending_amount':total_lifetime_amount };

        var db = Firestore.instance;
        db.collection("wallet")
            .document(docId)
            .updateData(up1)
            .then((val) {
          setState(() {
            _isInAsyncCall = false;
          });
          print("sucess");
        }).catchError((err)
        {
          setState(() {
            _isInAsyncCall = false;
          });
          print(err);
          _onAlertWithStyleError(context);
         // _isInAsyncCall = false;
        });

      });

    }








    // Reusable alert style
    var alertStyle = AlertStyle(
      animationType: AnimationType.fromTop,
      isCloseButton: false,
      isOverlayTapDismiss: false,
      descStyle: TextStyle(fontWeight: FontWeight.bold),
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
        side: BorderSide(
          color: Colors.grey,
        ),
      ),
      titleStyle: TextStyle(
        color: Colors.green,
      ),
    );

    // Alert dialog using custom alert style
    Alert(
      context: context,
      style: alertStyle,
      type: AlertType.success,
      title: "Congratulations!",
      desc: "Your Withdraw request has been successfully placed!",
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () =>    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PayOut_Screen(appbar_name: 'Payouts',))),
          color: Color.fromRGBO(0, 179, 134, 1.0),
          radius: BorderRadius.circular(0.0),
        ),
      ],
    ).show();
  }






  _onAlertWithStyleError(context) {
    // Reusable alert style
    var alertStyle = AlertStyle(
      animationType: AnimationType.fromTop,
      isCloseButton: false,
      isOverlayTapDismiss: false,
      descStyle: TextStyle(fontWeight: FontWeight.bold),
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
        side: BorderSide(
          color: Colors.grey,
        ),
      ),
      titleStyle: TextStyle(
        color: Colors.red,
      ),
    );

    // Alert dialog using custom alert style
    Alert(
      context: context,
      style: alertStyle,
      type: AlertType.error,
      title: "Error!",
      desc: "Could Not Complete Withdraw request",
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () =>   Navigator.of(context).pop(),
          color: Color.fromRGBO(0, 179, 134, 1.0),
          radius: BorderRadius.circular(0.0),
        ),
      ],
    ).show();
  }



}
