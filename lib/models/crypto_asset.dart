class CryptoAsset {
  final String id;
  final String name;
  final String symbol;
  final String icon;
  final double amount;
  final double valueUSD;
  final double priceUSD;
  final double changePercent;
  final String? imageUrl;

  CryptoAsset({
    required this.id,
    required this.name,
    required this.symbol,
    required this.icon,
    this.amount = 0,
    required this.valueUSD,
    required this.priceUSD,
    required this.changePercent,
    this.imageUrl,
  });

  // Factory constructor to create from API JSON
  factory CryptoAsset.fromJson(Map<String, dynamic> json) {
    final double price = (json['current_price'] ?? 0).toDouble();
    final double change = (json['price_change_percentage_24h'] ?? 0).toDouble();

    return CryptoAsset(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      symbol: (json['symbol'] ?? '').toString().toUpperCase(),
      icon: _getIconFromSymbol(json['symbol'] ?? ''),
      amount: 0, // Default amount, bisa diubah untuk portfolio
      valueUSD: 0, // Will be calculated: amount * price
      priceUSD: price,
      changePercent: change,
      imageUrl: json['image'],
    );
  }

  // Create a copy with different amount (for portfolio)
  CryptoAsset copyWithAmount(double newAmount) {
    return CryptoAsset(
      id: id,
      name: name,
      symbol: symbol,
      icon: icon,
      amount: newAmount,
      valueUSD: newAmount * priceUSD,
      priceUSD: priceUSD,
      changePercent: changePercent,
      imageUrl: imageUrl,
    );
  }

  // Helper method to get icon from symbol
  static String _getIconFromSymbol(String symbol) {
    switch (symbol.toLowerCase()) {
      case 'btc':
        return '₿';
      case 'eth':
        return '⟠';
      case 'xrp':
        return '✕';
      case 'bnb':
        return 'B';
      case 'ada':
        return '₳';
      case 'doge':
        return 'Ð';
      case 'dot':
        return '●';
      case 'sol':
        return '◎';
      case 'matic':
        return 'M';
      case 'ltc':
        return 'Ł';
      default:
        return symbol.toUpperCase().substring(0, 1);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'icon': icon,
      'amount': amount,
      'valueUSD': valueUSD,
      'priceUSD': priceUSD,
      'changePercent': changePercent,
      'imageUrl': imageUrl,
    };
  }
}