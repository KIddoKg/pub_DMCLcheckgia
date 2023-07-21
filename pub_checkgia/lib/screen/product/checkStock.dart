import 'dart:developer';

 import 'package:pub_dmclcheckgia/pub_DMCLcheckgia.dart';
import 'package:pub_checkgia/models/productModel.dart';
import 'package:pub_checkgia/services/services_temp.dart'; 
 
 import 'package:pub_dmclcheckgia/pub_DMCLcheckgia.dart';
import 'package:flutter/material.dart';

class Stock extends StatefulWidget {
  String sapCode;

  Stock(this.sapCode, {super.key});

  @override
  State<Stock> createState() => _StockState();
}

class _StockState extends State<Stock> {
  List<StockModel> data = [];
  List<StockModel> tmpData = [];

  List<StockSapModel> data1 = [];
  List<StockSapModel> tmpData1 = [];

  StockModel? selectItem;

  TextEditingController fieldSearch = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        duration: const Duration(milliseconds: 275),
        child: Container(
          child: Column(
            children: [
              DMCLShadow(
                radius: 20,
                // direction: const Offset(0.1, 0.1),
                child: Column(
                  children: [
                    Container(
                      height: 56,
                      color: '#f5f5f5'.toColor(),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 8, bottom: 8),
                        child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Danh sách chi nhánh',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              IconButton(
                                  onPressed: () {
                                    // isExpanStock = !isExpanStock;
                                    // setState(() {});
                                  },
                                  icon: const Icon(Icons.arrow_drop_down))
                            ]),
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: DMCLSearchBox(
                        controller: fieldSearch,
                        hint: 'Tìm kiếm (nhập thường, có dấu)',
                        isAutocomplete: false,
                        onChange: (value) {
                          if (value.isEmpty) {
                            tmpData1 = data1;
                            setState(() {});
                            return;
                          }
                          tmpData1 = [];
                          setState(() {});
                          for (var e in data1) {
                            var isMatchName =
                                e.plantName.toLowerCase().contains(value);
                            var isMatchCode =
                                e.plant.toLowerCase().contains(value);

                            // var isMatchName =
                            //     e.plantName.toLowerCase().contains(value);

                            if (isMatchName || isMatchCode) {
                              // tmpData.add(e);
                              // tmpData1 == convertToList(tmpData);
                              tmpData1.add(e);
                              setState(() {});
                            }
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
              // const SizedBox(
              //   height: 8,
              // ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 2, left: 8.0, right: 8, bottom: 8),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Column(children: [
                        if (isLoading) Center(child: LoadingFragment()),
                        ...tmpData1
                            .map((e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: DMCLCard(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Container(
                                            color: Colors.transparent,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                DMCLCardLabel(
                                                  label: 'Mã CN',
                                                  value: e.plant,
                                                ),
                                                // DMCLCardLabel(
                                                //   label: 'CN',
                                                //   value: e.plantName,
                                                // ),
                                                DMCLCard(
                                                  // width: 70,
                                                  borderWith: 0,
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'CN',
                                                          style: TextStyle(
                                                              color: GlobalStyles
                                                                  .textColor54,
                                                              fontSize: 14),
                                                        ),
                                                        Text(e.plantName,
                                                            style: const TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal))
                                                      ]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Column(
                                          children: e.collection
                                              .map(
                                                (e) => GestureDetector(
                                                  onTap: () {
                                                    selectItem = e;
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: selectItem == e
                                                            ? const Color
                                                                    .fromARGB(
                                                                57,
                                                                215,
                                                                215,
                                                                215)
                                                            : null,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6)),
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 5),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        AnimatedContainer(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      525),
                                                          width: 2,
                                                          height:
                                                              selectItem == e
                                                                  ? 78
                                                                  : 0,
                                                          color: selectItem == e
                                                              ? Colors
                                                                  .blueAccent
                                                              : Colors
                                                                  .transparent,
                                                        ),
                                                        Icon(
                                                          Icons.arrow_right,
                                                          color: selectItem == e
                                                              ? Colors
                                                                  .blueAccent
                                                              : Colors.grey,
                                                        ),
                                                        Expanded(
                                                          child: DMCLCard(
                                                            borderWith: 0,
                                                            backgroundColor:
                                                                const Color
                                                                        .fromRGBO(
                                                                    0, 0, 0, 0),
                                                            borderColor: Colors
                                                                .transparent,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    '${e.sloc}/ ${e.slocName}'),
                                                                DMCLCard(
                                                                  width: 80,
                                                                  borderColor:
                                                                      Colors
                                                                          .redAccent,
                                                                  child: Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Text(
                                                                          'Số lượng',
                                                                          style: TextStyle(
                                                                              color: GlobalStyles.textColor54,
                                                                              fontSize: 12),
                                                                        ),
                                                                        Text(
                                                                          '${e.stockMain}',
                                                                          style:
                                                                              const TextStyle(fontSize: 20),
                                                                        )
                                                                      ]),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                            .toList(),
                      ]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void loadData() async {
    // var stocks = await Services.instance.getStock(widget.basicInfo.sapCode);
    isLoading = true;
    var stocks =
        await Services.instance.getStockFromGetGiaService(widget.sapCode);
print(stocks);
    data = stocks ?? [];
    tmpData = data;

    // List<StockModel> tmpSort = [];
    // tmpSort.insertAll(0, data);
    // List<StockSapModel> sortResult = [];
    // if (tmpSort.isNotEmpty) {
    //   for (int i = 0; i < tmpSort.length; i++) {
    //     var parent = tmpSort[i];
    //     List<StockModel> list = [];
    //     list.add(parent);
    //     for (int j = 0; j < tmpSort.length; j++) {
    //       var child = tmpSort[j];

    //       if (parent.codeStore == child.codeStore &&
    //           parent.sloc != child.sloc) {
    //         list.add(child);
    //         tmpSort.remove(child);
    //       }
    //     }
    //     var newCollection =
    //         StockSapModel.create(parent.codeStore, parent.nameStore, list);
    //     sortResult.add(newCollection);
    //     tmpSort.remove(parent);
    //   }
    // }

    data1 = convertToList(data);
    tmpData1 = data1;
print(data1);
    for (var item in data1) {
      log('+ CN ${item.plantName}');
      for (var element in item.collection) {
        log('   > sloc ${element.sloc} | ${element.stockMain}');
      }
    }
    isLoading = false;
    setState(() {});
  }

  List<StockSapModel> convertToList(List<StockModel> source) {
    List<StockModel> tmpSort = [];
    tmpSort.insertAll(0, data);
    List<StockSapModel> sortResult = [];
    if (tmpSort.isNotEmpty) {
      for (int i = 0; i < tmpSort.length; i++) {
        var parent = tmpSort[i];
        List<StockModel> list = [];
        list.add(parent);
        for (int j = 0; j < tmpSort.length; j++) {
          var child = tmpSort[j];

          if (parent.codeStore == child.codeStore &&
              parent.sloc != child.sloc) {
            list.add(child);
            tmpSort.remove(child);
          }
        }
        var newCollection =
            StockSapModel.create(parent.codeStore, parent.nameStore, list);
        sortResult.add(newCollection);
        // tmpSort.remove(parent);
      }
    }

    return sortResult;
  }
}
