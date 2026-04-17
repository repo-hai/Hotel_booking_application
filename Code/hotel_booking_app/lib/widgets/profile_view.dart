import 'package:flutter/material.dart';
import 'package:hotel_booking_app/widgets/edit_profile.dart';
import 'package:hotel_booking_app/widgets/change_password.dart';
import 'package:hotel_booking_app/widgets/list_chatbox.dart';
import 'package:hotel_booking_app/widgets/view_comment_rating.dart';

class ProfileView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfileViewState();
  }
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: ()=>{
                      Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChangePasswordView(),
                          )
                      )
                    },
                    icon: Icon(Icons.density_medium)
                )
              ],
            ),
            Container(
              padding: EdgeInsets.all(60),
              height: 250,
              width: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(90)),
              ),
              child: Center(
                child: Column(
                  children: [
                    IconButton(
                        onPressed: ()=>{
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditProfileView(),
                              )
                          )
                        },
                        icon: Icon(Icons.edit_sharp)
                    ),
                    Text("John Smith"),
                    Text("johnSmith@gmail.com"),
                    Text("+89123425677"),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: IconButton(
              icon: Icon(Icons.comment_bank_outlined),
              onPressed: (){
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ViewCommentRating())
                );
              },
            ),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: IconButton(
              icon: Badge(label: Text('1'), child: Icon(Icons.message)),
              onPressed: (){
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ListChatboxView())
                );
              },
            ),
            label: 'Messages',
          ),
        ],
      ),
    );
  }
}