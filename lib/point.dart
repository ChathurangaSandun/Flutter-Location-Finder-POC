class Point{
  double latitude;
  double longitude;

  Point({this.latitude, this.longitude});

   factory Point.fromJson(Map<String, dynamic> json){
    return new Point(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

}