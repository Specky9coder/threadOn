import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {

  static final String _kLanguageCode = "language";
  static final String _saveCameraList = "camera";
  static final String _saveGalleryList = "gallery";
  static final String _length = "length";
  static final String _width = "width";
  static final String _hight = "hight";
  static final String _titile = "titile";
  static final String _description = "description";
  static final String _color = "color";
  static final String _sellingprice = "sprice";
  static final String _retailprice = "rprice";
  static final String _shippingKit = "shippingKit";

  static final String _tag = "tag";
  static final String _signs = "signs";
  static final String _new = "new";


  static final String _catid = "cat_id";
  static final String _catname = "cat_name";

  static final String _subcatname = "sub_cat_name";
  static final String _sub_cat_id = "sub_cat_id";

  static final String _product_id = "product_id";

  static final String _share_id = "share_id";

  static final String _pic_url = "pic_url";

  static final String _item_size = "item_size";


  static final String type = "type";

  static final String User_Follower ='user_follower';
  static final String User_Followeimg ='user_following';
  static final String Seller_Follower ='seller_follower';
  static final String Seller_Following ='seller_following';






  static Future<bool> setUser_Follower(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(User_Follower, value);
  }

  static Future<String> getuser_follower() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(User_Follower) ?? '';
  }




  static Future<bool> setUser_Following(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(User_Followeimg, value);
  }

  static Future<String> getuser_following() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(User_Followeimg) ?? '';
  }






  static Future<bool> setSeller_Following(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(Seller_Following, value);
  }

  static Future<String> getSeller_following() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(Seller_Following) ?? '';
  }






  static Future<bool> setSeller_Follower(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(Seller_Follower, value);
  }

  static Future<String> getSeller_follower() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(Seller_Follower) ?? '';
  }



  static Future<bool> setite_size(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_item_size, value);
  }

  static Future<String> getitem_size() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_item_size) ?? '';
  }



  static Future<bool> setpic_url(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_pic_url, value);
  }

  static Future<String> getpic_url() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_pic_url) ?? '';
  }
  


  static Future<String> getsubcat_id() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_sub_cat_id) ?? '';
  }

//  --------------------set_product_id----------------------------------------

  static Future<bool> setproduct_id(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_product_id, value);
  }

  static Future<String> getproduct_id() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_product_id) ?? '';
  }


  /// ----------------------------------------------------------
  /// Method that saves the user language code
  /// ----------------------------------------------------------
  static Future<bool> setsub_cat_id(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_sub_cat_id, value);
  }

  
 static Future<String> getcat_id() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_catid) ?? '';
  }


  /// ----------------------------------------------------------
  /// Method that saves the user language code
  /// ----------------------------------------------------------
  static Future<bool> setcat_id(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_catid, value);
  }

  static Future<String> getcat_name() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_catname) ?? '';
  }

  static Future<bool> setshare_id(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_share_id, value);
  }

  static Future<String> getshare_id() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_share_id) ?? '';
  }


  static Future<bool> setcat_name(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_catname, value);
  }

  static Future<bool> setsub_cat_name(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_subcatname, value);
  }

  static Future<String> getsub_cat_name() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_subcatname) ?? '';
  }



  static Future<String> getLanguageCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_kLanguageCode) ?? '';
  }


  /// ----------------------------------------------------------
  /// Method that saves the user language code
  /// ----------------------------------------------------------
  static Future<bool> setLanguageCode(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_kLanguageCode, value);
  }

  static Future<bool> set_length(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_length, value);
  }

  static Future<String> get_length() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_length) ?? '';
  }





  static Future<bool> set_width(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_width, value);
  }
  static Future<String> get_width() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_width) ?? 'Example \'Louis Vuitton\'';
  }







  static Future<bool> set_hight(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_hight, value);
  }

  static Future<String> get_hight() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_hight) ?? 'Louis Vuitton';
  }



  static Future<bool> set_tag(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_tag, value);
  }

  static Future<String> get_tag() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tag) ?? '';
  }


  static Future<bool> set_signs(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_signs, value);
  }

  static Future<String> get_signs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_signs) ?? '';
  }

  //
  static Future<bool> set_new(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_new, value);
  }

  static Future<String> get_new() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_new) ?? '';
  }

  //

  static Future<bool> set_titile(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_titile, value);
  }
  static Future<String> get_titile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_titile) ?? 'Louis Vuitton';
  }


  static Future<bool> set_description(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_description, value);
  }

  static Future<String> get_description() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_description) ?? '';
  }


  static Future<bool> set_sellingprice(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_sellingprice, value);
  }

  static Future<String> get_sellingprice() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_sellingprice) ?? '';
  }


  static Future<bool> set_sippingkit(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_shippingKit, value);
  }

  static Future<String> get_sippingKit() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_shippingKit) ?? '';
  }


  static Future<bool> set_retailprice(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_retailprice, value);
  }

  static Future<String> get_retailprice() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_retailprice) ?? '';
  }



  static Future<bool> set_color(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_color, value);
  }




  static Future<bool> setCameraList(List<String> camera) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setStringList(_saveCameraList, camera);
  }


  static Future<List<String>> getCameraList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getStringList(_saveCameraList) ?? 'Example \'Louis Vuitton\'';
  }





  static Future<bool> setGalleryList(List<String> camera) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setStringList(_saveGalleryList, camera);
  }
  static Future<List<String>> getGalleryList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getStringList(_saveGalleryList) ?? 'Example \'Louis Vuitton\'';
  }



  static Future<bool> settype(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(type, value);
  }
  static Future<String> gettype() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(type) ?? '';
  }

}