import 'package:flutter/foundation.dart';
import 'channel.dart';

import 'static_data.dart';

@immutable
class AppConfig {
  final List<Channel> channels;
  final StaticData? staticData; // Renamed from 'static' to avoid keyword conflict

  const AppConfig({
    required this.channels,
    this.staticData,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      channels: (json['channels'] as List<dynamic>?)
          ?.map((channelJson) =>
          Channel.fromJson(channelJson as Map<String, dynamic>))
          .toList() ??
          [],
      staticData: json['static'] != null
          ? StaticData.fromJson(json['static'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'channels': channels.map((channel) => channel.toJson()).toList(),
      'static': staticData?.toJson(), // Assuming StaticData has a toJson() method
    };
  }

}
