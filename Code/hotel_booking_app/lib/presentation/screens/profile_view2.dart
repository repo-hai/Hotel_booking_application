import 'package:flutter/material.dart';
import 'package:hotel_booking_app/presentation/screens/edit_profile.dart';
import 'package:hotel_booking_app/presentation/screens/change_password.dart';
import 'package:hotel_booking_app/presentation/screens/list_chatbox.dart';
import 'package:hotel_booking_app/presentation/screens/view_comment_rating.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ProfileViewState();
  }
}

class _ProfileViewState extends State<ProfileView> {
  String email = "";
  String name = "";
  String phone = "";

  Future<void> fetchUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email')!;
    final response = await http.get(
      Uri.parse('http://localhost:3000/get-user/$email'),
    );
    //print(jsonDecode(response.body));

    if(response.statusCode == 200){
      setState(() {
        email = jsonDecode(response.body)['Email'];
        name = jsonDecode(response.body)['Name'];
        phone = jsonDecode(response.body)['Phone'];
        prefs.setString('name', name);
        prefs.setString('phone', phone);
      });
    } else {
      //print("Mã đăng nhập: " );
      //print(response.statusCode);
    }
  }
  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: 600,
        height: 490,
        child: Stack(
          alignment: AlignmentGeometry.topCenter,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage("https://m.media-amazon.com/images/I/71-OTwKLziL._AC_SY300_SX300_QL70_FMwebp_.jpg")
                )
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  ),
                  Container(
                    height: 350,
                  )
                ],
              ),
            ),
            Positioned(
              top: 200,
              child: Container(
                padding: EdgeInsets.all(30),
                height: 290,
                width: 300,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(90)),
                  color: Colors.white,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsetsGeometry.fromLTRB(0, 0, 0, 20),
                            child: Text(
                              "Hoàng Hải",
                              style: TextStyle(
                                  fontSize: 25
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsGeometry.fromLTRB(0, 0, 0, 10),
                            child: Text(
                              "hoanghaidinh@gmail.com",
                              style: TextStyle(
                                  fontSize: 17
                              ),
                            ),
                          ),
                          Text(
                            "+89123425677",
                            style: TextStyle(
                                fontSize: 17
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ),
            Positioned(
              left: 300,
              top: 200,
              child: IconButton(
                color: Colors.white,
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll<Color>(Color.fromRGBO(0, 189, 107, 1)),
                ),
                onPressed: ()=>{
                  Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditProfileView(),
                      )
                  )
                },
                icon: Icon(
                  Icons.edit_sharp,
                  size: 35,
                )
              )
            )
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Trang chủ',
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
            label: 'Thông báo',
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
            label: 'Tin nhắn',
          ),
        ],
      ),
    );
  }
}