import 'package:flutter/foundation.dart';

@immutable
class Metadata {
  final String? type;
  final String? assetid;
  final String? program;
  final String? title;
  final String? genre;
  final String? length;
  final String? segB;
  final String? segC;
  final String? adobeId;
  final String? reportSuite;
  final String? crossId1;
  final String? crossId2;
  final String? adloadtype;
  final String? programId;
  final String? tvStationId;

  const Metadata({
    required this.type,
    required this.assetid,
    required this.program,
    required this.title,
    required this.genre,
    required this.length,
    required this.segB,
    required this.segC,
    required this.adobeId,
    required this.reportSuite,
    required this.crossId1,
    required this.crossId2,
    required this.adloadtype,
    required this.programId,
    required this.tvStationId,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      type: json['type'],
      assetid: json['assetid'],
      program: json['program'],
      title: json['title'],
      genre: json['genre'],
      length: json['length'],
      segB: json['segB'],
      segC: json['segC'],
      adobeId: json['adobeId'],
      reportSuite: json['reportSuite'],
      crossId1: json['crossId1'],
      crossId2: json['crossId2'],
      adloadtype: json['adloadtype'],
      programId: json['programId'],
      tvStationId: json['tvStationId'],
    );
  }
}