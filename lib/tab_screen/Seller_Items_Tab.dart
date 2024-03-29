import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Item.dart';
import 'package:threadon/model/Product.dart';
import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/pages/ItemList.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';



class Seller_Items_Tab extends StatefulWidget{
  @override
  State<StatefulWidget> createState() =>seller_items_tab();

}

class seller_items_tab extends State<Seller_Items_Tab>{


  double itemHeight;
  double itemWidth;
  String toolName;
  SharedPreferences sharedPreferences;
  String seller_Id="",Name="",email_id="",profile_image="",facebook_id="",user_id="",about_me="",country="",cover_picture="",password="",username="@",followers ="",following="",device_id="";
  TabController controller;
  List<Shell_Product_Model> item_list;
  List<Shell_Product_Model> final_item_list = new List<Shell_Product_Model>();
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;



  getCredential() async {

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    seller_Id = sharedPreferences.getString('seller_id');
   /* Name = sharedPreferences.getString('UserName');
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
   */ item_list = new List();

    noteSub?.cancel();
    noteSub = db.getProductList().listen((QuerySnapshot snapshot) {
      final List<Shell_Product_Model> notes = snapshot.documents.map((documentSnapshot) =>
          Shell_Product_Model.fromMap(documentSnapshot.data)).toList();
        
      setState(() {
        for(int i= 0;i<notes.length;i++){      
          if(seller_Id == notes[i].user_id) {
            if (notes[i].status == '0') {

              final_item_list.add(Shell_Product_Model(
                  notes[i].any_sign_wear,
                  notes[i].category,
                  notes[i].category_id,
                  notes[i].country,
                  notes[i].date,
                  notes[i].favourite_count,
                  notes[i].is_cart,
                  notes[i].is_favorite_count,
                  notes[i].item_Ounces,
                  notes[i].item_brand,
                  notes[i].item_color,
                  notes[i].item_description,
                  notes[i].item_measurements,
                  notes[i].item_picture,
                  notes[i].item_pound,
                  notes[i].item_price,
                  notes[i].item_sale_price,
                  notes[i].item_size,
                  notes[i].item_sold,
                  notes[i].item_sub_title,
                  notes[i].item_title,
                  notes[i].item_type,
                  notes[i].packing_type,
                  notes[i].picture,
                  notes[i].product_id,
                  notes[i].retail_tag,
                  notes[i].shipping_charge,
                  notes[i].shipping_id,
                  notes[i].status,
                  notes[i].sub_category,
                  notes[i].sub_category_id,
                  notes[i].user_id,
                  notes[i].tracking_id,
                  notes[i].order_id,
                  notes[i].brand_new
              ));
            }

          }
        }
        this.item_list = final_item_list;        
      });
    });
  }


  @override
  void initState() {

    super.initState();
    getCredential();
  this.item_list = final_item_list;   
  }

  @override
  void dispose() {
    noteSub?.cancel();
    super.dispose();
  //  controller.dispose();
  }



  @override
  Widget build(BuildContext context) {  
    var size = MediaQuery.of(context).size;
    itemHeight = (size.height - kToolbarHeight - 24);
    itemWidth = size.width / 2;

    
    return Scaffold(
      body: ModalProgressHUD(
        child: _gridView(),           
        inAsyncCall: false,
        opacity: 1,
        color: Colors.white,
        progressIndicator: CircularProgressIndicator(),
      ),
    );
    
     
    
  }


  Widget _gridView() {
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(4.0),
      childAspectRatio: 8.0 / 13.0,
      children: item_list.map((items) => ItemList(item: items),
      ).toList(),
    );     
  }




}