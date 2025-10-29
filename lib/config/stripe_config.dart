class StripeConfig {
  static const String publishableKey = 'pk_test_51S9ujB45kWmbgHe7qfJMh9s4Q6QwqcDd2btpIh8ycx3b5pOF2NlOQuJuZf8VbpwYd9MoxSE73G9NXM7W9o4uz4PS00RtsQZhAY';
  
  static const Map<String, String> priceIds = {
    'premium_monthly': 'price_1SH7Sn45kWmbgHe72v54WJM3',
    'premium_plus_monthly': 'price_1SH7So45kWmbgHe7bJ5qlCML',
    'premium_yearly_20': 'price_1SH7So45kWmbgHe7SBhFq8lN',
    'premium_yearly_30': 'price_1SH7Sp45kWmbgHe7akr5xaJA',
    'premium_yearly_40': 'price_1SH7Sp45kWmbgHe7iXX36XJQ',
    'premium_yearly_50': 'price_1SH7Sq45kWmbgHe73EqAL8Dq',
    'premium_plus_yearly_20': 'price_1SH7Sr45kWmbgHe7IPdMcDAH',
    'premium_plus_yearly_30': 'price_1SH7Sr45kWmbgHe7HzGwbtJE',
    'premium_plus_yearly_40': 'price_1SH7Ss45kWmbgHe7nXpVEdVE',
    'premium_plus_yearly_50': 'price_1SH7Ss45kWmbgHe72dl3jU6n',
  };
  
  static String getPriceId(String planKey) {
    return priceIds[planKey] ?? '';
  }
  
  static String getPlanName(String planKey) {
    const names = {
      'premium_monthly': 'Premium Mensuel - 60€/mois',
      'premium_plus_monthly': 'Premium+ Mensuel - 80€/mois',
      'premium_yearly_20': 'Premium Annuel -20% - 576€/an',
      'premium_yearly_30': 'Premium Annuel -30% - 504€/an',
      'premium_yearly_40': 'Premium Annuel -40% - 432€/an',
      'premium_yearly_50': 'Premium Annuel -50% - 360€/an',
      'premium_plus_yearly_20': 'Premium+ Annuel -20% - 768€/an',
      'premium_plus_yearly_30': 'Premium+ Annuel -30% - 672€/an',
      'premium_plus_yearly_40': 'Premium+ Annuel -40% - 576€/an',
      'premium_plus_yearly_50': 'Premium+ Annuel -50% - 480€/an',
    };
    return names[planKey] ?? '';
  }
}