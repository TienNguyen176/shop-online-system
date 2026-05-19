class StatisticItem {
  final String title;
  final int percent;

  StatisticItem({required this.title, required this.percent});

  factory StatisticItem.fromJson(Map<String, dynamic> json) {
    return StatisticItem(
      title: json["title"] ?? "",
      percent: (json["percent"] as num?)?.toInt() ?? 0,
    );
  }
}
