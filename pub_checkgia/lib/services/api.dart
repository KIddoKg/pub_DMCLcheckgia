// ignore_for_file: no_leading_underscores_for_local_identifiers, non_constant_identifier_names

import 'package:dio/dio.dart';
import 'package:pub_dmclcheckgia/pub_DMCLcheckgia.dart';

class API {
  /// Login DMCL
  // static String identityDMCL = 'http://118.69.205.71:8040/api/v1';
  static String identityDMCL = 'https://apiat.stdmcl.com:11443/api/v1';

  static String dmcl_search = 'https://dienmaycholon.vn/api/product';
  static String dmcl_checkgia = 'https://dienmaycholon.vn/apip/nhanvien';
  static String dmcl_mobile = 'https://apiat.stdmcl.com:11443/api/v1';
  static String dmcl_preorder = '$dmcl_mobile/preorder';
  // static String dmcl_preorder = 'http://118.69.205.71:8040/api/v1/preorder';
  static String telegram_api_bot = 'https://api.telegram.org/bot';

  static Dio dio = Dio();

  static NetRequest loginDMCL(String username, String pwd) {
    String url = '$identityDMCL/loginuser';

    Map<String, String> data = {};
    data['username'] = username;
    data['password'] = pwd;

    NetRequest req = NetRequest(url, 'post', data: data);
    req.withUserAgent();
    return req;
  }

  static NetRequest registerDevice(String deviceId) {
    String url = '$identityDMCL/updateimeiuser';

    Map<String, String> data = {};
    data['imei'] = deviceId;

    NetRequest req = NetRequest(url, 'post', data: data)
      ..withAuthen(isTokenHeader: true);
    return req;
  }

  static NetRequest updateUser({bool enablePush = false}) {
    String url = '$identityDMCL/updateusernotice';

    Map<String, dynamic> data = {};
    data['enablePushNotifi'] = enablePush ? 1 : 0;

    NetRequest req = NetRequest(url, 'post', data: data)
      ..withAuthen(isTokenHeader: true);
    return req;
  }

  static NetRequest requestPriceWebCode(String sapCode, String productName) {
    String url = '$identityDMCL/lognoteprice/create';
    var data = {'sap_code': sapCode, 'name_product': productName};

    NetRequest req = NetRequest(url, 'post', data: data)
      ..withAuthen(isTokenHeader: true);

    return req;
  }

  // static NetRequest logout() {
  //   String url = identity;

  //   NetRequest req = NetRequest(url, 'delete')..withAuthen();
  //   return req;
  // }

  // static NetRequest refreshToken(String refreshToken) {
  //   String url = '$identity/RefreshToken';

  //   Map<String, dynamic> data = {};
  //   data['refreshToken'] = refreshToken;

  //   NetRequest req = NetRequest(url, 'put', data: data)..withAuthen();
  //   return req;
  // }

  // static NetRequest getProfile() {
  //   // https://api.thuho.service.dienmaycholon.vn/Identity
  //   String url = identity;

  //   NetRequest req = NetRequest(
  //     url,
  //     'get',
  //   )..withAuthen();
  //   return req;
  // }

  static NetRequest sendNoti(String title, String subTitle, String content,
      String topic, String toId, String fromId) {
    String url = '$identityDMCL/notice/create';
    var data = {
      'name': title,
      'des': subTitle,
      'content': content,
      'app_send': fromId,
      'cid_user': toId,
      'store': topic,
    };

    NetRequest req = NetRequest(url, 'post', data: data);

    return req;
  }

  static NetRequest getNotification(
      {int? page = 1,
      String? title = '',
      List<String>? toId,
      String? sort = 'desc'}) {
    String url = '$identityDMCL/notice/list?page=$page';

    Map<String, dynamic> data = {
      'order_create_at': sort,
      'toId': toId ?? [],
      'title': title
    };

    NetRequest req = NetRequest(url, 'post', data: data)
      ..withAuthen(isTokenHeader: true);

    return req;
  }

  static NetRequest searchProduct(String keyword) {
    String url = '$dmcl_search/autocomplete?k=$keyword';
    NetRequest req = NetRequest(url, 'get');

    return req;
  }

  static NetRequest searchSapCodeByQR(
    String url_qr,
  ) {
    String url =
        'https://dienmaycholon.vn/default/webservice/getlinkbysapcode?alias=$url_qr';
    NetRequest req = NetRequest(url, 'get');
    return req;
  }

