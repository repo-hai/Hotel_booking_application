import 'package:sprintf/sprintf.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';

class ZaloPayConfig {
  //static const String appId ="2554";
  static const String appId="554";
  //static const String key1 = "sdngKKJmqEMzvh5QQcdD2A9XBSKUNaYn";
  static const String key1 = "9phuAOYhan4urywHTh0ndEXiV3pKHr5Q";
  static const String key2 = "trMrHtvjo6myautxDUiAcYsVtaeQ8nhf";

  static const String appUser ="zalopaydemo";
  static int tranIdDefault = 1;
}

class CreateOrderResponse{
  final String zptranstoken;
  final String orderurl;
  final int returncode;
  final String returnmessage;
  final int subreturncode;
  final String subreturnmessage;
  final String ordertoken;

  CreateOrderResponse({required this.zptranstoken, required this.orderurl, required this.returncode, required this.returnmessage,
          required this.subreturncode, required this.subreturnmessage, required this.ordertoken
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json){
    return CreateOrderResponse(
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

String formatNumber(double value){
  final f = new NumberFormat("#,###", "vi_VN");
  return f.format(value);
}

class Endpoints {
  static final String createOrderUrl = "https://sandbox.zalopay.com.vn/v001/tpe/createorder";
  //static final String createOrderUrl = "https://sb-openapi.zalopay.vn/v2/create";
}

String formatDateTime(DateTime datetime, String layout){
  return DateFormat(layout).format(datetime).toString();
}

String getAppTransId(){
  int transIdDefault = 1;
  if(transIdDefault >= 100000){
    transIdDefault = 1;
  }

  transIdDefault++;
  var timeString = formatDateTime(DateTime.now(), "yyMMdd_hhmmss");
  return sprintf("%s%06d", [timeString, transIdDefault]);
}

String getBankCode() => "zalopayapp";

String getDescription(String apptransid) => "Merchant Demo thanh toán cho đơn hàng  #$apptransid";

String getMacCreateOrder(String data){
  var hmac = new Hmac(sha256, utf8.encode(ZaloPayConfig.key1));

  return hmac.convert(utf8.encode(data)).toString();
}

Future<CreateOrderResponse?> createOrder(int price) async {
  var header = new Map<String, String>();
  header["Content-Type"] = "application/x-www-form-urlencoded";

  var item = [{"itemid": "knb", "itemname": "kim nguyen bao", "itemprice": 198400,
    "itemquantity": 1
  }];

  var embeddata = {"merchantinfo": "embeddata123"};
  var body = new Map<String, String>();
  body["appid"] = ZaloPayConfig.appId;
  body["appuser"] = ZaloPayConfig.appUser;
  body["apptime"] = DateTime.now().millisecondsSinceEpoch.toString();
  body["amount"] = price.toStringAsFixed(0);
  body["apptransid"] = getAppTransId();
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
  print("mac: ${body["mac"]}");
  print(header);
  print(body);

  http.Response response = await http.post(
    Uri.parse(Endpoints.createOrderUrl),
    //headers: header,
    body: body,
  );

  print("body_request: $body");
  if (response.statusCode != 200) {
    return null;
  }

  var data = jsonDecode(response.body);
  print("data_response: $data}");

  return CreateOrderResponse.fromJson(data);
}