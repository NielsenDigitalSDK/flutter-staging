import 'package:flutter/foundation.dart';
import 'channel_info.dart';
import 'ad.dart';
import 'channel_metadata.dart';

@immutable
class Channel {
  final String? url;
  final String? breakout;
  final ChannelInfo? channelInfo;
  final ChannelMetadata? metadata; // Used for video title in UI
  final List<Ad>? ads;

  const Channel({
    this.url,
    this.breakout,
    this.channelInfo,
    this.metadata,
    this.ads,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      url: json['url'] as String?,
      breakout: json['breakout'] as String?,
      channelInfo: json['channelInfo'] != null
          ? ChannelInfo.fromJson(json['channelInfo'] as Map<String, dynamic>)
          : null,
      metadata: json['metadata'] != null
          ? ChannelMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
      ads: (json['ads'] as List<dynamic>?)
          ?.map((adJson) => Ad.fromJson(adJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'breakout': breakout,
      'channelInfo': channelInfo?.toJson(), // Assuming Info has a toJson() method
      'metadata': metadata?.toJson(), // Assuming ChannelMetadata has a toJson() method
      'ads': ads?.map((ad) => ad.toJson()).toList(), // Assuming Ad has a toJson() method
    };
  }

}