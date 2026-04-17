import 'package:flutter/material.dart';
import 'package:hotel_booking_app/models/message.dart';

class ChatDetailPage extends StatefulWidget{
  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  List<Message> messages = [
    Message("Hello, Will", "receiver"),
    Message("How have you been?", "receiver"),
    Message("Hey Kriss, I am doing fine dude. wbu?", "sender"),
    Message("ehhhh, doing OK.", "receiver"),
    Message("Is there any thing wrong?", "sender"),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    messages = [
      Message("Hello, Will", "receiver"),
      Message("How have you been?", "receiver"),
      Message("Hey Kriss, I am doing fine dude. wbu?", "sender"),
      Message("ehhhh, doing OK.", "receiver"),
      Message("Is there any thing wrong?", "sender"),
    ];
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
              backgroundImage: NetworkImage("https://randomuser.me/api/portraits/men/5.jpg"),
              maxRadius: 20,
            ),
            SizedBox(width: 12,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Kriss Benwat",style: TextStyle( fontSize: 16 ,fontWeight: FontWeight.w600),),
                  SizedBox(height: 6,),
                  Text("Online",style: TextStyle(color: Colors.grey.shade600, fontSize: 13),),
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
                  alignment: (messages[index].messageType == "receiver"?Alignment.topLeft:Alignment.topRight),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: (messages[index].messageType  == "receiver"?Colors.grey.shade200:Color.fromRGBO(40, 83, 175, 1)),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Text(
                      messages[index].content,
                      style: TextStyle(
                        fontSize: 15,
                        color: (messages[index].messageType  == "receiver" ? Colors.black : Colors.white),
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
                        decoration: InputDecoration(
                            hintText: "Viết câu trả lời...",
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.fromLTRB(0, 0, 10, 0),
                      child: FloatingActionButton(
                        onPressed: (){},
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