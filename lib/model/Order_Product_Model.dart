class Ordered_Product_Model {
  String any_sign_wear;
  String category;
  String category_id;
  String country;
  DateTime date;
  String favourite_count;
  String is_cart;
  String is_favorite_count;
  int item_Ounces;
  String item_brand;
  String item_color;
  String item_description;
  String item_measurements;
  List item_picture;
  int item_pound;
  String item_price;
  String item_sale_price;
  String item_size;
  String item_sold;
  String item_sub_title;
  String item_title;
  String item_type;
  List packing_type;
  String picture;
  String product_id;
  String retail_tag;
  String shipping_charge;
  String shipping_id;
  String status;
  String sub_category;
  String sub_category_id;
  String user_id;

  String tracking_id;

  Ordered_Product_Model(
      this.any_sign_wear,
      this.category,
      this.category_id,
      this.country,
      this.date,
      this.favourite_count,
      this.is_cart,
      this.is_favorite_count,
      this.item_Ounces,
      this.item_brand,
      this.item_color,
      this.item_description,
      this.item_measurements,
      this.item_picture,
      this.item_pound,
      this.item_price,
      this.item_sale_price,
      this.item_size,
      this.item_sold,
      this.item_sub_title,
      this.item_title,
      this.item_type,
      this.packing_type,
      this.picture,
      this.product_id,
      this.retail_tag,
      this.shipping_charge,
      this.shipping_id,
      this.status,
      this.sub_category,
      this.sub_category_id,
      this.user_id,
      this.tracking_id);

  Ordered_Product_Model.map(dynamic obj) {
    this.any_sign_wear = obj['Any_sign_wear'];
    this.category = obj['category'];
    this.category_id = obj['category_id'];
    this.country = obj['country'];
    this.date = obj['date'];
    this.favourite_count = obj['favourite_count'];
    this.is_cart = obj['is_cart'];
    this.is_favorite_count = obj['is_favorite_count'];
    this.item_Ounces = obj['item_Ounces'];
    this.item_brand = obj['item_brand'];
    this.item_color = obj['item_color'];
    this.item_description = obj['item_description'];
    this.item_measurements = obj['item_measurements'];
    this.item_picture = obj['item_picture'];
    this.item_pound = obj['item_pound'];
    this.item_price = obj['item_price'];
    this.item_sale_price = obj['item_sale_price'];
    this.item_size = obj['item_size'];
    this.item_sold = obj['item_sold'];
    this.item_sub_title = obj['item_sub_title'];
    this.item_title = obj['item_title'];
    this.item_type = obj['item_type'];
    this.packing_type = obj['packing_type'];

    this.picture = obj['picture'];
    this.product_id = obj['product_id'];
    this.retail_tag = obj['retail_tag'];
    this.shipping_charge = obj['shipping_charge'];
    this.shipping_id = obj['shipping_id'];
    this.status = obj['status'];

    this.sub_category = obj['sub_category'];
    this.sub_category_id = obj['sub_category_id'];
    this.user_id = obj['user_id'];

    this.tracking_id = obj['tracking_id'];
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (product_id != null) {
      map['product_id'] = product_id;
    }

    map['Any_sign_wear'] = any_sign_wear;
    map['category'] = category;
    map['category_id'] = category_id;
    map['country'] = country;
    map['date'] = date;
    map['favourite_count'] = favourite_count;
    map['is_cart'] = is_cart;
    map['is_favorite_count'] = is_favorite_count;
    map['item_Ounces'] = item_Ounces;
    map['item_brand'] = item_brand;
    map['item_color'] = item_color;
    map['item_description'] = item_description;
    map['item_measurements'] = item_measurements;
    map['item_picture'] = item_picture;
    map['item_pound'] = item_pound;
    map['item_price'] = item_price;
    map['item_sale_price'] = item_sale_price;
    map['item_size'] = item_size;
    map['item_sold'] = item_sold;
    map['item_sub_title'] = item_sub_title;
    map['item_title'] = item_title;
    map['item_type'] = item_type;
    map['packing_type'] = packing_type;

    map['picture'] = picture;
    map['product_id'] = product_id;
    map['retail_tag'] = retail_tag;
    map['shipping_charge'] = shipping_charge;
    map['shipping_id'] = shipping_id;
    map['status'] = status;

    map['sub_category'] = sub_category;
    map['sub_category_id'] = sub_category_id;
    map['user_id'] = user_id;

    map['tracking_id'] = tracking_id;

    return map;
  }

  Ordered_Product_Model.fromMap(Map<String, dynamic> map) {
    this.any_sign_wear = map['Any_sign_wear'];
    this.category = map['category'];
    this.category_id = map['category_id'];
    this.country = map['country'];
    this.date = map['date'];
    this.favourite_count = map['favourite_count'];
    this.is_cart = map['is_cart'];
    this.is_favorite_count = map['is_favorite_count'];
    this.item_Ounces = map['item_Ounces'];
    this.item_brand = map['item_brand'];
    this.item_color = map['item_color'];
    this.item_description = map['item_description'];
    this.item_measurements = map['item_measurements'];
    this.item_picture = new List<String>.from(map['item_picture']);

    this.item_pound = map['item_pound'];
    this.item_price = map['item_price'];
    this.item_sale_price = map['item_sale_price'];
    this.item_size = map['item_size'];
    this.item_sold = map['item_sold'];
    this.item_sub_title = map['item_sub_title'];
    this.item_title = map['item_title'];
    this.item_type = map['item_type'];
    this.packing_type = new List<String>.from(map['packing_type']);

    this.picture = map['picture'];
    this.product_id = map['product_id'];
    this.retail_tag = map['retail_tag'];
    this.shipping_charge = map['shipping_charge'];
    this.shipping_id = map['shipping_id'];
    this.status = map['status'];

    this.sub_category = map['sub_category'];
    this.sub_category_id = map['sub_category_id'];
    this.user_id = map['user_id'];

    this.tracking_id = map['tracking_id'];
  }
}
