// ignore_for_file: unused_field


import 'package:pub_dmclcheckgia/pub_DMCLcheckgia.dart';
import 'package:pub_checkgia/models/productModel.dart';
import 'package:pub_checkgia/models/userInfoModel.dart';
import 'package:intl/intl.dart';
import '../../models/UserModel.dart';
import '../../services/api.dart';
import '../models/workDataModel.dart';

extension ServicesMethods on Services {
  Future<NetResponse> login(String username, String pwd) async {
    var res = await API.loginDMCL(username, pwd).request();
    if (res.isSuccess) {
      // res.cast<UserModel>(fromJson: res.data['profile']);

      UserModel userModel = res.cast<UserModel>(fromJson: UserModel.fromJson);

      AppSetting appSetting =
          res.cast<AppSetting>(fromJson: AppSetting.fromJson);

      userModel.save();
      // var x = json.encode(UserModel.instance.toJson());
      // AppSetting.pref.setString('@profile', x);

      appSetting.save();
      // var y = json.encode(AppSetting.instance.toJson());
      // AppSetting.pref.setString('@appSetting', y);

      return res;
    } else {
      errorAction(res, withLoadingBefore: false);
    }
    return res;
  }

  bool checkAuthenToken() {
    var startDate =
        DateFormat('HH:mm dd/MM/yyyy').parse(UserModel.instance.sessionStart);
    var defaultHours = 8;
    var expired = startDate.add(Duration(hours: defaultHours));

    var now = DateTime.now();
    // log('lastLoginDate $startDate');
    // log('expiredDate $expired');
    // log('now $now');

    var isExpired = now.isAfter(expired);
    return isExpired;
  }

  Future<dynamic> registerDevice(String deviceId) async {
    var res = await API.registerDevice(deviceId).request();
    if (res.isSuccess) {
      // res.cast<UserModel>(fromJson: res.data);
      return res.data;
    } else {
      errorAction(res);
    }
    return res.data;
  }

  Future<bool> updateUser({bool enablePush = false}) async {
    var res = await API.updateUser(enablePush: enablePush).request();
    if (res.isSuccess) {
      // res.cast<UserModel>(fromJson: res.data);
      var state = res.data['enablePushNotifi'] == 1 ? true : false;
      UserModel.instance.enablePushNotification = state;
      UserModel.instance.save();
      return state;
    } else {
      errorAction(res);
    }
    return false;
  }

  // Future<NetResponse> logout() async {
  //   // var res = API.logout().request();

  //   var time = DateTime.now().millisecondsSinceEpoch;
  //   UserModel.instance.sessionEnd = time.toDateString();

  //   AppSetting.pref.remove('profile');
  //   return NetResponse(true, null, null, null);
  // }

  // Future<NetResponse> refreshToken() async {
  //   return await API.refreshToken(AppSetting.instance.refreshToken).request();
  // }

  Future<NetResponseList> getNotifications(
      {int? page = 1, List<String>? groups, String? title = ''}) async {
    var res = await API
        .getNotification(page: 1, toId: groups ?? [], title: title)
        .request();

    if (res.isSuccess) {
      var result = NetResponseList.fromJson(res.orignal);
      result.isSuccess = true;
      return result;
    } else {
      res.isSuccess = false;
      errorAction(res, withLoadingBefore: false);
    }
    var resultError = NetResponseList.fromJson({
      "data": [],
      "meta": {"pagination": {}}
    });
    resultError.isSuccess = false;
    return resultError;
  }

  Future<List<ProductModel>> searchProduct(String keyword) async {
    var res = await API.searchProduct(keyword).request();
    if (res.isSuccess) {
      return res.castList<ProductModel>(
          fromList: res.data['product'], fromJson: ProductModel.fromJson);
    } else {
      errorAction(res, withLoadingBefore: false);
    }

    return res.castList<ProductModel>(fromJson: ProductModel.fromJson);
  }

  Future<String> searchQrCode(String urlQr) async {
    var res = await API.searchSapCodeByQR(urlQr).request();
    if (res.isSuccess) {
      return res.data;
    } else {
      errorAction(res, withLoadingBefore: false);
    }

    return '';
  }

