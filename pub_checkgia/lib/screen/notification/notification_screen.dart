// ignore_for_file: use_build_context_synchronously, must_be_immutable, avoid_unnecessary_containers

import 'package:pub_dmclcheckgia/pub_DMCLcheckgia.dart';
 import 'package:pub_dmclcheckgia/pub_DMCLcheckgia.dart';
import 'package:pub_checkgia/models/UserModel.dart';
import 'package:pub_checkgia/models/notificationModel.dart';
import 'package:pub_checkgia/screen/notification/notification_filter.dart';
import 'package:pub_checkgia/services/api.dart';
import 'package:pub_checkgia/services/services_temp.dart'; 
 
 import 'package:pub_dmclcheckgia/pub_DMCLcheckgia.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isLoading = true;
  List<NotificationModel> notifications = [];
  NotificationModel? _currentNotification;

  @override
  void initState() {
    super.initState();

    // UserModel.instance.isTester = true;
    initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalStyles.backgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: UserModel.instance.isTester
          ? FloatingActionButton(
              child: const Icon(Icons.send),
              onPressed: () async {
                var request = await API
                    .sendNoti(
                        'Thông báo quản lý',
                        'Quản lý quận 5',
                        'Yêu cầu duyệt sản phẩm giảm giá ...',
                        'H001/test',
                        'Quản lý',
                        'APPCHECK')
                    .request();
                if (!request.isSuccess) {
                  showAlert(context, 'Có lỗi trong quá trình xử lý',
                      'Chi tiết: ${request.error!['message']}');
                }
              },
            )
          : null,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: GlobalStyles.backgroundColorAppBar,
            pinned: true,
            title: const Text('Thông báo'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                  onPressed: () async {
                    var result = await showMaterialModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) => const NotificationFilter(),
                    );

                    if (result != null) {
                      var title = result['filter']['title'];
                      var groups = result['filter']['groups'];

                      notifications = [];
                      setState(() {});

                      var response = await Services.instance
                          .getNotifications(title: title, groups: groups);
                      notifications = response.castList<NotificationModel>(fromJson: NotificationModel.fromJson);
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.filter_alt))
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(children: [
                if (!UserModel.instance.isNotice)
                  DMCLCard(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 26.0, right: 26),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 12, bottom: 12.0),
                            child: Icon(
                              Icons.warning,
                              size: 42,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            'Bạn chưa được cấp quyền để xem.\nLiên hệ quản lý để kiểm tra.',
                            style: TextStyle(
                                fontSize: 18, color: GlobalStyles.textColor54),
                          )
                        ],
                      ),
                    ),
                  ),
                if (isLoading && UserModel.instance.isNotice)
                  DMCLCard(
                    // width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 26.0, right: 26),
                      child: Column(
                        children: [
                          if (notifications.isEmpty && !isLoading)
                            Column(
                              children: [
                                const Padding(
                                  padding:
                                      EdgeInsets.only(top: 12, bottom: 12.0),
                                  child: Icon(
                                    Icons.warning,
                                    // size: 42,
                                    // color: Colors.amberAccent,
                                  ),
                                ),
                                Text(
                                  'Không có dữ liệu',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: GlobalStyles.textColor54),
                                ),
                              ],
                            )
                          else
                            LoadingFragment(
                              text: 'Đang tải',
                            )
                        ],
                      ),
                    ),
                  )
                else if (!isLoading && UserModel.instance.isNotice)
                  ...notifications
                      .map((e) => NotificationCard(
                            data: e,
                            selected: e == _currentNotification,
                            onTap: () {
                              _currentNotification = e;
                              setState(() {});
                            },
                          ))
                      .toList()
              ]),
            ),
          )
        ],
      ),
    );
  }

  void initData() async {
    // sampleData();

    var response = await Services.instance.getNotifications();
    isLoading = false;
    notifications = response.castList<NotificationModel>(fromJson: NotificationModel.fromJson);

    AppSetting.modify(lastNoti: response.total).save();
    setState(() {});
  }

  void sampleData() {
    for (var i = 0; i < 10; i++) {
      var item = NotificationModel.fromJson({
        'title': 'Thông báo quản lý',
        'isSeen': i % 2 == 0 ? true : false,
        'message':
            'Bạn nhận được thông báo từ nhân viên chi nhánh quận 4 yêu cầu duyệt giá sản phẩm ÁBC',
        'from': 'Nhân viên quận 4',
        'createdDate': DateFormat.yMd().add_Hm().format(DateTime.now())
      });
      notifications.add(item);
    }
  }

  onNotiTap(NotificationModel item) {
    Fluttertoast.showToast(msg: 'Đã xem thông báo này');
    item.isSeen = true;
    setState(() {});
  }
}

class NotificationCard extends StatefulWidget {
  void Function()? onTap;
  bool selected;
  NotificationModel data;
  NotificationCard(
      {super.key, required this.data, this.onTap, this.selected = false});

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: GestureDetector(
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap!();
            }
          },
          child: DMCLCard(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Visibility(
                    visible: false,
                    child: Row(
                      children: [
                        CircleAvatar(
                            child: Text(
                          (widget.data.toId),
                        )),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: Text(widget.data.title,
                                    maxLines: 2,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: true,
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 375),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: widget.selected
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                              maxRadius: 34,
                              backgroundColor:
                                  const Color.fromARGB(179, 221, 221, 221),
                              child: Text(
                                (widget.data.toId),
                              )),
                          // DMCLCard(child: Text(widget.data.toId)),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.data.title,
                                    maxLines: 2,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16)),
                                const SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  widget.data.subTitle,
                                  maxLines: 3,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: GlobalStyles.textColor54),
                                ),
                                Visibility(
                                    visible: widget.selected,
                                    child: Container(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Column(
                                          children: [
                                            Text(
                                              widget.data.content,
                                              style:
                                                  const TextStyle(fontSize: 15),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  widget.data.createdDate.toDateString(),
                                  style: TextStyle(
                                      color: GlobalStyles.textColor45,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
