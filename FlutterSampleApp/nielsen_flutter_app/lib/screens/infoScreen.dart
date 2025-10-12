import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nielsen_flutter_app/models/static_metadata.dart';
import 'package:nielsen_flutter_app/screens/opt_out_webview.dart';
import 'package:nielsen_flutter_app/screens/video_player_screen.dart';
import 'package:nielsen_flutter_plugin/nielsen_flutter_plugin.dart';

String currentScreen = '';

// A StatefulWidget is a widget that can change its state.
// It's made up of two classes:
// 1. The StatefulWidget class itself.
// 2. The State class.
class Infoscreen extends StatefulWidget {
  final NielsenFlutterPlugin nielsen;
  final StaticMetadata optoutData;
  final String static_sdk_id;
  const Infoscreen({
    super.key,
    required this.nielsen,
    required this.optoutData,
    required this.static_sdk_id,
  });

  // Creates the mutable state for this widget.
  // This method is called exactly once in the lifetime of the widget.
  @override
  State<Infoscreen> createState() => _MyInfoWidgetState();
}

class _MyInfoWidgetState extends State<Infoscreen> with WidgetsBindingObserver {
  String? demographicId;
  String? optOutStatus;
  String? meterVersion;
  String? optOutUrl;
  String? deviceId;
  String? fpid;
  String? vendorId;
  CurrentScreen? currentPage;
  NielsenFlutterPlugin? nielsen;
  String? sdk_id;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentScreen = CurrentScreen.info.toString();
    WidgetsBinding.instance.addObserver(this);
    nielsen = widget.nielsen;
    sdk_id = widget.static_sdk_id;
    _getInfoData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<void> _getInfoData() async {
    try {
      String? versionNumber = await nielsen?.getMeterVersion(sdk_id!);
      String? demoId = await nielsen?.getDemographicId(sdk_id!);
      String? devId = await nielsen?.getDeviceId(sdk_id!);
      String? optout = await nielsen?.getOptOutStatus(sdk_id!);
      String? optoutUrl = await nielsen?.userOptOutURLString(sdk_id!);
      String? _fpid = await nielsen?.getFpId(sdk_id!);
      String? _vendorId = await nielsen?.getVendorId(sdk_id!);
      // Update the state with the result from the native platform.
      setState(() {
        meterVersion = versionNumber.toString();
        demographicId = demoId.toString();
        optOutStatus = optout.toString();
        optOutUrl = optoutUrl.toString();
        deviceId = devId!.isEmpty ? 'N/A' : devId.toString();
        fpid = _fpid.toString();
        vendorId = _vendorId.toString();
      });
    } on PlatformException catch (e) {
      print("Failed to send data: '${e.message}'.");
    }

    final staticMetadata = widget.optoutData.toJson();
    await nielsen?.loadMetadata(sdk_id ?? "", staticMetadata);

    Map<String, dynamic> updateOTT = {'ottStatus': '0', 'ottType': 'Casting'};
    await nielsen?.updateOTT(sdk_id!, updateOTT);

    await nielsen?.sendID3(
      sdk_id!,
      "www.nielsen.com/X100zdCIGeIlgZnkYj6UvQ==/UvQ9HSNOcTOL2ZobsXtIBQ==/AAkCZvkGtK-TRiT2J14KRFYkkNt1qeRsNw-c-3m6gUe_8Zz1koxbv3A3WAVVRN2m7k1lEPRm2qfT2w-RyfjQyF_lBFs3SAxJbLUGzBr0B_YlYvlFSj4_MhKzIFhaSy7AZSmRbvsH4VTbfTWyGmEHmUrfA1s1I01bNSNVNuQ=/00000/39675/00",
    );
    await nielsen?.sendID3(
      sdk_id!,
      "www.nielsen.com/X100zdCIGeIlgZnkYj6UvQ==/UvQ9HSNOcTOL2ZobsXtIBQ==/AAkCZvkGtK-TRiT2J14KRFYkkNt1qeRsNw-c-3m6gUe_8Zz1koxbv3A3WAVVRN2m7k1lEPRm2qfT2w-RyfjQyF_lBFs3SAxJbLUGzBr0B_YlYvlFSj4_MhKzIFhaSy7AZSmRbvsH4VTbfTWyGmEHmUrfA1s1I01bNSNVNuQ=/49695/39685/00",
    );
  }

  _launchURL() async {
    if (optOutUrl != null && optOutUrl!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => OptOutWebView(
                nielsen: nielsen!,
                sdkId: sdk_id!,
                optOutUrl: optOutUrl!,
              ),
        ),
      );
    } else {
      // Handle the case where the URL is not available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opt-out URL not available.')),
      );
    }
  }

  @override
  // The `build()` method is called every time the UI needs to be updated.
  // It describes the part of the user interface represented by this widget.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Sample Player Info'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, CurrentScreen.home);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                'SDK Version: $meterVersion',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                'Demo Id: $demographicId',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                'Device Id: $deviceId',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                'Optout Status: $optOutStatus',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text('FPID Id: $fpid', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                'Vendor Id: $vendorId',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: _launchURL,
                child: Text('Optout'),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await nielsen?.staticEnd(sdk_id ?? "");
                },
                child: Text('Static End'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
