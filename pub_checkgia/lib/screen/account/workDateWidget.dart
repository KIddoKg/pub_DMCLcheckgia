// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'dart:ui' as ui;
import 'dart:ui';


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pub_dmclcheckgia/pub_DMCLcheckgia.dart';
import 'package:pub_checkgia/models/workDataModel.dart';
import 'package:pub_checkgia/services/services_temp.dart';

class UIWorkDate extends StatefulWidget {
  Function(ScrollController controller)? delegateInitView;

  UIWorkDate({super.key, this.delegateInitView});

  @override
  State<UIWorkDate> createState() => _UIWorkDateState();
}

class _UIWorkDateState extends State<UIWorkDate> {
  ScrollController scrollController = ScrollController();

  List<WorkDateModel> dateWorkInfo = [];

  bool isLoading = false;

  var offDateColor = Colors.redAccent;
  var workDateColor = Colors.greenAccent;
  var normalDateColor = Colors.white;
  var toDateColor = Colors.green;

  int selectedDay = DateTime.now().day;
  int selectedMouth = -1;

  @override
  void initState() {
    super.initState();

    loadWorKDate();
  }

  Color markColorOfDate(int calendareDay) {
    var colorDate = normalDateColor;
    var sunday =
        DateTime(DateTime.now().year, DateTime.now().month, calendareDay)
                .weekday ==
            7;
    if (sunday) colorDate = offDateColor;
    if (calendareDay > dateWorkInfo.length) return colorDate;

    var matchDateIndex = dateWorkInfo.indexWhere((element) {
      var dateFormat = DateFormat('dd/MM/yyyy');
      var date = dateFormat.parse(element.date);

      return date.day == calendareDay;
    });

    if (matchDateIndex != -1) colorDate = workDateColor;

    return colorDate;
  }

  Border markBorderColor(int calendareDay) {
    var isMatch = calendareDay == DateTime.now().day;

    return Border.all(
        color: isMatch ? toDateColor : Colors.grey, width: isMatch ? 1.4 : 0.4);
  }

