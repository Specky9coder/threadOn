import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:threadon/pages/GridItemDetails1.dart';
import 'package:xml/xml.dart' as xml;

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/pages/AddressBook_screen.dart';
import 'package:threadon/pages/Edit_Drafts_Listing_details.dart';

import 'package:threadon/pages/GridItemDetails.dart';
import 'package:threadon/pages/Secure_Checkout_Screen.dart';
import 'package:threadon/pages/Shipping_Address_List_Screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:flutter/services.dart';

class Add_Address_Screen extends StatefulWidget {
  String appbar_name;
  int Flag;
  int exit_Flag;

  Add_Address_Screen({Key key, this.appbar_name, this.Flag, this.exit_Flag})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      add_address_screen(appbar_name, Flag, exit_Flag);
}

class add_address_screen extends State<Add_Address_Screen> {
  String tool_name1;
  int Flag;
  int exit_Flag;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController firstname = new TextEditingController();
  TextEditingController addressline1 = new TextEditingController();
  TextEditingController addressline2 = new TextEditingController();
  TextEditingController city = new TextEditingController();
  TextEditingController zipcode = new TextEditingController();
  TextEditingController phonenumber = new TextEditingController();

  TextEditingController state = new TextEditingController();
  bool _isInAsyncCall = false;
  StreamSubscription<QuerySnapshot> noteSub;

  FirebaseFirestoreService db = new FirebaseFirestoreService();

  String Cat_Name = "",
      Cat_Id = "",
      Sub_Cat_Name = "",
      Sub_Cat_Id = "",
      User_id = "",
      User_country = "",
      Item_Size = "";
  String managphoto = "";
  int cameraFlag = 0;
  String Product_Id = "";
  SharedPreferences sharedPreferences;
  String Item_shipping_id = "",
      Item_titile = "",
      Item_retailPrice = "",
      Item_sellingPrice = "",
      Item_description = "",
      Item_color = "";
  String Item_result = "";
  String Item_brand_name = "", Retail_Tag = "", Signs_Wear = "";
  String signs_press_text = '';
  String tag_press_Text = '';
  String PubishFlag = "0";
  String updateFlag = "0";
  String address_id = '';
  var Zip4 = "", Zip5 = "";

  String _First_name, _Address1, _Address3, _City, _Zipcode, _State;

  String _firstname = "";
  String _addressline1 = "";
  String _addressline2 = "";
  String _city = "";
  String _zipcode = "";
  String _state = "";
  String number = "";

  Shell_Product_Model shellproduct;

  add_address_screen(this.tool_name1, this.Flag, this.exit_Flag);
  String p_id = "";

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  List<String> UplodImageList;
  String add_Id = "";
  List<Shell_Product_Model> productList = new List();

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    if (Flag == 4) {
      updateAddress();
    } else if (Flag == 3) {
      getInitstat();
    } else if (Flag == 1) {
      getInitstat1();
    } else if (Flag == 0) {
      getInitstat1();
    }
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

  getInitstat1() async {
    sharedPreferences = await SharedPreferences.getInstance();
    User_id = await sharedPreferences.getString('user_id');
  }

  getInitstat() async {
    sharedPreferences = await SharedPreferences.getInstance();
    Product_Id = sharedPreferences.getString('pro_id');
    User_id = await sharedPreferences.getString('user_id');

    //_submit();

    /* CollectionReference ref = Firestore.instance.collection('shipping_address');
    QuerySnapshot eventsQuery = await ref
        .where("user_id", isEqualTo: User_id)
        .where('status', isEqualTo: '0')
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        _isInAsyncCall = false;
      });
    } else {
      eventsQuery.documents.forEach((doc) async {
      //
      });

      setState(() {
        _isInAsyncCall = false;
      });
    }*/
  }

