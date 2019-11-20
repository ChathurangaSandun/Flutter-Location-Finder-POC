import 'package:fluttergooglemapsapp/point.dart';

class PositionModel {
  String markerId;
  Point point;
  String address;
  String name;
  String imageUrl;
  String mobileNumber;
  
  PositionModel(
      {this.markerId, this.point, this.address, this.imageUrl, this.name, this.mobileNumber});

  factory PositionModel.fromJson(Map<String, dynamic> json) {
    return PositionModel(
      markerId: json['markId'],
      point: Point.fromJson(json['point']),
      address: json['address'],
      imageUrl: json['imageUrl'],
      name: json['name'].toString(),
      mobileNumber:  json['mobileNumber'].toString(),
    );
  }
}
