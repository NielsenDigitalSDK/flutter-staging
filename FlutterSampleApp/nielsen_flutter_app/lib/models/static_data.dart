// models/static_data.dart
import 'package:flutter/foundation.dart';
import 'home_section.dart';
import 'opt_out_section.dart';

@immutable
class StaticData {
  final HomeSection? home;
  final OptOutSection? optout;

  const StaticData({
    this.home,
    this.optout,
  });

  factory StaticData.fromJson(Map<String, dynamic> json) {
    return StaticData(
      home: json['home'] != null
          ? HomeSection.fromJson(json['home'] as Map<String, dynamic>)
          : null,
      optout: json['optout'] != null
          ? OptOutSection.fromJson(json['optout'] as Map<String, dynamic>)
          : null,
    );
  }

   Map<String, dynamic> toJson() {
    return {
      'home': home?.toJson(), // Assuming Section has a toJson() method
      'optout': optout?.toJson(), // Assuming Section has a toJson() method
    };
  }
}