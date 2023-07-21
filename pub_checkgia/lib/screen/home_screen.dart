// ignore_for_file: use_build_context_synchronously, must_be_immutable, non_constant_identifier_names

import 'dart:developer' as dev;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:pub_dmclcheckgia/pub_DMCLcheckgia.dart';
 import 'package:pub_dmclcheckgia/pub_DMCLcheckgia.dart';
import 'package:pub_checkgia/models/UserModel.dart';
import 'package:pub_checkgia/models/productModel.dart';
import 'package:pub_checkgia/screen/productDetail_popup.dart';
import 'package:pub_checkgia/services/services_temp.dart'; 
import 'package:pub_checkgia/services/socketClient.dart';
 
 import 'package:pub_dmclcheckgia/pub_DMCLcheckgia.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:socket_io_client/socket_io_client.dart';

class HomeScreen extends StatefulWidget {
  String QRText;
  HomeScreen({super.key, this.QRText = ''});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ProductModel> products = [];

  bool isNewNotification = false;
  int newNoti = 0;

  TextEditingController searchField = TextEditingController();

  ProductModel? mainProduct;
  ProductDetailModel? detailProduct;

  bool isDetailModalOpen = false;

  GlobalKey qrKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    AppSetting.instance.onChangeQRText = (text) {
      searchField.text = text;
      dev.log('searchfield.delegateText $text');
    };

    Services.instance.setContext(context);

    initData();

    initSocketIO();

