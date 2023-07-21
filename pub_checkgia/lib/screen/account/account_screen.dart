// ignore_for_file: non_constant_identifier_names, no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'dart:developer';


import 'package:pub_checkgia/models/UserModel.dart';
import 'package:pub_checkgia/models/userInfoModel.dart';
import 'package:pub_checkgia/screen/account/workDateWidget.dart';
import 'package:pub_checkgia/services/services_temp.dart';
import 'package:pub_dmclcheckgia/pub_DMCLcheckgia.dart';
import 'package:pub_checkgia/services/socketClient.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String imei = '';
  bool isDeviceVerify = false;
  UserInfoTarget? userTarget;

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Widget accountAppBar(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: height * .2),
      child: Container(
        color: GlobalStyles.backgroundColorAppBar,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AvatarLoad(
                UserModel.instance.avatarLink,
                editAvatar: true,
                // size: 45,
                onPickerImage: (pathImage) {
                  UserModel.instance.avatarLink = pathImage;
                  UserModel.instance.save();
                  setState(() {});
                },
              ),
              const SizedBox(
                height: 8,
              ),
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      UserModel.instance.name,
                      style: const TextStyle(
                          fontStyle: FontStyle.normal,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const VerticalDivider(
                      width: 15,
                      color: Colors.white,
                      thickness: 1,
                    ),
                    Text(
                      UserModel.instance.userType.description,
                      style: const TextStyle(
                          fontStyle: FontStyle.normal,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 5),
                child: Text(
                  'CN ${UserModel.instance.siteId}',
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
              ),
              if (userTarget != null)
                Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, bottom: 8, left: 24, right: 24),
                  child: Column(
                    children: [
                      DMCLProgressbar(
                        // progress: 10 * (userTarget!.rate / 100),
                        progress: 10,
                        foregroundColor: Colors.amberAccent,
                        height: 10,
                      ),

                      DMCLRowText(
                        'Tỉ lệ',
                        '${userTarget!.rate}%',
                        styleTitle: const TextStyle(color: Colors.white),
                        styleValue: const TextStyle(color: Colors.white),
                      ),

                      // DMCLRowText(
                      //   'Tỉ lệ',
                      //   '10%',
                      //   styleTitle: const TextStyle(color: Colors.white),
                      //   styleValue: const TextStyle(color: Colors.white),
                      // ),

                      // DMCLRowText(
                      //     'Tổng', userTarget!.total.toCurrency()),
                      // DMCLRowText('Điểm thưởng',
                      //     userTarget!.totalPoint.toString())
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: GlobalStyles.primaryColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: accountAppBar(context),
          ),
          SliverToBoxAdapter(
            child: Container(height: 8),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 58.0, right: 8, left: 8),
              child: SingleChildScrollView(
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 16, bottom: 16, left: 16, right: 16.0),
                      child: Column(
                        children: [
                          ExpansionTile(
                            leading: const Icon(
                              Icons.person_pin,
                              // color: GlobalStyles.primaryColor,
                            ),
                            tilePadding:
                                const EdgeInsets.symmetric(vertical: -0),
                            title: Container(
                                alignment: const Alignment(-1.25, 1),
                                child: const Text('Thông tin cá nhân')),
                            children: [
                              DMCLRowText(
                                'Tên nhân viên',
                                UserModel.instance.name,
                                styleValue: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              DMCLRowText(
                                'Chi nhánh',
                                UserModel.instance.siteId,
                                styleValue: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'ID thiết bị',
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 16),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          imei,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        )
                                      ],
                                    ),
                                    // DMCLRowText(
                                    //   'ID thiết bị',
                                    //   imei,
                                    //   spacing: 10,
                                    //   styleValue: const TextStyle(
                                    //     fontWeight: FontWeight.w500,
                                    //     // color: GlobalStyles.backgroundDisableColor,
                                    //   ),
                                    // ),
                                    ElevatedButton(
                                        onPressed: !isDeviceVerify
                                            ? () async {
                                                // [be need fix] formdata -> raw

                                                ///
                                                /// TODO: cần cập nhật lại trạng thái khi trả về dữ liệu sai
                                                /// hiện tại chỉ đúng với trường hợp đăng ký thành công
                                                ///
                                                var result = await Services
                                                    .instance
                                                    .registerDevice(imei);
                                                if (result is Map) {
                                                  AppSetting.instance
                                                    ..accessToken =
                                                        result['token']
                                                    ..save();

                                                  UserModel.fromJson(result
                                                          as Map<String,
                                                              dynamic>)
                                                      .save();

                                                  isDeviceVerify = true;
                                                  setState(() {});
                                                  log('registerDevice.success');

                                                  AppNotifi(
                                                          value: AppNotifiType
                                                              .registerDevice)
                                                      .dispatch(context);
                                                } else {
                                                  log('register.device error');
                                                }
                                              }
                                            : null,
                                        child: Text(isDeviceVerify
                                            ? 'Đã đăng ký'
                                            : 'Đăng ký thiết bị'))
                                  ],
                                ),
                              ),
                              Column(
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DMCLRowText(
                                    'Ngày công',
                                    '',
                                    styleValue: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  UIWorkDate(
                                    delegateInitView: (controller) {
                                      controller.animateTo(200,
                                          duration:
                                              const Duration(milliseconds: 275),
                                          curve: Curves.easeOut);
                                    },
                                  ),
                                ],
                              ),
                              if (userTarget != null)
                                Visibility(
                                  visible: false,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text('Doanh số'),
                                    subtitle: Column(
                                      children: [
                                        DMCLProgressbar(
                                          progress:
                                              width * (userTarget!.rate / 100),
                                          foregroundColor: Colors.amberAccent,
                                          height: 20,
                                        ),

                                        DMCLRowText(
                                          'Tỉ lệ',
                                          '${userTarget!.rate}%',
                                        ),

                                        // DMCLRowText(
                                        //     'Tổng', userTarget!.total.toCurrency()),
                                        // DMCLRowText('Điểm thưởng',
                                        //     userTarget!.totalPoint.toString())
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                            onExpansionChanged: (value) {
                              log('expan.state $value');
                              if (value) {
                                loadSalesInfo();
                                // loadWordDate();
                              }
                              setState(() {});
                              // if (value) {
                              //   var now = DateTime.now().day;
                              //   scrollController.animateTo(200,
                              //       duration: const Duration(milliseconds: 275),
                              //       curve: Curves.easeInOut);
                              // }
                            },
                          ),

                          // thay đổi giao diện ứng dụng
                          Visibility(
                            visible: false,
                            child: ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                leading: const Icon(Icons.design_services),
                                title: Container(
                                    alignment: const Alignment(-1.25, 1),
                                    child: const Text('Giao diện ứng dụng')),
                                children: [
                                  Row(
                                    // direction: Axis.horizontal,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ...[
                                        {
                                          'title': 'Cơ bản',
                                          'mode': UXAdvanceMode.normal
                                        },
                                        {
                                          'title': 'Nâng cao',
                                          'mode': UXAdvanceMode.advance
                                        }
                                      ]
                                          .map(
                                            (e) => Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.4,
                                              decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(children: [
                                                  Container(
                                                    clipBehavior: Clip.hardEdge,
                                                    decoration: BoxDecoration(
                                                        color: Colors.black45,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                    child: Image.network(
                                                      'https://i.stack.imgur.com/MIlnD.png',
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8.0,
                                                            bottom: 8),
                                                    child: Text(
                                                        (e['title'] as String)),
                                                  ),
                                                  Radio<UXAdvanceMode>(
                                                    value: e['mode']
                                                        as UXAdvanceMode,
                                                    groupValue: AppSetting
                                                            .instance
                                                            .enableMaterial3
                                                        ? UXAdvanceMode.advance
                                                        : UXAdvanceMode.normal,
                                                    onChanged: (value) {
                                                      var state = e['mode'] ==
                                                          UXAdvanceMode.advance;

                                                      AppSetting.instance
                                                              .enableMaterial3 =
                                                          state;

                                                      setState(() {});

                                                      log('pass. $state');

                                                      AppNotifi(
                                                              mode: e['mode']
                                                                  as UXAdvanceMode)
                                                          .dispatch(context);

                                                      showAlert(
                                                          context,
                                                          'Thay đổi giao diện',
                                                          'Giao diện ứng dụng được thay đổi',
                                                          actionAndroids: [
                                                            ElevatedButton(
                                                              child: const Text(
                                                                  'Đồng ý'),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            )
                                                          ]);
                                                    },
                                                  )
                                                ]),
                                              ),
                                            ),
                                          )
                                          .toList()

                                      // Container(
                                      //   width:
                                      //       MediaQuery.of(context).size.width * 0.4,
                                      //   decoration: BoxDecoration(
                                      //       color: Colors.black45,
                                      //       borderRadius: BorderRadius.circular(20)),
                                      //   child: Padding(
                                      //     padding: const EdgeInsets.all(8.0),
                                      //     child: Column(children: [
                                      //       Image.network(
                                      //         'https://i.stack.imgur.com/MIlnD.png',
                                      //         width: 275,
                                      //         height: 175,
                                      //       ),
                                      //       const Text('Cơ bản'),
                                      //       Radio(
                                      //         value:
                                      //             AppSetting.instance.enableMaterial3,
                                      //         groupValue: 'normal',
                                      //         onChanged: (value) {
                                      //           AppSetting.instance.enableMaterial3 =
                                      //               value == 'normal';
                                      //           setState(() {});
                                      //         },
                                      //       )
                                      //     ]),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ]),
                          ),

                          ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            leading: const Icon(Icons.notifications),
                            title: Container(
                                alignment: const Alignment(-1.25, 1),
                                child: const Text('Cài đặt thông báo')),
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DMCLRow(
                                    height: 22,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    title: const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Thông báo đẩy',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    child: Switch(
                                      value: UserModel
                                          .instance.enablePushNotification,
                                      onChanged: (value) async {
                                        if (!UserModel.instance.isNotice) {
                                          showAlert(context, 'Thông báo',
                                              'Bạn chưa được phân quyền để sử dụng tính năng này.\n\nLiên hệ quản lý để kiểm tra lại.');
                                          return;
                                        }

                                        if (!UserModel
                                            .instance.enablePushNotification) {
                                          subcriptionTopic();
                                        } else {
                                          unsubcriptionTopic();
                                        }
                                      },
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Các kênh đăng ký nhận thông báo',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 14),
                                      ),
                                      ...UserModel.instance.groupNotices
                                          .map(
                                            (e) => Text(
                                              '• $e',
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14),
                                            ),
                                          )
                                          .toList()
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  )
                                ],
                              ),
                            ],
                          ),
                          ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            // childrenPadding: const EdgeInsets.all(8),
                            leading: const Icon(Icons.security),
                            title: Container(
                                alignment: const Alignment(-1.25, 1),
                                child: const Text('Cài đặt bảo mật')),
                            children: [
                              SwitchListTile(
                                  contentPadding: const EdgeInsets.only(
                                      left: 0, right: 0, top: 0, bottom: 8),
                                  title: const Text(
                                      'Sử dụng vân tay để đăng nhập'),
                                  subtitle: const Text(
                                      'Cài đặt đăng nhập bằng vân tay sẽ thay thế mật khẩu của bạn.'),
                                  value: AppSetting.instance.enableAuthenLocal,
                                  onChanged: (value) {
                                    AppSetting.modify(enableAuthenLocal: value)
                                        .save();
                                    setState(() {});
                                  }),
                              // SwitchListTile(
                              //     contentPadding: const EdgeInsets.only(
                              //         left: 0, right: 0, top: 0, bottom: 8),
                              //     title: const Text('Quét khuôn mặt'),
                              //     subtitle: const Text(
                              //         'Cài đặt đăng nhập bằng quét khuôn mặt sẽ thay thế mật khẩu của bạn.'),
                              //     value: AppSetting.instance.enableAuthenLocal,
                              //     onChanged: (value) {
                              //       AppSetting.modify(enableAuthenLocal: value)
                              //           .save();
                              //       setState(() {});
                              //     })
                            ],
                          ),
                          ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            leading: const Icon(Icons.privacy_tip),
                            title: Container(
                                alignment: const Alignment(-1.35, 1),
                                child: const Text('Điều khoản và chính sách')),
                            children: [
                              Visibility(
                                visible: true,
                                child: ListTile(
                                  title: const Text('Điều khoản sử dụng'),
                                  onTap: () {
                                    var url =
                                        'https://dienmaycholon.vn/trang-dieu-khoan-su-dung';
                                    launchUrlString(url,
                                        mode: LaunchMode.externalApplication,
                                        webOnlyWindowName: 'Điện Máy Chợ Lớn');
                                  },
                                ),
                              ),
                              Visibility(
                                visible: true,
                                child: ListTile(
                                  title: const Text('Chính sách bảo hành'),
                                  onTap: () {
                                    var url =
                                        'https://dienmaycholon.vn/chinh-sach-bao-hanh';
                                    // canLaunchUrlString(url, );
                                    launchUrlString(url,
                                        mode: LaunchMode.externalApplication,
                                        webOnlyWindowName: 'Điện Máy Chợ Lớn');
                                  },
                                ),
                              )
                            ],
                          ),
                          ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            leading: const Icon(Icons.security_update_good),
                            title: Container(
                                alignment: const Alignment(-1.25, 1),
                                child: const Text('Phiên bản ứng dụng')),
                            // subtitle: Text(AppSetting.instance.version),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppSetting.instance.version,
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),

                          const SizedBox(
                            height: 38,
                          ),
                          DMCLButton('Đăng xuất',
                              fontColor: Colors.white,
                              backgroundColor: Colors.redAccent, onTap: () {
                            showAlert(
                                context, 'Thông báo', 'Bạn có muốn đăng xuất ?',
                                actions: [
                                  CupertinoButton(
                                      child: const Text('Đồng ý'),
                                      onPressed: () async {
                                        Fluttertoast.showToast(
                                            msg: 'Đang đăng xuất');

                                        DMCLSocket.instance.socket!
                                            .disconnect();

                                        for (var element in UserModel
                                            .instance.groupNotices) {
                                          try {
                                            await FirebaseMessaging.instance
                                                .unsubscribeFromTopic(element);
                                          } catch (error) {
                                            Fluttertoast.showToast(
                                                msg:
                                                    'Có lỗi xảy ra khi đăng xuất. Bạn vẫn đăng xuất bình thường.');
                                          } finally {
                                            AppSetting.instance.reset();
                                            UserModel.instance.passwordCache =
                                                '';
                                            Navigator.pushNamedAndRemoveUntil(
                                                context,
                                                '/login',
                                                (route) => false,
                                                arguments: {'isLogout': true});
                                          }
                                        }

                                        AppSetting.instance.reset();
                                        Fluttertoast.cancel();

                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            '/login',
                                            (route) => false);
                                      }),
                                  CupertinoButton(
                                      child: const Text('Hủy'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      }),
                                ],
                                actionAndroids: [
                                  ElevatedButton(
                                      onPressed: () {
                                        logOut();
                                      },
                                      child: const Text('Đồng ý')),
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Hủy'))
                                ]);
                          }),
                          const SizedBox(
                            height: 8,
                          ),
                        ],
                      ),
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  loadData() async {
    imei = AppSetting.instance.deviceID;
    isDeviceVerify = UserModel.instance.isDeviceVerify;

    loadSalesInfo();

    if (mounted) {
      setState(() {});
    }
  }

