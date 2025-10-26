import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nft_asset.dart';

class NFTService {
  // Menggunakan CoinGecko API untuk NFT data (gratis)
  static const String baseUrl = 'https://api.coingecko.com/api/v3';

  // Fetch NFT collections
  Future<List<NFTAsset>> fetchNFTAssets({int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/nfts/list?per_page=$limit',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isEmpty) {
          return _getDummyNFTs(limit);
        }

        // Get detailed info for each NFT
        return await _fetchDetailedNFTs(data.take(limit).toList());
      } else {
        print('NFT API Error: ${response.statusCode}');
        return _getDummyNFTs(limit);
      }
    } catch (e) {
      print('Error fetching NFTs: $e');
      return _getDummyNFTs(limit);
    }
  }

  // Fetch detailed NFT data
  Future<List<NFTAsset>> _fetchDetailedNFTs(List<dynamic> nftList) async {
    List<NFTAsset> detailedNFTs = [];

    for (var nft in nftList) {
      try {
        final id = nft['id'];
        final response = await http.get(
          Uri.parse('$baseUrl/nfts/$id'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          detailedNFTs.add(NFTAsset.fromJson(data));
        }
      } catch (e) {
        print('Error fetching NFT detail: $e');
        continue;
      }

      // Batasi request untuk menghindari rate limit
      if (detailedNFTs.length >= 10) break;
      await Future.delayed(const Duration(milliseconds: 300));
    }

    return detailedNFTs.isNotEmpty ? detailedNFTs : _getDummyNFTs(10);
  }

  // Fetch single NFT
  Future<NFTAsset> fetchSingleNFT(String nftId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/nfts/$nftId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return NFTAsset.fromJson(data);
      } else {
        throw Exception('Failed to load NFT');
      }
    } catch (e) {
      throw Exception('Error fetching NFT: $e');
    }
  }

  // Dummy NFT data sebagai fallback
  List<NFTAsset> _getDummyNFTs(int limit) {
    final dummyData = [
      {
        'id': 'bored-ape-yacht-club',
        'name': 'Bored Ape #1234',
        'collection': 'Bored Ape Yacht Club',
        'floor_price_in_usd': 45280.50,
        'floor_price_24h_percentage_change': 5.23,
        'volume_24h': 1250000,
        'image': {'small': 'https://via.placeholder.com/150/FF6B6B/FFFFFF?text=BAYC'},
      },
      {
        'id': 'cryptopunks',
        'name': 'CryptoPunk #5678',
        'collection': 'CryptoPunks',
        'floor_price_in_usd': 98750.00,
        'floor_price_24h_percentage_change': -2.15,
        'volume_24h': 3400000,
        'image': {'small': 'https://via.placeholder.com/150/4ECDC4/FFFFFF?text=PUNK'},
      },
      {
        'id': 'mutant-ape-yacht-club',
        'name': 'Mutant Ape #9012',
        'collection': 'Mutant Ape Yacht Club',
        'floor_price_in_usd': 12450.75,
        'floor_price_24h_percentage_change': 3.87,
        'volume_24h': 680000,
        'image': {'small': 'https://via.placeholder.com/150/95E1D3/FFFFFF?text=MAYC'},
      },
      {
        'id': 'azuki',
        'name': 'Azuki #3456',
        'collection': 'Azuki',
        'floor_price_in_usd': 18920.30,
        'floor_price_24h_percentage_change': 7.12,
        'volume_24h': 920000,
        'image': {'small': 'https://via.placeholder.com/150/F38181/FFFFFF?text=AZUKI'},
      },
      {
        'id': 'doodles-official',
        'name': 'Doodle #7890',
        'collection': 'Doodles',
        'floor_price_in_usd': 8340.20,
        'floor_price_24h_percentage_change': -1.45,
        'volume_24h': 430000,
        'image': {'small': 'https://via.placeholder.com/150/AA96DA/FFFFFF?text=DOODLE'},
      },
      {
        'id': 'clone-x',
        'name': 'CloneX #2345',
        'collection': 'CloneX',
        'floor_price_in_usd': 6780.90,
        'floor_price_24h_percentage_change': 4.56,
        'volume_24h': 540000,
        'image': {'small': 'https://via.placeholder.com/150/FCBAD3/FFFFFF?text=CLONEX'},
      },
      {
        'id': 'meebits',
        'name': 'Meebit #6789',
        'collection': 'Meebits',
        'floor_price_in_usd': 3420.50,
        'floor_price_24h_percentage_change': -3.21,
        'volume_24h': 280000,
        'image': {'small': 'https://via.placeholder.com/150/FFD93D/FFFFFF?text=MEEBIT'},
      },
      {
        'id': 'pudgy-penguins',
        'name': 'Pudgy Penguin #4567',
        'collection': 'Pudgy Penguins',
        'floor_price_in_usd': 7890.40,
        'floor_price_24h_percentage_change': 2.89,
        'volume_24h': 390000,
        'image': {'small': 'https://via.placeholder.com/150/6BCB77/FFFFFF?text=PUDGY'},
      },
      {
        'id': 'moonbirds',
        'name': 'Moonbird #8901',
        'collection': 'Moonbirds',
        'floor_price_in_usd': 5670.80,
        'floor_price_24h_percentage_change': 1.23,
        'volume_24h': 320000,
        'image': {'small': 'https://via.placeholder.com/150/4D96FF/FFFFFF?text=MOONBIRD'},
      },
      {
        'id': 'otherdeed',
        'name': 'Otherdeed #1111',
        'collection': 'Otherdeed for Otherside',
        'floor_price_in_usd': 1250.30,
        'floor_price_24h_percentage_change': -0.87,
        'volume_24h': 180000,
        'image': {'small': 'https://via.placeholder.com/150/C780FA/FFFFFF?text=OTHERDEED'},
      },
      {
        'id': 'cool-cats',
        'name': 'Cool Cat #2222',
        'collection': 'Cool Cats',
        'floor_price_in_usd': 4320.60,
        'floor_price_24h_percentage_change': 3.45,
        'volume_24h': 210000,
        'image': {'small': 'https://via.placeholder.com/150/FF6B9D/FFFFFF?text=COOLCAT'},
      },
      {
        'id': 'world-of-women',
        'name': 'WoW #3333',
        'collection': 'World of Women',
        'floor_price_in_usd': 2890.20,
        'floor_price_24h_percentage_change': -2.34,
        'volume_24h': 150000,
        'image': {'small': 'https://via.placeholder.com/150/FFB6C1/FFFFFF?text=WOW'},
      },
      {
        'id': 'vee-friends',
        'name': 'VeeFriend #4444',
        'collection': 'VeeFriends',
        'floor_price_in_usd': 3210.50,
        'floor_price_24h_percentage_change': 1.78,
        'volume_24h': 190000,
        'image': {'small': 'https://via.placeholder.com/150/98D8C8/FFFFFF?text=VEEFRIEND'},
      },
      {
        'id': 'the-sandbox',
        'name': 'Sandbox Land #5555',
        'collection': 'The Sandbox',
        'floor_price_in_usd': 980.90,
        'floor_price_24h_percentage_change': 0.56,
        'volume_24h': 120000,
        'image': {'small': 'https://via.placeholder.com/150/FFE66D/FFFFFF?text=SANDBOX'},
      },
      {
        'id': 'decentraland',
        'name': 'Decentraland LAND #6666',
        'collection': 'Decentraland',
        'floor_price_in_usd': 1450.30,
        'floor_price_24h_percentage_change': -1.23,
        'volume_24h': 160000,
        'image': {'small': 'https://via.placeholder.com/150/A8E6CF/FFFFFF?text=MANA'},
      },
    ];

    return dummyData
        .take(limit)
        .map((json) => NFTAsset.fromJson(json))
        .toList();
  }
}