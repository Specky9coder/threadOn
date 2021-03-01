
class Editor_Model{


  DateTime date;
  String editor_id;
  String editor_name;
  String featured_image;
  List product_id;
  String status;

  Editor_Model(this.date, this.editor_id, this.editor_name, this.featured_image,
      this.product_id, this.status);

  Editor_Model.map(dynamic obj) {
    this.date = obj['date'];
    this.editor_id = obj['editor_id'];
    this.editor_name = obj['editor_name'];
    this.featured_image = obj['featured_image'];
    this.product_id = obj['product_id'];
    this.status = obj['status'];
  }


  DateTime get _date => date;
  String get _editor_id => editor_id;
  String get _seditor_name => editor_name ;
  String get _featured_image => featured_image;
  List get _product_id => product_id.toList();
  String get _status => status;



  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (editor_id != null) {
      map['_editor_id'] = _editor_id;
    }
    map['date'] = date;
    map['editor_name'] = editor_name;
    map['featured_image'] = featured_image;
    map['product_id'] = product_id.toList();
    map['status'] = status;

    return map;
  }

  Editor_Model.fromMap(Map<String, dynamic> map) {
    this.editor_id = map['cart_id'];
    this.date = map['date'];
    this.editor_name = map['editor_name'];
    this.featured_image = map['featured_image'];
    this.product_id =new List<String>.from( map['product_id']);

    this.status = map['status'];
  }



}