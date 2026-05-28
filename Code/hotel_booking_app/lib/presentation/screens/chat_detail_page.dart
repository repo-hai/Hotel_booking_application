import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hotel_booking_app/models/message.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatDetailPage extends StatefulWidget{
  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  TextEditingController textController = TextEditingController();
  List<Message> messages = [
    // Message("Hello, Will", "receiver"),
    // Message("How have you been?", "receiver"),
    // Message("Hey Kriss, I am doing fine dude. wbu?", "sender"),
    // Message("ehhhh, doing OK.", "receiver"),
    // Message("Is there any thing wrong?", "sender"),
  ];
  String collaborative_name = "";
  String collaborative_url = "";
  String host_id = "";
  String message="";
  String chatboxId="";
  String collaborativeID="";

  Future<void> fetchUserChatbox() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    collaborative_name = prefs.getString('collaborative_name')!;
    collaborative_url = prefs.getString('collaborative_url')!;
    host_id = prefs.getString('userId')!;
    chatboxId = prefs.getString('chatboxId')!;
    collaborativeID = prefs.getString('collaborativeID')!;
    final response = await http.get(
      Uri.parse('http://localhost:3000/chatbox-controller/get-detail-chatbox/$chatboxId'),
    );
    print(jsonDecode(response.body));
    final jsonData = jsonDecode(response.body);
    if(response.statusCode == 200){
      for(var jsonObject in jsonData){
        var message = Message(message: jsonObject["message"], time: jsonObject["time"].toString(), receiverID: jsonObject["receiverID"], senderID: jsonObject["senderID"]);
        setState(() {
          messages.add(message);
        });
      }
    } else {
      print('Mã lỗi khi lấy danh sách tin nhắn từ hội thoại $chatboxId: ' );
      print(response.statusCode);
    }
  }

  @override
  void initState() {
    super.initState();
    messages = [
      // Message("Hello, Will", "receiver"),
      // Message("How have you been?", "receiver"),
      // Message("Hey Kriss, I am doing fine dude. wbu?", "sender"),
      // Message("ehhhh, doing OK.", "receiver"),
      // Message("Is there any thing wrong?", "sender"),
    ];
    setState(() {
      fetchUserChatbox();
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(collaborative_url),
              maxRadius: 20,
            ),
            SizedBox(width: 12,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(collaborative_name,style: TextStyle( fontSize: 16 ,fontWeight: FontWeight.w600),),
                  SizedBox(height: 6,),
                  //Text("Online",style: TextStyle(color: Colors.grey.shade600, fontSize: 13),),
                ],
              ),
            ),
            Icon(Icons.settings,color: Colors.black54,),
          ],
        ),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: messages.length,
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 10,bottom: 10),
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index){
              return Container(
                padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                child: Align(
                  alignment: (messages[index].senderID != host_id ?Alignment.topLeft:Alignment.topRight),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: (messages[index].senderID  != host_id ?Colors.grey.shade200:Color.fromRGBO(40, 83, 175, 1)),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Text(
                      messages[index].message,
                      style: TextStyle(
                        fontSize: 15,
                        color: (messages[index].senderID  != host_id ? Colors.black : Colors.white),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsetsGeometry.fromLTRB(20, 0, 20, 40),
              child: Container(
                padding: EdgeInsets.only(left: 10,bottom: 10,top: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                  color: Color.fromRGBO(236, 241, 246, 1),
                ),
                height: 60,
                width: double.infinity,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        onChanged: (String s){
                          message = s;
                        },
                        onSubmitted: (String s){
                          textController.text="";
                        },
                        decoration: InputDecoration(
                            hintText: "Viết câu trả lời...",
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none
                        ),
                        controller: textController,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.fromLTRB(0, 0, 10, 0),
                      child: FloatingActionButton(
                        onPressed: () async {
                          final response = await http.post(
                            Uri.parse('http://localhost:3000/chatbox-controller/push-up-new-message'),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: jsonEncode(<String, String>{'message': message, 'chatboxID': chatboxId, 'senderUserId': host_id, 'receiverUserId': collaborativeID}),
                          );
                          if(response.statusCode == 200){
                            messages=[];
                            fetchUserChatbox();
                            textController.clear();
                            textController.text="";
                            setState(() {
                            });
                          } else {
                            showDialog(context: context, builder: (ctx) => AlertDialog(
                              title: Text("Đã có lỗi khi gửi tin nhắn, vui lòng thực hiện lại"),
                              actions: [
                                TextButton(onPressed: () {
                                  Navigator.pop(ctx);
                                }, child: Text("OK"))
                              ],
                            ));
                          }
                        },
                        backgroundColor: Color.fromRGBO(40, 83, 175, 1),
                        elevation: 0,
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}