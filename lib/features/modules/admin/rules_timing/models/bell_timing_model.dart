class BellTimingModel {
  String title;
  String time;

  BellTimingModel({required this.title, required this.time});

  Map<String, dynamic> toMap() => {
    "title": title,
    "time": time,
  };

  factory BellTimingModel.fromMap(Map<String, dynamic> map) {
    return BellTimingModel(
      title: map['title'] ?? '',
      time: map['time'] ?? '',
    );
  }
}