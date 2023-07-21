// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class WorkDateModel {
  String date;
  String employeeId;
  List<String> timeScan;

  WorkDateModel({
    required this.date,
    required this.employeeId,
    required this.timeScan,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date,
      'employeeId': employeeId,
      'timeScan': timeScan,
    };
  }

  factory WorkDateModel.fromJson(Map<String, dynamic> json) {
    List<String> x = [];
    for (var i = 0; i < 10; i++) {
      var timeStr = json['Scan${i + 1}'] as String;
      if (timeStr.isNotEmpty) {
        x.add(timeStr);
      }
    }
    return WorkDateModel(
      date: json['DateScan'],
      employeeId: json['EmployeeId'],
      timeScan: x,
    );
  }

  String toJson() => json.encode(toMap());

}
