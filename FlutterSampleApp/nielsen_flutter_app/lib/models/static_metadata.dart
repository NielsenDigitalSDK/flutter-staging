// models/static_metadata.dart
import 'package:flutter/foundation.dart';

@immutable
class StaticMetadata {
  final String? type;
  final String? section;
  final String? segA;
  final String? segB;
  final String? segC;
  final String? adobeId;
  final String? reportSuite;
  final String? crossId1;

  const StaticMetadata({
    this.type,
    this.section,
    this.segA,
    this.segB,
    this.segC,
    this.adobeId,
    this.reportSuite,
    this.crossId1,
  });

  // Constructor for creating default instances if needed
  const StaticMetadata.empty()
      : type = null,
        section = null,
        segA = null,
        segB = null,
        segC = null,
        adobeId = null,
        reportSuite = null,
        crossId1 = null;


  factory StaticMetadata.fromJson(Map<String, dynamic> json) {
    return StaticMetadata(
      type: json['type'] as String?,
      section: json['section'] as String?,
      segA: json['segA'] as String?,
      segB: json['segB'] as String?,
      segC: json['segC'] as String?,
      adobeId: json['adobeId'] as String?,
      reportSuite: json['reportSuite'] as String?,
      crossId1: json['crossId1'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'section': section,
      'segA': segA,
      'segB': segB,
      'segC': segC,
      'adobeId': adobeId,
      'reportSuite': reportSuite,
      'crossId1': crossId1,
    };
  }
}