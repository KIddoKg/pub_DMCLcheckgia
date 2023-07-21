// ignore_for_file: unused_field

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import '../../helper/appsetting.dart';

import 'package:flutter/cupertino.dart';

import 'dio_helper.dart';

class Services {
  BuildContext? _context;
  BuildContext? _contextSnackbar;

  Services._internal();

  static final Services _instance = Services._internal();

  static Services get instance => _instance;

  Services setContextSnackbar(BuildContext context) {
    Services.instance._contextSnackbar = context;
    return _instance;
  }

  Services setContext(BuildContext? context) {
    Services.instance._context = context;
    return _instance;
  }

  void _showAlert(String title, String message,
      {void Function()? onTap,
        List<CupertinoButton>? actions,
        List<ElevatedButton>? actionAndroids}) async {
    if (_context == null) return;

    await showCupertinoDialog(
        context: _context!,
        builder: (context) =>
            CupertinoAlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                if (actions == null)
                  CupertinoButton(
                      child: const Text('Đồng ý'),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                if (actions != null) ...actions
              ],
            ));

    if (onTap != null) onTap();
  }

  void _gotoAuthenScreen() {
    Navigator.push(
        _context!,
        MaterialPageRoute(
            builder: (ctx) =>
                WillPopScope(
                  child:Text(""),
                  onWillPop: () => Future.value(false),
                )));
  }

  void _errorAction(NetResponse res,
      {String? metaData, bool withLoadingBefore = false}) async {
    String code = res.error!['code'];
    String message = res.error?['message'] ??= '';

    if (_context == null) log('Chưa gán context cho mã lỗi "$code" này');
    log('> services.context: $_context', stackTrace: StackTrace.current);

    // if (withLoadingBefore) Navigator.pop(_context!);

    switch (code) {
      case 'unauthorized':
      // case '401':

      // _showAlert('Thông báo', 'Hết thời gian đăng nhập. [Mã: $code]',
      //     onTap: () => _gotoAuthenScreen());

      // var res = await refreshToken();
        if (!res.isSuccess) {
          _showAlert('Thông báo',
              'Phiên đăng nhập hết hiệu lực.\nBạn cần phải đăng nhập lại. [Mã: $code]',
              onTap: () => _gotoAuthenScreen());
        } else {
          // res.cast<AppSetting>(fromJson: res.data);

          var y = json.encode(AppSetting.instance.toJson());
          AppSetting.pref.setString('appsetting', y);
        }
        break;
      default:
        _showAlert(metaData ?? 'Thông báo', '$message. [Mã lỗi: $code]',
            actionAndroids: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  onPressed: () {
                    Navigator.pop(_context!);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Bỏ qua'),
                  ))
            ]);
        break;
    }
  }
  // void _errorAction(NetResponse res,
  //     {String? metaData, bool withLoadingBefore = false}) async {
  //   // ... your existing implementation ...
  // }

  // Make _errorAction accessible from outside the class by changing its visibility.
  void errorAction(NetResponse res,
      {String? metaData, bool withLoadingBefore = false}) {
    _errorAction(res, metaData: metaData, withLoadingBefore: withLoadingBefore);
  }

  void Function(String url, NetResponse?)? whenCompleted;
}