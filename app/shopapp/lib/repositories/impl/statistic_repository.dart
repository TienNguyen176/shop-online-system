import '../../models/statistic_item.dart';
import '../../services/statistic_service.dart';
import '../interfaces/i_statistic_repository.dart';

class StatisticRepository implements IStatisticRepository {
  final StatisticService service = StatisticService();

  List<StatisticItem>? _statisticCache;

  @override
  Future<List<StatisticItem>> getStatistic() async {
    if (_statisticCache != null) {
      return _statisticCache!;
    }

    final data = await service.getStatistic();
    _statisticCache = data;

    return data;
  }

  void clearCache() {
    _statisticCache = null;
  }
}
