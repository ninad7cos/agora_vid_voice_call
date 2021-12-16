import 'dart:developer';
import 'package:flutter/material.dart';
import '../utils/AppID.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:lottie/lottie.dart';

class CallPage extends StatefulWidget {
  final String channelName;
  final String callType;
  final String token;
  final int id;
  const CallPage(
      {Key? key,
      required this.channelName,
      required this.callType,
      required this.token,
      required this.id})
      : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  RtcEngine? _engine;

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
  }

  Future<void> initialize() async {
    if (appID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }
    if (widget.callType == 'video') {
      log("video", name: "CALL TYPE");
      await _initAgoraRtcEngineV();
    }
    if (widget.callType == 'broadcast') {
      log("broadcast", name: "CALL TYPE");
      await _initAgoraRtcEngineB();
    } else if (widget.callType == 'audio') {
      log("audio", name: "CALL TYPE");
      await _initAgoraRtcEngineA();
    }
    _addAgoraEventHandlers();
    // await _engine.enableWebSdkInteroperability(true);
    await _engine!.joinChannel(widget.token, widget.channelName, null,
        widget.id); //-----------------JoinChannel
  }

  ///Video
  Future<void> _initAgoraRtcEngineV() async {
    _engine = await RtcEngine.create(appID);
    await _engine!.enableVideo();
    await _engine!.enableAudio();
    await _engine!.adjustAudioMixingPlayoutVolume(100);
  }

  ///Video Broadcasting
  Future<void> _initAgoraRtcEngineB() async {
    _engine = await RtcEngine.create(appID);
    await _engine!.enableVideo();
    await _engine!.setChannelProfile(ChannelProfile
        .LiveBroadcasting); //------------------------for Live Broadcasting
    await _engine!.setClientRole(ClientRole.Broadcaster);
    await _engine!.adjustAudioMixingPlayoutVolume(100);
  }

  ///Audio
  Future<void> _initAgoraRtcEngineA() async {
    _engine = await RtcEngine.create(appID); //----------------------Create
    await _engine!.disableVideo();
    await _engine!.enableAudio();
    await _engine!.adjustAudioMixingPlayoutVolume(100);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine!.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        setState(() {
          log("_____________-----------ERROR-------------_____________$code");
          final info = 'onError: $code';
          _infoStrings.add(info);
        });
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          log("_____________-----------joinChannelSuccess-------------_____________");
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
        });
      },
      leaveChannel: (stats) {
        setState(() {
          _infoStrings.add('onLeaveChannel');
          _users.clear();
        });
      },
      userJoined: (uid, elapsed) {
        setState(() {
          final info = 'userJoined: $uid';
          _infoStrings.add(info);
          _users.add(uid);
          log("_____________-----------userJoined-------------_____________");
          print(uid);
        });
      },
      userOffline: (uid, reason) {
        setState(() {
          final info = 'userOffline: $uid , reason: $reason';
          log("_____________-----------userOffline-------------_____________");
          _infoStrings.add(info);
          _users.remove(uid);
        });
      },
      firstRemoteVideoFrame: (uid, width, height, elapsed) {
        setState(() {
          final info = 'firstRemoteVideoFrame: $uid';
          _infoStrings.add(info);
        });
      },
    ));
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Agora Group Video Calling'),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            widget.callType == 'audio'
                ? Center(
                    child: Container(
                      width: size.width,
                      height: size.height,
                      color: Colors.green[200],
                      child: Center(
                        child: Lottie.asset("assets/call.json",
                            height: size.height * 0.2),
                      ),
                    ),
                  )
                : widget.callType == 'video'
                    ? _viewRows()
                    : bViewRows(),
            _toolbar(),
          ],
        ),
      ),
    );
  }

  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    list.add(RtcLocalView.SurfaceView());
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  Widget bViewRows() {
    final views = _getRenderViews();
    return Container(child: views[0]);
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
          child: Column(
            children: <Widget>[
              _expandedVideoRow(views.sublist(0, 2)),
              _expandedVideoRow(views.sublist(2, 4))
            ],
          ),
        );
      default:
    }
    return Container();
  }

  void _onCallEnd(BuildContext context) {
    try {
      _users.clear();
      // destroy
      if (_engine != null) {
        _engine!.leaveChannel();
        _engine!.destroy();
      }
    } catch (e) {
      print("Error at onCallEnd----------------------------$e");
    }
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine!.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine!.switchCamera();
  }
}