  @override
  Widget build(BuildContext context) {
    var currentMonth = DateTime.now().month;
    var currentDay = DateTime.now().day;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              border: Border.all(width: 0.4, color: Colors.transparent)),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hôm nay, ${DateTime.now().toWeekdayString()}',
                  style: const TextStyle(fontSize: 15),
                ),
                SizedBox(
                  height: 20,
                  child: DropdownButton(
                    elevation: 10,
                    // padding: const EdgeInsets.only(top: -2, bottom: -2),
                    underline: Container(color: Colors.transparent),
                    value: selectedMouth == -1 ? currentMonth : selectedMouth,
                    items: List.generate(
                        11,
                        (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text('Tháng ${index + 1}'))),
                    onChanged: (value) {
                      selectedMouth = value!;
                      setState(() {});

                      log('month.selected $selectedMouth');
                    },
                  ),
                )
              ],
            ),
          ),
        ),
        Container(
          // height: 50,
          decoration: BoxDecoration(
              // color: Colors.color,
              border: Border.all(width: 0.4, color: Colors.transparent)),
          child: SingleChildScrollView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List<int>.generate(DateTime.now().lastDateOfMouth().day,
                      (index) => index + 1)
                  .map((e) => Column(
                        children: [
                          Container(
                            // width: 25,
                            // height: 20,
                            // height: 24,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 0.1, color: Colors.transparent)),
                            child: Visibility(
                              visible: selectedDay == e && currentDay != e
                                  ? true
                                  : false,
                              child: const FittedBox(
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  fill: 1,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                          AnimatedPadding(
                            duration: const Duration(milliseconds: 600),
                            padding: const EdgeInsets.only(left: 4, right: 4),
                            child: GestureDetector(
                              onTap: () {
                                selectedDay = e;
                                setState(() {});
                                log('date.selected $e');
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(5),
                                        bottomRight: Radius.circular(10)),
                                    border: markBorderColor(e),
                                    color: markColorOfDate(e)),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 4,
                                        left: 4,
                                        child: Text(
                                          '$e',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 4,
                                        child: Text(
                                          DateTime(DateTime.now().year,
                                                  DateTime.now().month, e)
                                              .toWeekdayString(),
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        if (dateWorkInfo.isNotEmpty)
          UIWorkDateTimeline(times: getWorkTimescan(selectedDay)
              // : dateWorkInfo[selectedDay].timeScan,
              )
        else
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              child: const Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.amber,
                    size: 18,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Không tìm thấy dữ liệu. Vui lòng thử lại sau.',
                    style: TextStyle(color: Colors.black54),
                  )
                ],
              ),
            ),
          ),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }

  loadWorKDate() async {
    isLoading = false;
    var data = await Services.instance.getWorkDate();
    isLoading = true;

    if (data is List<WorkDateModel>) {
      dateWorkInfo = data;
      setState(() {});

      await Future.delayed(const Duration(milliseconds: 275));

      var today = DateTime.now().day;

      // today from 1 -> 6 return
      if (today < 6) return;
      var offset = (today - 1) * 50;
      log('scrollToDate.offset todate $today $offset');
      scrollController.animateTo(offset.toDouble(),
          duration: const Duration(milliseconds: 1075),
          curve: Curves.fastLinearToSlowEaseIn);
    }

    log('workdate.response');
    for (var i in data as List<WorkDateModel>) {
      log('> ${i.date}\n${i.timeScan}');
    }
    log('---------------');
  }

  List<String> getWorkTimescan(int day) {
    var index = dateWorkInfo.indexWhere(
        (element) => int.parse(element.date.split('/').first) == day);

    if (index == -1) return [];
    return dateWorkInfo[index].timeScan;
  }
}

class UIWorkDateTimeline extends StatefulWidget {
  List<String> times;
  Color? workTimeColor;

  UIWorkDateTimeline(
      {super.key, required this.times, this.workTimeColor = Colors.amber});

  @override
  State<UIWorkDateTimeline> createState() => _UIWorkDateTimelineState();
}

class _UIWorkDateTimelineState extends State<UIWorkDateTimeline> {
  Color? lateTime;

  Color? offTime;

  String displayType = 'chart';

  @override
  Widget build(BuildContext context) {
    log('UIWorkDateTimeline.rebuild ${widget.times}');

    return Container(
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 245, 245, 245),
          borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(top: 8),
      height: 450,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DMCLShadow(
                child: SizedBox(
                  height: 30,
                  child: SegmentedButton<String>(
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      elevation: MaterialStateProperty.all(0),
                      surfaceTintColor: MaterialStateProperty.all(Colors.grey),
                      // backgroundColor: MaterialStateProperty.all(Colors.grey),
                      // foregroundColor: MaterialStateProperty.all(Colors.blue)
                    ),
                    selectedIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Icon(Icons.check),
                    ),
                    segments: const [
                      ButtonSegment<String>(
                          value: 'chart',
                          label: Padding(
                            padding: EdgeInsets.only(bottom: 10.0),
                            child: Text('Biểu đồ'),
                          )),
                      ButtonSegment<String>(
                          value: 'numberic',
                          label: Padding(
                            padding: EdgeInsets.only(bottom: 10.0),
                            child: Text('Số liệu'),
                          ))
                    ],
                    selected: <String>{displayType},
                    onSelectionChanged: (result) {
                      displayType = result.first;
                      setState(() {});
                    },
                  ),
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
              firstChild: SizedBox(
                height: 400,
                child: ListView.separated(
                    itemBuilder: (context, index) {
                      return Card(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(widget.times[index]),
                      ));
                    },
                    separatorBuilder: (context, index) {
                      return Container();
                    },
                    itemCount: widget.times.length),
              ),
              secondChild: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      '06:00',
                      '08:00',
                      '10:00',
                      '12:00',
                      '14:00',
                      '16:00',
                      '18:00',
                      '20:00',
                      '22:00'
                    ]
                        .map((e) => Row(
                              children: [
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(e),
                                  ),
                                ),
                              ],
                            ))
                        .toList(),
                  ),
                  ChartTimeline(
                    times: widget.times,
                    workTimeColor: widget.workTimeColor,
                  )
                ],
              ),
              crossFadeState: displayType == 'chart'
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 375))
        ],
      ),
    );
  }
}

class ChartTimeline extends StatefulWidget {
  List<String> times;
  Color? workTimeColor;
  Color? lateTime;
  Color? offTime;

  ChartTimeline({super.key, required this.times, this.workTimeColor});

  @override
  State<ChartTimeline> createState() => _ChartTimelineState();
}

class _ChartTimelineState extends State<ChartTimeline> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(border: Border.all(width: 0.4)),
      child: CustomPaint(
        size: const Size(280, 375),
        painter: ChartTimelinePainter(
            times: widget.times,
            workTimeColor: widget.workTimeColor,
            onTap: (touch) {
              if (touch) {
                setState(() {});
              }
              return touch;
            }),
      ),
    );
  }
}

class ChartTimelinePainter extends CustomPainter {
  List<String> times;

  bool Function(bool isTouch)? onTap;
  Color? workTimeColor;
  Color? lateTime;
  Color? offTime;

  ChartTimelinePainter(
      {required this.times, this.onTap, this.workTimeColor = Colors.amber});

  Path pathCache = Path();

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    var height = size.height;
    var step = 42;

    var maxStep = height / step;

