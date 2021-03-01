import 'package:meta/meta.dart';

class Open_Sale {
  int id;
  String name;
  String category;
  DateTime releaseDate;
  DateTime releaseDateDesc;
  String directors;
  String runtime;
  String desc;
  double rating;
  String imageUrl;
  String bannerUrl;
  String trailerImg1;
  String trailerImg2;
  String trailerImg3;
  String price;

  Open_Sale({this.id, this.name, this.category, this.releaseDate,
      this.releaseDateDesc, this.directors, this.runtime, this.desc,
      this.rating, this.imageUrl, this.bannerUrl, this.trailerImg1,
      this.trailerImg2, this.trailerImg3, this.price});

  factory Open_Sale.fromJson(Map<String, dynamic> json) {
    return Open_Sale(
      id: json['id'] as int,
      name: json['title'] as String,
      imageUrl: json['thumbnailUrl'] as String,
    );
  }

}
