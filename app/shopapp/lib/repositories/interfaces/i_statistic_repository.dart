import '../../models/statistic_item.dart';

abstract class IStatisticRepository {
  Future<List<StatisticItem>> getStatistic();
}
