import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crypto_asset.dart';
import '../models/news_article.dart';

class CryptoService {
  static const String baseUrl = 'https://api.coingecko.com/api/v3';

  // Fetch list of cryptocurrencies with market data
  Future<List<CryptoAsset>> fetchCryptoAssets({int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=$limit&page=1&sparkline=false&price_change_percentage=24h',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CryptoAsset.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load crypto assets');
      }
    } catch (e) {
      throw Exception('Error fetching crypto data: $e');
    }
  }

  // Fetch specific crypto data
  Future<CryptoAsset> fetchSingleCrypto(String coinId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/coins/markets?vs_currency=usd&ids=$coinId&price_change_percentage=24h',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return CryptoAsset.fromJson(data[0]);
        }
        throw Exception('Crypto not found');
      } else {
        throw Exception('Failed to load crypto');
      }
    } catch (e) {
      throw Exception('Error fetching crypto: $e');
    }
  }

  // Get trending cryptocurrencies
  Future<List<String>> fetchTrendingCoins() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search/trending'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> coins = data['coins'];
        return coins.map((coin) => coin['item']['id'] as String).toList();
      } else {
        throw Exception('Failed to load trending coins');
      }
    } catch (e) {
      throw Exception('Error fetching trending: $e');
    }
  }

  // ** METHOD BARU ** Fetch trending cryptocurrencies dengan detail lengkap
  Future<List<TrendingCrypto>> fetchTrendingCryptos({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=$limit&page=1&sparkline=false&price_change_percentage=24h',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => TrendingCrypto.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load trending cryptos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching trending crypto data: $e');
    }
  }

  // ** METHOD BARU ** Fetch trending berdasarkan volume tertinggi
  Future<List<TrendingCrypto>> fetchTrendingByVolume({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/coins/markets?vs_currency=usd&order=volume_desc&per_page=$limit&page=1&sparkline=false&price_change_percentage=24h',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => TrendingCrypto.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load trending by volume: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching trending by volume: $e');
    }
  }

  // ** METHOD BARU ** Fetch top gainers (crypto dengan perubahan harga tertinggi)
  Future<List<TrendingCrypto>> fetchTopGainers({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false&price_change_percentage=24h',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Filter yang positif dan urutkan berdasarkan perubahan persen tertinggi
        final gainers = data
            .where((item) => (item['price_change_percentage_24h'] as num?) != null &&
            (item['price_change_percentage_24h'] as num) > 0)
            .toList();

        gainers.sort((a, b) =>
            (b['price_change_percentage_24h'] as num).compareTo(
                a['price_change_percentage_24h'] as num
            )
        );

        return gainers
            .take(limit)
            .map((json) => TrendingCrypto.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load top gainers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching top gainers: $e');
    }
  }

  // ** METHOD BARU ** Fetch trending dari API trending CoinGecko
  Future<List<TrendingCrypto>> fetchTrendingFromAPI({int limit = 7}) async {
    try {
      // Step 1: Get trending coin IDs
      final trendingResponse = await http.get(
        Uri.parse('$baseUrl/search/trending'),
      );

      if (trendingResponse.statusCode != 200) {
        throw Exception('Failed to load trending coins');
      }

      final trendingData = json.decode(trendingResponse.body);
      final List<dynamic> coins = trendingData['coins'];

      // Ambil ID coins
      final coinIds = coins
          .take(limit)
          .map((coin) => coin['item']['id'] as String)
          .join(',');

      // Step 2: Get detail dari coins tersebut
      final detailResponse = await http.get(
        Uri.parse(
          '$baseUrl/coins/markets?vs_currency=usd&ids=$coinIds&price_change_percentage=24h',
        ),
      );

      if (detailResponse.statusCode == 200) {
        final List<dynamic> data = json.decode(detailResponse.body);
        return data.map((json) => TrendingCrypto.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load trending details: ${detailResponse.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching trending from API: $e');
    }
  }
}