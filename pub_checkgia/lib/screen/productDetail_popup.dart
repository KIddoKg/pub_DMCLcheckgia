// ignore_for_file: must_be_immutable, avoid_unnecessary_containers, file_names, use_build_context_synchronously

import 'dart:developer' as dev;
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
 import 'package:pub_dmclcheckgia/pub_DMCLcheckgia.dart';
import 'package:pub_checkgia/models/UserModel.dart';
import 'package:pub_checkgia/models/productModel.dart';
import 'package:pub_checkgia/screen/product/checkStock.dart';
import 'package:pub_checkgia/services/services_temp.dart'; 
 
 import 'package:pub_dmclcheckgia/pub_DMCLcheckgia.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ProductDetailPopup extends StatefulWidget {
  ProductDetailModel productDetail;
  ProductModel basicInfo;
  Widget productImage;

  void Function()? openStock;

  ProductDetailPopup(
      {super.key,
      required this.productImage,
      required this.basicInfo,
      required this.productDetail,
      this.openStock});

  @override
  State<ProductDetailPopup> createState() => _ProductDetailPopupState();
}

class _ProductDetailPopupState extends State<ProductDetailPopup> {
  var colorIndex = 0;
  List<StockModel> infoStocks = [];

  bool isWebCodePrice = false;

