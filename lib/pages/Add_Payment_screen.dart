import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/CountryCode.dart';
import 'package:threadon/model/PaymentBill.dart';
import 'package:threadon/pages/PaymentMethods_screen.dart';
import 'package:threadon/utils/credit_card_bloc.dart';
import 'package:threadon/utils/flutter_masked_text.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class Add_Payment_Screen extends StatefulWidget {
  String appbar_name;

  Add_Payment_Screen({Key key, this.appbar_name}) : super(key: key);

  @override
  State<StatefulWidget> createState() => add_payment_screen(appbar_name);
}

class add_payment_screen extends State<Add_Payment_Screen> {
  String tool_name1;
  bool switchValue = false;
  add_payment_screen(this.tool_name1);
  var icon;
  var prevMonth = new DateTime.now().month;
  var curentyears = new DateTime.now().year;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  var cardNumber, expMonth, expYear, Responce, _countryCode, cardType;
  var AccessToken;
  List<CountryCodeModel> CountryCode1;

  StreamSubscription<QuerySnapshot> noteSub;
  FirebaseFirestoreService db = new FirebaseFirestoreService();

  CreditCardBloc cardBloc;
  MaskedTextController ccMask =
      MaskedTextController(mask: "0000-0000-0000-0000");
  MaskedTextController expMask = MaskedTextController(mask: "00/0000");

  MaskedTextController zipcodeMask = MaskedTextController(mask: "00000000000");
  TextEditingController stateMask = new TextEditingController();
  TextEditingController cnameMask = new TextEditingController();
  TextEditingController address1Mask = new TextEditingController();
  TextEditingController address2Mask = new TextEditingController();
  TextEditingController cityMask = new TextEditingController();
  TextEditingController cvvMask = TextEditingController();