  updateAddress() async {
    sharedPreferences = await SharedPreferences.getInstance();
    User_id = await sharedPreferences.getString('user_id');
    address_id = await sharedPreferences.getString('shipping_add_id');

    _isInAsyncCall = true;

    CollectionReference ref = Firestore.instance.collection('shipping_address');
    QuerySnapshot eventsQuery = await ref
        .where("user_id", isEqualTo: User_id)
        .where('shipping_add_id', isEqualTo: address_id)
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        _isInAsyncCall = false;
      });
    } else {
      eventsQuery.documents.forEach((doc) async {
        firstname.text = doc['name'];
        addressline1.text = doc['address_line_1'];
        addressline2.text = doc['address_line_2'];
        city.text = doc['city'];
        zipcode.text = doc['zipcode'];
        state.text = doc['state'];
      });

      setState(() {
        _isInAsyncCall = false;
      });
    }
  }

  Future validAddresCheck() async {
    final FormState form = formKey.currentState;

    number = phonenumber.text;
    String n = phonenumber.text.substring(0, 3) + "-";
    String n1 = phonenumber.text.substring(3, 6) + "-";
    String n3 = phonenumber.text.substring(6, 10);
    number = n + n1 + n3;

    if (form.validate()) {
      setState(() {
        _isInAsyncCall = true;
      });

      if (Flag == 3) {
        var builder = new xml.XmlBuilder();
        //builder.processing('xml', 'version="1.0" encoding="iso-8859-9"');
        builder.element('CarrierPickupAvailabilityRequest', nest: () {
          builder.attribute('USERID', '186LOFTY0774');
          builder.element('FirmName', nest: "");
          builder.element('SuiteOrApt', nest: "");
          builder.element('Address2', nest: addressline1.text);
          builder.element('Urbanization', nest: "");
          builder.element('City', nest: city.text);
          builder.element('State', nest: state.text);

          builder.element('ZIP5', nest: zipcode.text);
          builder.element('ZIP4', nest: "");
        });

        var bookshelfXml = builder.build();

        String _uriMsj = bookshelfXml.toString();

        print("_uriMsj: $_uriMsj");

        String _uri =
            "https://secure.shippingapis.com/ShippingAPI.dll?API=CarrierPickupAvailability&XML=";

        HttpClient client = new HttpClient();

        HttpClientRequest request =
            await client.postUrl(Uri.parse(_uri + _uriMsj));

        // request.write(_message);
        //request.writeln(_message);
        //request.writeAll(_message);

        HttpClientResponse response = await request.close();

        StringBuffer _buffer = new StringBuffer();

        // await for (String a in await response.transform(utf8.decoder)) {
        //   _buffer.write(a);
        // }
        await for (String a in await utf8.decoder.bind(response)) {
          _buffer.write(a);
        }

        bool error = _buffer.toString().contains('Error');
        print("_buffer.toString: ${_buffer.toString()}");

        if (error == false) {
          var responseJson = xml.parse(_buffer.toString());
          var valid = responseJson.findAllElements('Address2');
          Zip4 = responseJson.findAllElements('ZIP5').single.text;
          Zip5 = responseJson.findAllElements('ZIP4').single.text;

          if (valid != null && valid != "") {
            final FormState form = formKey.currentState;

            if (form.validate()) {
              setState(() {
                _isInAsyncCall = true;
              });
              handleSubmit();
            } else {
              showInSnackBar('Please fix the errors in red before submitting.');
            }
          } else {
            _showDialog("Error");
          }
        } else {
          var responseJson = xml.parse(_buffer.toString());
          var valid = responseJson.findAllElements('Description').single.text;
          setState(() {
            _isInAsyncCall = false;
          });
          _showDialog(valid);
        }
      } else {
        var builder = new xml.XmlBuilder();
        //builder.processing('xml', 'version="1.0" encoding="iso-8859-9"');
        builder.element('AddressValidateRequest', nest: () {
          builder.attribute('USERID', '186LOFTY0774');
          builder.element('Revision', nest: 1);
          builder.element('Address', nest: () {
            builder.attribute('ID', '0');
            builder.element('Address1', nest: addressline1.text);
            builder.element('Address2', nest: addressline2.text);
            builder.element('City', nest: city.text);
            builder.element('State', nest: state.text);
            builder.element('Zip5', nest: zipcode.text);
            builder.element('Zip4', nest: "");
          });
        });

        var bookshelfXml = builder.build();

        String _uriMsj = bookshelfXml.toString();

        print("_uriMsj: $_uriMsj");

        String _uri =
            "http://production.shippingapis.com/ShippingApi.dll?API=Verify&XML=";

        HttpClient client = new HttpClient();

        HttpClientRequest request =
            await client.postUrl(Uri.parse(_uri + _uriMsj));

        // request.write(_message);
        //request.writeln(_message);
        //request.writeAll(_message);

        HttpClientResponse response = await request.close();

        StringBuffer _buffer = new StringBuffer();

        // await for (String a in await response.transform(utf8.decoder)) {
        //   _buffer.write(a);
        // }

        await for (String a in await utf8.decoder.bind(response)) {
          _buffer.write(a);
        }

        bool error = _buffer.toString().contains('Error');
        print("_buffer.toString: ${_buffer.toString()}");

        if (error == false) {
          var responseJson = xml.parse(_buffer.toString());
          var valid = responseJson.findAllElements('Address');
          Zip4 = responseJson.findAllElements('Zip4').single.text;

          Zip5 = responseJson.findAllElements('Zip5').single.text;
          if (valid != null && valid != "") {
            final FormState form = formKey.currentState;

            if (form.validate()) {
              setState(() {
                _isInAsyncCall = true;
              });
              handleSubmit();
            } else {
              setState(() {
                _isInAsyncCall = false;
              });
              showInSnackBar('Please fix the errors in red before submitting.');
            }
          } else {
            setState(() {
              _isInAsyncCall = false;
            });
            _showDialog("Error");
          }
        } else {
          var responseJson = xml.parse(_buffer.toString());
          var valid = responseJson.findAllElements('Description').single.text;

          setState(() {
            _isInAsyncCall = false;
          });
          _showDialog(valid);
        }
      }
/*


    http.Response response1 = await http.post(Uri.parse(_uri+_uriMsj));
   // xml2json.parse(response1.body);
    var responseJson = xml.parse(response1.body);
    String error = responseJson.toString();
    bool errorto = error.contains('Error');



*/
    } else {
      showInSnackBar('Please fix the errors in red before submitting.');
    }
  }

  void _showDialog(String msg) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Address Error"),
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

  Future handleSubmit() async {
    if (Flag == 0) {
      CollectionReference ref =
          Firestore.instance.collection('shipping_address');
      QuerySnapshot eventsQuery =
          await ref.where("user_id", isEqualTo: User_id).getDocuments();

      if (eventsQuery.documents.isEmpty) {
        var db1 = Firestore.instance;

        db1.collection("shipping_address").add({
          "address_line_1": addressline1.text,
          "address_line_2": addressline2.text,
          "city": city.text,
          'date': DateTime.now(),
          'id_default': "1",
          'name': firstname.text,
          'phone': number,
          "state": state.text,
          "status": "1",
          'user_id': User_id,
          'zipcode': zipcode.text,
          'zip4': Zip4
        }).then((val) {
          var docId = val.documentID;
          var updateId = {"shipping_add_id": docId};

          db1
              .collection("shipping_address")
              .document(docId)
              .updateData(updateId)
              .then((val) {
            setState(() {
              _isInAsyncCall = false;
            });

            if (exit_Flag == 1) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Secure_Checkout_Screen()));
            } else if (exit_Flag == 2) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => Address_Book()));
            } else if (exit_Flag == 3) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Edit_Drafts_Listing_details()));
            } else if (exit_Flag == 4) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Shipping_Address_List()));
            }

            print("sucess");
          }).catchError((err) {
            print(err);
            _isInAsyncCall = false;
          });
          print("sucess");
        }).catchError((err) {
          print(err);
          _isInAsyncCall = false;
        });
        setState(() {
          _isInAsyncCall = false;
        });
      } else {
        var da = eventsQuery.documents;

        for (int i = 0; i < da.length; i++) {
          String shipp_id = da[i].data['shipping_add_id'];
          var up = {'id_default': '0'};
          var db = Firestore.instance;
          db
              .collection("shipping_address")
              .document(shipp_id)
              .updateData(up)
              .then((val) {
            print("sucess");
          }).catchError((err) {
            print(err);
          });
        }

        var db1 = Firestore.instance;

        db1.collection("shipping_address").add({
          "address_line_1": addressline1.text,
          "address_line_2": addressline2.text,
          "city": city.text,
          'date': DateTime.now(),
          'id_default': "1",
          'name': firstname.text,
          'phone': number,
          "state": state.text,
          "status": "1",
          'user_id': User_id,
          'zipcode': zipcode.text,
          'zip4': Zip4
        }).then((val) {
          var docId = val.documentID;
          var updateId = {"shipping_add_id": docId};

          db1
              .collection("shipping_address")
              .document(docId)
              .updateData(updateId)
              .then((val) {
            setState(() {
              _isInAsyncCall = false;
            });

            if (exit_Flag == 1) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Secure_Checkout_Screen()));
            } else if (exit_Flag == 2) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => Address_Book()));
            } else if (exit_Flag == 3) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Edit_Drafts_Listing_details()));
            } else if (exit_Flag == 4) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Shipping_Address_List()));
            }

            print("sucess");
          }).catchError((err) {
            print(err);
            _isInAsyncCall = false;
          });
          print("sucess");
        }).catchError((err) {
          print(err);
          _isInAsyncCall = false;
        });

        setState(() {
          _isInAsyncCall = false;
        });
      }
    } else if (Flag == 1) {
      var db1 = Firestore.instance;

      db1.collection("shipping_address").add({
        "address_line_1": addressline1.text,
        "address_line_2": addressline2.text,
        "city": city.text,
        'date': DateTime.now(),
        'id_default': "1",
        'name': firstname.text,
        'phone': number,
        "state": state.text,
        "status": "1",
        'user_id': User_id,
        'zipcode': zipcode.text,
        'zip4': Zip4
      }).then((val) {
        var docId = val.documentID;
        var updateId = {"shipping_add_id": docId};

        db1
            .collection("shipping_address")
            .document(docId)
            .updateData(updateId)
            .then((val) {
          setState(() {
            _isInAsyncCall = false;
          });
          if (exit_Flag == 1) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Secure_Checkout_Screen()));
          } else if (exit_Flag == 2) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => Address_Book()));
          } else if (exit_Flag == 3) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Edit_Drafts_Listing_details()));
          } else if (exit_Flag == 4) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Shipping_Address_List()));
          }

          print("sucess");
        }).catchError((err) {
          print(err);
          _isInAsyncCall = false;
        });
        print("sucess");
      }).catchError((err) {
        print(err);
        _isInAsyncCall = false;
      });
    } else if (Flag == 3) {
      var db1 = Firestore.instance;

      db1.collection("shipping_address").add({
        "address_line_1": addressline1.text,
        "address_line_2": addressline2.text,
        "city": city.text,
        'date': DateTime.now(),
        'id_default': "1",
        'name': firstname.text,
        'phone': number,
        "state": state.text,
        "status": "0",
        'user_id': User_id,
        'zipcode': zipcode.text,
        'zip4': Zip4
      }).then((val) {
        var docId = val.documentID;
        var updateId = {"shipping_add_id": docId};

        db1
            .collection("shipping_address")
            .document(docId)
            .updateData(updateId)
            .then((val) {
          _submit();

          //  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Secure_Checkout_Screen()));

          print("sucess");
        }).catchError((err) {
          print(err);
          _isInAsyncCall = false;
        });
        print("sucess");
      }).catchError((err) {
        print(err);
        _isInAsyncCall = false;
      });
    } else if (Flag == 4) {
      var updateId = {
        "address_line_1": addressline1.text,
        "address_line_2": addressline2.text,
        "city": city.text,
        "date": DateTime.now(),
        "name": firstname.text,
        "state": state.text,
        "zipcode": zipcode.text,
        'phone': number,
      };
      var docId = address_id;

      var db1 = Firestore.instance;
      db1
          .collection("shipping_address")
          .document(docId)
          .updateData(updateId)
          .then((val) {
        sharedPreferences.setString('shipping_add_id', '');
        setState(() {
          _isInAsyncCall = false;
        });
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => Shipping_Address_List()));

        print("sucess");
      }).catchError((err) {
        print(err);
        _isInAsyncCall = false;
      });
    }
  }

  // @override
  // void dispose() {
  //   // Clean up the controller when the widget is disposed.
  //   myController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      child: Scaffold(
        key: scaffoldKey,
        appBar: new AppBar(
          leading: GestureDetector(
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                if (exit_Flag == 1) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Secure_Checkout_Screen()));
                } else if (exit_Flag == 2) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Address_Book()));
                } else if (exit_Flag == 3) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Edit_Drafts_Listing_details()));
                } else if (exit_Flag == 4) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Shipping_Address_List()));
                }
              },
            ),
            onTap: () {
              if (exit_Flag == 1) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Secure_Checkout_Screen()));
              } else if (exit_Flag == 2) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Address_Book()));
              } else if (exit_Flag == 3) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Edit_Drafts_Listing_details()));
              } else if (exit_Flag == 4) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Shipping_Address_List()));
              }
            },
          ),
          title: new Text(tool_name1),
          backgroundColor: Colors.white70,
        ),
        body: ModalProgressHUD(
          child: ListView(children: <Widget>[
            Container(
//          padding: const EdgeInsets.all(10.0),

              child: Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      // padding: const EdgeInsets.all(20.0),
                      children: <Widget>[
                        const SizedBox(height: 00.0),
                        TextFormField(
                          controller: firstname,
                          decoration: const InputDecoration(
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black87,
                                    style: BorderStyle.solid),
                              ),
                              errorStyle: TextStyle(color: Colors.red),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black87,
                                    style: BorderStyle.solid),
                              ),
                              labelText: 'First and Last Name',
                              labelStyle: TextStyle(color: Colors.black54)),
                          keyboardType: TextInputType.text,
                          validator: (String val) {
                            if (val.isEmpty) {
                              return 'Please enter your Full Name..';
                            }
                          },

                          // val.length < 1 ? 'Please enter your Full Name..!' : null,
                          onSaved: (val) => _firstname = val,
                          // obscureText: true,
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          controller: phonenumber,
                          decoration: const InputDecoration(
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black87,
                                    style: BorderStyle.solid),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black87,
                                    style: BorderStyle.solid),
                              ),
                              hintText: '0123456789',
                              labelText: 'Mobile number',
                              labelStyle: TextStyle(color: Colors.black54)),
                          keyboardType: TextInputType.text,
                          validator: (val) => val.length < 10
                              ? 'Please put 10 digit mobile number'
                              : null,
                          onSaved: (val) => number = val,
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          controller: addressline1,
                          decoration: const InputDecoration(
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black87,
                                    style: BorderStyle.solid),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black87,
                                    style: BorderStyle.solid),
                              ),
                              labelText: 'Address Line 1',
                              labelStyle: TextStyle(color: Colors.black54)),
                          keyboardType: TextInputType.text,
                          validator: (val) => val.length < 1
                              ? 'Please enter your Address1..!'
                              : null,
                          onSaved: (val) => _addressline1 = val,
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          controller: addressline2,
                          decoration: const InputDecoration(
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black87,
                                    style: BorderStyle.solid),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black87,
                                    style: BorderStyle.solid),
                              ),
                              labelText: 'Address Line 2',
                              labelStyle: TextStyle(color: Colors.black54)),
                          keyboardType: TextInputType.text,
                          validator: (val) => val.length < 1
                              ? 'Please enter your Address2..!'
                              : null,
                          onSaved: (val) => _addressline2 = val,
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          controller: city,
                          decoration: const InputDecoration(
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black87,
                                    style: BorderStyle.solid),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black87,
                                    style: BorderStyle.solid),
                              ),
                              labelText: 'City',
                              labelStyle: TextStyle(color: Colors.black54)),
                          keyboardType: TextInputType.text,
                          validator: (val) => val.length < 1
                              ? 'Please enter your City..!'
                              : null,
                          onSaved: (val) => _city = val,
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          controller: zipcode,
                          decoration: const InputDecoration(
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black87,
                                    style: BorderStyle.solid),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black87,
                                    style: BorderStyle.solid),
                              ),
                              labelText: 'Zip Code',
                              labelStyle: TextStyle(color: Colors.black54)),
                          keyboardType: TextInputType.number,
                          validator: (val) => val.length < 1
                              ? 'Please enter your ZipCode..!'
                              : null,
                          onSaved: (val) => _zipcode = val,
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          controller: state,
                          decoration: const InputDecoration(
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black87,
                                    style: BorderStyle.solid),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black87,
                                    style: BorderStyle.solid),
                              ),
                              labelText: 'State',
                              labelStyle: TextStyle(color: Colors.black54)),
                          keyboardType: TextInputType.text,
                          validator: (val) => val.length < 1
                              ? 'Please enter your State..! '
                              : null,
                          onSaved: (val) => _state = val,
                        ),
                      ],
                    ),
                  )),
            ),
            new Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(
                  top: 35.0, left: 10.0, right: 10.0, bottom: 0.0),
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
                      onPressed: () => validAddresCheck(),
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
                                "Save Address",
                                // "Publish Listing",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16.0),
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
          ]),
          inAsyncCall: _isInAsyncCall,
          opacity: 0.7,
          color: Colors.white,
          progressIndicator: CircularProgressIndicator(),
        ),
      ),
      onWillPop: () {
        if (exit_Flag == 1) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => Secure_Checkout_Screen()));
        } else if (exit_Flag == 2) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Address_Book()));
        } else if (exit_Flag == 3) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => Edit_Drafts_Listing_details()));
        } else if (exit_Flag == 4) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => Shipping_Address_List()));
        }
      },
    );
  }

  Future _submit() async {
    final form = formKey.currentState;

    if (form.validate()) {
      setState(() {
        _isInAsyncCall = true;
      });

      String Status = "0";

      var db1 = Firestore.instance;

      var updateId = {
        "status": Status,
      }; //Item_Ounces};

      db1
          .collection("product")
          .document(Product_Id)
          .updateData(updateId)
          .then((val) {
        sharedPreferences.setString('pro_id', "");

        // sharedPreferences = await SharedPreferences.getInstance();
        // sharedPreferences.setString('product_id', );

        showInSnackBar('Product successfully Add');

        Firestore.instance
            .collection('product')
            .where("product_id", isEqualTo: Product_Id)
            .snapshots()
            .listen((data) {
          data.documents.forEach((doc) async {
            if (doc.exists) {
              setState(() {
                productList.add(Shell_Product_Model(
                    doc['Any_sign_wear'],
                    doc['category'],
                    doc['category_id'],
                    doc['country'],
                    doc['date'].toDate(),
                    doc['favourite_count'],
                    doc['is_cart'],
                    doc['is_favorite_count'],
                    doc['item_Ounces'],
                    doc['item_brand'],
                    doc['item_color'],
                    doc['item_description'],
                    doc['item_measurements'],
                    doc['item_picture'],
                    doc['item_pound'],
                    doc['item_price'],
                    doc['item_sale_price'],
                    doc['item_size'],
                    doc['item_sold'],
                    doc['item_sub_title'],
                    doc['item_title'],
                    doc['item_type'],
                    doc['packing_type'],
                    doc['picture'],
                    doc['product_id'],
                    doc['retail_tag'],
                    doc['shipping_charge'],
                    doc['shipping_id'],
                    doc['status'],
                    doc['sub_category'],
                    doc['sub_category_id'],
                    doc['user_id'],
                    doc['tracking_id'],
                    doc['order_id'],
                    doc['like_new']));
              });

              setState(() {
                _isInAsyncCall = false;
              });
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          GridItemDetails1(item: productList[0])));
            } else {
              setState(() {
                _isInAsyncCall = false;
              });
              showInSnackBar('No payoutd data found!');
            }
          });
        });

        print("sucess");
      }).catchError((err) {
        print(err);
        _isInAsyncCall = false;
      });
    } else {
      setState(() {
        _isInAsyncCall = false;
      });
      showInSnackBar('Please fix the errors in red before submitting.');
    }
  }

  void showInSnackBar(String value) {
    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }
}
