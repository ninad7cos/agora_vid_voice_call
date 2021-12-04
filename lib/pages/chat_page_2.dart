import 'dart:developer';

import 'package:agora_rtm/agora_rtm.dart';
import 'package:agora_video_call/utils/AppID.dart';
import 'package:agora_video_call/utils/token_call.dart';
import 'package:flutter/material.dart';

class ChatPage2 extends StatefulWidget {
  const ChatPage2({Key? key}) : super(key: key);

  @override
  State<ChatPage2> createState() => _ChatPage2State();
}

class _ChatPage2State extends State<ChatPage2> {
  ApiCalls calls = ApiCalls();
  final TextEditingController chat = TextEditingController();
  TextEditingController channelTextField = TextEditingController();
  final TextEditingController id = TextEditingController();
  final TextEditingController peerId = TextEditingController();
  String rMessage = '';
  List<String> msgList = [];
  AgoraRtmClient? client;
  AgoraRtmChannel? channel;

  initializeClient()async{
    client = await AgoraRtmClient.createInstance(appID);
    client?.onMessageReceived = onMsgRec;
  }

  Future getToken()async{
    await calls.commonApiCallResponse(
        "RtmTokenBuilderSample.php",
        {
          "uId": id.text,
        }
    ).then((value) async{
      log(value.toString(), name: "TOKEN");
      await client!.login(value, id.text).then((value) {
        log(value.toString(), name: "Login Value");
      });
    });
  }

  Future<AgoraRtmChannel?> createChannel(String name) async {
    AgoraRtmChannel? channel = await client?.createChannel(name);
    await channel!.join();
    // if (channel != null) {
      channel.onMemberJoined = (AgoraRtmMember member) {
        log("Member joined: " +
            member.userId +
            ', channel: ' +
            member.channelId);
      };
      channel.onMemberLeft = (AgoraRtmMember member) {
        log(
            "Member left: " + member.userId + ', channel: ' + member.channelId);
      };
      channel.onMessageReceived =
          (AgoraRtmMessage message, AgoraRtmMember member) {
        log(
            "Channel msg: " + member.userId + ", msg: " + (message.text));
      };
    // }else{
    //   log("channel is null");
    // }
    return channel;
  }


  onMsgRec (AgoraRtmMessage message, String peerId) {
    log("Peer msg: " + peerId + ", msg: " + (message.text), name: "onMessageReceived");
    rMessage = message.text;
    msgList.add(rMessage);
    setState((){
      channelTextField.text = (DateTime.now().millisecondsSinceEpoch).toString();
    });
  }

  Future sendMessages(AgoraRtmChannel? channel)async{
    await channel!.sendMessage(AgoraRtmMessage.fromText(chat.text));
    await client!.sendMessageToPeer(peerId.text, AgoraRtmMessage.fromText(chat.text), false);

    // client?.onMessageReceived = (AgoraRtmMessage message, String peerId) {
    //   log("Peer msg: " + peerId + ", msg: " + (message.text), name: "onMessageReceived");
    //   rMessage = message.text;
    // };
    // channel.onMessageReceived =
    //     (AgoraRtmMessage message, AgoraRtmMember member) {
    //   log(
    //       "Channel msg: " + member.userId + ", msg: " + (message.text), name: "onMessageReceived-Channel");
    // };
      return rMessage;
  }

  @override
  void initState() {
    super.initState();
    initializeClient();
  }

  @override
  Widget build(BuildContext context) {
    channelTextField.text = (DateTime.now().microsecondsSinceEpoch).toString();
    return Scaffold(
      appBar: AppBar(),
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10,),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextFormField(
                  controller: id,
                  decoration: InputDecoration(
                    labelText: 'Enter Id',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'test',
                    hintStyle: TextStyle(color: Colors.black45),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              MaterialButton(
                child: Text('Login'),
                onPressed: (){
                  if(id.text != ''){
                    getToken();
                  }
                }
               ),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextFormField(
                  controller: channelTextField,
                  decoration: InputDecoration(
                    labelText: 'Enter Channel',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'test',
                    hintStyle: TextStyle(color: Colors.black45),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextFormField(
                  controller: chat,
                  decoration: InputDecoration(
                    labelText: 'Enter Message',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'test',
                    hintStyle: TextStyle(color: Colors.black45),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextFormField(
                  controller: peerId,
                  decoration: InputDecoration(
                    labelText: 'send to',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'test',
                    hintStyle: TextStyle(color: Colors.black45),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              // MaterialButton(
              //   child: Text('Connect Channel'),
              //   onPressed: (){
              //     createChannel(channelTextField.text).then((value) {
              //
              //     });
              //   }
              //  ),
              MaterialButton(
                child: Text('Send msg'),
                onPressed: ()async{
                  await createChannel(channelTextField.text).then((value) async{
                    await sendMessages(value).then((value) {});
                  });
                  setState((){});
                }
               ),

              SizedBox(height: 10,),
              Builder(
                builder: (context) {
                  return
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: msgList.length,
                      itemBuilder: (BuildContext context, int index) {
                      return Text('${msgList[index]}', style: TextStyle(color: Colors.black, fontSize: 25),);
                    },);

                }
              )
            ],
          ),
        ),
      ),
    );
  }
}