  @override
  Widget build(BuildContext context) {
    var product = widget.productDetail;
    var priceOnline = product.priceOnline.toCurrency();
    var priceGift = product.priceGift.toCurrency();
    var priceCoupon = product.priceCoupon.toCurrency();
    var priceType = product.priceType.toCurrency();
    var pricePayoo = product.pricePayoo.toCurrency();
    var price = product.price.toCurrency();
    var giftPricePromotionText1 = product.giftPricePromotionText1.toCurrency();
    var giftPricePromotionPrice = product.giftPricePromotionPrice.toCurrency();

    var stockNum = product.stockNum;
    var stockMain = product.stockMain;

    var status = product.status;

    var preorder = product.preorder;

    dev.log('pass');
    return FractionallySizedBox(
      // height: MediaQuery.of(context).size.height * 0.9,
      heightFactor: 0.85,
      // constraints: const BoxConstraints(maxHeight: 700),
      child: CustomScrollView(
        shrinkWrap: true,
        // physics: BottomSheetScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            // hasScrollBody: true,
            child: Column(
              children: [
                Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 56,
                          padding: const EdgeInsets.only(left: 16, right: 8),
                          decoration: const BoxDecoration(
                              // color: Colors.grey,
                              border: Border(
                                  bottom: BorderSide(
                                      width: 1,
                                      color:
                                          Color.fromARGB(255, 219, 219, 219)))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Thông tin sản phẩm',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.close))
                            ],
                          ),
                        ),
                        Container(
                          color: GlobalStyles.backgroundCardColor,
                          child: DefaultTextStyle(
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 16, bottom: 8.0, left: 8, right: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  widget.productImage,
                                  const SizedBox(height: 12),
                                  renderStatus(status),
                                  if (widget.productDetail.colors.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Wrap(
                                        direction: Axis.horizontal,
                                        children: widget.productDetail.colors
                                            .map(
                                              (e) => Container(
                                                // color: Colors.black,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      colorIndex = widget
                                                          .productDetail.colors
                                                          .indexOf(e);
                                                      dev.log(
                                                          'product.color $e');

                                                      await showLoading(
                                                          context);
                                                      widget.productDetail =
                                                          (await Services
                                                              .instance
                                                              .detailProduct(
                                                                  e.alias))!;
                                                      // Navigator.pop(context);

                                                      setState(() {});
                                                    },
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          width: 18,
                                                          height: 18,
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: CircleAvatar(
                                                            radius: 5,
                                                            backgroundColor: widget
                                                                        .productDetail
                                                                        .colors
                                                                        .indexOf(
                                                                            e) ==
                                                                    colorIndex
                                                                ? Colors.blue
                                                                : Colors
                                                                    .transparent,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(e.color)
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  if (widget
                                      .productDetail.promotionPrice.isNotEmpty)
                                    productDetailDescription(
                                        'Quà tặng kèm trị giá $giftPricePromotionPrice',
                                        widget.productDetail.promotionPrice),
                                  if (widget
                                      .productDetail.promotionText1.isNotEmpty)
                                    productDetailDescription(
                                        'Quà tặng kèm trị giá $giftPricePromotionText1',
                                        widget.productDetail.promotionText1),
                                  if (widget
                                      .productDetail.promotionText2.isNotEmpty)
                                    productDetailDescription('Ưu đãi đi kèm',
                                        widget.productDetail.promotionText2,
                                        borderColor: Colors.pink),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, bottom: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        DMCLGroup(
                                          'Giá web',
                                          paddingContent: EdgeInsets.zero,
                                          paddingTitle: const EdgeInsets.only(
                                              top: 4, bottom: 4),
                                          child: AnimatedCrossFade(
                                              firstChild: DMCLVerifySMS(
                                                onRequestCode: () => Services
                                                    .instance
                                                    .requestPriceWebCode(
                                                        widget
                                                            .basicInfo.sapCode,
                                                        widget.basicInfo.name),
                                                onAuthen: (value) {
                                                  isWebCodePrice = value;
                                                  dev.log('pass $value');
                                                  // setStateBuilder(() {});
                                                  setState(() {});
                                                },
                                              ),
                                              secondChild: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Wrap(
                                                    children: [
                                                      'Giảm miệng $priceOnline ',
                                                      'Giảm quà $priceGift ',
                                                      'Giảm coupon $priceCoupon',
                                                      'Giảm loại $priceType'
                                                    ]
                                                        .map((e) => Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 4,
                                                                      bottom: 4,
                                                                      right: 8),
                                                              child: DMCLCard(
                                                                borderColor: Colors
                                                                    .blueAccent,
                                                                child: Text(e),
                                                              ),
                                                            ))
                                                        .toList(),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8.0,
                                                            bottom: 8),
                                                    child: Text(
                                                      'Thanh toán online giảm thêm cho sản phẩm: $pricePayoo',
                                                      style: const TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                  ),
                                                  Text(
                                                      'Loại ${widget.productDetail.ofType} - Giá Data Đối Chiếu: $price'),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8.0,
                                                            bottom: 8),
                                                    child: Text(
                                                      'Note khuyến mãi\n${widget.productDetail.note}',
                                                      style: const TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      DMCLCard(
                                                        borderColor: stockMain <
                                                                10
                                                            ? Colors.red
                                                            : Colors.blueAccent,
                                                        child: Text.rich(TextSpan(
                                                            text: 'Tồn chính ',
                                                            style: TextStyle(
                                                                color: GlobalStyles
                                                                    .textColor54),
                                                            children: [
                                                              TextSpan(
                                                                  text:
                                                                      '$stockMain',
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500))
                                                            ])),
                                                      ),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      DMCLCard(
                                                        borderColor: stockNum <
                                                                10
                                                            ? Colors.redAccent
                                                            : Colors.blueAccent,
                                                        child: Text.rich(TextSpan(
                                                            text: 'Tồn all ',
                                                            style: TextStyle(
                                                                color: GlobalStyles
                                                                    .textColor54),
                                                            children: [
                                                              TextSpan(
                                                                  text:
                                                                      '$stockNum',
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500))
                                                            ])),
                                                      ),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              crossFadeState: isWebCodePrice
                                                  ? CrossFadeState.showSecond
                                                  : CrossFadeState.showFirst,
                                              duration: const Duration(
                                                  milliseconds: 375)),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        DMCLGroup(
                                            'Giá sàn (CN ${UserModel.instance.siteId})',
                                            paddingContent: EdgeInsets.zero,
                                            paddingTitle: const EdgeInsets.only(
                                                top: 4, bottom: 4),
                                            child: Column(
                                              children: [
                                                if (preorder == null)
                                                  DMCLCard(
                                                    borderColor: Colors.red,
                                                    child: const Text(
                                                        'Có lỗi khi lấy dữ liệu. Vui lòng thử lại sau.'),
                                                  ),
                                                if (preorder != null)
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              DMCLCard(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Text(
                                                                      'Giảm thêm',
                                                                      style: TextStyle(
                                                                          color:
                                                                              GlobalStyles.textColor54),
                                                                    ),
                                                                    Text(preorder
                                                                        .giamthem
                                                                        .toCurrency()),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              DMCLCard(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Text(
                                                                      'Giảm thêm MC',
                                                                      style: TextStyle(
                                                                          color:
                                                                              GlobalStyles.textColor54),
                                                                    ),
                                                                    Text(preorder
                                                                        .giamthemMC
                                                                        .toCurrency()),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Container(
                                                            constraints:
                                                                const BoxConstraints(
                                                                    minWidth:
                                                                        125),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Container(
                                                                  child: Text(
                                                                    preorder
                                                                        .salePrice
                                                                        .toCurrency(),
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                        color: Colors
                                                                            .red,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 4,
                                                                ),
                                                                Container(
                                                                  constraints:
                                                                      const BoxConstraints(
                                                                          minWidth:
                                                                              100),
                                                                  child:
                                                                      DMCLCard(
                                                                    duration: const Duration(
                                                                        milliseconds:
                                                                            2000),
                                                                    animationBorderColor: const [
                                                                      Colors
                                                                          .blue,
                                                                      Colors
                                                                          .redAccent
                                                                    ],
                                                                    borderWith:
                                                                        1.1,
                                                                    borderColor:
                                                                        Colors
                                                                            .blue,
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Text(
                                                                          'Thưởng nóng',
                                                                          style: TextStyle(
                                                                              fontSize: 13,
                                                                              color: GlobalStyles.textColor54),
                                                                        ),
                                                                        Text(
                                                                          widget
                                                                              .productDetail
                                                                              .preorder!
                                                                              .bonus
                                                                              .toCurrency(),
                                                                          style: const TextStyle(
                                                                              fontSize: 15,
                                                                              color: Colors.blueAccent),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Wrap(
                                                        spacing: 8,
                                                        children: [
                                                          // DMCLCard(
                                                          //   child:
                                                          //       Column(children: [
                                                          //     const Text('Ngành'),
                                                          //     Text(preorder.mc)
                                                          //   ]),
                                                          // ),
                                                          DMCLCard(
                                                            width: 70,
                                                            borderColor:
                                                                Colors.blueGrey,
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Text(
                                                                    'VAT',
                                                                    style: TextStyle(
                                                                        color: GlobalStyles
                                                                            .textColor54),
                                                                  ),
                                                                  Text(preorder
                                                                      .nameForVAT)
                                                                ]),
                                                          ),
                                                          DMCLCard(
                                                            width: 70,
                                                            borderColor:
                                                                Colors.blueGrey,
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Text(
                                                                    'Loại',
                                                                    style: TextStyle(
                                                                        color: GlobalStyles
                                                                            .textColor54),
                                                                  ),
                                                                  Text(preorder
                                                                      .type)
                                                                ]),
                                                          ),
                                                          DMCLCard(
                                                            width: 120,
                                                            borderColor: preorder
                                                                        .stock ==
                                                                    0
                                                                ? Colors.red
                                                                : Colors
                                                                    .blueGrey,
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Text(
                                                                    'Số lượng tồn',
                                                                    style: TextStyle(
                                                                        color: GlobalStyles
                                                                            .textColor54),
                                                                  ),
                                                                  Text(
                                                                      '${preorder.stock}')
                                                                ]),
                                                          )
                                                        ],
                                                      ),
                                                      if (preorder
                                                          .gifts.isNotEmpty)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 8.0,
                                                                  bottom: 8),
                                                          child: Column(
                                                            children: [
                                                              DMCLTitleCard(
                                                                title:
                                                                    'Quà tặng kèm',
                                                                borderColor:
                                                                    Colors
                                                                        .purple,
                                                                children: preorder
                                                                    .gifts
                                                                    .map((e) =>
                                                                        Container(
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                e.itemId,
                                                                                style: TextStyle(color: GlobalStyles.textColor54),
                                                                              ),
                                                                              Text(e.itemName),
                                                                              if (e.promotionPrice != 0)
                                                                                DMCLCard(child: Text(e.promotionPrice.toCurrency())),
                                                                              if (e.giamgiaKLKM != 0)
                                                                                DMCLCard(child: Text(e.giamgiaKLKM.toCurrency())),
                                                                              const Divider()
                                                                            ],
                                                                          ),
                                                                        ))
                                                                    .toList(),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      if (preorder.description
                                                          .isNotEmpty)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 8.0),
                                                          child: DMCLCard(
                                                            child: Text(preorder
                                                                .description),
                                                          ),
                                                        )
                                                    ],
                                                  ),
                                              ],
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Container(
                        //   padding: const EdgeInsets.only(
                        //       left: 8, right: 8, bottom: 8),
                        //   child: renderCheckStock(),
                        // )
                      ]),
                ),
                // renderCheckStock(),
              ],
            ),
          ),
          // const Spacer(),
          SliverFillRemaining(
            hasScrollBody: false,
            child: renderFunction(),
          )
        ],
      ),
    );
  }

  Widget productDetailDescription(String title, List source,
      {Color borderColor = Colors.blueAccent}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, top: 8),
      decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(12)),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
            // color: Colors.yellow,
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  color: '#f5f5f5'.toColor(),
                  backgroundBlendMode: BlendMode.multiply,
                  border: Border(
                      bottom:
                          BorderSide(color: '#dedede'.toColor(), width: 1))),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                // direction: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: source.map((e) => Text('+ $e')).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool isExpanStock = false;

  Widget renderFunction() {
    return Container(
        // constraints: const BoxConstraints(maxHeight: 150),
        color: Colors.transparent,
        child: Padding(
          padding:
              const EdgeInsets.only(top: 8.0, bottom: 0, left: 0, right: 0),
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                // const Spacer(),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    child: const Text(
                      'Kiểm tra hàng tồn',
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () async {
                      // if (infoStocks.isEmpty) {
                      //   infoStocks = await requestDataStock();

                      //   setState(() {});
                      //   // AppNotifi(value: AppNotifiType.asyncGetStock)
                      //   //     .dispatch(context);
                      // }

                      showMaterialModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) {
                          return FractionallySizedBox(
                              heightFactor: 0.7,
                              child: Stock(widget.basicInfo.sapCode));
                        },
                      );
                    },
                  ),
                ),
                // const SizedBox(height: 8),
                Visibility(
                  visible: false,
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent),
                      child: const Text(
                        'Thêm vào đơn hàng',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () async {
                        var json = widget.basicInfo.toJson();
                        var msgPackage = json;

                        if (Platform.isAndroid) {
                          AndroidIntent intent = AndroidIntent(
                            action: 'com.dmcl.appcheck.preorder',

                            // data: 'content://com.dmcl.inventory',
                            // action: 'com.dmcl.appcheck.inventory',

                            package: 'com.dmcl.preorder',
                            arguments: msgPackage,
                          );
                          var canIntentLaunch =
                              await intent.canResolveActivity() ?? false;
                          if (canIntentLaunch) {
                            await intent.launch();
                          } else {
                            Fluttertoast.showToast(
                                msg: 'Chưa cài đặt ứng dụng preorder');
                          }
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  // Widget renderStockPanel() {
  //   TextEditingController fieldSearchStore = TextEditingController();
  //   dev.log('rebuild.renderStockPanel');

  //   return AnimatedContainer(
  //       clipBehavior: Clip.hardEdge,
  //       decoration: BoxDecoration(
  //           color: Colors.white, borderRadius: BorderRadius.circular(16)),
  //       duration: const Duration(milliseconds: 275),
  //       child: StatefulBuilder(builder: (context, setStateBuilder) {
  //         List<StockModel> data = infoStocks;
  //         dev.log('rebuild.StatefulBuilder');

  //         return Container(
  //           child: Column(
  //             children: [
  //               DMCLShadow(
  //                 radius: 20,
  //                 // direction: const Offset(0.1, 0.1),
  //                 child: Column(
  //                   children: [
  //                     Container(
  //                       height: 56,
  //                       color: '#f5f5f5'.toColor(),
  //                       child: Padding(
  //                         padding: const EdgeInsets.only(
  //                             left: 16, right: 16, top: 8, bottom: 8),
  //                         child: Row(
  //                             mainAxisSize: MainAxisSize.max,
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             children: [
  //                               const Text(
  //                                 'Danh sách chi nhánh',
  //                                 style: TextStyle(
  //                                     fontSize: 16,
  //                                     fontWeight: FontWeight.w500),
  //                               ),
  //                               IconButton(
  //                                   onPressed: () {
  //                                     isExpanStock = !isExpanStock;
  //                                     setState(() {});
  //                                   },
  //                                   icon: const Icon(Icons.arrow_drop_down))
  //                             ]),
  //                       ),
  //                     ),
  //                     const Divider(
  //                       height: 1,
  //                       thickness: 1,
  //                     ),
  //                     Padding(
  //                       padding: const EdgeInsets.all(8),
  //                       child: DMCLSearchBox(
  //                         controller: fieldSearchStore,
  //                         hint: 'Tìm kiếm (nhập thường, có dấu)',
  //                         isAutocomplete: false,
  //                         onChange: (value) {
  //                           if (value.isEmpty) return;
  //                           data = [];
  //                           setStateBuilder(() {});
  //                           for (var e in infoStocks) {
  //                             var isMatchName =
  //                                 e.nameStore.toLowerCase().contains(value);
  //                             var isMatchCode =
  //                                 e.codeStore.toLowerCase().contains(value);

  //                             if (isMatchName || isMatchCode) {
  //                               data.add(e);
  //                               setStateBuilder(() {});

  //                               dev.log(
  //                                   'fieldsearch.after $value, ${data.length}');
  //                             }
  //                           }
  //                         },
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //               // const SizedBox(
  //               //   height: 8,
  //               // ),
  //               Expanded(
  //                 child: Padding(
  //                   padding: const EdgeInsets.only(
  //                       top: 2, left: 8.0, right: 8, bottom: 8),
  //                   child: SingleChildScrollView(
  //                     keyboardDismissBehavior:
  //                         ScrollViewKeyboardDismissBehavior.onDrag,
  //                     child: Padding(
  //                       padding: const EdgeInsets.only(top: 16.0),
  //                       child: Column(children: [
  //                         if (data.isEmpty) Center(child: LoadingFragment()),
  //                         ...data
  //                             .map((e) => Padding(
  //                                   padding: const EdgeInsets.only(bottom: 8.0),
  //                                   child: DMCLCard(
  //                                     child: Column(
  //                                       mainAxisAlignment:
  //                                           MainAxisAlignment.start,
  //                                       crossAxisAlignment:
  //                                           CrossAxisAlignment.start,
  //                                       children: [
  //                                         Padding(
  //                                           padding: const EdgeInsets.only(
  //                                               bottom: 8.0),
  //                                           child: Container(
  //                                             color: Colors.transparent,
  //                                             child: Row(
  //                                               mainAxisSize: MainAxisSize.max,
  //                                               mainAxisAlignment:
  //                                                   MainAxisAlignment
  //                                                       .spaceBetween,
  //                                               children: [
  //                                                 DMCLCard(
  //                                                   // width: 70,
  //                                                   borderWith: 0,
  //                                                   child: Column(
  //                                                       crossAxisAlignment:
  //                                                           CrossAxisAlignment
  //                                                               .start,
  //                                                       children: [
  //                                                         Text(
  //                                                           'CN',
  //                                                           style: TextStyle(
  //                                                               color: GlobalStyles
  //                                                                   .textColor54,
  //                                                               fontSize: 14),
  //                                                         ),
  //                                                         Text(e.nameStore,
  //                                                             style: const TextStyle(
  //                                                                 fontSize: 16,
  //                                                                 fontWeight:
  //                                                                     FontWeight
  //                                                                         .w500))
  //                                                       ]),
  //                                                 ),
  //                                                 // DMCLCard(
  //                                                 //   borderWith: 0,
  //                                                 //   child: Column(
  //                                                 //     crossAxisAlignment:
  //                                                 //         CrossAxisAlignment
  //                                                 //             .start,
  //                                                 //     children: [
  //                                                 //       Text(
  //                                                 //         'CN',
  //                                                 //         style: TextStyle(
  //                                                 //             color: GlobalStyles
  //                                                 //                 .textColor54),
  //                                                 //       ),
  //                                                 //       Text(
  //                                                 //         e.nameStore,
  //                                                 //         style: const TextStyle(
  //                                                 //             fontWeight:
  //                                                 //                 FontWeight
  //                                                 //                     .w500),
  //                                                 //       ),
  //                                                 //     ],
  //                                                 //   ),
  //                                                 // ),
  //                                                 Row(
  //                                                   children: [
  //                                                     DMCLCard(
  //                                                       // width: 70,
  //                                                       borderColor:
  //                                                           Colors.blueGrey,
  //                                                       child: Column(
  //                                                           crossAxisAlignment:
  //                                                               CrossAxisAlignment
  //                                                                   .end,
  //                                                           children: [
  //                                                             Text(
  //                                                               'Mã SLOC/ Tên kho',
  //                                                               style: TextStyle(
  //                                                                   color: GlobalStyles
  //                                                                       .textColor54,
  //                                                                   fontSize:
  //                                                                       14),
  //                                                             ),
  //                                                             Text(
  //                                                                 '${e.sloc}/ ${e.slocName}',
  //                                                                 style: const TextStyle(
  //                                                                     fontSize:
  //                                                                         16))
  //                                                           ]),
  //                                                     ),
  //                                                     // DMCLCard(
  //                                                     //   // width: 70,
  //                                                     //   borderColor:
  //                                                     //       Colors.blueGrey,
  //                                                     //   child: Column(
  //                                                     //       crossAxisAlignment:
  //                                                     //           CrossAxisAlignment
  //                                                     //               .end,
  //                                                     //       children: [
  //                                                     //         Text(
  //                                                     //           'Tên kho',
  //                                                     //           style: TextStyle(
  //                                                     //               color: GlobalStyles
  //                                                     //                   .textColor54),
  //                                                     //         ),
  //                                                     //         Text(e.slocName)
  //                                                     //       ]),
  //                                                     // ),
  //                                                   ],
  //                                                 ),
  //                                               ],
  //                                             ),
  //                                           ),
  //                                         ),
  //                                         Row(
  //                                           mainAxisAlignment:
  //                                               MainAxisAlignment.spaceBetween,
  //                                           children: [
  //                                             DMCLCard(
  //                                               // width: 70,
  //                                               borderColor: Colors.blueGrey,
  //                                               child: Column(
  //                                                   crossAxisAlignment:
  //                                                       CrossAxisAlignment.end,
  //                                                   children: [
  //                                                     Text(
  //                                                       'Loại',
  //                                                       style: TextStyle(
  //                                                           color: GlobalStyles
  //                                                               .textColor54),
  //                                                     ),
  //                                                     Text(e.productType)
  //                                                   ]),
  //                                             ),
  //                                             // const SizedBox(
  //                                             //   width: 8,
  //                                             // ),
  //                                             renderStock(
  //                                                 'Số lượng', e.stockMain),

  //                                             // renderStock(
  //                                             //     'Tồn all', e.stockNum),
  //                                           ],
  //                                         ),

  //                                         // Wrap(
  //                                         //   children: e.status.map((status) {
  //                                         //     if ((status['title'] as String)
  //                                         //         .isNotEmpty) {
  //                                         //       return Card(
  //                                         //         child: Padding(
  //                                         //           padding:
  //                                         //               const EdgeInsets.all(
  //                                         //                   8.0),
  //                                         //           child: Text(
  //                                         //               ' ${status['title']}'),
  //                                         //         ),
  //                                         //       );
  //                                         //     }
  //                                         //     return Container();
  //                                         //   }).toList(),
  //                                         // )
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 ))
  //                             .toList(),
  //                       ]),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         );
  //       }));
  // }

  // Widget renderStock(String title, int stockNum) => DMCLCard(
  //       width: 90,
  //       borderColor: stockNum >= 5 ? Colors.blue : Colors.redAccent,
  //       child: Column(
  //         children: [
  //           Text(
  //             title,
  //             style: const TextStyle(color: Colors.black54, fontSize: 14),
  //           ),
  //           Text(
  //             '$stockNum',
  //             style: const TextStyle(
  //                 color: Colors.black,
  //                 fontWeight: FontWeight.w500,
  //                 fontSize: 17),
  //           )
  //         ],
  //       ),
  //     );

  Widget renderStatus(status) {
    dev.log('product.status $status');
    var newStatus = [];
    for (var i in status) {
      var item = i;
      if ((item['title'] as String).isNotEmpty) newStatus.add(item);
    }
    setState(() {});

    return Wrap(
        children: newStatus
            .map((e) => Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.pinkAccent)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(e['title']),
                    ))))
            .toList());
  }
}
