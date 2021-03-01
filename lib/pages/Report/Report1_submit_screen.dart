import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Cart.dart';
import 'package:threadon/pages/Cart_screen.dart';
import 'package:threadon/pages/main_screen.dart';
import 'package:threadon/pages/signup_screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/SharedPreferencesHelper.dart';
import 'package:threadon/utils/my_navigator.dart';

class Report1_Submitscreen extends StatefulWidget {
  String title;

  Report1_Submitscreen({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new report1_submit(title);
// TODO: implement createState

}

class report1_submit extends State<Report1_Submitscreen> {
  String title;
  String user_id = '', product_id = '';
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  report1_submit(this.title);
  final myController = TextEditingController();

  bool checkBoxValue = false,
      checkBoxValue1 = false,
      checkBoxValue2 = false,
      checkBoxValue3 = false,
      checkBoxValue4 = false,
  checkBoxValue5 = false;
  String Carttotal = "0";

  String value = '', value1 = '', value2 = '', value3 = '', value4 = '', value5 = '';

  bool _isInAsyncCall = false;
  List<Cart> cartList;
  List<Cart> cartList1 = new List<Cart>();

  getCredential() async {
    product_id = await SharedPreferencesHelper.getproduct_id();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      user_id= sharedPreferences.getString("user_id");
      if(user_id == null){
        user_id ="";
      }
    });
  }

