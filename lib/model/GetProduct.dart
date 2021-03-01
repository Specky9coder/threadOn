class GetProduct{
  String Category;
  String Country;
  String Is_cart;
  String Item_brand;
  String Item_color;
  String Item_description;
  String Item_measurements;
  String Item_price;
  String Item_sale_price;
  String Item_size;
  String Item_sold;
  String Item_sub_title;
  String Item_title;
  String Item_type;
  String Picture;
  String Product_id;
  String Status;
  String Sub_category;
  String Sub_category_id;
  String User_id;
  String Share_id;
//
//
//  String Item_collection;
//  String Item_condition_details;
//  String Item_fabric;
//  String Item_remain_quantity;
//  String Item_tag;
//  String Item_total_quantity;


  GetProduct(this.Category, this.Country, this.Is_cart, this.Item_brand,
      this.Item_color, this.Item_description, this.Item_measurements,
      this.Item_price, this.Item_sale_price, this.Item_size, this.Item_sold, this.Item_sub_title,
      this.Item_title, this.Item_type, this.Picture, this.Product_id, this.Status,
      this.Sub_category, this.Sub_category_id, this.User_id, this.Share_id);

//  Product(this.Category, this.Item_brand, this.Item_collection, this.Item_color,
//      this.Item_condition_details, this.Item_description, this.Item_fabric, this.Item_measurements,
//      this.Item_remain_quantity, this.Item_sale_price, this.Item_size, this.Item_sold, this.Item_sub_title, this.Item_tag,
//      this.Item_total_quantity, this.Item_type, this.Item_price, this.Item_title, this.Status,
//      this.Sub_category, this.Sub_category_id, this.User_id, this.Picture);


  String get category => Category;
  String get country => Country;
  String get is_cart => Is_cart;
  String get item_brand => Item_brand;
  String get item_color => Item_color;
  String get item_description => Item_description;
  String get item_measurements => Item_measurements;
  String get item_price => Item_price;
  String get item_sale_price => Item_sale_price;
  String get item_size => Item_size;
  String get item_sold => Item_sold;
  String get item_sub_title => Item_sub_title;
  String get item_title => Item_title;
  String get item_type => Item_type;
  String get picture => Picture;
  String get product_id => Product_id;
  String get status => Status;
  String get sub_category => Sub_category;
  String get sub_category_id => Sub_category_id;
  String get user_id => User_id;
  String get share_id => Share_id;


  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (Sub_category_id != null) {
      map['category'] = Category;
    }
    map['country'] = Country;
    map['is_cart'] = Is_cart;
    map['item_brand'] = Item_brand;
    map['item_color'] = Item_color;
    map['item_description'] = Item_description;
    map['item_measurements'] = Item_measurements;
    map['item_price'] = Item_price;
    map['item_sale_price'] = Item_sale_price;
    map['item_size'] = Item_size;
    map['item_sold'] = Item_sold;
    map['item_sub_title'] = Item_sub_title;
    map['item_title'] = Item_title;
    map['item_type'] = Item_type;
    map['picture'] = Picture;
    map['product_id'] = Product_id;
    map['status'] = Status;
    map['sub_category'] = Sub_category;
    map['sub_category_id'] = Sub_category_id;
    map['user_id'] = user_id;
    return map;
  }


  GetProduct.fromMap(Map<String, dynamic> map) {
    this.Category = map['category'];
    this.Country = map['country'];
    this.Is_cart = map['is_cart'];
    this.Item_brand = map['item_brand'];
    this.Item_color = map['item_color'];
    this.Item_description = map['item_description'];
    this.Item_measurements = map['item_measurements'];
    this.Item_price = map['item_price'];
    this.Item_sale_price = map['item_sale_price'];
    this.Item_size = map['item_size'];
    this.Item_sold = map['item_sold'];
    this.Item_sub_title = map['item_sub_title'];
    this.Item_title = map['item_title'];
    this.Item_type = map['item_type'];
    this.Picture = map['picture'];
    this.Product_id = map['product_id'];
    this.Status = map['status'];
    this.Sub_category = map['sub_category'];
    this.Sub_category_id = map['sub_category_id'];
    this.User_id = map['user_id'];

  }
}