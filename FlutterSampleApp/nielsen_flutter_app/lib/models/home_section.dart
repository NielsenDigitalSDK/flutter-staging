// models/home_section.dart
import 'package:flutter/foundation.dart';
import 'static_metadata.dart';

@immutable
class HomeSection {
  final StaticMetadata? metadata;

  const HomeSection({
    this.metadata,
  });

  factory HomeSection.fromJson(Map<String, dynamic> json) {
    return HomeSection(
      metadata: json['metadata'] != null
          ? StaticMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metadata': metadata?.toJson(), // Assuming Section has a toJson() method
    };
  }

}