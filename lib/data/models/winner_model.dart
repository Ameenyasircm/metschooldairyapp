import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class WinnerModel {
  final String name;
  final String aggregate;
  final String tag;
  final String imageUrl;
  final Color badgeColor;

  WinnerModel({
    required this.name,
    required this.aggregate,
    required this.tag,
    required this.imageUrl,
    required this.badgeColor,
  });

  factory WinnerModel.fromJson(Map<String, dynamic> json) {
    return WinnerModel(
      name: json['name'] ?? '',
      aggregate: json['aggregate'] ?? '',
      tag: json['tag'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      // Parsing the hex string from your Node.js script
      badgeColor: Color(int.parse(json['badgeColor'] ?? "0xff00796B")),
    );
  }
}

class SchoolEvent {
  final String title;
  final String location;
  final String time;
  final String day;   // e.g., "24"
  final String month; // e.g., "SEP"

  SchoolEvent({
    required this.title,
    required this.location,
    required this.time,
    required this.day,
    required this.month,
  });

  // For easy mapping if you get data from a backend later
  factory SchoolEvent.fromJson(Map<String, dynamic> json) {
    return SchoolEvent(
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      time: json['time'] ?? '',
      day: json['day'] ?? '',
      month: json['month'] ?? '',
    );
  }
}