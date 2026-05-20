import '../core/api/api_client.dart';
import '../models/statistic_item.dart';

class StatisticService {
  /// Lay du lieu cho getStatistic.
  Future<List<StatisticItem>> getStatistic() async {
    final res = await ApiClient.dio.get("/api/Statistic");

    final data = res.data;
    final List raw = data is List ? data : data["data"] ?? [];

    return raw.map((e) => StatisticItem.fromJson(e)).toList();
  }
}
