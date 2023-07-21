import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ua_client_hints/ua_client_hints.dart';

class AppSetting {
  String deviceID = '';
  String deviceOS = '';
  bool deviceSupportBiometric = false;
  String passwordCache = '';
  bool isFirstInstalled = true;
  bool isWrongDeviceRegistration = false;
  bool enableMaterial3 = false;

  /// User-agent của thiết bị
  String ua = '';

  String? _qrText;

  AppLifecycleState? appLifecycleState;

  ///
  /// Set [value] text for qr scan, function callback [AppSetting.instance.onChangeQRText] will receive event when qrText change
  ///
  set qrText(String value) {
    _qrText = value;
    _onChangeQR(value);
  }

  String get qrText => _qrText ?? '';

  late String accessToken;
  late String refreshToken;
  int lastNotificationCount = 0;
  bool enableAuthenLocal = true;
  String version = '1.1@build23052023';

  AppSetting._internal();

  static final AppSetting _instance = AppSetting._internal();
  static AppSetting get instance => _instance;

  static late SharedPreferences pref;

  factory AppSetting.fromJson(Map<String, dynamic> json) {
    _instance.accessToken = json['token'] ?? '';
    // _instance.refreshToken = json['refreshToken'] && '';
    return _instance;
  }

  factory AppSetting.loadConfig(Map<String, dynamic> json) {
    // _instance.isAcceptPushNoti = json['isAcceptPushNoti'] ?? false;
    _instance.lastNotificationCount = json['lastNotification'] ?? 0;
    _instance.accessToken = json['token'] ?? '';
    _instance.enableAuthenLocal = json['enableAuthenLocal'] ?? false;
    _instance.deviceSupportBiometric = json['deviceSupportBiometric'] ?? false;
    _instance.enableMaterial3 = json['enableMaterial3'] ?? false;

    log('appsetting.load $json');
    return _instance;
  }

  Map<String, dynamic> toJson() {
    return {
      // "isAcceptPushNoti": _instance.isAcceptPushNoti,
      "lastNotification": _instance.lastNotificationCount,
      "token": _instance.accessToken,
      "enableAuthenLocal": _instance.enableAuthenLocal,
      "deviceSupportBiometric": _instance.deviceSupportBiometric,
      'enableMaterial3': _instance.enableMaterial3

      // "refreshToken": _instance.refreshToken
    };
  }

  static init() async {
    _instance.deviceOS = Platform.operatingSystem;

    var deviceInfo = DeviceInfoPlugin();
    var data = Platform.isAndroid
        ? await deviceInfo.androidInfo
        : await deviceInfo.iosInfo;

    if (data is AndroidDeviceInfo) {
      _instance.deviceID = data.id;
      log('appsetting.deviceId ${data.id}');
    } else if (data is IosDeviceInfo) {
      _instance.deviceID = data.identifierForVendor!;
    }

    _instance.ua = await userAgent();

    pref = await SharedPreferences.getInstance();

    _instance.isFirstInstalled = pref.containsKey('@appVersion');
    if (!_instance.isFirstInstalled) {
      pref.setString('@appVersion', _instance.version);
    } else {
      AppSetting.instance.version = pref.getString('@appVersion')!;
    }

    var hasConfig = pref.containsKey('@appSetting');
    if (hasConfig) {
      var json = pref.getString('@appSetting');
      var objJson = jsonDecode(json!);
      AppSetting.loadConfig(objJson);
    }
  }

  void reset() {
    pref.remove("@profile");

    _instance.accessToken = '';
    _instance.refreshToken = '';

    log('AppSetting.reset clean profileLocal');
  }

  ///
  /// `onChangeQRText` will callback when [AppSetting.instance.qrText] assign value
  ///
  void Function(String)? onChangeQRText;
  void _onChangeQR(String text) {
    if (onChangeQRText != null) onChangeQRText!(text);
  }

  void save() async {
    var json = _instance.toJson();
    pref.setString('@appSetting', jsonEncode(json));

    log('appsetting.save $json');
  }

  static AppSetting modify(
      {int? lastNoti,
      bool? isAcceptNotiPush,
      bool? enableAuthenLocal,
      bool? enableMaterial3}) {
    // _instance.isAcceptPushNoti = isAcceptNotiPush ?? _instance.isAcceptPushNoti;
    _instance.lastNotificationCount =
        lastNoti ?? _instance.lastNotificationCount;
    _instance.enableAuthenLocal =
        enableAuthenLocal ?? _instance.enableAuthenLocal;
    _instance.enableMaterial3 = enableMaterial3 ?? _instance.enableMaterial3;
    return _instance;
  }
}
