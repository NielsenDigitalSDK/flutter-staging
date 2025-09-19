import 'package:flutter/foundation.dart';
import 'ad_metadata.dart';

@immutable
class Ad {
  final String? url;
  final String? adtype;
  final String? duration;
  final AdMetadata? metadata;
  final String? start; // Specific to midroll

  const Ad({
    this.url,
    this.adtype,
    this.duration,
    this.metadata,
    this.start,
  });

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      url: json['url'] as String?,
      adtype: json['adtype'] as String?,
      duration: json['duration'] as String?,
      metadata: json['metadata'] != null
          ? AdMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
      start: json['start'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'adtype': adtype,
      'duration': duration,
      'metadata': metadata?.toJson(), // Assuming AdMetadata has a toJson() method
      'start': start,
    };
  }
}