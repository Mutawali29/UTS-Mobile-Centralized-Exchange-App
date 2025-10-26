class ExchangeRate {
  final String fromCrypto;
  final String toCrypto;
  final double rate;
  final DateTime timestamp;

  ExchangeRate({
    required this.fromCrypto,
    required this.toCrypto,
    required this.rate,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromCrypto': fromCrypto,
      'toCrypto': toCrypto,
      'rate': rate,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      fromCrypto: json['fromCrypto'],
      toCrypto: json['toCrypto'],
      rate: (json['rate'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class ExchangePair {
  final String symbol;
  final String name;
  final String icon;
  final double balance;
  final double priceUSD;
  final String? imageUrl;

  ExchangePair({
    required this.symbol,
    required this.name,
    required this.icon,
    required this.balance,
    required this.priceUSD,
    this.imageUrl,
  });
}