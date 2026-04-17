import 'package:flutter/material.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyForgotPasswordPage(),
    );
  }
}

class MyForgotPasswordPage extends StatefulWidget {
  const MyForgotPasswordPage({super.key});

  // Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyForgotPasswordPage> createState() => _MyForgotPasswordPage();
}

class _MyForgotPasswordPage extends State<MyForgotPasswordPage> {
  final String registerState = "not register";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "Quên mật khẩu?",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                )
              ],
            ),
            Text("Vui lòng nhập vào email của bạn để thục hiện lấy lại mật khẩu"),
            ListTile(
              leading: Icon(Icons.email, color: Colors.blue,),
              title: Text("Email"),
            ),
            TextField(),
            Center(
              child:  Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Center(),
                        ),
                      );
                    },
                    child: Text("Gửi"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    // appBar: AppBar(
    //   title: Text(widget.title),
    // ),
  }
}
