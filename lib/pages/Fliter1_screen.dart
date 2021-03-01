import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Sub_Category.dart';
import 'package:threadon/pages/Brand_Search_Screen.dart';
import 'package:threadon/pages/Seller_User_Profile_Screen_1.dart';
import 'package:threadon/pages/departments_screen.dart';
import 'package:threadon/utils/SharedPreferencesHelper.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'package:flutter/services.dart';

class Filter1_Screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new filter1();
// TODO: implement createState

}

class filter1 extends State<Filter1_Screen> {
  List<String> _selecteCategorys = List();
  List<String> brand_list = new List();
  List<String> condition_list = new List();
  List<Sub_CategoryModel> categoryList;
  List<Sub_CategoryModel> sub_categoryList1 = new List<Sub_CategoryModel>();
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  String Cat_id = '';
  int _radioValue = 0;
  bool checkBoxValue = false;
  bool checkBoxValue1 = false;
  bool checkBoxValue2 = false;
  String Cat_name = '';
  String Sub_cat_name = '';
  double _result = 0.0;

  bool signs_press_yes = false;
  bool signs_press_no = false;
  bool signs_press_no1 = false;
  bool signs_press_no2 = false;
  bool signs_press_no3 = false;
  bool signs_press_no4 = false;
  String signs_press_text = 'Under \$25';
  String signs_press_text1 = '\$25 - \$50';
  String signs_press_text2 = '\$50 - \$100';
  String signs_press_text3 = '\$100 - \$200';
  String signs_press_text4 = '\$200 and up';
  String filter_price = "";
  String condition1 = "", condition2 = "", condition3 = "";
  SharedPreferences sharedPreferences;
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue = value;

      switch (_radioValue) {
        case 0:
//          _result = _currencyCalculate(_currencyController.text, EURO_MUL);

          break;
        case 1:
//          _result = _currencyCalculate(_currencyController.text, POUND_MUL);

          break;
        case 2:
//          _result = _currencyCalculate(_currencyController.text, YEN_MUL);

          break;
      }
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
    categoryList = new List();

    noteSub?.cancel();
    noteSub = db.getSubCategoryList().listen((QuerySnapshot snapshot) {
      final List<Sub_CategoryModel> notes = snapshot.documents
          .map((documentSnapshot) =>
          Sub_CategoryModel.fromMap(documentSnapshot.data))
          .toList();         
      setState(() {
        for (int i = 0; i < notes.length; i++) {
          if (Cat_id == notes[i].Category_id) {
            sub_categoryList1.add(Sub_CategoryModel(
                notes[i].Category_id, notes[i].Is_sub_category,notes[i].Is_sub_category_id,notes[i].polybag.toList(),
                notes[i].premium_box.toList(),notes[i].Sub_category_id, notes[i].Sub_category_image,notes[i].Sub_category_name
            ));
          }
        }       
        this.categoryList = sub_categoryList1;
      
      });
    });
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
  void dispose() {
    noteSub?.cancel();
    super.dispose();
  }

  getCredential() async {
    sharedPreferences = await SharedPreferences.getInstance();
    Cat_name = await SharedPreferencesHelper.getcat_name();
    Cat_id = await SharedPreferencesHelper.getcat_id();
    Sub_cat_name = await SharedPreferencesHelper.getsub_cat_name();
     
    if(sharedPreferences.getStringList('brand_list') != null ){
        setState(() {
          // print("Click");
          // print(brand_list);      
        brand_list = sharedPreferences.getStringList('brand_list').toList();
      }); 
    } 
  }
    
  