  void handleSubmit()async{
    String submit_value = value+','+value1+','+value2+','+value3+','+value4+','+value5+','+myController.text;


    if(submit_value == "" || submit_value == null || submit_value == ",,,,,"){

      _showDialog('Report value null');

    }
    else{
      setState(() {
        _isInAsyncCall = true;
      });
      noteSub?.cancel();
      db.createReport('', user_id, product_id, '0', DateTime.now(), submit_value, '', '').then((_) {
        _isInAsyncCall = false;

        Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(
                builder: (BuildContext context) => new MyHome()),
                (Route<dynamic> route) => false);

      });


    }

  }


  void _showDialog(String msg) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Warning"),
          content: new Text(msg),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    getCredential();

    cartList = new List();
    noteSub?.cancel();
    noteSub = db.getCartList().listen((QuerySnapshot snapshot) {
      final List<Cart> notes = snapshot.documents
          .map((documentSnapshot) => Cart.fromMap(documentSnapshot.data))
          .toList();
      setState(() {
        for(int i=0;i<notes.length;i++){
          if(user_id == notes[i].user_id){
            cartList1.add(Cart(notes[i].cart_id, notes[i].product_id, notes[i].status, notes[i].user_id, notes[i].date));
          }
        }
        this.cartList = cartList1;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    noteSub?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white70,
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.search),
            tooltip: 'Action Tool Tip',
            onPressed: () {
              print("onPressed");
            },
          ),
          new Stack(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () {
                      if (user_id == "") {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignupPage()));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CartScreen()));
                      }
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream:Firestore.instance
                        .collection("cart")
                        .where("user_id", isEqualTo: user_id)
                        .snapshots(),
                    builder: (context, snapshot) {

                      if (!snapshot.hasData)return Container();
                      Carttotal = snapshot.data.documents.length.toString();

                      if (Carttotal == "0") {
                        return Container();
                      } else {
                        return Container(
                          height: 30,
                          width: 60,
                          padding: EdgeInsets.only(right: 10),
                          alignment: Alignment.topRight,
                          child: Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(2),
                            child: Text(
                              Carttotal,
                              style: TextStyle(color: Colors.white),
                            ),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                          ),
                        );
                      }

                    },
                  )
                ],
              )
            ],
          ),
          new IconButton(
            icon: new Icon(Icons.perm_identity),
            tooltip: 'Action Tool Tip',
            onPressed: () => MyNavigator.goToProfile(context),
          ),
        ],
      ),
      body: ModalProgressHUD(
        child: ListView(
          children: <Widget>[
            new Card(
              elevation: 4.0,
              child: new Column(
                children: <Widget>[
                  Container(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Checkbox(
                            activeColor: Colors.black,
                            value: checkBoxValue,
                            onChanged: (bool newValue) {
                              setState(() {
                                checkBoxValue = newValue;
                                if(newValue == true){
                                  value = 'Blurry';
                                } else {
                                  value = '';
                                }
                                print(checkBoxValue);
                              });
                            }),
                        new Text('Blurry'),
                      ],
                    ),
                  ),

                  Container(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Checkbox(
                            activeColor: Colors.black,
                            value: checkBoxValue1,
                            onChanged: (bool newValue) {
                              setState(() {
                                checkBoxValue1 = newValue;
                                if(newValue == true){
                                  value1 = 'Poor lighting';
                                } else {
                                  value1 = '';
                                }
                                print(checkBoxValue1);
                              });
                            }),
                        new Text('Poor lighting'),
                      ],
                    ),
                  ),

                  Container(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Checkbox(
                            activeColor: Colors.black,
                            value: checkBoxValue2,
                            onChanged: (bool newValue) {
                              setState(() {
                                checkBoxValue2 = newValue;
                                if(newValue == true){
                                  value2 = 'Item not in frame';
                                } else {
                                  value2 = '';
                                }
                                print(checkBoxValue2);
                              });
                            }),
                        new Text('Item not in frame'),
                      ],
                    ),
                  ),
                  Container(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Checkbox(
                            activeColor: Colors.black,
                            value: checkBoxValue3,
                            onChanged: (bool newValue) {
                              setState(() {
                                checkBoxValue3 = newValue;
                                if(newValue == true){
                                  value3 = 'Copyright infringement';
                                } else {
                                  value3 = '';
                                }
                                print(checkBoxValue3);
                              });
                            }),
                        new Text('Copyright infringement'),
                      ],
                    ),
                  ),
                  Container(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Checkbox(
                            activeColor: Colors.black,
                            value: checkBoxValue4,
                            onChanged: (bool newValue) {
                              setState(() {
                                checkBoxValue4 = newValue;
                                if(newValue == true){
                                  value4 = 'Inappropriate image';
                                } else {
                                  value4 = '';
                                }
                                print(checkBoxValue4);
                              });
                            }),
                        new Text('Inappropriate image'),
                      ],
                    ),
                  ),

                  Container(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Checkbox(
                            activeColor: Colors.black,
                            value: checkBoxValue5,
                            onChanged: (bool newValue) {
                              setState(() {
                                checkBoxValue5 = newValue;
                                if(newValue == true){
                                  value5 = 'Poorly cleaned image';
                                } else {
                                  value5 = '';
                                }
                                print(checkBoxValue5);
                              });
                            }),
                        new Text('Poorly cleaned image'),
                      ],
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(
                        left: 10.0, top: 10.0, bottom: 0.0),
                    alignment: Alignment.centerLeft,
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Other",
                          style: new TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(
                        left: 10.0, top: 0.0, bottom: 0.0),
                    child: TextFormField(
                      controller: myController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white,style: BorderStyle.solid),
                        ),
                        focusedBorder:  UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white,style: BorderStyle.solid),
                        ),
                        hintText: 'Other ',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                ],
              ),
            ),

            new Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 50.0),
              alignment: Alignment.center,
              decoration: new BoxDecoration(color: Colors.black),
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    child: new OutlineButton(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(2.0)),
                      borderSide: BorderSide(color: Colors.black),
                      color: Colors.black,
                      splashColor: Colors.grey,
                      highlightedBorderColor: Colors.black,
                      onPressed: () => handleSubmit(),
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
                                "Submit",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0),
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
          ],
        ),
        inAsyncCall: _isInAsyncCall,
        opacity: 0.5,
        color: Colors.black,
        progressIndicator: CircularProgressIndicator(),
      ),
    );
  }
}