  Future<ProductDetailModel?> detailProduct(String alias) async {
    var res = await API.detailProduct(alias).request();
    if (whenCompleted != null) {
      whenCompleted!('detailProduct', res);
    }

    // if (_context != null) {
    //   Navigator.pop(_context!);
    //   // await Future.delayed(const Duration(milliseconds: 1500));
    // }

    if (res.isSuccess) {
      return res.cast<ProductDetailModel>(
          fromJson: ProductDetailModel.fromJson);
    } else {
      errorAction(res, withLoadingBefore: true);
    }
    return null;
  }

  Future<ProductPreorderModel?> getPriceDetail(
    String sapCode,
  ) async {
    var res = await API
        .getDetailPrice(sapCode, AppSetting.instance.deviceID)
        .request();

    if (whenCompleted != null) {
      whenCompleted!('getPriceDetail', res);
    }

    if (res.isSuccess) {
      return res.cast<ProductPreorderModel>(
          fromJson: ProductPreorderModel.fromJson);
    } else {
      errorAction(res, withLoadingBefore: true);
      // return null;
    }
    return null;
    // return res.cast<ProductDetailModel>();
  }

  Future<ProductDetailModel?> getCrossDetailProduct(
    String alias,
    String sapCode,
  ) async {
    var detailProduct = await API.detailProduct(alias).request();

    var preorderProduct = await API
        .getDetailPrice(sapCode, AppSetting.instance.deviceID)
        .request();

    if (whenCompleted != null) {
      var responseError = !detailProduct.isSuccess
          ? detailProduct
          : !preorderProduct.isSuccess
              ? preorderProduct
              : null;

      whenCompleted!('detailProduct', responseError);
    }

    if (detailProduct.isSuccess && preorderProduct.isSuccess) {
      ProductDetailModel productDetail = detailProduct.cast<ProductDetailModel>(
          fromJson: ProductDetailModel.fromJson);
      if (preorderProduct.data != null) {
        productDetail.preorder = preorderProduct.cast<ProductPreorderModel>(
            fromJson: ProductPreorderModel.fromJson);
      }
      return productDetail;
    }
    return null;
  }

  Future<UserInfoTarget?> getUserInfoTarget(
      {int? fromDate, int? toDate}) async {
    var res = await API
        .getUserInfoTarget(fromDate: fromDate, toDate: toDate)
        .request();

    // whenCompleted!('getUserInfoTarget', res);

    if (res.isSuccess) {
      // return res.cast<UserInfoTarget>();
    } else {
      errorAction(res, withLoadingBefore: true);
    }
    return null;
  }

  Future<List<StockModel>?> getStock(String sapCode) async {
    var res = await API.getStock(sapCode).request();

    if (res.isSuccess) {
      return res.castList<StockModel>(fromJson: StockModel.fromJson);
    } else {
      errorAction(res, withLoadingBefore: false);
      // return null;
    }
    return null;
    // return res.cast<ProductDetailModel>();
  }

  Future<List<StockModel>?> getStockFromGetGiaService(String sapCode,
      {bool isSloc = false}) async {
    NetResponse res;
    if (!isSloc) {
      res = await API.getStockFromGetGiaService(sapCode).request();
    } else {
      res = await API.getStockSlocFromGetGiaService(sapCode).request();
    }

    if (res.isSuccess) {
      return res.castList<StockModel>(
          fromList: res.data, fromJson: StockModel.fromJson);
    } else {
      errorAction(res, withLoadingBefore: false);
      // return null;
    }
    return null;
  }

  Future<dynamic>? getWorkDate({DateTime? target}) async {
    var mouth = DateTime.now().month;
    var year = DateTime.now().year;
    var res = await API
        .getWorkDate(UserModel.instance.accountId, mouth: mouth, year: year)
        .request();

    if (res.isSuccess) {
      return res.castList<WorkDateModel>(fromJson: WorkDateModel.fromJson);
    }
    return res.data;
  }

  Future<String> requestPriceWebCode(String sapCode, String productName) async {
    var res = await API.requestPriceWebCode(sapCode, productName).request();

    if (res.isSuccess) {
      return res.data['code'].toString();
    } else {
      errorAction(res, withLoadingBefore: false);
    }
    return '';
    // return res.cast<ProductDetailModel>();
  }

  Future<NetResponse> checkUpdate(
      {List<Map<String, dynamic>>? packageInfo}) async {
    var data = packageInfo ??
        [
          {
            'package': 'com.dmcl.appcheck',
            'version': AppSetting.instance.version
          }
        ];

    var res = await API.update_ota(data).request();

    return res;
  }
}
