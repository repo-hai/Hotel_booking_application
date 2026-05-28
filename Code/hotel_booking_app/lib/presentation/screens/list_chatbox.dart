import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hotel_booking_app/models/chatUsersModel.dart';
import 'package:hotel_booking_app/presentation/screens/chat_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ListChatboxView extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ListChatboxView> {
  List<ChatUsers> chatUsers = [
    // ChatUsers(name: "Jane Russel",
    //     messageText: "Awesome Setup",
    //     imageURL: "https://m.media-amazon.com/images/I/71-OTwKLziL._AC_SL1500_.jpg",
    //     time: "Now"),
    // ChatUsers(name: "Glady's Murphy",
    //     messageText: "That's Great",
    //     imageURL: "https://m.media-amazon.com/images/I/71-OTwKLziL._AC_SL1500_.jpg",
    //     time: "Yesterday"),
    // ChatUsers(name: "Jorge Henry",
    //     messageText: "Hey where are you?",
    //     imageURL: "https://m.media-amazon.com/images/I/71-OTwKLziL._AC_SL1500_.jpg",
    //     time: "31 Mar"),
    // ChatUsers(name: "Philip Fox",
    //     messageText: "Busy! Call me in 20 mins",
    //     imageURL: "https://m.media-amazon.com/images/I/71-OTwKLziL._AC_SL1500_.jpg",
    //     time: "28 Mar"),
    // ChatUsers(name: "Debra Hawkins",
    //     messageText: "Thankyou, It's awesome",
    //     imageURL: "https://m.media-amazon.com/images/I/71-OTwKLziL._AC_SL1500_.jpg",
    //     time: "23 Mar"),
    // ChatUsers(name: "Jacob Pena",
    //     messageText: "will update you in evening",
    //     imageURL: "https://m.media-amazon.com/images/I/71-OTwKLziL._AC_SL1500_.jpg",
    //     time: "17 Mar"),
    // ChatUsers(name: "Andrey Jones",
    //     messageText: "Can you please share the file?",
    //     imageURL: "https://m.media-amazon.com/images/I/71-OTwKLziL._AC_SL1500_.jpg",
    //     time: "24 Feb"),
    // ChatUsers(name: "John Wick",
    //     messageText: "How are you?",
    //     imageURL: "https://m.media-amazon.com/images/I/71-OTwKLziL._AC_SL1500_.jpg",
    //     time: "18 Feb"),
  ];

  Future<void> fetchUserChatbox() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId')!;
    final response = await http.get(
      Uri.parse('http://localhost:3000/chatbox-controller/get-list-chatbox/$userId'),
    );
    final jsonData = jsonDecode(response.body);
    print(jsonData);
    if(response.statusCode == 200){
      for(var jsonObject in jsonData){
        print(jsonObject);
        var date = DateTime.fromMillisecondsSinceEpoch(int.parse(jsonObject["time"]));
        print(date);
        var now = DateTime.now();
        var time="";
        if(now.year == date.year && now.month == date.month && now.day == date.day){
          time = date.hour.toString() + ":" + date.minute.toString();
        } else {
          time = date.day.toString() + "/" + date.month.toString() + " " + date.hour.toString() + ":" + date.minute.toString();
        }
        var user = ChatUsers(chatboxID: jsonObject["chatboxID"], userID: jsonObject["collaborativeID"], isRead: jsonObject["isRead"], name: jsonObject["collaborative_name"], messageText: jsonObject["lastMessage"], imageURL: jsonObject["user_url"], time: time);
        setState(() {
          chatUsers.add(user);
        });
      }
    } else {
      print("Mã lỗi khi lấy danh sách hội thoại: " );
      print(response.statusCode);
    }
  }

  @override
  void activate() {
    // TODO: implement activate
    setState(() {
      fetchUserChatbox();
    });
  }

  @override
  void initState() {
    super.initState();
    // chatUsers = [
    //   ChatUsers(name: "Jane Russel",
    //       messageText: "Awesome Setup",
    //       imageURL: "https://m.media-amazon.com/images/I/71-OTwKLziL._AC_SL1500_.jpg",
    //       time: "Now"),
    //   ChatUsers(name: "Glady's Murphy",
    //       messageText: "That's Great",
    //       imageURL: "https://m.media-amazon.com/images/I/71-OTwKLziL._AC_SL1500_.jpg",
    //       time: "Yesterday"),
    //   ChatUsers(name: "Jorge Henry",
    //       messageText: "Hey where are you?",
    //       imageURL: "https://m.media-amazon.com/images/I/71-OTwKLziL._AC_SL1500_.jpg",
    //       time: "31 Mar"),
    //   ChatUsers(name: "Philip Fox",
    //       messageText: "Busy! Call me in 20 mins",
    //       imageURL: "https://m.media-amazon.com/images/I/71-OTwKLziL._AC_SL1500_.jpg",
    //       time: "28 Mar"),
    //   ChatUsers(name: "Debra Hawkins",
    //       messageText: "Thankyou, It's awesome",
    //       imageURL: "https://m.media-amazon.com/images/I/71-OTwKLziL._AC_SL1500_.jpg",
    //       time: "23 Mar"),
    //   ChatUsers(name: "Jacob Pena",
    //       messageText: "will update you in evening",
    //       imageURL: "https://m.media-amazon.com/images/I/71-OTwKLziL._AC_SL1500_.jpg",
    //       time: "17 Mar"),
    //   ChatUsers(name: "Andrey Jones",
    //       messageText: "Can you please share the file?",
    //       imageURL: "https://m.media-amazon.com/images/I/71-OTwKLziL._AC_SL1500_.jpg",
    //       time: "24 Feb"),
    //   ChatUsers(name: "John Wick",
    //       messageText: "How are you?",
    //       imageURL: "https://m.media-amazon.com/images/I/71-OTwKLziL._AC_SL1500_.jpg",
    //       time: "18 Feb"),
    // ];
    setState(() {
      fetchUserChatbox();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)
        ),
        title: Text("Tin nhắn"),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 16,left: 16,right: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(Icons.search,color: Colors.grey.shade600, size: 20,),
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      )
                  ),
                ),
              ),
            ),
            ListView.builder(
              itemCount: chatUsers.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 16),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index){
                return ConversationList(
                  name: chatUsers[index].name,
                  messageText: chatUsers[index].messageText,
                  time: chatUsers[index].time,
                  isMessageRead: chatUsers[index].isRead,
                  chatboxId: chatUsers[index].chatboxID,
                  collaborative_name: chatUsers[index].name,
                  collaborative_url: chatUsers[index].imageURL,
                  collaborativeID: chatUsers[index].userID,
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        destinations: [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.notifications_sharp)),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Badge(label: Text('2'), child: Icon(Icons.messenger_sharp)),
            label: 'Messages',
          ),
        ],
      ),
    );
  }
}