  static NetRequest detailProduct(String alias) {
    var deviceId = AppSetting.instance.deviceID;

    String url = '$dmcl_checkgia/xemgiaansanpham/$alias?imei=$deviceId';
    if (alias.contains('?')) {
      url = '$dmcl_checkgia/xemgiaansanpham/$alias&imei=$deviceId';
    }

    NetRequest req = NetRequest(url, 'get')
      ..withAuthen(isTokenHeader: true)
      ..withUserAgent();
    return req;
  }

//http://118.69.205.71:8040/api/v1/getgiabanhr?sap_code=150341&imei=123
  /// Lấy giá sàn
  static NetRequest getDetailPrice(String sapCode, String imei) {
    var url = '$dmcl_preorder?sap_code=$sapCode&imei=$imei';
    var req = NetRequest(url, 'get')..withAuthen(isTokenHeader: true);
    return req;
  }

// /userInfoTarget?FromDate=1648801058000&imei=123&ToDate=1651306658000
  /// Lấy doanh số của nhân viên
  static NetRequest getUserInfoTarget({int? fromDate, int? toDate}) {
    var now = DateTime.now();
    var fromDate =
        now.subtract(Duration(days: now.weekday - 1)).millisecondsSinceEpoch;
    var toDate = now
        .add(Duration(days: DateTime.daysPerWeek - now.weekday))
        .millisecondsSinceEpoch;

    var url =
        '$dmcl_preorder/userInfoTarget?imei=${AppSetting.instance.deviceID}&FromDate=$fromDate&ToDate=$toDate';
    var req = NetRequest(url, 'get')..withAuthen(isTokenHeader: true);
    return req;
  }

  static NetRequest getStock(String sapCode) {
    String url =
        'https://dienmaycholon.vn/nhanvien/nhanvienkiemtrahangtonkho/$sapCode?imei=${AppSetting.instance.deviceID}';

    NetRequest req = NetRequest(url, 'get')..withAuthen(isTokenHeader: true);
    return req;
  }

  ///preorder/getsitestoresloc?imei=123&sap_code=145309
  static NetRequest getStockSlocFromGetGiaService(String sapCode) {
    String url =
        '$dmcl_preorder/getsitestoresloc?imei=${AppSetting.instance.deviceID}&sap_code=$sapCode';

    NetRequest req = NetRequest(url, 'get')..withAuthen(isTokenHeader: true);
    return req;
  }

  ///preorder/getallsite?imei=123&sap_code=150341
  static NetRequest getStockFromGetGiaService(String sapCode) {
    String url =
        '$dmcl_preorder/getallsite?imei=${AppSetting.instance.deviceID}&sap_code=$sapCode';

    NetRequest req = NetRequest(url, 'get')..withAuthen(isTokenHeader: true);
    return req;
  }

//1010018800
  static NetRequest getCustomerInfo(
      {String? customerId = '',
      String? mobilePhone = '',
      String? customerName = '',
      String? cmnd = ''}) {
    String url =
        '$dmcl_preorder/getinfocustomer?imei=${AppSetting.instance.deviceID}';

    var data = {
      "CustomerId": customerId,
      "MobilePhone": mobilePhone,
      "CustomerName": customerName,
      "CMND": cmnd
    };

    NetRequest req = NetRequest(url, 'post', data: data)
      ..withAuthen(isTokenHeader: true);
    return req;
  }

  static NetRequest getDiscountMembership(String sapCode, String maKH,
      String profit, String cardType, String productType) {
    String url =
        '$dmcl_preorder/getdiscountformember?imei=${AppSetting.instance.deviceID}';

    // var data = {
    //   "MaKH": 1001003801,
    //   "LoaiThe": "C10000002",
    //   "DoanhSo": 41896000,
    //   "ItemID": 145137,
    //   "LoaiSP": "A"
    // };
    var data = {
      "MaKH": maKH,
      "LoaiThe": cardType,
      "DoanhSo": profit,
      "ItemID": sapCode,
      "LoaiSP": productType
    };

    NetRequest req = NetRequest(url, 'post', data: data)
      ..withAuthen(isTokenHeader: true);
    return req;
  }

  static NetRequest getDiscountMC(String sapCode) {
    String url =
        '$dmcl_preorder/getallsite?imei=${AppSetting.instance.deviceID}&sap_code=$sapCode';

    NetRequest req = NetRequest(url, 'get')..withAuthen(isTokenHeader: true);
    return req;
  }

  static NetRequest getWorkDate(String userId,
      {int mouth = 6, int year = 2023}) {
    String url =
        '$dmcl_preorder/getdatachamcong?imei=${AppSetting.instance.deviceID}';

    var data = {
      'month': mouth,
      'year': year,
    };

    NetRequest req = NetRequest(url, 'post', data: data)
      ..withAuthen(isTokenHeader: true);

    return req;
  }

  /// API chat bot telegram
  /// Gửi report message, kết hợp try catch để truy vấn lỗi trên ứng dụng
  /// telegram-bot: chatid = '-917999918'
  static NetRequest botReport(
      {String chatid = '-917999918',
      String request = '',
      String tokenRequest = '',
      String msg = ''}) {
    String token = '6271300269:AAHOMJ1im45N2RCF6czPY9cF7a7ikvwghD4';
    String _tokenRequest =
        tokenRequest.isEmpty ? AppSetting.instance.accessToken : tokenRequest;
    String reportFormat =
        'Url: $request\nToken: $_tokenRequest\nLỗi xảy ra:$msg';
    String url =
        '$telegram_api_bot$token/sendmessage?chat_id=$chatid&text=$reportFormat';
    NetRequest req = NetRequest(url, 'get');
    return req;
  }

  static NetRequest update_ota(List<Map<String, dynamic>> packageInfo) {
    var url = '$dmcl_mobile/getUpdate';

    var data = packageInfo;

    NetRequest req = NetRequest(url, 'post', data: data);
    return req;
  }
}
