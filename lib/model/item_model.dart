class ItemModel{
  DateTime date;
  String item_description;
  String item_id;
  String item_name;
  String item_picture;
  String item_price;
  String item_rating;
  String item_status;
  String item_type;
  String shop_id;


  ItemModel(this.date, this.item_description, this.item_id, this.item_name,
      this.item_picture, this.item_price, this.item_rating, this.item_status,
      this.item_type, this.shop_id);

  ItemModel.map(dynamic obj) {
    this.date = obj['date'];
    this.item_description = obj['item_description'];
    this.item_id = obj['item_id'];
    this.item_name = obj['item_name'];
    this.item_picture = obj['item_picture'];
    this.item_price = obj['item_price'];
    this.item_rating = obj['item_rating'];
    this.item_status = obj['item_status'];
    this.item_type = obj['item_type'];
    this.shop_id = obj['shop_id'];
    }


  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (item_id != null) {
      map['item_id'] = item_id;
    }
    map['date'] = date;
    map['item_description'] = item_description;
    map['item_name'] = item_name;
    map['item_picture'] = item_picture;
    map['item_price'] = item_price;
    map['item_rating'] = item_rating;
    map['item_status'] = item_status;
    map['item_type'] = item_type;
    map['shop_id'] = shop_id;

    return map;
  }

  ItemModel.fromMap(Map<String, dynamic> map) {
    this.date = map['date'];
    this.item_description = map['item_description'];
    this.item_id = map['item_id'];
    this.item_name = map['item_name'];
    this.item_picture = map['item_picture'];
    this.item_price = map['item_price'];
    this.item_rating = map['item_rating'];
    this.item_status = map['item_status'];
    this.item_type = map['item_type'];
    this.shop_id = map['shop_id'];


  }
}
