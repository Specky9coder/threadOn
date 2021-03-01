class BrandModel{
  String Id;
  String Brand_name;
  String Status;


  BrandModel(this.Id, this.Brand_name, this.Status);

  BrandModel.map(dynamic obj) {
    this.Id = obj['id'];
    this.Brand_name = obj['brand_name'];
    this.Status = obj['status'];
    }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (Id != null) {
      map['id'] = Id;
    }
    map['brand_name'] = Brand_name;
    map['status'] = Status;

    return map;
  }

  BrandModel.fromMap(Map<String, dynamic> map) {
    this.Id = map['id'];
    this.Brand_name = map['brand_name'];
    this.Status = map['status'];

  }
}
