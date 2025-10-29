import '../models/analytics_data.dart';

class AnalyticsService {
  Future<AnalyticsData?> getAnalytics(String restaurantId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return AnalyticsData(
      monthlyViews: 1247,
      recommendationCount: 23,
      totalClicks: 87,
    );
  }

  Future<void> trackAction({
    required String restaurantId,
    required String actionType,
  }) async {
    print('Mode démo: Action trackée - $actionType');
  }

  Future<List<Map<String, dynamic>>> getEvents({
    required String restaurantId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));
    return [];
  }
}
