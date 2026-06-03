import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_zalopay_sdk/flutter_zalopay_sdk.dart';
import 'package:hotel_booking_app/utils//config.dart';
import 'package:hotel_booking_app/utils/theme_data.dart';
import 'dart:async';
import '../../models/payment.dart';
import "package:pretty_qr_code/pretty_qr_code.dart";
import 'dart:convert';

import 'booking_history_screen.dart';

// Khai báo container cho giao diện cho trang thanh toán
class PaymentView extends StatelessWidget {
  // Ghi đè phương thức build - tự định nghĩa lại phương thức build
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      home: Dashboard(title: "Thanh toán", version: ""),
      color: Colors.white,
      debugShowCheckedModeBanner: false,
    );
  }
}

// Khai báo một StatefulWidget cho giao diện thanh toán
class Dashboard extends StatefulWidget {
  final String title;
  final String version;

  // Định nghĩa phương thức khởi tạo
  Dashboard({required this.title, required this.version});

  // Định nghĩa lại phương thức createState()
  @override
  _DashboardState createState() => _DashboardState();
}

// Khai báo State cho giao diện thanh toán
class _DashboardState extends State<Dashboard> {
  // Ghi đè phương thức build - tự định nghĩa lại phương thức build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: SafeArea(child: HomeZaloPay(widget.title)),
    );
  }
}

// Khai báo giao diện phần thanh toán
class HomeZaloPay extends StatefulWidget {
  final String title;

  // Định nghĩa phương thức khởi tạo
  HomeZaloPay(this.title);

  // Định nghĩa lại phương thức createState()
  @override
  _HomeZaloPayState createState() => _HomeZaloPayState();
}

// Khai báo state phần thanh toán
class _HomeZaloPayState extends State<HomeZaloPay> {
  Timer? timer;
  late QrCode qrCode;
  late QrImage qrImage;
  late PrettyQrDecoration decoration;

  final textStyle = TextStyle(color: Colors.black54);
  final valueStyle = TextStyle(
    color: AppColor.accentColor,
    fontSize: 18.0,
    fontWeight: FontWeight.w400,
  );
  String zpTransToken = "";
  String? payAmount;
  bool showResult = false;
  String? hotelName;
  String? roomType;
  String? checkin;
  String? checkout;
  String? quantity;
  String? totalCost;
  String? bookingCode;
  String? app_trans_id;

  // Kiểm tra trạng thái thanh toán
  Future<void> checkForPayment() async {
    if (checkPayment(app_trans_id!) == true){

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Gửi request tới server để tạo đơn đặt phòng và lưu lịch sử thanh toán
      final response = await http.post(
        Uri.parse('http://localhost:3000/booking-controller/create-new-booking'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'checkin': checkin!,
          'checkout': checkout!,
          'customerEmail': prefs.getString("userEmail")!,
          'customerName': prefs.getString("userName")!,
          'customerCountry': prefs.getString("userEmail")!,
          'customerPhone': prefs.getString("userPhone")!,
          'room': prefs.getString("roomID")!,
          'quantity': quantity!,
          'total': totalCost!
        }),
      );

      if(response.statusCode == 200){
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("Thanh toán thành công"),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => BookingHistoryScreen()),
                  );
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      } else {
        showDialog(context: context, builder: (ctx) {
          return AlertDialog(
            title: Text("Đã có lỗi phía hệ thống, vui lòng thử chờ giây lát"),
            actions: [
              TextButton(onPressed: () {
                Navigator.pop(ctx);
              }, child: Text("Ok")),
            ],
          );
        },);
      }
    }
  }

  // Định nghĩa lại hàm initState() - tạo đơn thanh toán, định nghĩa một timer và khởi gán giá trị ban đầu cho các biến
  @override
  void initState() async {
    super.initState();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    payAmount = await prefs.getString("payAmount")!;
    hotelName = await prefs.getString("hotelName")!;
    checkin = await prefs.getString("checkin")!;
    checkout = await prefs.getString("checkout")!;
    roomType = await prefs.getString("roomType")!;
    quantity = await prefs.getString("quantity")!;
    totalCost = await prefs.getString("totalCost")!;

    // Gọi gàm tạo đơn thanh toán
    var result = await createOrder(int.parse(payAmount!));
    bookingCode = result?.ordertoken;
    app_trans_id = result?.app_trans_id;
    if (result != null) {
      zpTransToken = result.zptranstoken;
      setState(() {
        zpTransToken = result.zptranstoken;
      });
    }

    // Tạo đối tượng qrCode
    qrCode = QrCode.fromData(
      data: result!.orderurl,
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );

    // Tạo ảnh QR code
    qrImage = QrImage(qrCode);

    // Check trạng thai thanh toán mỗi 10s
    timer = Timer.periodic(
      Duration(seconds: 10),
      (Timer t) => checkForPayment(),
    );
  }

  // Ghi đè phương thức dispose - tắt timer khi chuyển sang giao diện khác
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // Ghi đè phương thức build - tự định nghĩa lại phương thức build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsetsGeometry.fromLTRB(30, 0, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Mã hóa đơn: ",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      bookingCode!,
                      style: TextStyle(color: Colors.deepOrange),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Khách sạn: ",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(hotelName!),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Loại phòng: ",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(roomType!),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Số lượng: ",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(quantity!),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Ngày nhận phòng: ",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(checkin!),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Ngày trả phòng: ",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(checkout!),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.fromLTRB(30, 20, 0, 30),
            child: Row(
              children: [
                Text(
                  "Tổng tiền: ",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  totalCost! + " (VNĐ)",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.blueAccent,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.fromLTRB(0, 20, 0, 20),
            child: Text(
              "Quét mã QR dưới đây bằng ứng dụng ZaloPay để thanh toán",
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsetsGeometry.fromLTRB(0, 0, 0, 20),
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: PrettyQrView(qrImage: qrImage),
                ),
              ),
              Text("Hết hiệu lực sau: 5:25"),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Visibility(
              visible: showResult,
              child: Text("zptranstoken:", style: textStyle),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Text(zpTransToken, style: valueStyle),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Visibility(
              visible: showResult,
              child: Text("Transaction status:", style: textStyle),
            ),
          ),
        ],
      ),
    );
  }
}