    List<Offset> offets = [];

    List<List<String>> baseTime = [
      // ['06:30', '08:30'],
      ['06:30', '12:00'],
      ['12:00', '22:00'],
      // ['18:30', '22:00'],
    ];
    var baseTimeRange =
        baseTime.map((e) => convertToDateTime(DateTime.now(), e)).toList();

    var worksTime = convertToDateTime(DateTime.now(), times);
    log('chartTimelinePainter.time $worksTime');

    var timeRelax = [];
    var timeWorkHard = [];
    var timeWorks = [
      getTimeOfRange(baseTimeRange[0], worksTime),
      getTimeOfRange(baseTimeRange[1], worksTime),
      // getTimeOfRange(baseTimeRange[2], worksTime),
      // getTimeOfRange(baseTimeRange[3], worksTime)
    ];

    if (timeWorks.isEmpty) {
      createCanvasLabel(canvas, 'Không có dữ liệu.',
          Offset(size.width / 2 - 50, size.height / 2 - 36));
    } else {
      for (var i in timeWorks) {
        log('> timeWorks $i');
        if (i.isNotEmpty) {
          var rect = convertTimeRangeToRect(i, rectWidth: size.width * 0.9);

          paint.color = workTimeColor!;
          canvas.drawRect(rect, paint);
        }
      }
    }

    // pathCache.addRect(rect);

    // createCanvasLabel(canvas, '${str[0]}-${str[1]}',
    //     Offset(rect.width / 2 - 20, rect.top - 24));

    // if (onTap != null && onTap!(false)) {
    //   createCanvasLabel(canvas, '$str[0]-$str[1]',
    //       Offset(rect.width / 2 - 20, rect.top - 24));
    // }

    for (var i = 20; i < height; i += step) {
      var offset1 = Offset(0, i.toDouble());
      var offet2 = Offset(size.width, i.toDouble());

      paint.color = Colors.grey;
      paint.strokeWidth = 0.4;
      canvas.drawLine(offset1, offet2, paint);

      offets.add(offset1);
    }

    paint.color = const ui.Color.fromARGB(206, 255, 82, 82);
    paint.strokeWidth = 5;
    canvas.drawPoints(PointMode.points, offets, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  bool hitTest(Offset position) {
    bool hit = pathCache.contains(position);
    if (onTap != null) onTap!(hit);

    log('hitTest $hit');
    return hit;
  }

  List<DateTime> convertToDateTime(DateTime date, List<String> times) {
    var dateTimeStr = date.toIso8601String();

    String dateStr = dateTimeStr.split('T')[0];

    var listTime = times.map((e) {
      var x = '$dateStr $e';
      // var dateFormat = DateFormat('yyyy-MM-dd hh:mm:ss');
      var date = DateTime.parse(x);
      return date;
    }).toList();
    return listTime;
  }

  List<DateTime> getTimeOfRange(
      List<DateTime> baseRange, List<DateTime> times) {
    List<DateTime> x = [];
    for (var t in times) {
      var isMatch = t.isAfter(baseRange[0]) && t.isBefore(baseRange[1]);
      if (isMatch) {
        x.add(t);
      }
    }

    List<DateTime> closerRange =
        x.isNotEmpty ? (x.length >= 2 ? [x.first, x.last] : [x.first]) : [];
    return closerRange;
  }

  Rect convertTimeRangeToRect(List<DateTime> times, {double? rectWidth = 200}) {
    var now = DateTime.now();
    var timeStart = DateTime(2023, now.month, now.day, 6, 00);
    var topStart = 20;

    var step = 42;
    var hours = 2;
    var hoursPerPixel = hours / step;
    var msPerPixel = hoursPerPixel * 3600000;
// 2h = 42 pixel

//  2/42   = 1 pixel
// msPerPixel = 1 pixel
// diff = ?

// 2h = 42pixel
//   6h = 20
//   8h = 62
// 7h50 = ?

// 2h = ms = 42p;
// diff = 1h30 = ms = ?p

    var timeDiff = timeStart.difference(times[0]);
    var startDiffMS = timeDiff.inMilliseconds;
    timeDiff = timeStart.difference(times[1]);
    var endDiffMS = timeDiff.inMilliseconds;

    var startOffset = startDiffMS / msPerPixel;
    var endOffset = endDiffMS / msPerPixel;

    return Rect.fromLTRB(20, topStart + -startOffset, rectWidth!, -endOffset);
  }

  void createCanvasLabel(Canvas canvas, String label, Offset offset) {
    TextSpan span =
        TextSpan(text: label, style: const TextStyle(color: Colors.black54));

    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: ui.TextDirection.ltr);

    tp.layout();
    tp.paint(canvas, offset);
  }
}
