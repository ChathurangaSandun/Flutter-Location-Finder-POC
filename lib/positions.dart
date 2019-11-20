import 'package:fluttergooglemapsapp/position.dart';

class Positions {
  final List<PositionModel> positionList;

  Positions({this.positionList});

  factory Positions.fromJson(List<dynamic> json) {
     //List<PositionModel> posisions = new List<PositionModel>();
    return new Positions(     
      positionList: json.map((i)=>PositionModel.fromJson(i)).toList()
    );
  }
}
