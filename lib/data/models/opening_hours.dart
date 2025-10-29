class OpeningHours {
  final bool isOpen;
  final String? openTime;
  final String? closeTime;
  
  OpeningHours({required this.isOpen, this.openTime, this.closeTime});

  Map<String, dynamic> toJson() => {'isOpen': isOpen, 'openTime': openTime, 'closeTime': closeTime};

  factory OpeningHours.fromJson(Map<String, dynamic> json) => OpeningHours(
    isOpen: json['isOpen'] ?? false, openTime: json['openTime'], closeTime: json['closeTime'],
  );
}
