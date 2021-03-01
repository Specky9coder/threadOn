import 'dart:io';

import 'package:camera/camera.dart';
// import 'package:custom_multi_image_picker/asset.dart';
import 'package:flutter/material.dart';

import 'package:threadon/image_picker/asset_view.dart';
// import 'package:threadon/image_picker/view.dart';
import 'package:threadon/utils/SharedPreferencesHelper.dart';
import 'package:threadon/image_picker/asset_view.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class ManagePhoto_Screen extends StatefulWidget {
  List<String> ListOfCameraphoto;
  List<Asset> ListOfGalleryphoto;

  ManagePhoto_Screen(this.ListOfCameraphoto, this.ListOfGalleryphoto);

  @override
  managephoto_screen createState() {
    return managephoto_screen(ListOfCameraphoto, ListOfGalleryphoto);
  }
}

class managephoto_screen extends State<ManagePhoto_Screen> {
  CameraController controller;
  String imagePath;
  List<String> ListOfCameraphoto;
  List<Asset> ListOfGalleryphoto;
  int Flag = 0;
  var _loadImage = 'images/place_h.png';
  var _myEarth =
      new NetworkImage("http://qige87.com/data/out/73/wp-image-144183272.png");
  String ImagePth;

  managephoto_screen(this.ListOfCameraphoto, this.ListOfGalleryphoto);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        backgroundColor: Colors.white70,
        title: Text('Manage Photos'),
        actions: <Widget>[
          Center(
            child: GestureDetector(
                child: Container(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Text(
                      'DONE',
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500),
                    )),
                onTap: () {
                  // MyNavigator.gotoAdd_Item_4_Screen(context, 'Listing Details',ListofItem ,images);
                }),
            /* child:GestureDetector(
          child:Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    'COUTINUE',
                    style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w500),
                  ))
    onTap: () {
      Navigator.pop(context);
    },),*/
          )
        ],
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
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                    child: Container(
                  child: ListOfGalleryphoto.length != 0
                      ? getImageInGalleryView()
                      : _getImageFromFileView(ListOfCameraphoto),
                )),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(5.0),
            height: 70.0,
            alignment: Alignment.center,
            child: ListOfGalleryphoto.length != 0
                ? getImageInGallery()
                : _getImageFromFile(ListOfCameraphoto),
          ),
          new SizedBox(
            height: 20.0,
            child: new Center(
              child: new Container(
                margin: new EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
                height: 2.0,
                color: Colors.black87,
              ),
            ),
          ),
          _captureControlRowWidget(),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                //  _cameraTogglesRowWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getImageFromFile(List<String> imagePath) {
    List<String> reversedAnimals = imagePath.reversed.toList();
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 8,
        itemBuilder: (BuildContext context, int index) {
          String first = reversedAnimals[index].toString();

          if (first == "") {
            return Container(
              margin: EdgeInsets.all(5.0),
              child: Image.asset(
                _loadImage,
                //fit: BoxFit.fill,
                fit: BoxFit.cover,
                width: 50.0,
                height: 60.0,
                //centerSlice: Rect.fromLTRB(2.0, 2.0, 2.0, 2.0),
                //colorBlendMode: BlendMode.srcOver,
                //color: Color.fromARGB(120, 20, 10, 40),
              ),
            );
          } else {
            return Container(
                margin: EdgeInsets.all(5.0),
                child: GestureDetector(
                    child: Image.file(
                      File(
                        reversedAnimals[index],
                      ),
                      fit: BoxFit.cover,
                      width: 50.0,
                      height: 60.0,
                    ),
                    onTap: () {
                      setState(() {
                        _showAlert(reversedAnimals[index].toString());
                      });
                    }));
          }
        });
    /*
  */
  }

  Widget getImageInGallery() {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 8,
        itemBuilder: (BuildContext context, int index) {
          String first = ListOfGalleryphoto[index].toString();
          if (first == null) {
            return Container(
              margin: EdgeInsets.all(5.0),
              child: Image.asset(
                _loadImage,
                //fit: BoxFit.fill,
                fit: BoxFit.cover,
                width: 50.0,
                height: 60.0,
                //centerSlice: Rect.fromLTRB(2.0, 2.0, 2.0, 2.0),
                //colorBlendMode: BlendMode.srcOver,
                //color: Color.fromARGB(120, 20, 10, 40),
              ),
            );
          } else {
            Asset asset = ListOfGalleryphoto[index];
            return Container(
                margin: EdgeInsets.all(5.0),
                child: GestureDetector(
                    child: Container(
                        height: 60.0,
                        width: 50.0,
                        child: AssetThumb(
                          asset: asset,
                          width: 300,
                          height: 300,
                        )
                        // child: AssetView(index, ListOfGalleryphoto[index]),
                        ),
                    onTap: () {
                      Flag = 1;

                      _showAlert(ListOfGalleryphoto[0].toString());
                    }));
          }
        });
    /*
  */
  }

  Widget _getImageFromFileView(List<String> imagePath) {
    List<String> reversedAnimals = imagePath.reversed.toList();
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          String first = reversedAnimals[index].toString();

          if (first == "") {
            return Container(
              margin: EdgeInsets.all(5.0),
              child: Image.asset(
                _loadImage,
                //fit: BoxFit.fill,
                fit: BoxFit.cover,
                //centerSlice: Rect.fromLTRB(2.0, 2.0, 2.0, 2.0),
                //colorBlendMode: BlendMode.srcOver,
                //color: Color.fromARGB(120, 20, 10, 40),
              ),
            );
          } else {
            return Container(
                margin: EdgeInsets.all(5.0),
                child: GestureDetector(
                    child: Image.file(
                      File(
                        reversedAnimals[index],
                      ),
                      fit: BoxFit.cover,
                    ),
                    onTap: () {
                      setState(() {
                        _showAlert(reversedAnimals[index].toString());
                      });
                    }));
          }
        });
    /*
  */
  }

  Widget getImageInGalleryView() {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          String first = ListOfGalleryphoto[index].toString();
          if (first == null) {
            return Container(
              margin: EdgeInsets.all(5.0),
              child: Image.asset(
                _loadImage,
                //fit: BoxFit.fill,
                fit: BoxFit.cover,
                //centerSlice: Rect.fromLTRB(2.0, 2.0, 2.0, 2.0),
                //colorBlendMode: BlendMode.srcOver,
                //color: Color.fromARGB(120, 20, 10, 40),
              ),
            );
          } else {
            Asset asset = ListOfGalleryphoto[index];
            return Container(
                margin: EdgeInsets.all(5.0),
                child: GestureDetector(
                    child: Container(
                        child: AssetThumb(
                      asset: asset,
                      width: 300,
                      height: 300,
                    )
                        // child: AssetView(index, ListOfGalleryphoto[index]),
                        ),
                    onTap: () {
                      Flag = 1;

                      _showAlert(ListOfGalleryphoto[0].toString());
                    }));
          }
        });
    /*
  */
  }

  Widget _getImageFromAsset() {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 8,
        itemBuilder: (BuildContext context, int index) {
          return Image.asset(
            _loadImage,
            //fit: BoxFit.fill,
            fit: BoxFit.cover,
            width: 50.0,
            height: 60.0,
            //centerSlice: Rect.fromLTRB(2.0, 2.0, 2.0, 2.0),
            //colorBlendMode: BlendMode.srcOver,
            //color: Color.fromARGB(120, 20, 10, 40),
          );
        });
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }
  }

  /// Display the thumbnail of the captured image or video.

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    return Stack(alignment: Alignment.center, children: <Widget>[
      Align(
        alignment: Alignment.center,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(50.0)),
              onTap: () {
                // _captureImage();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                      size: 50.0,
                    ),
                  ),
                  Text(
                    'DELETE',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 17.0,
                        color: Colors.redAccent),
                  )
                ],
              )),
        ),
      ),
    ]);
  }

  void _showAlert(String listname) {
    AlertDialog dialog = new AlertDialog(
      content: new Container(
        width: 260.0,
        height: 230.0,
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
        ),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // dialog top
            new Expanded(
              child: new Row(
                children: <Widget>[
                  new Container(
                    alignment: Alignment.center,
                    // padding: new EdgeInsets.all(10.0),
                    decoration: new BoxDecoration(
                      color: Colors.white,
                    ),
                    child: new Text(
                      'Alert',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // dialog centre
            /*   new Expanded(
              child: new Container(
                  alignment: Alignment.center,
                  child: new TextField(
                    decoration: new InputDecoration(
                      border: InputBorder.none,
                      filled: false,
                      contentPadding: new EdgeInsets.only(
                          left: 10.0, top: 10.0, bottom: 10.0, right: 10.0),
                      hintText: '',
                      hintStyle: new TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12.0,
                      ),
                    ),
                  )),
              flex: 2,
            ),*/

            Divider(
              height: 10.0,
            ),
            // dialog bottom
            new Expanded(
                child: GestureDetector(
              child: new Container(
                alignment: Alignment.center,
                padding: new EdgeInsets.all(10.0),
                decoration: new BoxDecoration(
                  color: Colors.white,
                ),
                child: new Text(
                  'DELETE',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 18.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              onTap: () {
                setState(() {
                  if (Flag == 1) {
                    ListOfGalleryphoto.remove(listname);
                    ListOfGalleryphoto.join(',');
                    getsave2(ListOfGalleryphoto);
                    _getImageFromAsset();
                  } else {
                    ListOfCameraphoto.remove(listname);
                    ListOfCameraphoto.join(',');
                    getsave(ListOfCameraphoto);
                    _getImageFromFile(ListOfCameraphoto);
                  }
                  Navigator.pop(context);
                });
              },
            )),
          ],
        ),
      ),
    );

    showDialog(context: context, child: dialog);
  }

  getsave(List<String> ListOfCameraphoto) async {
    // Save the user preference
    await SharedPreferencesHelper.setCameraList(ListOfCameraphoto);
  }

  getsave2(List<Asset> ListOfCameraphoto) async {
    // Save the user preference
    List<String> data = ListOfCameraphoto.cast<String>();
    await SharedPreferencesHelper.setCameraList(data);
  }
}
