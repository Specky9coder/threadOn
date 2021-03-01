import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

class USPS extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new usps();
  }
}

class usps extends State<USPS> {
  Future<HttpClientResponse> _sendOTP() async {
    /* var builder = new xml.XmlBuilder();

    builder.processing('xml', 'version="1.0" encoding="UTF-8"');

    builder.element('ZipCodeLookupRequest', nest: () {
      builder.attribute('USERID','186LOFTY0774');
      builder.element('Address', nest: () {
        builder.attribute('ID', '0');
        builder.element('Address1', nest: '');
        builder.element('Address2', nest: "8 Wildwood Drive");
        builder.element('City', nest: "Old Lyme");
        builder.element('State', nest: "CT");
        builder.element('Zip5', nest: "06371");
        builder.element('Zip4', nest: "");
      });
    });*/

    var builder = new xml.XmlBuilder();
    //builder.processing('xml', 'version="1.0" encoding="iso-8859-9"');
    builder.element('AddressValidateRequest', nest: () {
      builder.attribute('USERID', '186LOFTY0774');
      builder.element('Revision', nest: 1);
      builder.element('Address', nest: () {
        builder.attribute('ID', '0');
        builder.element('Address1', nest: '');
        builder.element('Address2', nest: "29851 Aventura #k");
        builder.element('City', nest: "");
        builder.element('State', nest: "CA");
        builder.element('Zip5', nest: "92688");
        builder.element('Zip4', nest: "");
      });
    });

    var bookshelfXml = builder.build();

    String _uriMsj = bookshelfXml.toString();

    print("_uriMsj: $_uriMsj");

    String _uri =
        "http://production.shippingapis.com/ShippingApi.dll?API=Verify&XML=";

    var _responseOtp = postOTP(_uri, _uriMsj);

    print("_responseOtp: $_responseOtp");
  }

  Future<String> postOTP(String _uri, String _message) async {
    HttpClient client = new HttpClient();

    HttpClientRequest request =
        await client.postUrl(Uri.parse(_uri + _message));

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
    print("_buffer.toString: ${_buffer.toString()}");

    return _buffer.toString();
  }

  Future<HttpClientResponse> getXml() async {
    var builder = new xml.XmlBuilder();
    //builder.processing('xml', 'version="1.0" encoding="iso-8859-9"');
    builder.element('AddressValidateRequest', nest: () {
      builder.attribute('USERID', '186LOFTY0774');
      builder.element('Revision', nest: 1);
      builder.element('Address', nest: () {
        builder.attribute('ID', '0');
        builder.element('Address1', nest: '');
        builder.element('Address2', nest: "29851 Aventura #k");
        builder.element('City', nest: "");
        builder.element('State', nest: "CA");
        builder.element('Zip5', nest: "92688");
        builder.element('Zip4', nest: "");
      });
    });

/*

    var bookshelfXml = """<AddressValidateRequest USERID="186LOFTY0774">

<Revision>1</Revision>
<Address ID="0">
      <Address1></Address1>
 <Address2>29851 Aventura #k</Address2>
  <City></City>
   <State>CA</State>
 <Zip5>92688</Zip5>
 <Zip4></Zip4>
</Address>
</AddressValidateRequest>""";
*/

    //   var document = xml.parse(bookshelfXml);

    var bookshelfXml = builder.build();
    String _uriMsj = bookshelfXml.toString();
    print("_uriMsj: $_uriMsj");

    String _uri = "http://production.shippingapis.com/ShippingApi.dll?";
    var _responseOtp = postOTP(_uri, _uriMsj);
    print("_responseOtp: $_responseOtp");
  }

  Future<String> data(String _uri, String _message) async {
    /*String username = "186LOFTY0774";
    String password = "136MF36TB360";
    var bytes = utf8.encode("$username:$password");
    var credentials = base64.encode(bytes);
   var requestBody = {

     'Content-Type': 'text/xml; charset=utf-8',
    };


    http.Response response1 = await http.post(_uri+"API=Verify&XML=", headers: requestBody,body: _message);
    var responseJson = xml.parse(response1.body);
    var data = responseJson.toString();*/

    HttpClient client = new HttpClient();
    client
        .postUrl(Uri.parse(_uri + "API=Verify&XML=" + _message))
        .then((HttpClientRequest request) async {
      // request.write(_message);

      HttpClientResponse response = await request.close();
      StringBuffer _buffer = new StringBuffer();
      // await for (String a in await response.transform(utf8.decoder)) {
      //   _buffer.write(a);
      // }
      await for (String a in await utf8.decoder.bind(response)) {
        _buffer.write(a);
      }
      print("_buffer.toString: ${_buffer.toString()}");
      // Optionally set up headers...
      // Optionally write to the request object...
      // Then call close.
      return request.close();
    }).then((HttpClientResponse response) {
      // Process the response.
      print(response);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        child: RaisedButton(onPressed: _sendOTP),
      ),
    );
  }
}