    initNotificationBadge();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalStyles.primaryColor,
      body: SafeArea(
        bottom: false,
        top: true,
        child: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: GlobalStyles.backgroundColorAppBar,
              expandedHeight: 120,
              // expandedHeight: 175 + 8,
              // collapsedHeight: 124 + 4,
              // bottom: PreferredSize(
              //   preferredSize: const Size.fromHeight(0),
              //   child: Padding(
              //     padding: const EdgeInsets.all(8.0),
              //     child: DMCLSearchBox(
              //       enableAnimationSubmit: true,
              //       hint: 'Tìm kiếm sản phẩm (sap code, tên sản phẩm)',
              //       controller: searchField,
              //       isAutocomplete: true,
              //       backgroundColor: Colors.white,
              //       onChange: (value) {
              //         if (value.isEmpty) {
              //           products.clear();
              //         }
              //         setState(() {});
              //       },
              //       onSubmit: (value) async {
              //         var result = await Services.instance.searchProduct(value);
              //         products = result;
              //         setState(() {});
              //       },
              //     ),
              //   ),
              // ),
              flexibleSpace: Container(
                // margin: const EdgeInsets.only(top: 42),
                margin: const EdgeInsets.only(top: 8),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          "assets/img/logo.png",
                          width: MediaQuery.of(context).size.width * 0.55,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 45,
                                  height: 45,
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.topRight,
                                        // child: Icon(
                                        //   Icons.person,
                                        //   color: Colors.white,
                                        //   size: 32,
                                        // ),
                                        child: AvatarLoad(
                                          UserModel.instance.avatarLink,
                                          // size: 16,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: CircleAvatar(
                                          backgroundColor: DMCLSocket
                                                  .instance.socket!.connected
                                              ? Colors.green
                                              : Colors.grey,
                                          radius: 6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                DefaultTextStyle(
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        UserModel.instance.name,
                                      ),
                                      Text(
                                        'CN ${UserModel.instance.siteId}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Badge(
                                isLabelVisible: isNewNotification,
                                // alignment: AlignmentDirectional.center,
                                label: Text(
                                  '$newNoti',
                                  // style: TextStyle(fontSize: 20),
                                ),
                                backgroundColor: Colors.red,
                                child: IconButton(
                                    splashRadius: 28,
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushNamed('/notification');

                                      isNewNotification = false;
                                      setState(() {});
                                    },
                                    icon: const Icon(
                                      Icons.notifications,
                                      color: Colors.white,
                                    )),
                              ),
                            )
                          ],
                        )
                      ]),
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: true,
              // fillOverscroll: false,
              child: SingleChildScrollView(
                child: Container(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.9),
                    // height: 100,
                    padding: const EdgeInsets.only(bottom: 60),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 240, 240, 240),
                      // borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                            child: Stack(
                              children: [
                                DMCLSearchBox(
                                  enableAnimationSubmit: true,
                                  hint:
                                      'Tìm kiếm sản phẩm (sapCode, tên sản phẩm)',
                                  controller: searchField,
                                  isAutocomplete: true,
                                  backgroundColor: Colors.white,
                                  onChange: (value) {
                                    if (value.isEmpty) {
                                      products.clear();
                                    }
                                    setState(() {});
                                  },
                                  onSubmit: (value) async {
                                    var result = await Services.instance
                                        .searchProduct(value);
                                    products = result;
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                              // visible: products.isEmpty,
                              visible: false,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Wrap(
                                  spacing: 16,
                                  runSpacing: 8,
                                  children: [
                                    {
                                      'title': 'Sản phẩm abc',
                                      'sapCode': '151076'
                                    },
                                    {
                                      'title': 'Sản phẩm abc',
                                      'sapCode': '151076'
                                    },
                                    {
                                      'title': 'Sản phẩm abc',
                                      'sapCode': '151076'
                                    },
                                    {
                                      'title': 'Sản phẩm abc',
                                      'sapCode': '151076'
                                    },
                                  ]
                                      .map(
                                        (e) => DMCLCard(
                                          child: Column(
                                            children: [
                                              Text(e['sapCode']!),
                                              Text(e['title']!,
                                                  style: TextStyle(
                                                      color: GlobalStyles
                                                          .textColor54)),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              )),
                          Column(
                            children: products
                                .map((e) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: GestureDetector(
                                          onTap: () =>
                                              onItemPress(products.indexOf(e)),
                                          child: productBasicInfo(
                                              (products.indexOf(e)))),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void initData() {}

  void initSocketIO() {
    DMCLSocket.instance.socket!.onConnect((data) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) setState(() {});
      });
    });

    DMCLSocket.instance.socket!.onDisconnect((data) {
      // DMCLSocket.instance.isConnected = false;
      if (mounted) setState(() {});
      dev.log(
        'socket.disconnected on home_screen',
      );
    });
  }

  Widget productBasicInfo(int index,
      {double? width = 100, double? height = 80, bool isBorder = true}) {
    return DMCLCard(
      borderColor: !isBorder ? Colors.transparent : null,
      child: Row(
        children: [
          DMCLShadow(
            enable: false,
            child: SizedBox(
              width: width,
              height: height,
              child: CachedNetworkImage(
                imageUrl: products[index].imageLink,
                placeholder: (context, url) => const Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: Text(
                  products[index].sapCode,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                products[index].name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Visibility(
                visible: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 4),
                  child: Text(
                    products[index].discount.toCurrency(),
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  onItemPress(int index) async {
    if (isDetailModalOpen) {
      showAlert(context, 'Thông báo', 'Truy vấn trước đó xảy ra lỗi.',
          actionAndroids: [
            ElevatedButton(
                child: const Text('Bỏ qua'),
                onPressed: () {
                  isDetailModalOpen = false;
                  Navigator.pop(context);
                })
          ]);
      return;
    }
    isDetailModalOpen = true;
    var item = products[index];
    mainProduct = item;

    showLoading(context);

    Services.instance.whenCompleted = (requestURL, response) {
      // response.
      Navigator.pop(context);

      if (response != null && response.error != null) {
        showAlert(context, 'Thông báo', response.error!['message']);
        return;
      }
    };

    var productDetail =
        await Services.instance.getCrossDetailProduct(item.alias, item.sapCode);
    // var productPrice = await Services.instance.getPriceDetail(item.sapCode);

    if (productDetail == null) {
      isDetailModalOpen = false;
      return;
    }

    // productDetail.preorder = productPrice;

    showMaterialModalBottomSheet(
        context: context,
        isDismissible: false,
        backgroundColor: Colors.transparent,
        // enableDrag: true,

        builder: (context) => Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: ProductDetailPopup(
                productImage: productBasicInfo(index,
                    width: 120, height: 100, isBorder: true),
                basicInfo: item,
                productDetail: productDetail,
              ),
            ));

    isDetailModalOpen = false;
    dev.log('pop.detail closed');
  }

  initNotificationBadge() async {
    if (UserModel.instance.isNotice) {
      dev.log('notifications.alert: user not permission');
      return;
    }

    var result = await Services.instance.getNotifications();
    if (result.isSuccess) {
      isNewNotification =
          result.total != AppSetting.instance.lastNotificationCount;
      if (isNewNotification) {
        newNoti = result.total - AppSetting.instance.lastNotificationCount;
        setState(() {});
      } else {
        dev.log('notification.checknew no new message');
      }
    }
  }
}
