import 'package:flutter/foundation.dart';

@immutable
class ChannelInfo {
  final String? channelName;
  final String? adModel;
  final String? dataSrc;

  const ChannelInfo({
    this.channelName,
    this.adModel,
    this.dataSrc,
  });

  factory ChannelInfo.fromJson(Map<String, dynamic> json) {
    return ChannelInfo(
      channelName: json['channelName'] as String?,
      adModel: json['adModel'] as String?,
      dataSrc: json['dataSrc'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'channelName': channelName,
      'adModel': adModel,
      'dataSrc': dataSrc,
    };
  }

}
