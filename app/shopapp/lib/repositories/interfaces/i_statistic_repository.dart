import '../../models/statistic_item.dart';

abstract class IStatisticRepository {
  /// Lay du lieu cho getStatistic.
  Future<List<StatisticItem>> getStatistic();
}