class ConversationList extends StatefulWidget{
  String name;
  String messageText;
  String collaborative_url;
  String collaborative_name;
  String time;
  bool isMessageRead;
  String chatboxId;
  String collaborativeID;
  ConversationList({ required this.collaborativeID, required this.collaborative_name, required this.collaborative_url, required this.chatboxId, required this.name,required this.messageText,required this.time,required this.isMessageRead});

  @override
  _ConversationListState createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:  () async {
        final pref = await SharedPreferences.getInstance();

        await pref.setString("chatboxId", widget.chatboxId);
        await pref.setString("collaborative_name", widget.collaborative_name);
        await pref.setString("collaborative_url", widget.collaborative_url);
        await pref.setString("collaborativeID", widget.collaborativeID);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return ChatDetailPage();
          }),
        );
      },
      child: Container(
        padding: EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.collaborative_url),
                    maxRadius: 30,
                  ),
                  SizedBox(width: 16,),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.name, style: TextStyle(fontSize: 16),),
                          SizedBox(height: 6,),
                          Text(widget.messageText,style: TextStyle(fontSize: 13,color: Colors.grey.shade600, fontWeight: widget.isMessageRead?FontWeight.bold:FontWeight.normal),),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              widget.time,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: widget.isMessageRead ? FontWeight.bold : FontWeight.normal
              ),
            ),
          ],
        ),
      ),
    );
  }
}