import 'dart:developer';

import 'package:pub_checkgia/models/UserModel.dart';
import 'package:pub_checkgia/screen/account/account_screen.dart';
import 'package:pub_checkgia/screen/home_screen.dart';
import 'package:pub_dmclcheckgia/pub_DMCLcheckgia.dart';
import 'package:pub_checkgia/services/services_temp.dart';
import 'package:pub_checkgia/services/socketClient.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with WidgetsBindingObserver {
  int _tabIndex = 0;

  List<BottomNavigationBarItem> tabs = [
    const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
    const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
  ];

  List<NavigationRailDestination> rails = [
    const NavigationRailDestination(icon: Icon(Icons.home), label: Text('')),
    const NavigationRailDestination(
        icon: FaIcon(FontAwesomeIcons.user), label: Text('')),
  ];

  var tabViews = [
    HomeScreen(),
    // OrderScreen(),
    const AccountScreen(),
    // UserScreen(),
  ];

  GlobalKey qrKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    Services.instance.setContextSnackbar(context);
    DMCLSocket.instance.setContext(context);

    initFCM();
    initData();
  }

  initFCM() async {
    var initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.pushNamed(context, '/notification',
            arguments: {'messageId': initialMessage.messageId});
        log('notification.click fromTerminal');
      });
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        Navigator.pushNamed(
          context,
          '/notification',
        );
        log('notification.click fromBackground');
      });
    });
  }

  initData() async {
    await Future.delayed(const Duration(milliseconds: 555));

    if (AppSetting.instance.isFirstInstalled &&
        !UserModel.instance.isDeviceVerify) {
      initGuideApp();
    }
  }

  void createGuideStep(
      {required String title,
      String? content,
      bool enableCloseIcon = false,
      bool autoDismiss = false,
      IconData? icon,
      Color? iconColor = Colors.greenAccent,
      String? actionLabel,
      void Function()? action}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.transparent,
      showCloseIcon: !enableCloseIcon ? autoDismiss : enableCloseIcon,
      closeIconColor: Colors.white54,
      elevation: 0,
      padding: const EdgeInsets.all(8),
      content: Container(
        decoration: BoxDecoration(
            color: Colors.black87, borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(
                icon ?? Icons.info,
                color: iconColor,
              ),
              const SizedBox(
                width: 8,
              ),
              Flexible(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (content != null)
                      Column(
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            content,
                            maxLines: 3,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              if (action != null)
                ElevatedButton(
                    onPressed: () {
                      action();
                    },
                    child: Text(actionLabel!))
            ],
          ),
        ),
      ),
      duration:
          Duration(hours: autoDismiss ? 0 : 8, seconds: autoDismiss ? 12 : 0),
    ));
  }

  void initGuideApp() {
    createGuideStep(
        title: 'Thiết bị chưa được đăng ký.',
        content: 'Bạn cần đăng ký để sử dụng đầy đủ các tính năng ứng dụng.',
        icon: Icons.warning,
        iconColor: Colors.amberAccent,
        actionLabel: 'Đến cài đặt',
        action: () async {
          _tabIndex = 1;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          setState(() {});

          await Future.delayed(const Duration(milliseconds: 125));

          createGuideStep(
              title: 'Chọn Thông tin cá nhân > Đăng ký thiết bị',
              icon: Icons.warning,
              iconColor: Colors.amberAccent);
        });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    AppSetting.instance.appLifecycleState = state;

    log('appLifecyle.state $state');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isTabAccount = _tabIndex == 1;
    var isKeyboardShow =
        MediaQuery.of(context).viewInsets.bottom != 0 ? true : false;

    return Scaffold(
        extendBody: true,
        bottomNavigationBar: MediaQuery.of(context).size.width < 640
            ? BottomAppBar(
                clipBehavior: Clip.antiAlias,
                elevation: 0,
                shape: const CircularNotchedRectangle(),
                // color: Theme.of(context).primaryColor.withAlpha(255),
                // notchMargin: ,
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  items: tabs,
                  currentIndex: _tabIndex,
                  onTap: (index) => onTapItem(index),
                  selectedItemColor: GlobalStyles.primaryColor,
                  unselectedItemColor: Colors.grey,
                  showUnselectedLabels: true,
                ),
              )
            : null,
        body: NotificationListener<AppNotifi>(
          onNotification: (notification) {
            var registerDevice =
                notification.value == AppNotifiType.registerDevice;
            if (registerDevice) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();

              createGuideStep(
                  title: 'Bạn đã đăng ký thiết bị thành công.',
                  content:
                      'Lưu ý: Khi đổi sang thiết bị khác, để sử dụng bạn cần liên hệ quản lý để cấp lại quyền đăng ký thiết bị mới.',
                  icon: Icons.check,
                  enableCloseIcon: true,
                  autoDismiss: true);
            }
            return false;
          },
          child: Row(
            children: [
              if (MediaQuery.of(context).size.width >= 640)
                SafeArea(
                  child: NavigationRail(
                      onDestinationSelected: (int index) {
                        onTapItem(index);
                      },
                      labelType: NavigationRailLabelType.all,
                      destinations: rails,
                      minWidth: 55.0,
                      selectedIndex: _tabIndex),
                ),
              Expanded(child: tabViews[_tabIndex])
            ],
          ),
        ),
        // floatingActionButtonLocation: isTabAccount
        //     ? FloatingActionButtonLocation.endFloat
        //     : FloatingActionButtonLocation.centerDocked,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton:
            !UserModel.instance.isDeviceVerify || isTabAccount || isKeyboardShow
                ? null
                : Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton(
                        backgroundColor: GlobalStyles.primaryColor,
                        // backgroundColor: Colors.transparent,
                        elevation: 0,
                        onPressed: () {
                          showQRView();
                        },
                        child: const Icon(
                          Icons.qr_code,
                          size: 28,
                        ),
                      ),
                    ),
                  ));
  }

  onTapItem(index) {
    setState(() {
      _tabIndex = index;
    });
  }

  void showQRView() async {
    var result = await showDialog(
      useRootNavigator: true,
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (_, setState) => Material(
          child: Container(
            color: Colors.grey,
            child: Stack(
              children: [
                Positioned.fill(
                  child: QRView(
                    key: qrKey,
                    overlay: QrScannerOverlayShape(
                        cutOutWidth: MediaQuery.of(context).size.width * 0.8,
                        cutOutHeight: MediaQuery.of(context).size.width * 0.8,
                        cutOutBottomOffset: 270),
                    // overlayMargin: const EdgeInsets.all(16),
                    onQRViewCreated: (controller) {
                      controller.scannedDataStream.listen(
                        (event) {
                          log('scan.data ${event.code} | ${event.format}');

                          controller.dispose();
                          Navigator.pop(context, event);
                        },
                      );
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.4,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      const Text(
                        'Kết quả',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: const Card(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'http://192.168.1.22:6789/svGetGiaBan.svc/GetDoanhSoBonusNV?SiteId=s023&EmployeeId=ES030026&FromDate=2023-07-03&ToDate=2023-07-09&Thang=07&Nam=2023',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 15, color: Colors.black54),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color.fromARGB(231, 255, 82, 82),
                      child: IconButton(
                          iconSize: 32,
                          onPressed: () {
                            Navigator.pop(context, null);
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          )),
                    ))
              ],
            ),
          ),
        ),
      ),
    );

    if (result != null) {
      var code = result.code as String;

      var isURL = Uri.tryParse(code)?.hasAbsolutePath ?? false;
      if (isURL) {
        // List lst = result.code.split('/');
        // var productCode = lst.last.split('-').last;
        // productCode = productCode.split('?').first;

        var url = code.replaceAll('https://', '');
        var result = await Services.instance.searchQrCode(url);
        if (result.isNotEmpty) {
          AppSetting.instance.qrText = result;
        }
      } else {
        AppSetting.instance.qrText = result.code;
      }
    }
  }
}
