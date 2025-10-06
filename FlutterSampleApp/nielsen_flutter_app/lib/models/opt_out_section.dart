// models/opt_out_section.dart
import 'package:flutter/foundation.dart';
import 'static_metadata.dart';

@immutable
class OptOutSection {
  final StaticMetadata? metadata;

  const OptOutSection({
    this.metadata,
  });

  factory OptOutSection.fromJson(Map<String, dynamic> json) {
    return OptOutSection(
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