// ignore_for_file: file_names

class NotificationModel {
  String title;
  String content;
  String subTitle;
  String fromId;
  String toId;

  bool isSelected;

  int id;
  int type;
  int level;
  bool isSeen;
  int createdDate;

  NotificationModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? -1,
        title = json['title'] ?? '',
        subTitle = json['subTitle'] ?? '',
        content = json['content'] ?? '',
        type = json['type'] ?? 0,
        level = json['level'] ?? 0,
        isSeen = json['isSeen'] ?? false,
        toId = json['toId'] ?? '',
        fromId = json['fromId'] ?? '',
        isSelected = json['isSelected'] ?? false,
        createdDate = json['created_at'] ?? 0;

  // String getCreatedDate() get => DateTime(createdDate).
}
