class Sub_CategoryModel{

  String Category_id;
  var Is_sub_category;
  var Is_sub_category_id;
  List polybag;
  List premium_box;
  String Sub_category_id;
  String Sub_category_image;
  String Sub_category_name;


  Sub_CategoryModel(this.Category_id, this.Is_sub_category,
      this.Is_sub_category_id, this.polybag, this.premium_box,
      this.Sub_category_id, this.Sub_category_image, this.Sub_category_name);


  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (Sub_category_id != null) {
      map['sub_category_id'] = Sub_category_id;
    }
    map['category_id'] = Category_id;
    map['sub_category_name'] = Sub_category_name;
    map['sub_category_image'] = Sub_category_image;
    map['is_sub_category_id'] = Is_sub_category_id;
    map['is_sub_category'] = Is_sub_category;
    map['polybag'] = polybag;
    map['premium_box'] = premium_box;

    return map;
  }



  Sub_CategoryModel.fromMap(Map<String, dynamic> map) {

    this.Category_id = map['category_id'];
    this.Is_sub_category = map['is_sub_category'];
    this.Is_sub_category_id = map['is_sub_category_id'];
    this.polybag = List<String>.from(map['polybag']);
    this.premium_box = List<String>.from(map['premium_box']);
    this.Sub_category_id = map['sub_category_id'];
    this.Sub_category_name = map['sub_category_name'];
    this.Sub_category_image = map['sub_category_image'];



  }
}