  void _onCategorySelected(bool selected, category_id) {
    if (selected == true) {
      setState(() {
        _selecteCategorys.add(category_id);
      });
    } else {
      setState(() {
        _selecteCategorys.remove(category_id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.white70,
        title: Text('Filter'),
        leading: 
        // GestureDetector(
          // child:
           IconButton(
            icon : Icon(
            Icons.close),
            color: Colors.black,
            onPressed: (){
               Navigator.of(context).pushReplacement(
                new MaterialPageRoute(
                    builder: (BuildContext context) =>
                        DepartmentsScreen()));
            },
          ),
          // onTap: () {
//            if (Navigator.canPop(context)) {
//              Navigator.pop(context);
//
//            } else {
////              SystemNavigator.pop();
//            }

            // Navigator.of(context).pushReplacement(
            //     new MaterialPageRoute(
            //         builder: (BuildContext context) =>
            //             DepartmentsScreen()));
          // },
        // ),
      ),
      body: new ListView(
        children: <Widget>[
          new Card(
              margin: const EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
              elevation: 2.0,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.all(18.0),
                      child:brand_list.length ==0? new Text(
                        "Designer" ,
//                        "Designer",
                        style: new TextStyle(
                            color: Colors.black,
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold),
                      ):new Text(
                        "Designer (" +brand_list.length.toString() +")" ,
//                        "Designer",
                        style: new TextStyle(
                            color: Colors.black,
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    onTap: () {
//                      MyNavigator.gotoBrand_Screen(context);
                      Navigator.of(context).pushReplacement(
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  Brand_SearchList()));
                    },
                  ),
                  new GestureDetector(
                    child: Container(
                      child: IconButton(
                        icon : Icon(Icons.keyboard_arrow_right),
                        color: Colors.black,
                        onPressed: (){
                              MyNavigator.gotoBrand_Screen(context);
                        },
                      ),
                    ),
                    onTap: () {
                      MyNavigator.gotoBrand_Screen(context);
                    },
                  ),
                ],
//                title: new Text(
//                  "Designer",
//                  style: new TextStyle(
//                      color: Colors.black,
//                      fontSize: 17.0,
//                      fontWeight: FontWeight.bold),
//                ),
//                onTap: () {
//                  MyNavigator.gotoBrand_Screen(context);
//                },
              )),

//          new Card(
//            margin: const EdgeInsets.only(
//                left: 10.0, right: 10.0, top: 0.0, bottom: 10.0),
//            elevation: 2.0,
//            child: new Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: <Widget>[
//                Container(
//                  padding: const EdgeInsets.all(18.0),
//                  child: new Text(
//                    "Department - " + Cat_name,
//                    style: new TextStyle(
//                        color: const Color(0xFF2D2D2D),
//                        fontSize: 16.0,
//                        letterSpacing: 0.3,
//                        fontWeight: FontWeight.bold),
//                  ),
//                ),
//                Container(
//                  height: 200,
//                  child: ListView.builder(
//                      itemCount: categoryList.length,
//                      itemBuilder: (context, position) {
//                        return CheckboxListTile(
//                          value: _selecteCategorys
//                              .contains(categoryList[position].Sub_category_id),
//                          onChanged: (bool selected) {
//                            _onCategorySelected(selected,
//                                categoryList[position].Sub_category_id);
//                          },
//                          title: Text(categoryList[position].Sub_category_name),
//                        );
////
//                      }),
//                ),
//              ],
//            ),
//          ),

          new Card(
            margin: const EdgeInsets.only(
                left: 10.0, right: 10.0, top: 0.0, bottom: 10.0),
            elevation: 2.0,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(18.0),
                  child: new Text(
                    "Price",
                    style: new TextStyle(
                        color: const Color(0xFF2D2D2D),
                        fontSize: 14.0,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  child: new Row(
                    children: <Widget>[
                      new Container(
                        margin: EdgeInsets.only(left: 5.0, right: 20.0),
                        child: new RaisedButton(
                            padding: const EdgeInsets.all(8.0),
                            child: new Text(
                              signs_press_no ? 'Under \$25' : signs_press_text,
                              textAlign: TextAlign.center,
                            ),
                            textColor:
                            signs_press_no ? Colors.white : Colors.black,
                            color: signs_press_no ? Colors.black : Colors.white,
                            shape: new RoundedRectangleBorder(
                                side: BorderSide(color: Colors.black)),
                            onPressed: () async {
                              if (signs_press_no == false) {
                                setState(() {
                                  signs_press_no1 = false;
                                  signs_press_no2 = false;
                                  signs_press_no3 = false;
                                  signs_press_no4 = false;
                                  filter_price = signs_press_text;
//                                  _isInAsyncCall = true;
                                });
                                setState(
                                        () => signs_press_no = !signs_press_no);
                                // _showSnackBar();
                              } else {
                                filter_price = "";

                                setState(() => signs_press_no = !signs_press_no);
                                filter_price = "";
                                setState(
                                        () => signs_press_no = !signs_press_no);
                              }
                            }),
                      ),
                      new Container(
                        margin: EdgeInsets.only(left: 0.0, right: 20.0),
                        child: new RaisedButton(
                            padding: const EdgeInsets.all(8.0),
                            child: new Text(
                              signs_press_no1
                                  ? '\$25 - \$50'
                                  : signs_press_text1,
                              textAlign: TextAlign.center,
                            ),
                            textColor:
                            signs_press_no1 ? Colors.white : Colors.black,
                            color:
                            signs_press_no1 ? Colors.black : Colors.white,
                            shape: new RoundedRectangleBorder(
                                side: BorderSide(color: Colors.black)),
                            onPressed: () async {
                              if (signs_press_no1 == false) {
                                setState(() {
                                  signs_press_no = false;
                                  signs_press_no2 = false;
                                  signs_press_no3 = false;
                                  signs_press_no4 = false;
                                  filter_price = signs_press_text1;

//                                  _isInAsyncCall = true;
                                });
                                setState(
                                        () => signs_press_no1 = !signs_press_no1);
                                // _showSnackBar();
                              } else {

                                filter_price = "";

                                setState(() => signs_press_no1 = !signs_press_no1);
                                filter_price = "";
                                setState(
                                        () => signs_press_no1 = !signs_press_no1);
                              }
                            }),
                      ),
                      new Container(
                        margin: EdgeInsets.only(left: 0.0, right: 20.0),
                        child: new RaisedButton(
                            padding: const EdgeInsets.all(8.0),
                            child: new Text(
                              signs_press_no2
                                  ? '\$50 - \$100'
                                  : signs_press_text2,
                              textAlign: TextAlign.center,
                            ),
                            textColor:
                            signs_press_no2 ? Colors.white : Colors.black,
                            color:
                            signs_press_no2 ? Colors.black : Colors.white,
                            shape: new RoundedRectangleBorder(
                                side: BorderSide(color: Colors.black)),
                            onPressed: () async {
                              if (signs_press_no2 == false) {
                                setState(() {

                                  signs_press_no = false;
                                  signs_press_no1 = false;
                                  signs_press_no3 = false;
                                  signs_press_no4 = false;
                                  filter_price = signs_press_text2;

//                                  _isInAsyncCall = true;
                                });
                                setState(
                                        () => signs_press_no2 = !signs_press_no2);
                                // _showSnackBar();
                              } else {
                                filter_price = "";

                                setState(() => signs_press_no2 = !signs_press_no2);
                                setState(
                                        () => signs_press_no2 = !signs_press_no2);
                              }
                            }),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: new Row(
                    children: <Widget>[
                      new Container(
                        margin: EdgeInsets.only(
                            left: 5.0, right: 20.0, bottom: 5.0),
                        child: new RaisedButton(
                            padding: const EdgeInsets.all(8.0),
                            child: new Text(
                              signs_press_no3
                                  ? '\$100 - \$200'
                                  : signs_press_text3,
                              textAlign: TextAlign.center,
                            ),
                            textColor:
                            signs_press_no3 ? Colors.white : Colors.black,
                            color:
                            signs_press_no3 ? Colors.black : Colors.white,
                            shape: new RoundedRectangleBorder(
                                side: BorderSide(color: Colors.black)),
                            onPressed: () async {
                              if (signs_press_no3 == false) {
                                setState(() {
                                  signs_press_no = false;
                                  signs_press_no1 = false;
                                  signs_press_no2 = false;
                                  signs_press_no4 = false;
                                  filter_price = signs_press_text3;

//                                  _isInAsyncCall = true;
                                });
                                setState(
                                        () => signs_press_no3 = !signs_press_no3);
                                // _showSnackBar();
                              } else {
                                filter_price = "";

                                setState(() => signs_press_no3 = !signs_press_no3);
                                setState(
                                        () => signs_press_no3 = !signs_press_no3);
                              }
                            }),
                      ),
                      new Container(
                        margin: EdgeInsets.only(
                            left: 0.0, right: 20.0, bottom: 5.0),
                        child: new RaisedButton(
                            padding: const EdgeInsets.all(8.0),
                            child: new Text(
                              signs_press_no4
                                  ? '\$200 and up'
                                  : signs_press_text4,
                              textAlign: TextAlign.center,
                            ),
                            textColor:
                            signs_press_no4 ? Colors.white : Colors.black,
                            color:
                            signs_press_no4 ? Colors.black : Colors.white,
                            shape: new RoundedRectangleBorder(
                                side: BorderSide(color: Colors.black)),
                            onPressed: () async {
                              if (signs_press_no4 == false) {
                                setState(() {
                                  signs_press_no = false;
                                  signs_press_no1 = false;
                                  signs_press_no2 = false;
                                  signs_press_no3 = false;
                                  filter_price = signs_press_text4;

//                                  _isInAsyncCall = true;
                                });
                                setState(
                                        () => signs_press_no4 = !signs_press_no4);
                                // _showSnackBar();
                              } else {
                                filter_price = "";

                                setState(() => signs_press_no4 = !signs_press_no4);
                                setState(
                                        () => signs_press_no4 = !signs_press_no4);
                              }
                            }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

//          new Card(
//            margin: const EdgeInsets.only(
//                left: 10.0, right: 10.0, top: 0.0, bottom: 10.0),
//            elevation: 2.0,
//            child: new Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: <Widget>[
//                Container(
//                  padding: const EdgeInsets.all(18.0),
//                  child: new Text(
//                    "Discount",
//                    style: new TextStyle(
//                        color: const Color(0xFF2D2D2D),
//                        fontSize: 14.0,
//                        letterSpacing: 0.3,
//                        fontWeight: FontWeight.bold),
//                  ),
//                ),
//
//                Container(
//                  child:  new Row(
//                    mainAxisAlignment: MainAxisAlignment.start,
//                    children: <Widget>[
//                      new Radio(
//                        value: 0,
//                        groupValue: _radioValue,
//                        onChanged: _handleRadioValueChange,
//                      ),
//                      new Text('30% off or more'),
//                    ],
//                  ),
//                ),
//
//                Container(
//                  child:  new Row(
//                    mainAxisAlignment: MainAxisAlignment.start,
//                    children: <Widget>[
//                      new Radio(
//                        value: 0,
//                        groupValue: _radioValue,
//                        onChanged: _handleRadioValueChange,
//                      ),
//                      new Text('50% off or more'),
//                    ],
//                  ),
//                ),
//              ],
//            ),
//          ),

          new Card(
            margin: const EdgeInsets.only(
                left: 10.0, right: 10.0, top: 0.0, bottom: 10.0),
            elevation: 2.0,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(18.0),
                  child: new Text(
                    "Condition",
                    style: new TextStyle(
                        color: const Color(0xFF2D2D2D),
                        fontSize: 14.0,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new Checkbox(
                          activeColor: Colors.black,
                          value: checkBoxValue,
                          onChanged: (bool newValue) {
                            setState(() {
                              if(newValue == true){
//                                checkBoxValue1 = false;
                                condition1 = "";
                                checkBoxValue = newValue;
                                print(checkBoxValue);
                                condition1 = "Retail Tags";
                                condition_list.add("Retail Tags");
                              } else{
                                checkBoxValue = newValue;
                                print(checkBoxValue);
                                condition1 = "";
                                condition_list.remove("Retail Tags");
                              }

                            });
                          }),
                      new Text('Retail Tags'),
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
                              if(newValue == true){
                                condition2 = "";
                                checkBoxValue1 = newValue;
                                print(checkBoxValue1);
                                condition2 = "Like New";
                                condition_list.add("Like New");
                              }
                              else{
                                checkBoxValue1 = newValue;
                                print(checkBoxValue1);
                                condition2 = "";
                                condition_list.remove("Like New");
                              }
                              
                            });
                          }),
                      new Text('Like New'),
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
                              if(newValue == true){
//                                checkBoxValue = false;
                                condition3 = "";
                                checkBoxValue2 = newValue;
                                print(checkBoxValue2);
                                condition3 = "Any sign wear";
                                condition_list.add("Any sign wear");
                              }else{
                                checkBoxValue2 = newValue;
                                print(checkBoxValue2);
                                condition3 = "";
                                condition_list.remove("Any sign wear");
                              }
                            });
                          }),
                      new Text('Any sign wear'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.only(left: 0.0, right: 0.0, top: 150),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 200,
                  height: 50,
                  child: new RaisedButton(
                    child: const Text('CLEAR ALL',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16.0,
                        )),
                    color: Colors.white,
                    elevation: 4.0,
                    splashColor: Colors.blueGrey,
                    onPressed: () {
                      brand_list = new List();
                      brand_list.clear();
//                      MyNavigator.gotoFilter1_Screen(context);
                      Navigator.of(context).pushReplacement(
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  Filter1_Screen()));
                      // Perform some action
                    },
                  ),
                ),
                Container(
                  width: 200,
                  height: 50,
                  child: new RaisedButton(
                    child: const Text(
                      'APPLY',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16.0,
                      ),
                    ),
                    color: Colors.white,
                    elevation: 4.0,
                    splashColor: Colors.blueGrey,
                    onPressed: () async {
                      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                      sharedPreferences.setString('filter_price', filter_price);
                      sharedPreferences.setString('condition1', condition1);
                      sharedPreferences.setString('condition2', condition2);
                      sharedPreferences.setString('condition3', condition3);
                      
//                      sharedPreferences.setStringList(
//                          'department_list', _selecteCategorys);
                      sharedPreferences.setStringList("condition_list", condition_list);
                      sharedPreferences.setStringList('brand_list', brand_list);
                      sharedPreferences.setString('type', "1");
                    //  await SharedPreferencesHelper.settype('1');
                      Navigator.of(context).pushReplacement(
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  DepartmentsScreen()));
//                       Perform some action
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}