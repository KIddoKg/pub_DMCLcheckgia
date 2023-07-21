// ignore_for_file: unused_field

import 'dart:developer';

import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:dio/dio.dart';
// import 'package:pub_DMCLcheckgia/models/notificationModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../helper/appsetting.dart';
class NetResponseList extends NetResponse {
  int total;
  int pageIndex;
  int size;
  int pageCount;
  int totalPage;

  NetResponseList.fromJson(Map<String, dynamic> json)
      : total = json['meta']['pagination']['total'],
        pageIndex = json['meta']['pagination']['current_page'],
        size = json['meta']['pagination']['per_page'],
        pageCount = json['meta']['pagination']['count'],
        totalPage = json['meta']['pagination']['total_pages'],
        super.fromJson(json);
}

class NetResponse {
  late Map<String, dynamic>? meta;

  /// Response data Map type or orignal data
  late dynamic orignal;
  late dynamic data;
  late bool isSuccess;
  late Map<String, dynamic>? error;

  // NetResponse(
  //     bool success, dynamic data, dynamic error, Map<String, dynamic>? meta) {
  //   this.data = data;
  //   isSuccess = success;
  //   this.error = error;
  //   this.meta = meta;
  // }

  NetResponse(this.isSuccess, this.data, this.error, this.meta);

  NetResponse.fromJson(Map<String, dynamic> json)
      : meta = json['meta'],
  // isSuccess = json['meta']['success'],
  // isSuccess = json['isSuccess'],
        error = json['error'],
        data = json['data'];


  // // json[$'ảg']
  //
  // // if (T != null) return type.fromJson(json) as T;
  // //
  // if (T != null) return ProductModel.fromJson(json) as T;
  // //
  // // if (T == AppSetting) return AppSetting.fromJson(json) as T;
  // //
  // // if (T == ProductModel) return ProductModel.fromJson(json) as T;
  // //
  // // if (T == ProductDetailModel) return ProductDetailModel.fromJson(json) as T;
  // //
  // // if (T == ProductPreorderModel) {
  // //   return ProductPreorderModel.fromJson(json) as T;
  // // }
  // //
  // // if (T == StockModel) return StockModel.fromJson(json) as T;
  // //
  // // if (T == NotificationModel) return NotificationModel.fromJson(json) as T;
  // //
  // // if (T == WorkDateModel) return WorkDateModel.fromMap(json) as T;


  T cast<T>({required dynamic Function(Map<String, dynamic>) fromJson}) {
  var json = data!;
  return fromJson(json) as T;
  }
  List<T> castList<T>({List? fromList, required T Function(Map<String, dynamic>) fromJson}) {
    var listMap = fromList ?? [];
    var lst = listMap.map((e) => fromJson(e)).toList();
    return lst;
  }



  // List<T> castList<T>({List? fromList, required dynamic Function(Map<String, dynamic>) fromJson}) {
  // var listMap = (data is List) ? (data as List) : fromList!;
  // var lst = listMap.map((e) => cast<T>(fromJson: fromJson)).toList();
  // return lst;
  // }



  // List<T> castList<T>({List? fromList, required dynamic Function(Map<String, dynamic>) fromJson}) {
  //   var listMap = (data is List) ? (data as List) : fromList!;
  //   var lst = listMap.map((e) => cast<T>(fromJson: e)).toList();
  //   return lst;
  // }

  void catchError(Function(Map<String, dynamic>) onError) {
    onError(error!);

    log('onError $error');
  }
}

class NetRequest {
  late String url;
  late String method;
  // late Map<String, dynamic>? data;
  late Object? data;
  late Map<String, dynamic>? header;
  CancelToken canceltoken = CancelToken();
  NetRequest(this.url, this.method, {this.header, this.data});

  late BuildContext _context;
  NetRequest setContext(BuildContext ctx) {
    _context = ctx;
    return this;
  }

  void withAuthen({bool isTokenHeader = false}) async {
    header = header ?? <String, dynamic>{};
    if (AppSetting.instance.accessToken.isEmpty) {
      throw {'message': 'Có lỗi trong phiên đăng nhập. Vui lòng đăng nhập lại'};
    }
    if (isTokenHeader) {
      header!['token'] = AppSetting.instance.accessToken;
    } else {
      header!['Authorization'] = AppSetting.instance.accessToken;
    }

    log('dio.authen: ${AppSetting.instance.accessToken}');
  }

  void withUserAgent() {
    header = header ?? <String, dynamic>{};
    header!['user-agent'] = AppSetting.instance.ua.replaceFirst('Đ', 'D');

    log('dio.user-agent: ${AppSetting.instance.ua}');
  }

  /// Setup console log for debug
  void configLogRequest(Dio dio) {
    dio.interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: true));

    dio.interceptors.add(PrettyDioLogger(
      requestHeader: false,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
    ));
  }

  Future<NetResponse> request() async {
    Map<String, dynamic>? error;

    Dio dio = Dio();

    configLogRequest(dio);
    Options options = Options(
        method: method, headers: header, validateStatus: (status) => true);
    try {
      var response = await dio.request(url,
          cancelToken: canceltoken,
          // queryParameters: data,
          data: this.data,
          options: options);

      // lỗi http
      if (response.statusCode != 200) {
        {
          if (response.data['status'] != 200) {}
          var res = NetResponse.fromJson(response.data);
          res.isSuccess = false;
          var error = {
            "code": response.statusCode.toString(),
            'message': response.data['message'] ?? response.statusMessage ?? ''
          };
          return NetResponse(false, null, error, null);
        }
      }

      // dữ liệu trả về có thể có lỗi
      if (response.data['status'] != null && response.data['status'] != 200) {
        var res = NetResponse.fromJson(response.data);
        res.isSuccess = false;
        var error = {
          "code": response.data['status'].toString(),
          'message': response.data['message'] ?? ''
        };
        return NetResponse(false, null, error, null);
      }

      bool isMap = response.data is Map<String, dynamic>;
      var data = isMap ? response.data['data'] : response.data;
      var error = isMap ? response.data['error'] : null;
      var x = NetResponse(true, data, error, response.data['meta']);
      x.orignal = response.data;
      return x;
    } on DioException catch (e) {
      error = {"code": 'DioError | ${e.type}', 'message': e.error};

      log('dio.error $e');
      // await API
      //     .botReport(request: url, msg: '[dmcl.checkgia] ${e.message}')
      //     .request();

      return NetResponse(false, null, error, null);
    }
  }

  void cancel() {
    canceltoken.cancel();
  }
}
