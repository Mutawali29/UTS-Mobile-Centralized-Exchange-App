class NewsArticle {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String source;
  final DateTime publishedAt;
  final String url;
  final String category;

  NewsArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.source,
    required this.publishedAt,
    required this.url,
    required this.category,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      source: json['source'] ?? '',
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'])
          : DateTime.now(),
      url: json['url'] ?? '',
      category: json['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'source': source,
      'publishedAt': publishedAt.toIso8601String(),
      'url': url,
      'category': category,
    };
  }
}

class TrendingCrypto {
  final String symbol;
  final String name;
  final String icon;
  final double priceUSD;
  final double changePercent;
  final double volume24h;
  final double marketCap;
  final int rank;
  final String? imageUrl;

  TrendingCrypto({
    required this.symbol,
    required this.name,
    required this.icon,
    required this.priceUSD,
    required this.changePercent,
    required this.volume24h,
    required this.marketCap,
    required this.rank,
    this.imageUrl,
  });

  bool get isPositive => changePercent >= 0;

  // Factory method untuk membuat dari JSON API CoinGecko
  factory TrendingCrypto.fromJson(Map<String, dynamic> json) {
    final symbol = (json['symbol'] as String).toUpperCase();

    return TrendingCrypto(
      symbol: symbol,
      name: json['name'] as String,
      icon: _getIconForSymbol(symbol),
      priceUSD: (json['current_price'] as num).toDouble(),
      changePercent: (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
      volume24h: (json['total_volume'] as num?)?.toDouble() ?? 0.0,
      marketCap: (json['market_cap'] as num?)?.toDouble() ?? 0.0,
      rank: json['market_cap_rank'] as int? ?? 0,
      imageUrl: json['image'] as String?,
    );
  }

  // Static helper method untuk mendapatkan icon berdasarkan symbol
  static String _getIconForSymbol(String symbol) {
    switch (symbol) {
      case 'BTC':
        return '₿';
      case 'ETH':
        return 'Ξ';
      case 'SOL':
        return '◎';
      case 'XRP':
        return '✕';
      case 'ADA':
        return '₳';
      case 'BNB':
        return 'B';
      case 'DOGE':
        return 'Ð';
      case 'DOT':
        return '●';
      case 'MATIC':
        return 'M';
      case 'LTC':
        return 'Ł';
      default:
        return symbol.isNotEmpty ? symbol.substring(0, 1) : '?';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'icon': icon,
      'priceUSD': priceUSD,
      'changePercent': changePercent,
      'volume24h': volume24h,
      'marketCap': marketCap,
      'rank': rank,
      'imageUrl': imageUrl,
    };
  }
}