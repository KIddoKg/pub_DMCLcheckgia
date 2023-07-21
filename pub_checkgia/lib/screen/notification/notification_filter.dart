import 'package:pub_checkgia/models/UserModel.dart';
 
 import 'package:pub_dmclcheckgia/pub_DMCLcheckgia.dart';
import 'package:flutter/material.dart';

class NotificationFilter extends StatefulWidget {
  const NotificationFilter({super.key});

  @override
  State<NotificationFilter> createState() => _NotificationFilterState();
}

class _NotificationFilterState extends State<NotificationFilter> {
  TextEditingController fieldSearch = TextEditingController();

  List<String> sourceGroups = [];
  List<String> selectGroups = [];

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FractionallySizedBox(
      heightFactor: 0.75,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 50,
                    color: GlobalStyles.backgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, bottom: 8, left: 8, right: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Bộ lọc tìm kiếm',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.close,
                                size: 28,
                                color: Colors.black54,
                              ))
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8.0),
                            child: DMCLSearchBox(
                              hint: 'Tìm kiếm tiêu đề',
                              controller: fieldSearch,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Phân loại theo nhóm',
                                  style: TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: sourceGroups
                                      .map((e) => GestureDetector(
                                            onTap: () {
                                              if (selectGroups.contains(e)) {
                                                selectGroups.remove(e);
                                                setState(() {});
                                                return;
                                              }
                                              selectGroups.add(e);
                                              setState(() {});
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 575),
                                              child: DMCLCard(
                                                backgroundColor: selectGroups
                                                        .contains(e)
                                                    ? GlobalStyles.activeColor
                                                    : Colors.white,
                                                borderColor: selectGroups
                                                        .contains(e)
                                                    ? GlobalStyles.activeColor
                                                    : Colors.grey,
                                                child: Text(
                                                  e,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: selectGroups
                                                              .contains(e)
                                                          ? Colors.white
                                                          : Colors.black),
                                                ),
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ]),
                  ),
                ],
              ),
              SizedBox(
                height: 46,
                width: double.infinity,
                child: ElevatedButton(
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0.0),
                                    side: const BorderSide(
                                        color: Colors.transparent)))),
                    onPressed: () async {
                      if (fieldSearch.text == '') {}

                      // var res = await Services.instance.getNotification(
                      //     title: fieldSearch.text, groups: selectGroups);
                      // var response = res.castList<NotificationModel>();

                      Navigator.pop(context, {
                        "filter": {
                          "groups": selectGroups,
                          "title": fieldSearch.text
                        }
                      });
                    },
                    child: const Text(
                      'Áp dụng',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  initData() {
    sourceGroups =
        UserModel.instance.groupNotices.map((e) => e as String).toList();
    setState(() {});
  }
}
