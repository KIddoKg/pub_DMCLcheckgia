// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:pub_checkgia/models/UserModel.dart';
import 'package:pub_checkgia/screen/authen/progressionUpdate.dart';
import 'package:pub_checkgia/services/services_temp.dart';
import 'package:pub_checkgia/services/services_temp.dart';
import 'package:pub_checkgia/services/socketClient.dart';
import 'package:pub_dmclcheckgia/pub_DMCLcheckgia.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_installer/flutter_app_installer.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class StatusCheckVersion {
  static const String initApp = 'Khởi tạo ứng dụng';

  static const String checking = 'Kiểm tra phiên bản';
  static const String newVersion = 'Có phiên bản mới';
  static const String fileUpdateExits = 'Đã tải về phiên bản cập nhật';
  static const String done = 'Hoàn tất';
  static const String dowloading = 'Đang tải';
  static const String copyFile = 'Đang xử lý tệp';
  static const String installing = 'Đang cài đặt';
  static const String prepairFinish = 'Tối ưu dụng lượng';
}

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key, this.isContinues = false}) : super(key: key);

  bool isContinues;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController fieldPwd = TextEditingController();
  TextEditingController fieldUser = TextEditingController();

  bool hasToken = false;
  bool isHasInternet = false;
  bool isLoading = false;
  bool isTokenExpired = false;

  /// status checking update progress step;
  bool isCheckUpdate = false;

  /// status checking has new version, then download and install
  ///
  bool hasNewVersion = false;
  double progressingDownload = 0;
  String status = '';

  late AppLinks _appLinks;
  // ignore: unused_field
  late StreamSubscription _subUniURI;

  @override
  void initState() {
    super.initState();

    onInit();

    initUniLink();
    initUniStream();
  }

  Future onInit() async {
    await requestPermissions();
    await checkHasInternet();
    // await checkHasUpdate();

    await AppSetting.init();
    DMCLSocket.instance.initSocket();

    // Services.instance.registerDevice(AppSetting.instance.deviceID);

    if (widget.isContinues) return;

    bool isExits = AppSetting.pref.containsKey('@profile');
    if (isExits) {
      var user = AppSetting.pref.getString('@profile')!;
      log('> appsetting.profile: $user');
      var userJson = json.decode(user);
      UserModel.fromJson(userJson, isLocalData: true);

      var appsetting = json.decode(AppSetting.pref.getString('@appSetting')!);
      AppSetting.fromJson(appsetting);

      fieldUser.text = UserModel.instance.username;

      // TODO: kiểm tra authen quá 8 tiếng
      isTokenExpired = Services.instance.checkAuthenToken();
      if (isTokenExpired) {
        Fluttertoast.showToast(msg: 'Phiên đăng nhập đã hết hiệu lực.');

        if (AppSetting.instance.enableAuthenLocal &&
            UserModel.instance.passwordCache.isNotEmpty) {
          await onAuthenLocal();
          return;
        }
        return;
      }

      setState(() {
        hasToken = true;
      });

      isLoading = true;
      // case auto-login, connect socket and register user
      DMCLSocket.instance.setContext(context);
      DMCLSocket.instance.userConnect(UserModel.instance);

      Future.delayed(const Duration(milliseconds: 525), () {
        Navigator.pushNamedAndRemoveUntil(context, '/tabbar', (route) => false);
      });
      return;
    }
  }

  Future requestPermissions() async {
    var permissionStorage = (await Permission.storage.status);
    log('permission.storage $permissionStorage');
    if (permissionStorage.isDenied) {
      await Permission.requestInstallPackages.status;
    }

    var permissionInstallApp = await Permission.requestInstallPackages.status;
    log('permission.installApp $permissionInstallApp');

    if (permissionInstallApp.isDenied) {
      await Permission.requestInstallPackages.request();
    }

    var permissionManagerStorage =
        await Permission.manageExternalStorage.status;
    log('permission.managerStorage $permissionManagerStorage');

    if (permissionManagerStorage.isDenied) {
      await Permission.manageExternalStorage.request();
    }
  }

  Future checkHasInternet() async {
    var result = await Connectivity().checkConnectivity();
    var hasInternet = result == ConnectivityResult.none ? false : true;
    isHasInternet = hasInternet;
    setState(() {});

    Connectivity().onConnectivityChanged.listen((event) {
      if (result == event) return;

      hasInternet = event == ConnectivityResult.none ? false : true;

      var stringNoInternet =
          'Thiết bị không kết nối mạng.\nVui lòng kiểm tra lại kết nối.';
      var stringHasInternet = 'Đã kết nối mạng.';
      var message = hasInternet ? stringHasInternet : stringNoInternet;

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }

      isHasInternet = hasInternet;
      setState(() {});
    });
    return;
  }

  Future checkHasUpdate() async {
    await Future.delayed(Duration.zero);

    isCheckUpdate = true;

    var arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments['isLogout']) {
      isCheckUpdate = false;
      log('navigation.login from logout');
      return;
    }

    var appUpdateInfo = {};
    await Future.microtask(() async {
      var resultUpdateInfo = await Services.instance.checkUpdate();
      // isCheckUpdate = false;
      if (resultUpdateInfo.isSuccess) {
        var data = resultUpdateInfo.data;
        if (data is List<Map<String, dynamic>>) {
          if (data.isNotEmpty) {
            appUpdateInfo = data.first;
          }
        }
      }
    });

    await createProgressionUpdate(
        '${StatusCheckVersion.checking} v${AppSetting.instance.version}',
        pauseDuration: const Duration(milliseconds: 2500));

    if (appUpdateInfo.isNotEmpty) {
      hasNewVersion = appUpdateInfo['version'] != AppSetting.instance.version;
    }

    // TODO: before release comment below code
    // hasNewVersion = true;

    if (hasNewVersion) {
      await createProgressionUpdate(
          status = hasNewVersion
              ? StatusCheckVersion.newVersion
              : StatusCheckVersion.initApp,
          pauseDuration: const Duration(milliseconds: 2500));

      var downloadDir = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOWNLOADS);
      var file = File('$downloadDir/app-release.apk');
      var isExists = await file.exists();

      if (!isExists) {
        await createProgressionUpdate(StatusCheckVersion.dowloading,
            beginAction: () async {
          var download =
              'https://storage.googleapis.com/dmclmobileapp.appspot.com/app-release.apk';

          await FileDownloader.downloadFile(
            url: download,
            onProgress: (fileName, progress) {
              status = 'Đang tải $progress%';
              progressingDownload = progress;
              setState(() {});
            },
            onDownloadError: (errorMessage) {
              log('download.error $errorMessage');
            },
            onDownloadCompleted: (path) {
              file = File(path);
            },
          );
        });
      }

      var fileInstall = await createProgressionUpdate(
          StatusCheckVersion.copyFile, beginAction: () async {
        var pathDirTemp = await getExternalCacheDirectories();
        var fileInstall = await file.copy('${pathDirTemp![0].path}/update.apk');
        return fileInstall;
      });

      var resultInstall = await createProgressionUpdate(
          StatusCheckVersion.installing, beginAction: () async {
        // var result = await AndroidPackageInstaller.installApk(
        //     apkFilePath: fileInstall.path);
        // log('appinstaller.result ${PackageInstallerStatus.byCode(result!)}');
        // var resultState = PackageInstallerStatus.byCode(result) ==
        //     PackageInstallerStatus.success;
        // if (!resultState) {
        //   Fluttertoast.showToast(msg: 'Ứng dụng chưa hoàn tất cập nhật.');
        // }
        // return resultState;

        // await AndroidIntent(
        //     action: 'action_view',
        //     data: 'content://$path',
        //     type: "application/vnd.android.package-archive",
        //     flags: [Flag.FLAG_ACTIVITY_NEW_TASK]).launch();

        var result =
            await FlutterAppInstaller.installApk(filePath: fileInstall.path);

        return result;
      }, pauseDuration: const Duration(milliseconds: 2200));

      if (resultInstall) {
        await createProgressionUpdate(StatusCheckVersion.prepairFinish,
            beginAction: () async {
          await fileInstall.delete();
          await file.delete();
        });
      }

      await createProgressionUpdate(StatusCheckVersion.done,
          beginAction: () async {});
    }
    // var path = 'storage/emulated/0/Download/xapk.apk';

    await createProgressionUpdate(StatusCheckVersion.initApp,
        beginAction: () async {
      // isCheckUpdate = false;
    });

    isCheckUpdate = false;
    Future.delayed(const Duration(milliseconds: 1000));
    setState(() {});

    return isCheckUpdate;
  }

  Future createProgressionUpdate(String name,
      {Duration pauseDuration = const Duration(milliseconds: 1500),
      Function()? beginAction,
      Function()? completeAction}) async {
    progressingDownload = 0;
    status = name;
    setState(() {});

    if (beginAction != null) beginAction();

    await Future.delayed(pauseDuration);
    progressingDownload = 100;
    setState(() {});

    if (completeAction != null) completeAction();

    await Future.delayed(const Duration(milliseconds: 1000));
  }

  List<String> onValidate() {
    List<String> errors = [];
    if (fieldUser.text.isEmpty) {
      errors.add('Tên đăng nhập không được để trống.');
    }
    if (fieldPwd.text.isEmpty) errors.add('Mật khẩu không được để trống.');
    return errors;
  }

  toggleLoading() {
    if (!mounted) return;
    setState(() {
      isLoading = !isLoading;
    });
  }

  void onLogin({String password = ''}) async {
    if (onValidate().isNotEmpty && password.isEmpty) {
      String txt = '';
      onValidate().forEach((e) => txt += '$e\n');

      showAlert(context, 'Thông báo', txt);
      return;
    }

    toggleLoading();
    var res = await Services.instance
        .setContext(context)
        .login(fieldUser.text, password.isEmpty ? fieldPwd.text : password);

    toggleLoading();

    if (res.isSuccess) {
      if (widget.isContinues) {
        Navigator.pop(context);
        return;
      }

      if (!DMCLSocket.instance.socket!.connected) {
        DMCLSocket.instance.socket!.connect();
      }

      UserModel.instance.passwordCache = fieldPwd.text;
      UserModel.instance.save();
      DMCLSocket.instance.userConnect(UserModel.instance);

      FocusManager.instance.primaryFocus?.unfocus();

      await Future.delayed(const Duration(milliseconds: 250));
      Fluttertoast.showToast(msg: 'Đang xác minh ...');
      await Future.delayed(const Duration(seconds: 1));

      Fluttertoast.cancel();

      if (!AppSetting.instance.enableAuthenLocal) {
        await alertEnableFigurePrint();
      }

      Navigator.pushNamedAndRemoveUntil(context, '/tabbar', (route) => false);
    }
  }