// lấy thông tin danh số theo tháng hiện tại của nhân viên
  loadSalesInfo() async {
    var _userTarget = await Services.instance.getUserInfoTarget();

    userTarget = _userTarget;
    log('userTarget.rate ${userTarget!.rate}');
  }

  subcriptionTopic() async {
    for (var element in UserModel.instance.groupNotices) {
      FirebaseMessaging.instance.subscribeToTopic(element).then((value) {
        Fluttertoast.showToast(msg: 'Đăng ký thành công $element');
      }).catchError((error) {
        Fluttertoast.showToast(msg: 'Đăng ký không thành công $element');
      });
    }

    FirebaseMessaging.instance.subscribeToTopic('all').then((value) {
      Fluttertoast.showToast(msg: 'Đăng ký thành công all');
    }).catchError((error) {
      Fluttertoast.showToast(msg: 'Đăng ký không thành công all');
    });

    await Services.instance.updateUser(enablePush: true);
    setState(() {});
  }

  unsubcriptionTopic() async {
    try {
      for (var element in UserModel.instance.groupNotices) {
        // UserModel.instance.enablePushNotification = false;
        await FirebaseMessaging.instance.unsubscribeFromTopic(element);
      }
    } catch (error) {
      Fluttertoast.showToast(msg: 'Hủy đăng ký không thành công. Thử lại sau.');
    }

    await Services.instance.updateUser(enablePush: false);
    setState(() {});
  }

  void logOut() async {
    Fluttertoast.showToast(msg: 'Đang đăng xuất');

    try {
      DMCLSocket.instance.socket!.disconnect();
    } catch (error) {
      Fluttertoast.showToast(
          msg: 'Có lỗi xảy ra khi đăng xuất. Bạn vẫn đăng xuất bình thường.');
    } finally {
      AppSetting.instance.reset();
      // UserModel.instance.passwordCache = '';

      Fluttertoast.cancel();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }
}
