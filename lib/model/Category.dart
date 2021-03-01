
class CategoryModel{

  String Cat_Name;
  String Cat_id;
  String Cat_image;
  int is_sub_category;
  List polybag;
  List premium_box;


  CategoryModel(this.Cat_Name, this.Cat_id, this.Cat_image,
      this.is_sub_category, this.polybag, this.premium_box);

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (Cat_id != null) {
      map['category_id'] = Cat_id;
    }
    map['category_name'] = Cat_Name;
    map['category_image'] = Cat_image;
    map['is_sub_category'] = is_sub_category;
    map['polybag'] = polybag;
    map['premium_box'] = premium_box;

    return map;
  }

  CategoryModel.fromMap(Map<String, dynamic> map) {
    this.Cat_id = map['category_id'];
    this.Cat_Name = map['category_name'];
    this.Cat_image = map['category_image'];
    this.is_sub_category = map['is_sub_category'];
    this.polybag =new List<String>.from(map['polybag']);
    this.premium_box = List<String>.from(map['premium_box']);
  }
}