// TODO: Cài đặt vân tay cho lần đăng nhập sau

  /// Cài đặt vân tay cho lần đăng nhập sau,
  ///
  /// `Mô tả`: Trong trường hợp token chưa hết timeout, app được mở lần đầu (k0 chạy nền)
  ///
  /// `lý do`: user clean, crash app, ...
  ///
  /// `hành động`: hiển thị xác nhận = vân tay.
  ///
  Future onAuthenLocal() async {
    // if login.success then appsetting.pass.save
    // enable local_authen
    // next login if local_authen.pass then call api login with pass save -> update new token

    LocalAuthentication auth = LocalAuthentication();

    var isAuthen = await auth.authenticate(
        localizedReason: 'Quét vân tay của bạn để đăng nhập.',
        options: const AuthenticationOptions(
          sensitiveTransaction: true,
          biometricOnly: true,
        ));

    if (isAuthen) {
      onLogin(password: UserModel.instance.passwordCache);

      // Navigator.pushNamedAndRemoveUntil(context, '/tabbar', (route) => false);
    }
    return;
  }

  Future alertEnableFigurePrint() async {
    // TODO: Cho phép sử dụng vân tay để thay thế đăng nhập

    LocalAuthentication auth = LocalAuthentication();
    List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();

    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      await showAlert(context, 'Thông báo',
          'Bạn muốn sử dụng vân tay cho lần đăng nhập sau ?',
          actions: [
            CupertinoButton(
                child: const Text('Đồng ý'),
                onPressed: () async {
                  AppSetting.instance.enableAuthenLocal = true;
                  AppSetting.instance.save();

                  Navigator.pushNamedAndRemoveUntil(
                      context, '/tabbar', (route) => false);
                }),
            CupertinoButton(
                child: const Text('Bỏ qua'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/tabbar', (route) => false);
                })
          ]);
    }
  }

  initUniLink() async {
    _appLinks = AppLinks();

    var initialLink = await _appLinks.getInitialAppLinkString();
    if (initialLink == null) {
      var uri = await _appLinks.getInitialAppLink();
      initialLink = uri?.path;
    }

    var x = initialLink;
    if (x != null) {
      var code = x.getProductCodeFromUrl;
      if (code.isNotEmpty) {
        log('deeplink.search productcode $code');
      }
    }
    log('deeplink.initLink $x');
  }

  initUniStream() {
    _subUniURI = _appLinks.uriLinkStream.listen((event) {
      log('deeplink.initStream $event');
      var hasPath = event.hasAbsolutePath;
      if (hasPath) {
        var code = event.toString().getProductCodeFromUrl;
        log('deeplink.productCode $code');

        AppSetting.instance.qrText = code;
      }
    }, onError: (error) {
      log('error $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          // backgroundColor: HexColor.fromHex("025ca6"),
          backgroundColor: GlobalStyles.primaryColor,
          body: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * .1,
                      // bottom: MediaQuery.of(context).size.height * .1,
                      left: MediaQuery.of(context).size.width * .1,
                      right: MediaQuery.of(context).size.width * .1),
                  child: Image.asset(
                    "assets/img/logo.png",
                    width: MediaQuery.of(context).size.width * .9,
                    height: MediaQuery.of(context).size.height * .1,
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 275),
                  child: Visibility(
                      visible: isCheckUpdate,
                      child: ProgressionUpdateVersion(
                        onCheckingVersion: (result) {
                          isCheckUpdate = result;
                          // setState(() {});
                        },
                      )),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 575),
                  child: Visibility(
                    visible: !isCheckUpdate,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * .05,
                            right: MediaQuery.of(context).size.width * .05,
                            top: MediaQuery.of(context).size.height * .05,
                            // bottom: MediaQuery.of(context).size.height * .04
                          ),
                          child: Container(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * .05,
                                bottom:
                                    MediaQuery.of(context).size.height * .05),
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16.0)),
                              color: Colors.white,
                            ),
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Column(
                              children: [
                                DMCLFieldFrom(
                                  width:
                                      MediaQuery.of(context).size.width * 0.75,
                                  labelTitle: 'Mã nhân viên',
                                  controller: fieldUser,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                DMCLFieldFrom(
                                  width:
                                      MediaQuery.of(context).size.width * .75,
                                  labelTitle: 'Mật khẩu',
                                  controller: fieldPwd,
                                  enableSecure: true,
                                ),
                                Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .05),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .75,
                                        height: 44,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  HexColor.fromHex("025ca6")),
                                          onPressed:
                                              isHasInternet ? onLogin : null,
                                          child: !isLoading
                                              ? const Text(
                                                  "Đăng nhập",
                                                )
                                              : const SizedBox(
                                                  height: 24,
                                                  width: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.amber,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: false,
                                      child: Column(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Divider(
                                              indent: 28,
                                              endIndent: 28,
                                            ),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .75,
                                            height: 44,
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    foregroundColor:
                                                        HexColor.fromHex(
                                                            "025ca6"),
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255,
                                                            245,
                                                            245,
                                                            245)),
                                                onPressed: () {
                                                  Navigator.pushNamed(
                                                      context, '/register');
                                                },
                                                child: const Text(
                                                  "Đăng ký",
                                                )
                                                // : const SizedBox(
                                                //     height: 24,
                                                //     width: 24,
                                                //     child: CircularProgressIndicator(
                                                //       strokeWidth: 2,
                                                //       color: Colors.amber,
                                                //     ),
                                                // ),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.27),
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * .05,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              showAlert(context, 'Thông báo',
                                  'Liên hệ quản lý để lấy thông tin tài khoản.');
                            },
                            child: const SizedBox(
                              width: double.infinity,
                              child: Text(
                                "Quên mật khẩu ?",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
