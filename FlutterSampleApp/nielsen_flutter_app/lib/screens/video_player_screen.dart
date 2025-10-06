import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:nielsen_flutter_app/screens/infoScreen.dart';
import 'dart:io' show Platform;
import 'package:nielsen_flutter_app/models/app_config.dart';
import 'package:nielsen_flutter_app/models/home_section.dart';
import 'package:nielsen_flutter_app/models/opt_out_section.dart';
import 'package:nielsen_flutter_app/models/static_data.dart';
import 'package:nielsen_flutter_app/models/static_metadata.dart';

import 'package:video_player/video_player.dart';
import 'package:nielsen_flutter_plugin/nielsen_flutter_plugin.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with WidgetsBindingObserver {
  // Singleton instance of the Nielsen plugin
  final nielsen = NielsenFlutterPlugin.instance;
  String? sdk_id;
  String? static_sdk_id;
  String? dtvr_sdk_id;

  AppConfig? _appConfig; // Uses your AppConfig model
  int _currentVideoIndex = 0;
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _mediaControlsVisible = false;
  Timer? _controlsTimer;

  bool _isScrubbing =
      false; // To know if the user is currently dragging the seek bar
  double _scrubToPosition =
      0.0; // To store the temporary position while scrubbing
  bool _wasPlayingBeforeScrub =
      false; // To remember play state before scrubbing
  Timer? _timer;
  StaticMetadata? optoutMetadata;
  StaticMetadata? homeMetadata;
  static const EventChannel _channel = EventChannel('id3_timed_metadata');

  var appInfo =
      (Platform.isAndroid)
          ? {
            "appid": "P35BCE6CE-3D2B-440E-A313-85B01587000F",
            "nol_devDebug": "DEBUG",
            "uid2": "MTKVpUAzwYAPnHrtfE0wlINOMzhU7UUEjjVdCdRu63k=",
            "uid2_token":
                "AgAAAAPFR0zA5ogv/yaAPiUsAdZPsfqS8QlDSGxAB+rr8yekFs3AjLYVk5qqqiyV2XHbSuwzHmxSlLeQeKQI1mp015jsNnpX5/xGgXldcgVz+gFnyh3T8/3agMwRmyrhCxG4oH2C7fc48AQk2eotE7FW0ZDEYM8fD9ZxDaxFUC/OV3OuZA==",
            "hem_sha256":
                "0d27635fc9ca53b6aec32fbfb67d84c0c148857a74399f2ba0a21d8413db74ea",
            "hem_sha1": "FA92088EB2E94C2B71B98C423DA3C0B1F10AA211",
            "hem_md5": "D5F252F907B95001D7BAB577AE1A514C",
            "hem_unknown": "unknown",
          }
          : {
            "appid": "PD8B6BE43-2128-44B1-AC90-FE03B565ADCF",
            "nol_devDebug": "DEBUG",
            "uid2": "MTKVpUAzwYAPnHrtfE0wlINOMzhU7UUEjjVdCdRu63k=",
            "uid2_token":
                "AgAAAAPFR0zA5ogv/yaAPiUsAdZPsfqS8QlDSGxAB+rr8yekFs3AjLYVk5qqqiyV2XHbSuwzHmxSlLeQeKQI1mp015jsNnpX5/xGgXldcgVz+gFnyh3T8/3agMwRmyrhCxG4oH2C7fc48AQk2eotE7FW0ZDEYM8fD9ZxDaxFUC/OV3OuZA==",
            "hem_sha256":
                "0d27635fc9ca53b6aec32fbfb67d84c0c148857a74399f2ba0a21d8413db74ea",
            "hem_sha1": "FA92088EB2E94C2B71B98C423DA3C0B1F10AA211",
            "hem_md5": "D5F252F907B95001D7BAB577AE1A514C",
            "hem_unknown": "unknown",
          };

  var staticAppInfo =
      (Platform.isAndroid)
          ? {
            "appid": "PFFD0B0C5-01DA-4EA2-99CB-C0F7577FAC76",
            "nol_devDebug": "DEBUG",
            "uid2": "MTKVpUAzwYAPnHrtfE0wlINOMzhU7UUEjjVdCdRu63k=",
            "uid2_token":
                "AgAAAAPFR0zA5ogv/yaAPiUsAdZPsfqS8QlDSGxAB+rr8yekFs3AjLYVk5qqqiyV2XHbSuwzHmxSlLeQeKQI1mp015jsNnpX5/xGgXldcgVz+gFnyh3T8/3agMwRmyrhCxG4oH2C7fc48AQk2eotE7FW0ZDEYM8fD9ZxDaxFUC/OV3OuZA==",
            "hem_sha256":
                "0d27635fc9ca53b6aec32fbfb67d84c0c148857a74399f2ba0a21d8413db74ea",
            "hem_sha1": "FA92088EB2E94C2B71B98C423DA3C0B1F10AA211",
            "hem_md5": "D5F252F907B95001D7BAB577AE1A514C",
            "hem_unknown": "unknown",
          }
          : {
            "appid": "PC50B2802-E640-4FA6-AA49-2397AB06650A",
            "nol_devDebug": "DEBUG",
            "uid2": "MTKVpUAzwYAPnHrtfE0wlINOMzhU7UUEjjVdCdRu63k=",
            "uid2_token":
                "AgAAAAPFR0zA5ogv/yaAPiUsAdZPsfqS8QlDSGxAB+rr8yekFs3AjLYVk5qqqiyV2XHbSuwzHmxSlLeQeKQI1mp015jsNnpX5/xGgXldcgVz+gFnyh3T8/3agMwRmyrhCxG4oH2C7fc48AQk2eotE7FW0ZDEYM8fD9ZxDaxFUC/OV3OuZA==",
            "hem_sha256":
                "0d27635fc9ca53b6aec32fbfb67d84c0c148857a74399f2ba0a21d8413db74ea",
            "hem_sha1": "FA92088EB2E94C2B71B98C423DA3C0B1F10AA211",
            "hem_md5": "D5F252F907B95001D7BAB577AE1A514C",
            "hem_unknown": "unknown",
          };

  @override
  initState() {
    super.initState();
    // Enable Nielsen SDK for debugging
    nielsen.enableDebugLogs(true);
    currentScreen = CurrentScreen.home.toString();
    // currentPage = CurrentScreen.home;
    WidgetsBinding.instance.addObserver(this);
    _controller = VideoPlayerController.networkUrl(
      Uri.parse("http://dummyurl.com"),
    );
    _initializeVideoPlayerFuture = Completer<void>().future;
    _loadAppConfig();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        homeMetadata = _appConfig?.staticData?.home?.metadata;
        optoutMetadata = _appConfig?.staticData?.optout?.metadata;
        var metadata =
            currentScreen == CurrentScreen.home.toString()
                ? homeMetadata
                : optoutMetadata;

        await nielsen.loadMetadata(
          static_sdk_id ?? "",
          metadata?.toJson() ?? {},
        );
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        if (_controller.value.isPlaying) {
          _controller.pause();
        }
        handleStopOnPause(sdk_id ?? "");

        await nielsen.staticEnd(static_sdk_id ?? "");
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controlsTimer?.cancel();
    _controller.removeListener(_videoListener);
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _loadAppConfig() async {
    try {
      String jsonString = await DefaultAssetBundle.of(
        context,
      ).loadString('assets/appConfig.json');
      final jsonResponse = json.decode(jsonString);
      if (mounted) {
        _appConfig = AppConfig.fromJson(jsonResponse);
        if (_appConfig!.channels.isNotEmpty) {
          if (static_sdk_id == null) {
            String? sdkId = await nielsen.createInstance(staticAppInfo);
            static_sdk_id = sdkId;
          }

          await Future.delayed(const Duration(seconds: 2));
          homeMetadata = _appConfig?.staticData?.home?.metadata;
          optoutMetadata = _appConfig?.staticData?.optout?.metadata;
          await nielsen.loadMetadata(
            static_sdk_id ?? "",
            homeMetadata?.toJson() ?? {},
          );

          sdk_id ??= await nielsen.createInstance(appInfo);
          await Future.delayed(const Duration(seconds: 2));
          _playVideo(_currentVideoIndex, isInitialLoad: true);
        } else {
          _initializeVideoPlayerFuture = Future.value();
        }
      }
    } catch (e) {
      print("Error loading appConfig.json: $e");
      if (mounted) {
        setState(() {
          _appConfig = AppConfig(
            channels: [], // No channels loaded
            staticData: const StaticData(
              // 1. Corrected: Used 'staticData:' instead of 'static:'
              home: HomeSection(
                // 2. Corrected: Explicitly use 'StaticMetadata.empty()'
                // This resolves the ambiguity and uses a const constructor.
                metadata: StaticMetadata.empty(),
              ),
              optout: OptOutSection(metadata: StaticMetadata.empty()),
            ),
          );
          _initializeVideoPlayerFuture =
              Future.value(); // Mark future as complete for empty state
        });
      }
    }
  }

  _playVideo(int index, {bool isInitialLoad = false}) async {
    if (!mounted || _appConfig == null || _appConfig!.channels.isEmpty) {
      _initializeVideoPlayerFuture = Future.value(); // Ensure future completes
      if (mounted) setState(() {});
      return;
    }

    if (index < 0 || index >= _appConfig!.channels.length) {
      print("Invalid video index: $index");
      _initializeVideoPlayerFuture = Future.value(); // Ensure future completes
      if (mounted) setState(() {});
      return;
    }

    if (!isInitialLoad && _controller.value.isInitialized) {
      _controller.removeListener(_videoListener);
      await _controller.dispose();
    }

    if (mounted) {
      setState(() {
        _currentVideoIndex = index;
        _mediaControlsVisible = false;
        _controlsTimer?.cancel();
        _stopTimer();
      });
    }

    // Assuming your Channel class has a 'url' property
    final channelUrl = _appConfig!.channels[index].url;
    if (channelUrl == null || channelUrl.isEmpty) {
      _initializeVideoPlayerFuture = Future.error("Invalid video URL");
      if (mounted) setState(() {});
      return;
    }

    _controller = VideoPlayerController.networkUrl(Uri.parse(channelUrl));
    _controller.addListener(_videoListener);

    _initializeVideoPlayerFuture = _controller
        .initialize()
        .then((_) async {
          if (!mounted) return;
          _controller.play();

          dtvr_sdk_id ??= await nielsen.createInstance(appInfo);
          Future.delayed(Duration(milliseconds: 500), () {
            var sendID3Data = {'url': channelUrl, 'sdkId': dtvr_sdk_id};
            _channel.receiveBroadcastStream(jsonEncode(sendID3Data)).listen((
              event,
            ) {
              if (event is Map) {
                setState(() {
                  print("broad cast event is $event");
                });
              }
            });
          });

          final channelInfo = _appConfig?.channels[index].channelInfo;
          final metadata = _appConfig?.channels[index].metadata;

          if (dtvr_sdk_id != null) {
            // play for dtvr
            await nielsen.play(dtvr_sdk_id!, channelInfo?.toJson() ?? {});
          }

          if (sdk_id != null) {
            // play for DCR
            await nielsen.play(sdk_id!, channelInfo?.toJson() ?? {});
            // loadmetadata for DCR
            await nielsen.loadMetadata(sdk_id!, metadata?.toJson() ?? {});
          }

          if (mounted) {
            setState(() {});
          }
        })
        .catchError((error) {
          print("Error initializing video: $error");
          _initializeVideoPlayerFuture = Future.error("failed to load video");
          if (mounted) setState(() {});
        });

    if (mounted) {
      setState(() {});
    }
  }

  void _videoListener() {
    if (!mounted) return;
    if (_controller.value.isPlaying) {
      _startTimer();
      _controller.removeListener(
        _videoListener,
      ); // Remove listener once playing
    } else if (!_controller.value.isPlaying && _timer?.isActive == true) {
      _stopTimer(); // Stop timer if video is paused or stopped
      _controller.addListener(_videoListener); // Listen again for play
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      if (_controller.value.isInitialized && _controller.value.isPlaying) {
        await nielsen.setPlayheadPosition(
          sdk_id ?? "",
          _controller.value.position.inSeconds,
        );
      } else if (_controller.value.isCompleted) {
        await nielsen.setPlayheadPosition(
          sdk_id ?? "",
          _controller.value.position.inSeconds,
        );

        await nielsen.end(sdk_id ?? "");

        // end for dtvr instance
        await nielsen.end(dtvr_sdk_id ?? "");

        _stopTimer();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _handleVideoTap() {
    if (!mounted) return;
    setState(() {
      _mediaControlsVisible = !_mediaControlsVisible;
    });
    if (_mediaControlsVisible) {
      _startControlsTimer();
    } else {
      _controlsTimer?.cancel();
    }
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(Duration(seconds: 2), () {
      if (mounted && _mediaControlsVisible) {
        setState(() {
          _mediaControlsVisible = false;
        });
      }
    });
  }

  void _handleMediaControlInteraction() {
    if (_mediaControlsVisible) {
      _startControlsTimer();
    }
  }

  Future<void> _playNextVideo() async {
    // end call for previous video
    _endCallForCurrentStream();

    if (_appConfig != null &&
        _currentVideoIndex < _appConfig!.channels.length - 1) {
      _playVideo(_currentVideoIndex + 1);
    }
    _handleMediaControlInteraction();
  }

  Future<void> _playPreviousVideo() async {
    // end call for previous video
    _endCallForCurrentStream();

    if (_currentVideoIndex > 0) {
      _playVideo(_currentVideoIndex - 1);
    }
    _handleMediaControlInteraction();
  }

  _endCallForCurrentStream() async {
    await nielsen.end(sdk_id ?? "");

    // end call for dtvr
    handleStopOnPause(dtvr_sdk_id ?? "");
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  // handle stop api
  handleStopOnPause(String sdkID) async {
    await nielsen.stop(sdkID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:
          _appConfig == null
              ? Center(child: CircularProgressIndicator(color: Colors.white))
              : SafeArea(
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    bool isLandscape = orientation == Orientation.landscape;

                    if (isLandscape) {
                      SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.immersiveSticky,
                      );
                      return _buildVideoPlayerArea();
                    } else {
                      SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.edgeToEdge,
                      );
                      return Column(
                        children: [
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.width *
                                (_controller.value.isInitialized &&
                                        _controller.value.aspectRatio > 0
                                    ? (1 / _controller.value.aspectRatio)
                                    : (9.0 / 16.0)),
                            width: MediaQuery.of(context).size.width,
                            child: _buildVideoPlayerArea(),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                _buildHorizontalVideoList(),
                                _buildVideoDescription(),
                              ],
                            ),
                          ),
                          _buildPortraitControls(),
                        ],
                      );
                    }
                  },
                ),
              ),
    );
  }

  Widget _buildVideoPlayerArea() {
    return FutureBuilder<void>(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _controller.value.isInitialized) {
          return GestureDetector(
            onTap: _handleVideoTap,
            child: Container(
              color: Colors.transparent,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  _buildMediaControls(),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildSeekBar(),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading video: ${snapshot.error}",
              style: TextStyle(color: Colors.red),
            ),
          );
        } else if (_appConfig!.channels.isEmpty &&
            snapshot.connectionState == ConnectionState.done) {
          return Center(
            child: Text(
              "No videos available.",
              style: TextStyle(color: Colors.white),
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator(color: Colors.white));
        }
      },
    );
  }

  Widget _buildMediaControls() {
    if (!_controller.value.isInitialized) {
      return SizedBox.shrink();
    }
    bool isFirstVideo = _currentVideoIndex == 0;
    bool isLastVideo =
        _appConfig == null ||
        _appConfig!.channels.isEmpty ||
        _currentVideoIndex == _appConfig!.channels.length - 1;

    return AnimatedOpacity(
      opacity: _mediaControlsVisible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
      child: AbsorbPointer(
        absorbing: !_mediaControlsVisible,
        child: Container(
          color: Colors.black.withOpacity(0.4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.skip_previous,
                  color: isFirstVideo ? Colors.grey : Colors.white,
                ),
                onPressed: isFirstVideo ? null : _playPreviousVideo,
              ),
              IconButton(
                icon: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 40.0,
                ),
                onPressed: () async {
                  _handleMediaControlInteraction();

                  if (_controller.value.isPlaying) {
                    setState(() {
                      _controller.pause();
                    });
                    await handleStopOnPause(sdk_id ?? "");
                    await handleStopOnPause(dtvr_sdk_id ?? "");
                  } else {
                    setState(() {
                      _controller.play();
                    });
                    await nielsen.setPlayheadPosition(
                      sdk_id ?? "",
                      _controller.value.position.inSeconds,
                    );
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.skip_next,
                  color: isLastVideo ? Colors.grey : Colors.white,
                ),
                onPressed: isLastVideo ? null : _playNextVideo,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeekBar() {
    if (!_controller.value.isInitialized ||
        _controller.value.duration == Duration.zero) {
      return SizedBox.shrink();
    }

    double currentValue =
        _isScrubbing
            ? _scrubToPosition
            : _controller.value.position.inMilliseconds.toDouble();

    double maxDuration = _controller.value.duration.inMilliseconds.toDouble();
    if (maxDuration <= 0) {
      // handles cases where duration might be invalid
      maxDuration =
          currentValue > 0
              ? currentValue
              : 1.0; // Avoid division by zero or negative max
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      color: Colors.black.withOpacity(0.3),
      child: Row(
        children: <Widget>[
          Text(
            _formatDuration(
              _isScrubbing
                  ? Duration(milliseconds: _scrubToPosition.toInt())
                  : _controller.value.position,
            ),
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2.0,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 12.0),
                activeTrackColor: Colors.red,
                inactiveTrackColor: Colors.white38,
                thumbColor: Colors.red,
              ),
              child: Slider(
                value: currentValue.clamp(0.0, maxDuration),
                min: 0.0,
                max: maxDuration,
                onChangeStart: (double value) {
                  if (!_controller.value.isInitialized) return;
                  setState(() {
                    _isScrubbing = true;
                    // Initialize _scrubToPosition with current slider value (which is video position)
                    _scrubToPosition =
                        _controller.value.position.inMilliseconds.toDouble();
                    _wasPlayingBeforeScrub = _controller.value.isPlaying;
                    if (_wasPlayingBeforeScrub) {
                      _controller.pause();
                    }
                  });
                  _handleMediaControlInteraction(); // Keep controls visible
                },
                onChanged: (double value) {
                  if (!_controller.value.isInitialized) return;
                  // While dragging, only update the temporary scrub position.
                  // This makes the slider thumb follow the finger smoothly.
                  setState(() {
                    _scrubToPosition = value;
                  });
                  _handleMediaControlInteraction();
                },
                onChangeEnd: (double value) {
                  if (!_controller.value.isInitialized) return;
                  // When dragging ends, perform the actual seek.
                  _controller.seekTo(
                    Duration(milliseconds: value.toInt()),
                  ); // Use the final value from slider

                  // It's important to wait a moment for seekTo to process
                  // before attempting to play, especially for network streams.
                  Future.delayed(Duration(milliseconds: 100), () {
                    if (mounted && _wasPlayingBeforeScrub) {
                      _controller.play();
                    }
                  });

                  // Reset scrubbing state after a short delay to allow UI to settle
                  Future.delayed(Duration(milliseconds: 200), () {
                    if (mounted) {
                      setState(() {
                        _isScrubbing = false;
                      });
                    }
                  });
                  _handleMediaControlInteraction();
                },
              ),
            ),
          ),
          Text(
            _formatDuration(_controller.value.duration),
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalVideoList() {
    if (_appConfig == null || _appConfig!.channels.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "No videos to display in list.",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return Container(
      height: 150,
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _appConfig!.channels.length,
        itemBuilder: (context, index) {
          final channel = _appConfig!.channels[index]; // Type: Channel
          String thumbnailUrl =
              'https://via.placeholder.com/150/000000/FFFFFF/?text=Video+${index + 1}';

          return GestureDetector(
            onTap: () => _playVideo(index),
            child: Container(
              width: 150,
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color:
                      _currentVideoIndex == index
                          ? Colors.blueAccent
                          : Colors.transparent,
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(8.0),
                      ),
                      child: Image.network(
                        thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: Center(
                              child: Icon(
                                Icons.movie_creation_outlined,
                                color: Colors.white70,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        // Assuming Channel has .metadata and Metadata has .title
                        // Ensure 'channel.metadata' and 'channel.metadata.title' are valid paths for your models
                        channel.metadata?.title ?? 'Video ${index + 1}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoDescription() {
    if (_appConfig == null ||
        _appConfig!.channels.isEmpty ||
        _currentVideoIndex >= _appConfig!.channels.length) {
      return SizedBox.shrink();
    }
    final currentChannel =
        _appConfig!.channels[_currentVideoIndex]; // Type: Channel
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        // Assuming Channel has .metadata and Metadata has .title
        currentChannel.metadata?.title ?? 'No Title',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPortraitControls() {
    return Container(
      color: Colors.blueGrey[900],
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
            onPressed: () async {
              await nielsen.loadMetadata(
                static_sdk_id ?? "",
                homeMetadata?.toJson() ?? {},
              );
            },
            child: Text('Static Reload', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              await nielsen.staticEnd(static_sdk_id ?? "");
            },
            child: Text('StaticEnd', style: TextStyle(color: Colors.white)),
          ),
          _controller.value.isInitialized
              ? TextButton(
                onPressed: () {
                  setState(() {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                      handleStopOnPause(sdk_id ?? "");

                      // handle dtvr pause
                      handleStopOnPause(dtvr_sdk_id ?? "");
                    }
                  });
                  if (mounted &&
                      optoutMetadata != null &&
                      static_sdk_id != null) {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder:
                                (context) => Infoscreen(
                                  nielsen: nielsen,
                                  optoutData: optoutMetadata!,
                                  static_sdk_id: static_sdk_id!,
                                ),
                          ),
                        )
                        .then((screen) async {
                          currentScreen = screen.toString();
                          print("current screen is $currentScreen");

                          await nielsen.loadMetadata(
                            static_sdk_id ?? "",
                            homeMetadata?.toJson() ?? {},
                          );
                        });
                  }
                },
                child: Text('Info', style: TextStyle(color: Colors.white)),
              )
              : Container(),
        ],
      ),
    );
  }
}

enum CurrentScreen { home, info }
