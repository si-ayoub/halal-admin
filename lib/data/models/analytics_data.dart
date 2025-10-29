class AnalyticsData {
  final int totalViews;
  final int monthlyViews;
  final int weeklyViews;
  final int totalClicks;
  final int phoneClicks;
  final int whatsappClicks;
  final int directionsClicks;
  final int shareCount;
  final int recommendationCount;
  
  AnalyticsData({
    this.totalViews = 0, this.monthlyViews = 0, this.weeklyViews = 0,
    this.totalClicks = 0, this.phoneClicks = 0, this.whatsappClicks = 0,
    this.directionsClicks = 0, this.shareCount = 0, this.recommendationCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'totalViews': totalViews, 'monthlyViews': monthlyViews, 'weeklyViews': weeklyViews,
    'totalClicks': totalClicks, 'phoneClicks': phoneClicks, 'whatsappClicks': whatsappClicks,
    'directionsClicks': directionsClicks, 'shareCount': shareCount, 'recommendationCount': recommendationCount,
  };

  factory AnalyticsData.fromJson(Map<String, dynamic> json) => AnalyticsData(
    totalViews: json['totalViews'] ?? 0, monthlyViews: json['monthlyViews'] ?? 0,
    weeklyViews: json['weeklyViews'] ?? 0, totalClicks: json['totalClicks'] ?? 0,
    phoneClicks: json['phoneClicks'] ?? 0, whatsappClicks: json['whatsappClicks'] ?? 0,
    directionsClicks: json['directionsClicks'] ?? 0, shareCount: json['shareCount'] ?? 0,
    recommendationCount: json['recommendationCount'] ?? 0,
  );
}
