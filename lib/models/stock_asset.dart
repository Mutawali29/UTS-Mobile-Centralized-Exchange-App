class StockAsset {
  final String symbol;
  final String name;
  final double price;
  final double changePercent;
  final double changeAmount;
  final double marketCap;
  final double volume;
  final double amount; // Jumlah yang dimiliki user

  StockAsset({
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePercent,
    required this.changeAmount,
    required this.marketCap,
    required this.volume,
    this.amount = 0,
  });

  factory StockAsset.fromJson(Map<String, dynamic> json) {
    return StockAsset(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? json['symbol'] ?? '',
      price: (json['price'] ?? json['regularMarketPrice'] ?? 0).toDouble(),
      changePercent: (json['changesPercentage'] ?? json['regularMarketChangePercent'] ?? 0).toDouble(),
      changeAmount: (json['change'] ?? json['regularMarketChange'] ?? 0).toDouble(),
      marketCap: (json['marketCap'] ?? 0).toDouble(),
      volume: (json['volume'] ?? json['regularMarketVolume'] ?? 0).toDouble(),
      amount: 0,
    );
  }

  StockAsset copyWithAmount(double newAmount) {
    return StockAsset(
      symbol: symbol,
      name: name,
      price: price,
      changePercent: changePercent,
      changeAmount: changeAmount,
      marketCap: marketCap,
      volume: volume,
      amount: newAmount,
    );
  }

  double get valueUSD => price * amount;

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'price': price,
      'changePercent': changePercent,
      'changeAmount': changeAmount,
      'marketCap': marketCap,
      'volume': volume,
      'amount': amount,
    };
  }
}