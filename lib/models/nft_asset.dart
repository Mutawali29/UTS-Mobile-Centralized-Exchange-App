class NFTAsset {
  final String id;
  final String name;
  final String collection;
  final double floorPrice;
  final double changePercent;
  final double volume24h;
  final String imageUrl;
  final double amount; // Jumlah yang dimiliki user

  NFTAsset({
    required this.id,
    required this.name,
    required this.collection,
    required this.floorPrice,
    required this.changePercent,
    required this.volume24h,
    required this.imageUrl,
    this.amount = 0,
  });

  factory NFTAsset.fromJson(Map<String, dynamic> json) {
    return NFTAsset(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['nft_id'] ?? '',
      collection: json['collection'] ?? json['name'] ?? '',
      floorPrice: _parsePrice(json['floor_price_in_usd'] ?? json['floor_price'] ?? 0),
      changePercent: _parseDouble(json['floor_price_24h_percentage_change'] ?? json['change_24h'] ?? 0),
      volume24h: _parsePrice(json['volume_24h'] ?? json['h24_volume'] ?? 0),
      imageUrl: json['image']?['small'] ?? json['image'] ?? json['thumb_url'] ?? '',
      amount: 0,
    );
  }

  static double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  NFTAsset copyWithAmount(double newAmount) {
    return NFTAsset(
      id: id,
      name: name,
      collection: collection,
      floorPrice: floorPrice,
      changePercent: changePercent,
      volume24h: volume24h,
      imageUrl: imageUrl,
      amount: newAmount,
    );
  }

  double get valueUSD => floorPrice * amount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'collection': collection,
      'floorPrice': floorPrice,
      'changePercent': changePercent,
      'volume24h': volume24h,
      'imageUrl': imageUrl,
      'amount': amount,
    };
  }
}