// models/ad_metadata.dart
import 'package:flutter/foundation.dart';

@immutable
class AdMetadata {
  final String? assetid;
  final String? type;
  final String? title;

  const AdMetadata({
    this.assetid,
    this.type,
    this.title,
  });

  factory AdMetadata.fromJson(Map<String, dynamic> json) {
    return AdMetadata(
      assetid: json['assetid'] as String?,
      type: json['type'] as String?,
      title: json['title'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assetid': assetid,
      'type': type,
      'title': title,
    };
  }

}