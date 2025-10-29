class SocialMedia {
  final String? instagram;
  final String? facebook;
  final String? tiktok;
  final String? snapchat;
  final String? twitter;
  final String? youtube;
  
  SocialMedia({this.instagram, this.facebook, this.tiktok, this.snapchat, this.twitter, this.youtube});

  Map<String, dynamic> toJson() => {'instagram': instagram, 'facebook': facebook, 'tiktok': tiktok, 'snapchat': snapchat, 'twitter': twitter, 'youtube': youtube};

  factory SocialMedia.fromJson(Map<String, dynamic> json) => SocialMedia(
    instagram: json['instagram'], facebook: json['facebook'], tiktok: json['tiktok'],
    snapchat: json['snapchat'], twitter: json['twitter'], youtube: json['youtube'],
  );
}
