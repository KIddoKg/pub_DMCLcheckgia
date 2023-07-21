// ignore_for_file: file_names

import 'dart:convert';
import 'dart:developer';

import 'package:pub_dmclcheckgia/pub_DMCLcheckgia.dart';

class UserModel {
  late String accountId;
  late String username;
  late String name;
  late String siteId;
  late String siteName;
  late String avatarLink;
  late UserType userType;
  String passwordCache = '';

  String level = '';

  bool isTester = false;

  bool isDeviceVerify = false;

  /// User có quyền xem thông báo hay không
  bool isNotice = false;
  bool enablePushNotification = false;

  String phoneNumber = '';

  String sessionStart = '';
  String sessionEnd = '';

  List groupNotices = [];

  UserModel._internal();
  static final UserModel _instance = UserModel._internal();
  static UserModel get instance => _instance;

  factory UserModel.fromJson(Map<String, dynamic> json,
      {bool isLocalData = false}) {
    _instance.accountId = json['accountId'] ?? '';
    _instance.username = json['username'] ?? '';
    _instance.name = json['name'] ?? '';
    _instance.siteId = json['store'] ?? '';
    _instance.siteName = json['storeName'] ?? '';
    _instance.avatarLink = json['avatarLink'] ?? '';
    _instance.isDeviceVerify = json['is_authen'] ?? false;
    _instance.isNotice = json['is_notice'] ?? false;
    _instance.level = json['level'] ?? '';
    _instance.groupNotices = json['group_notice'] ?? [];
    _instance.passwordCache = json['passwordCache'] ?? '';
    _instance.sessionStart = json['sessionStart'] ?? '';

    /// Cho phép đăng ký/ hủy nhận thông báo đẩy
    _instance.enablePushNotification =
        json['enablePushNotifi'] == 0 ? false : true;

    // (json['group_notice'] as List) ?? [];
    _instance.userType = UserType.fromJson(json['userType'] ?? 0);
    if (!isLocalData) {
      var time = DateTime.now();
      _instance.sessionStart = time.millisecondsSinceEpoch.toDateString();
    }
    log('user.sessionStart ${_instance.sessionStart}');
    return _instance;
  }

  Map<String, dynamic> toJson() {
    return {
      "accountId": _instance.accountId,
      "name": _instance.name,
      "username": _instance.username,
      "store": _instance.siteId,
      "storeName": _instance.siteName,
      "avatarLink": _instance.avatarLink,
      "is_authen": _instance.isDeviceVerify,
      "is_notice": _instance.isNotice,
      "level": _instance.level,
      "group_notice": _instance.groupNotices,
      "sessionStart": _instance.sessionStart,
      "passwordCache": _instance.passwordCache,
      "enablePushNotification": _instance.enablePushNotification ? 1 : 0
    };
  }

  static sampleData() {
    _instance.accountId = '';
    _instance.username = 'khang trần';
    _instance.siteName = 'Quận 5';
    _instance.avatarLink = '';
  }

  void save() {
    var json = jsonEncode(toJson());
    AppSetting.pref.setString('@profile', json);
  }
}

enum UserType {
  staff,
  manager,
  hr;

  static UserType fromJson(int json) =>
      values.where((element) => element.index == json).first;

  String get description {
    switch (this) {
      case UserType.staff:
        return 'Nhân viên';
      case UserType.manager:
        return 'Quản lý';
      case UserType.hr:
        return 'Hành chính';
      default:
        return 'Nhân viên';
    }
  }
}
