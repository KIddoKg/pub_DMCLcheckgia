// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_installer/flutter_app_installer.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pub_dmclcheckgia/pub_DMCLcheckgia.dart';
import 'package:pub_checkgia/screen/authen/login_screen.dart';
import 'package:pub_checkgia/services/services_temp.dart'; 
 

class ProgressionUpdateVersion extends StatefulWidget {
  void Function(bool result)? onCheckingVersion;
  void Function(bool result)? onHasNewVerion;

  ProgressionUpdateVersion({
    Key? key,
    this.onCheckingVersion,
    this.onHasNewVerion,
  }) : super(key: key);

  @override
  State<ProgressionUpdateVersion> createState() =>
      _ProgressionUpdateVersionState();
}

class _ProgressionUpdateVersionState extends State<ProgressionUpdateVersion> {
  bool isCheckUpdate = false;
  bool hasNewVersion = false;
  double progressingDownload = 0;

  String status = '';

  @override
  void initState() {
    // TODO: implement initState

    log('progression.checkingupdate');
    checkHasUpdate();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          DMCLProgressbar(
            duration: const Duration(milliseconds: 200),
            backgroundColor: const Color.fromARGB(64, 0, 0, 0),
            progress: progressingDownload,
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            status,
            style: const TextStyle(fontSize: 13, color: Colors.white),
          ),
        ],
      ),
    );
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
      if (widget.onHasNewVerion != null) widget.onHasNewVerion!(hasNewVersion);
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

    if (widget.onCheckingVersion != null) {
      widget.onCheckingVersion!(isCheckUpdate);
    }

    return isCheckUpdate;
  }

  ///
  /// Tạo một thanh tiến trình hiển thị quá trình kiểm tra cập nhật
  ///
  /// `[name]` - tên tiến trình
  ///
  /// `[action]` - hàm xử lý
  ///
  /// `[pauseDuration]` - thời gian tạm ừng khi kết thúc
  ///
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
}
