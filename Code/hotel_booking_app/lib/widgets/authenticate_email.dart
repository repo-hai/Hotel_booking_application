import 'package:flutter/material.dart';
import 'package:hotel_booking_app/widgets/login.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

double containerHeight = 600;
double containerWidth = 450;

class AuthenticateEmail extends StatelessWidget {
  const AuthenticateEmail({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyAuthenticateEmail(),
    );
  }
}

class MyAuthenticateEmail extends StatefulWidget {
  const MyAuthenticateEmail({super.key});

  // Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyAuthenticateEmail> createState() => _MyAuthenticateEmail();
}

class _MyAuthenticateEmail extends State<MyAuthenticateEmail> {
  final String loginState = "not login";

  void _onLogin(){}

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color.fromRGBO(40, 83, 175, 1),
              Color.fromRGBO(105, 177, 241, 1),
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.fromLTRB(25, 40, 10, 30),
                  child: Text(
                    "Xác thực tài khoản",
                    selectionColor: Colors.white,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: containerHeight,
                  width: containerWidth,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(80)),
                  ),
                  padding: EdgeInsetsGeometry.fromLTRB(30, 50, 30, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsetsGeometry.fromLTRB(0, 0, 0, 10),
                        child: Text(
                          "Xác thực Email",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight(550),
                          ),
                        ),
                      ),
                      Text("Vui lòng nhập mã OTP được gửi tới email của bạn"),
                      OtpTextField(
                        numberOfFields: 4,
                        onSubmit: (String code){
                          print(code);
                        },
                        fieldWidth: 60,
                        textStyle: TextStyle(
                            fontSize: 25
                        ),
                        margin: EdgeInsetsGeometry.fromLTRB(10, 20, 10, 20),
                      ),
                      Padding(
                        padding: EdgeInsetsGeometry.fromLTRB(0, 10, 0, 20),
                        child: Center(
                          child: Text("Không nhận được mã OTP?"),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 30,
                        children: [
                          ElevatedButton(
                            onPressed: _onLogin,
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(160, 35),
                              backgroundColor: Color.fromRGBO(40, 83, 175, 1),
                            ),
                            child: Text(
                              "Gửi lại",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          ElevatedButton(
                              onPressed: (){
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => Login(),
                                    )
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size(160, 35),
                                backgroundColor: Color.fromRGBO(0, 144, 255, 1),
                              ),
                              child: Text(
                                "Xác nhận",
                                style: TextStyle(
                                    color: Colors.white
                                ),
                              )
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
    // appBar: AppBar(
    //   title: Text(widget.title),
    // ),
  }
}
