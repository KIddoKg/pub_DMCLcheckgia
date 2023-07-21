class UserInfoTarget {
  int week1;
  int week2;
  int week3;
  int week4;
  int target;
  int total;
  int rate;
  int totalPoint;

  UserInfoTarget.fromJson(Map<String, dynamic> json)
      : week1 = json['TargetTuan1'] ?? 0,
        week2 = json['TargetTuan2'] ?? 0,
        week3 = json['TargetTuan3'] ?? 0,
        week4 = json['TargetTuan4'] ?? 0,
        target = json['TargetAmount'] ?? 0,
        total = json['TotalAmount'] ?? 0,
        totalPoint = json['TongDiemThuong'] ?? 0,
        rate = json['TiLe'] ?? 0;
}
