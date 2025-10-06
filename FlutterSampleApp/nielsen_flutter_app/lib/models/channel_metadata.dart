// models/channel_metadata.dart
import 'package:flutter/foundation.dart';

@immutable
class ChannelMetadata {
  final String? type;
  final String? assetid;
  final String? program;
  final String? title; // This is used for display in your video player
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

  const ChannelMetadata({
    this.type,
    this.assetid,
    this.program,
    this.title,
    this.genre,
    this.length,
    this.segB,
    this.segC,
    this.adobeId,
    this.reportSuite,
    this.crossId1,
    this.crossId2,
    this.adloadtype,
    this.programId,
    this.tvStationId,
  });

  factory ChannelMetadata.fromJson(Map<String, dynamic> json) {
    return ChannelMetadata(
      type: json['type'] as String?,
      assetid: json['assetid'] as String?,
      program: json['program'] as String?,
      title: json['title'] as String?,
      genre: json['genre'] as String?,
      length: json['length'] as String?,
      segB: json['segB'] as String?,
      segC: json['segC'] as String?,
      adobeId: json['adobeId'] as String?,
      reportSuite: json['reportSuite'] as String?,
      crossId1: json['crossId1'] as String?,
      crossId2: json['crossId2'] as String?,
      adloadtype: json['adloadtype'] as String?,
      programId: json['programId'] as String?,
      tvStationId: json['tvStationId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'assetid': assetid,
      'program': program,
      'title': title,
      'genre': genre,
      'length': length,
      'segB': segB,
      'segC': segC,
      'adobeId': adobeId,
      'reportSuite': reportSuite,
      'crossId1': crossId1,
      'crossId2': crossId2,
      'adloadtype': adloadtype,
      'programId': programId,
      'tvStationId': tvStationId,
    };
  }
}