  SharedPreferences sharedPreferences;
  String User_id = "";

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  Widget bodyData() => SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[fillEntries()],
        ),
      );

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    getInitstat();
    CountryCode1 = new List();
    CountryCode1.add(CountryCodeModel('CANADA', 'CA'));
    CountryCode1.add(CountryCodeModel('INDIA', 'IN'));
    CountryCode1.add(CountryCodeModel('UNITED KINGDOM', 'GB'));
    CountryCode1.add(CountryCodeModel('UNITED STATES', 'US'));
  }

  getInitstat() async {
    sharedPreferences = await SharedPreferences.getInstance();

    User_id = await sharedPreferences.getString('user_id');
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

  _onAlertWithStylePressed(context) {
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
      title: "Opps!",
      desc: "Error while fetching data",
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
          color: Color.fromRGBO(0, 179, 134, 1.0),
          radius: BorderRadius.circular(0.0),
        ),
      ],
    ).show();
  }

  Future makePost() async {
    String username =
        "AVrtqjI938aTqO9zZHOh1Lvm4ku_zUrBA1XJrwk-Ns-yr6o77EuAtq0YyRlkHBUsILFlWlgfYzffVcrb";
    String password =
        "EEoB8DUFd0pCnbh9S_P91Z3VvIEZ5h1PqJlCegr3EXKqg0oLgl3FgmmU2bGx-FEw1r4PnGqlab-zQskB";
    var bytes = utf8.encode("$username:$password");
    var credentials = base64.encode(bytes);
    Map token = {'grant_type': 'client_credentials'};
    var headers = {
      "Accept": "application/json",
      'Accept-Language': 'en_US',
      "Authorization": "Basic $credentials"
    };
    var url = "https://api.sandbox.paypal.com/v1/oauth2/token";
    var requestBody = token;
    http.Response response1 =
        await http.post(url, body: requestBody, headers: headers);
    var responseJson = json.decode(response1.body);
    // var res = fromJson(responseJson);
    AccessToken = responseJson['access_token'];

    Map map = {
      'number': cardNumber,
      'type': cardType,
      'expire_month': expMonth,
      'expire_year': expYear,
      'first_name': cnameMask.text,
      'last_name': 'parmar',
      'billing_address': {
        'line1': address1Mask.text,
        'city': cityMask.text,
        'country_code': _countryCode,
        'postal_code': zipcodeMask.text,
        'state': stateMask.text,
        'phone': '9974619782'
      },
      'external_customer_id': 'customer_id-' + User_id,
    };

    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(
        Uri.parse('https://api.sandbox.paypal.com/v1/vault/credit-cards/'));
    request.headers.set('content-type', 'application/json');
    request.headers.set('authorization', 'Bearer ' + AccessToken);

    request.add(utf8.encode(json.encode(map)));
    HttpClientResponse response = await request.close();
    // todo - you should check the response.statusCode

    final int statusCode = response.statusCode;
    // Responce = await response.transform(utf8.decoder).join();
    Responce = await utf8.decoder.bind(response).join();
    if (statusCode <= 200 || statusCode >= 299) {
      _onAlertWithStylePressed(context);
      throw new Exception("Error while fetching data");
    } else {
      List<String> biilingAdd = new List();

      Map valueMap = json.decode(Responce);
      biilingAdd.add(valueMap['billing_address']['line1']);
      biilingAdd.add(valueMap['billing_address']['city']);
      biilingAdd.add(valueMap['billing_address']['state']);
      biilingAdd.add(valueMap['billing_address']['postal_code']);
      biilingAdd.add(valueMap['billing_address']['country_code']);
      biilingAdd.add(valueMap['billing_address']['phone']);

      db
          .createCardIndo(
              '',
              valueMap['id'],
              DateTime.now(),
              valueMap['external_customer_id'],
              valueMap['type'],
              valueMap['number'],
              valueMap['expire_month'],
              valueMap['expire_year'],
              valueMap['first_name'],
              valueMap['last_name'],
              biilingAdd,
              valueMap['valid_until'],
              valueMap['create_time'],
              valueMap['update_time'],
              User_id,
              AccessToken)
          .then((_) {
        //_isInAsyncCall = false;

        List<String> d;
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Payments_Methods(
                      tool_name: 'Payments Methods',
                      shippingAdd: d,
                    )));
      });
      httpClient.close();
    }

    return Responce;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: scaffoldKey,
      appBar: new AppBar(
        title: new Text(tool_name1),
        backgroundColor: Colors.white70,
//        automaticallyImplyLeading: false,
      ),
      body: bodyData(),
    );
  }

  Widget fillEntries() => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: ccMask,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.black),
              onChanged: (out) => cc_brand_id(ccMask.text),
              decoration: InputDecoration(
                suffixIcon: Icon(
                  icon,
                  color: Colors.black38,
                ),
                labelText: "Credit Card Number",
                labelStyle:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black87, style: BorderStyle.solid),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black87, style: BorderStyle.solid),
                ),
              ),
            ),
            new Container(
              height: 10.0,
            ),
            TextField(
              controller: expMask,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.black),
              onChanged: (out) => cardBloc.expInputSink.add(expMask.text),
              decoration: InputDecoration(
                labelStyle:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black87, style: BorderStyle.solid),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black87, style: BorderStyle.solid),
                ),
                labelText: "MM/YYYY",
              ),
            ),
            new Container(
              height: 10.0,
            ),
            TextField(
              keyboardType: TextInputType.text,
              controller: cnameMask,
              style: TextStyle(color: Colors.black),
              onChanged: (out) => cardBloc.nameInputSink.add(out),
              decoration: InputDecoration(
                labelStyle:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black87, style: BorderStyle.solid),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black87, style: BorderStyle.solid),
                ),
                labelText: "Name on card",
              ),
            ),
            new Container(
              height: 40.0,
            ),
            new Container(
              child: new Row(
                children: <Widget>[
                  Text(
                    "Billing Address",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
            ),
            new Container(
              height: 20.0,
            ),
            TextField(
              keyboardType: TextInputType.text,
              controller: address1Mask,
              style: TextStyle(color: Colors.black),
              onChanged: (out) => cardBloc.nameInputSink.add(out),
              decoration: InputDecoration(
                labelStyle:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black87, style: BorderStyle.solid),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black87, style: BorderStyle.solid),
                ),
                labelText: "Address line 1",
              ),
            ),
            new Container(
              height: 10.0,
            ),
            TextField(
              keyboardType: TextInputType.text,
              controller: address2Mask,
              style: TextStyle(color: Colors.black),
              onChanged: (out) => cardBloc.nameInputSink.add(out),
              decoration: InputDecoration(
                labelStyle:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black87, style: BorderStyle.solid),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black87, style: BorderStyle.solid),
                ),
                labelText: "Address line 2",
              ),
            ),
            new Container(
              height: 10.0,
            ),
            TextField(
              controller: cvvMask,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.black),
              onChanged: (out) => cardBloc.cvvInputSink.add(cvvMask.text),
              decoration: InputDecoration(
                labelStyle:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black87, style: BorderStyle.solid),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black87, style: BorderStyle.solid),
                ),
                labelText: "Mobile",
              ),
            ),
            new Container(
              height: 10.0,
            ),
            new Row(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.only(right: 5.0),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      controller: cityMask,
                      style: TextStyle(color: Colors.black),
                      onChanged: (out) => cardBloc.nameInputSink.add(out),
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black87, style: BorderStyle.solid),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black87, style: BorderStyle.solid),
                        ),
                        labelText: "City",
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.only(right: 0.0),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: zipcodeMask,
                      style: TextStyle(color: Colors.black),
                      onChanged: (out) => cardBloc.nameInputSink.add(out),
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black87, style: BorderStyle.solid),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black87, style: BorderStyle.solid),
                        ),
                        labelText: "Zip Code",
                      ),
                    ),
                  ),
                ),
              ],
            ),
            new Container(
              height: 10.0,
            ),
            TextField(
              keyboardType: TextInputType.text,
              controller: stateMask,
              style: TextStyle(color: Colors.black),
              onChanged: (out) => cardBloc.nameInputSink.add(out),
              decoration: InputDecoration(
                labelStyle:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black87, style: BorderStyle.solid),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black87, style: BorderStyle.solid),
                ),
                labelText: "State",
              ),
            ),
            new Container(
              height: 10.0,
            ),
            InputDecorator(
                decoration: InputDecoration(
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black87, style: BorderStyle.solid),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black87, style: BorderStyle.solid),
                  ),
                  labelText: "Country",
                ),
                child: DropdownButtonHideUnderline(
                  child: new DropdownButton(
                    items: CountryCode1.map((item) {
                      return new DropdownMenuItem(
                        child: new Text(item.CountryName),
                        value: item.CountryCode.toString(),
                      );
                    }).toList(),
                    hint: Text("Country"),
                    onChanged: (newVal) {
                      setState(() {
                        _countryCode = newVal;
                      });
                    },
                    value: _countryCode,
                  ),
                )),
            new Container(
              height: 20.0,
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
                                    color: Colors.white, fontSize: 18.0),
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
      );

  void showInSnackBar(String value) {
    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  handleSubmit() {
    cardNumber = ccMask.text.replaceAll('-', '');
    // int num = int.parse(ccMask.text.length);

    if (16 <= cardNumber.length) {
      var expDate = expMask.text.split('/');

      expMonth = expDate[0];
      expYear = expDate[1];
      if (0 != int.parse(expDate[0]) && 12 >= int.parse(expDate[0])) {
        if (curentyears <= int.parse(expDate[1])) {
          if (prevMonth <= int.parse(expDate[1])) {
            if (cvvMask.text != '') {
              if (address1Mask.text != '') {
                if (cityMask.text != '') {
                  if (_countryCode != '') {
                    makePost();

                    // showInSnackBar('kskksk');

                  } else {
                    showInSnackBar('Country required!!');
                  }
                } else {
                  showInSnackBar('City required!');
                }
              } else {
                showInSnackBar('Address required!!');
              }
            } else {
              showInSnackBar('Mobile number required!');
            }
          } else {
            showInSnackBar('Exp.Month not valid!');
          }
        } else {
          showInSnackBar('Exp.Year not valid!');
        }
      } else {
        showInSnackBar('Card number not valid!');
      }
    } else {
      showInSnackBar('Card number not valid!');
    }
  }

  cc_brand_id(cur_val) {
    //JCB

    // American Express
    RegExp amex_regex = new RegExp('^3[47][0-9]{0,}\$'); //34, 37
    // Diners Club

    // Visa
    RegExp visa_regex = new RegExp('^4[0-9]{0,}\$'); //4
    // MasterCard
    RegExp mastercard_regex = new RegExp(
        '^(5[1-5]|222[1-9]|22[3-9]|2[3-6]|27[01]|2720)[0-9]{0,}\$'); //2221-2720, 51-55

    RegExp maestro_regex = new RegExp(
        '^(5[06789]|6)[0-9]{0,}\$'); //always growing in the range: 60-69, started with / not something else, but starting 5 must be encoded as mastercard anyway
    //Discover
    RegExp discover_regex = new RegExp(
        '^(6011|65|64[4-9]|62212[6-9]|6221[3-9]|622[2-8]|6229[01]|62292[0-5])[0-9]{0,}\$');
    ////6011, 622126-622925, 644-649, 65

    // get rid of anything but numbers
    cur_val = cur_val;

    // checks per each, as their could be multiple hits
    //fix: ordering matter in detection, otherwise can give false results in rare cases
    var sel_brand = "unknown";

    if (amex_regex.hasMatch(cur_val)) {
      cardType = "amex";
      icon = FontAwesomeIcons.ccAmex;
    } else if (visa_regex.hasMatch(cur_val)) {
      cardType = "visa";
      icon = FontAwesomeIcons.ccVisa;
    } else if (mastercard_regex.hasMatch(cur_val)) {
      cardType = "mastercard";
      icon = FontAwesomeIcons.ccMastercard;
    } else if (discover_regex.hasMatch(cur_val)) {
      cardType = "discover";
      icon = FontAwesomeIcons.ccDiscover;
    } else if (maestro_regex.hasMatch(cur_val)) {
      if (cur_val[0] == '5') {
        //started 5 must be mastercard
        cardType = "mastercard";
        icon = FontAwesomeIcons.ccMastercard;
      } else {
        cardType = "maestro";
        //maestro is all 60-69 which is not something else, thats why this condition in the end
      }
    }

    setState(() {
      return icon;
    });
  }
}
