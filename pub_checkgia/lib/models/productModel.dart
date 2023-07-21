// ignore_for_file: file_names

import 'dart:developer';

import 'package:pub_dmclcheckgia/pub_DMCLcheckgia.dart';

class ProductModel {
  int id;
  String code;
  String sapCode;
  String name;
  int saleprice;
  int discount;
  String imageLink;
  String alias;

  ProductModel.fromJson(Map<String, dynamic> json)
      : id = json['_source']['id'] ?? '',
        alias = json['_source']['alias'] ?? '',
        code = json['_source']['code'] ?? '',
        sapCode = json['_source']['sap_code'] ?? '',
        name = json['_source']['name'] ?? '',
        saleprice = json['_source']['saleprice'] ?? '',
        discount = json['_source']['discount'] ?? '',
        imageLink = ProductModel.makeImageLink(
            json['_source']['id'] ?? '', json['_source']['picture'] ?? '');


  static String makeImageLink(int id, String picture) {
    var link =
        'http://cdn11.dienmaycholon.vn/filewebdmclnew/DMCL21/Picture/Apro/Apro_product_$id/$picture.png';
    log('product.image $link');

    return link;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alias': alias,
      'code': code,
      'sapCode': sapCode,
      'name': name,
      'imageLink': imageLink,
      'saleprice': saleprice
    };
  }
  @override
  String toString() {
    return 'ProductModel {\n'
        '  id: $id,\n'
        '  alias: $alias,\n'
        '  code: $code,\n'
        '  sapCode: $sapCode,\n'
        '  name: $name,\n'
        '  imageLink: $imageLink,\n'
        '  saleprice: $saleprice\n'
        '}';
  }
}

class ProductColor {
  String color;
  String alias;
  int active;

  ProductColor.fromJson(Map<String, dynamic> json)
      : color = json['color'],
        active = json['active'],
        alias = json['alias'];
}

class ProductDetailModel {
  String note;
  String ofType;
  int priceOnline;
  int priceGift;
  int priceCoupon;
  int priceType;
  int price;
  int pricePayoo;
  int giftPricePromotionText1;
  int giftPricePromotionPrice;
  int stockNum, stockMain;
  int storeStockNum, storeStockMain;

  List<ProductColor> colors;
  List promotionText1;
  List promotionText2;
  List promotionPrice;
  List status;

  ProductPreorderModel? preorder;

  ProductDetailModel.fromJson(Map<String, dynamic> json)
      : note = json['note'],
        stockNum = json['stock_num'] ?? 0,
        stockMain = json['stock_num_main'] ?? 0,
        price = json['price'],
        priceOnline = json['price_online'],
        priceGift = json['price_gift'],
        priceCoupon = json['price_coupon'],
        priceType = json['price_oftype'],
        pricePayoo = json['price_payoo'] ?? 0,
        giftPricePromotionText1 = json['gift_price_promotion_text1'] ?? 0,
        giftPricePromotionPrice = json['gift_price_promotion_price'] ?? 0,
        ofType = json['of_type'] ?? '',
        status = json['status'],
        storeStockMain = json['store_stock_num_main'],
        storeStockNum = json['store_stock_num'],
        colors = (json['list_link_color'] as List)
            .map((e) => ProductColor.fromJson(e))
            .toList(),
        promotionText1 =
            (json['promotion_text1'] as List).map((e) => e).toList(),
        promotionText2 =
            (json['promotion_text2'] as List).map((e) => e).toList(),
        promotionPrice =
            (json['promotion_price'] as List).map((e) => e).toList();

  ProductDetailModel createPreorderFromJson(Map<String, dynamic> json) {
    preorder = ProductPreorderModel.fromJson(json);
    return this;
  }
}

class StockSapModel {
  String plant;
  String plantName;

  List<StockModel> collection;

  StockSapModel.create(this.plant, this.plantName, this.collection);
}

class StockModel {
  String codeStore;
  String nameStore;
  int stockMain;
  int stockNum;

  String productType;

  String sloc;
  String slocName;

  List status;

  StockModel.fromJson(Map<String, dynamic> json)
      : codeStore = json['code_store'] ?? "",
        nameStore = (json['name_store'] as String?)?.isEmpty ?? true
            ? json['code_store'] ?? ""
            : (json['name_store'] as String).toLowerCase().replaceFirst('chi nhánh', '').toUpFirstCase(),
        stockMain = json['stock_num_main'] ?? 0,
        stockNum = json['stock_num'] ?? 0,
        sloc = json['SLOC'] ?? "",
        slocName = json['SLOCNAME'] ?? "",
        productType = json['VALUATIONTYPE'] ?? "",
        status = json['status'] ?? [];



  Map<String, dynamic> toJson() {
    return {
     'codeStore':codeStore,
     'nameStore':nameStore,
     'stockMain':stockMain,
     'stockNum':stockNum,
     'productType':productType,
     'sloc':sloc,
     'slocName':slocName,
     'status':status,
    };
  }
  @override
  String toString() {
    return 'ProductModel {\n'
        '  id: $codeStore,\n'
        '  alias: $codeStore,\n'
        '  code: $codeStore,\n'
        '  sapCode: $codeStore,\n'
        '  name: $codeStore,\n'
        '  imageLink: $codeStore,\n'
        '  saleprice: $codeStore\n'
        '}';
  }
}

class ProductPreorderModel {
  int bonus;
  int salePrice;
  int giamthemMC;
  int giamthem;
  int flagPromotion;
  int stock;
  String dvt;
  String description;
  String mc;
  String type;
  String idVAT;

  List<PreorderGiftModel> gifts;

  ProductPreorderModel.fromJson(Map<String, dynamic> json)
      : bonus = json['Bonus'] ?? 0,
        salePrice = json['SalesPrice'] ?? 0,
        giamthem = json['GiamThem'] ?? 0,
        giamthemMC = json['GiamThemMC'] ?? 0,
        dvt = json['DVT'] ?? '',
        flagPromotion = json['FlagPromotion'] ?? 0,
        description = json['Mota'] ?? '',
        type = json['TypeItemID'] ?? '',
        mc = json['MC'] ?? '',
        idVAT = json['VATID'] ?? '',
        stock = json['SoLuongTon'] ?? '',
        gifts = (json['List_Itemkm'] as List)
            .map((e) => PreorderGiftModel.fromJson(e))
            .toList();

  String get nameForVAT {
    return idVAT == 'R1' ? '5%' : (idVAT == 'R2' ? '10%' : idVAT);
  }
}

class PreorderGiftModel {
  String itemId;
  String itemName;
  int giamgiaKLKM;
  int permissionBuyItemAttach;
  int promotionPrice;
  int quantity;
  int tachGia;
  String vATID;

  PreorderGiftModel.fromJson(Map<String, dynamic> json)
      : itemName = json['ItemNameKM'],
        itemId = json['ItemIDKM'],
        giamgiaKLKM = json['GiamGiaKLKM'] ?? 0,
        promotionPrice = json['PromotionPrice'] ?? '',
        permissionBuyItemAttach = json['PermissonBuyItemAttach'] ?? -1,
        quantity = json['quantity'] ?? 1,
        tachGia = json['tachGia'] ?? 0,
        vATID = json['VATID'] ?? '';
}
