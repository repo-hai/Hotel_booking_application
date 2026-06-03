import 'package:sprintf/sprintf.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';

// Khai báo các key kết nối tới ZaloPay
class ZaloPayConfig {
  static const String appId ="5554";
  static const String key1 = "9phuAOYhan4urywHTh0ndEXiV3pKHr5Q";
  static const String key2 = "trMrHtvjo6myautxDUiAcYsVtaeQ8nhf";

  static const String appUser ="HoangHai123321";
  static int tranIdDefault = 1;
}

// Khai báo đối tượng response từ server
class CreateOrderResponse{
  final String zptranstoken;
  final String orderurl;
  final int returncode;
  final String returnmessage;
  final int subreturncode;
  final String subreturnmessage;
  final String ordertoken;
  final String app_trans_id;

  // Định nghĩa phương thức khởi tạo
  CreateOrderResponse({required this.zptranstoken, required this.orderurl, required this.returncode, required this.returnmessage,
          required this.subreturncode, required this.subreturnmessage, required this.ordertoken, required this.app_trans_id
  });

  // Định nghĩa phương thức parse từ JSON sang đối tượng
  factory CreateOrderResponse.fromJson(Map<String, dynamic> json){
    return CreateOrderResponse(
      app_trans_id: json["app_trans_id"] as String,
      zptranstoken: json['zp_trans_token'] as String,
      orderurl:  json['order_url'] as String,
      returncode: json['return_code'] as int,
      returnmessage: json["return_message"] as String,
      subreturncode:  json['sub_return_code'] as int,
      subreturnmessage: json['sub_return_message'] as String,
      ordertoken: json['order_token'] as String,
    );
  }
}

// Khai báo hàm định dạng số
String formatNumber(double value){
  final f = new NumberFormat("#,###", "vi_VN");
  return f.format(value);
}

// Khai báo link API tạo đơn thanh toán
class Endpoints {
  static final String createOrderUrl = "https://openapi.zalopay.vn/v2/create";
}

// Khai báo hàm định dạng thời gian
String formatDateTime(DateTime datetime, String layout){
  return DateFormat(layout).format(datetime).toString();
}

// Khai báo hàm lấy AppTransId
String getAppTransId(){
  int transIdDefault = 1;
  if(transIdDefault >= 100000){
    transIdDefault = 1;
  }

  transIdDefault++;
  var timeString = formatDateTime(DateTime.now(), "yyMMdd_hhmmss");
  return sprintf("%s%06d", [timeString, transIdDefault]);
}

// Khai báo hàm lấy lấy BankCode
String getBankCode() => "zalopayapp";

// Khai báo hàm lấy description
String getDescription(String apptransid) => "Merchant Demo thanh toán cho đơn hàng  #$apptransid";

// Khai báo hàm mã hóa lấy Mac
String getMacCreateOrder(String data){
  var hmac = new Hmac(sha256, utf8.encode(ZaloPayConfig.key1));

  return hmac.convert(utf8.encode(data)).toString();
}

// Khai báo hàm tạo đơn thanh toán
Future<CreateOrderResponse?> createOrder(int price) async {
  var header = new Map<String, String>();
  header["Content-Type"] = "application/x-www-form-urlencoded";

  var item = [{}];
  var apptransid = getAppTransId();
  var embeddata = {"merchantinfo": "embeddata123"};
  var body = new Map<String, String>();
  body["appid"] = ZaloPayConfig.appId;
  body["appuser"] = ZaloPayConfig.appUser;
  body["apptime"] = DateTime.now().millisecondsSinceEpoch.toString();
  body["amount"] = price.toStringAsFixed(0);
  body["apptransid"] = apptransid;
  body["embed_data"] = jsonEncode(embeddata);
  body["item"] = jsonEncode(item);
  body["bankcode"] = getBankCode();
  body["description"] = getDescription(body["apptransid"]!);

  var dataGetMac = sprintf("%s|%s|%s|%s|%s|%s|%s", [
    body["appid"],
    body["apptransid"],
    body["appuser"],
    body["amount"],
    body["apptime"],
    body["embeddata"],
    body["item"]
  ]);
  body["mac"] = getMacCreateOrder(dataGetMac);

  http.Response response = await http.post(
    Uri.parse(Endpoints.createOrderUrl),
    headers: header,
    body: body,
  );

  print("body_request: $body");
  if (response.statusCode != 200) {
    return null;
  }

  var data = jsonDecode(response.body);
  data["app_trans_id"] = apptransid;
  print("data_response: $data}");

  return CreateOrderResponse.fromJson(data);
}

// Hàm kiểm tra trạng thái thanh toán
Future<bool> checkPayment(String app_trans_id) async {
  var header = new Map<String, String>();
  header["Content-Type"] = "application/x-www-form-urlencoded";

  var body = new Map<String, String>();
  body["appid"] = ZaloPayConfig.appId;
  body["apptransid"] = app_trans_id;

  var dataGetMac = sprintf("%s|%s|%s", [
    body["appid"],
    body["apptransid"],
    ZaloPayConfig.key1
  ]);
  body["mac"] = getMacCreateOrder(dataGetMac);

  http.Response response = await http.post(
    Uri.parse("https://openapi.zalopay.vn/v2/query"),
    headers: header,
    body: body,
  );

  var data = jsonDecode(response.body);

  if(data["return_code"] == 1){
    return true;
  } else {
    return false;
  }
}