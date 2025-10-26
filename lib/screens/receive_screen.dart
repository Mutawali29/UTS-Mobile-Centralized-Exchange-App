import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_colors.dart';
import '../services/wallet_service.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final WalletService _walletService = WalletService();
  String? _walletAddress;
  bool _isLoading = true;
  bool _isLoadingCrypto = true;
  String _selectedCrypto = 'bitcoin';
  List<Map<String, dynamic>> _cryptoOptions = [];

  @override
  void initState() {
    super.initState();
    _loadWalletAddress();
    _loadCryptoData();
  }

  Future<void> _loadWalletAddress() async {
    setState(() {
      _isLoading = true;
    });

    final address = await _walletService.getWalletAddress();

    setState(() {
      _walletAddress = address;
      _isLoading = false;
    });
  }

  Future<void> _loadCryptoData() async {
    setState(() {
      _isLoadingCrypto = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=20&page=1&sparkline=false'
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _cryptoOptions = data.map((crypto) => {
            'id': crypto['id'] as String,
            'symbol': (crypto['symbol'] as String).toUpperCase(),
            'name': crypto['name'] as String,
            'image': crypto['image'] as String,
            'current_price': crypto['current_price'],
            'price_change_percentage_24h': crypto['price_change_percentage_24h'],
          }).toList();

          if (_cryptoOptions.isNotEmpty) {
            _selectedCrypto = _cryptoOptions[0]['id'];
          }
          _isLoadingCrypto = false;
        });
      } else {
        _setFallbackData();
      }
    } catch (e) {
      _setFallbackData();
    }
  }

  void _setFallbackData() {
    setState(() {
      _cryptoOptions = [
        {
          'id': 'bitcoin',
          'symbol': 'BTC',
          'name': 'Bitcoin',
          'image': 'https://assets.coingecko.com/coins/images/1/large/bitcoin.png',
          'current_price': 0.0,
          'price_change_percentage_24h': 0.0,
        },
        {
          'id': 'ethereum',
          'symbol': 'ETH',
          'name': 'Ethereum',
          'image': 'https://assets.coingecko.com/coins/images/279/large/ethereum.png',
          'current_price': 0.0,
          'price_change_percentage_24h': 0.0,
        },
        {
          'id': 'tether',
          'symbol': 'USDT',
          'name': 'Tether',
          'image': 'https://assets.coingecko.com/coins/images/325/large/Tether.png',
          'current_price': 0.0,
          'price_change_percentage_24h': 0.0,
        },
        {
          'id': 'binancecoin',
          'symbol': 'BNB',
          'name': 'BNB',
          'image': 'https://assets.coingecko.com/coins/images/825/large/bnb-icon2_2x.png',
          'current_price': 0.0,
          'price_change_percentage_24h': 0.0,
        },
      ];
      _selectedCrypto = 'bitcoin';
      _isLoadingCrypto = false;
    });
  }

  Map<String, dynamic> get _selectedCryptoData {
    return _cryptoOptions.firstWhere(
          (crypto) => crypto['id'] == _selectedCrypto,
      orElse: () => _cryptoOptions.isNotEmpty ? _cryptoOptions[0] : {},
    );
  }

  String get _networkInfo {
    final id = _selectedCrypto.toLowerCase();
    if (id.contains('bitcoin') || id == 'btc') {
      return 'Bitcoin Network';
    } else if (id.contains('ethereum') || id == 'eth') {
      return 'Ethereum (ERC-20)';
    } else if (id.contains('binance') || id.contains('bnb')) {
      return 'Binance Smart Chain';
    } else if (id.contains('tether') || id.contains('usdt')) {
      return 'Ethereum (ERC-20)';
    } else if (id.contains('solana') || id == 'sol') {
      return 'Solana Network';
    } else if (id.contains('cardano') || id == 'ada') {
      return 'Cardano Network';
    } else if (id.contains('ripple') || id == 'xrp') {
      return 'XRP Ledger';
    } else if (id.contains('polygon') || id.contains('matic')) {
      return 'Polygon Network';
    } else if (id.contains('avalanche') || id == 'avax') {
      return 'Avalanche C-Chain';
    } else if (id.contains('polkadot') || id == 'dot') {
      return 'Polkadot Network';
    } else {
      return 'Blockchain Network';
    }
  }

  void _copyToClipboard() {
    if (_walletAddress != null && _walletAddress!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _walletAddress!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Address copied to clipboard'),
            ],
          ),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareAddress() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Share functionality coming soon'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Receive Crypto',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.textPrimary),
            onPressed: _shareAddress,
          ),
        ],
      ),
      body: (_isLoading || _isLoadingCrypto)
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Select Crypto
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Cryptocurrency',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButton<String>(
                    value: _selectedCrypto,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: AppColors.cardBackground,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                    items: _cryptoOptions.map((crypto) {
                      return DropdownMenuItem<String>(
                        value: crypto['id'],
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.network(
                                crypto['image'],
                                width: 36,
                                height: 36,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        crypto['symbol'][0],
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    crypto['name'],
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    _networkInfo,
                                    style: TextStyle(
                                      color: AppColors.textSecondary.withOpacity(0.6),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (crypto['current_price'] != null && crypto['current_price'] > 0)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${crypto['current_price'].toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (crypto['price_change_percentage_24h'] != null)
                                    Text(
                                      '${crypto['price_change_percentage_24h'] > 0 ? '+' : ''}${crypto['price_change_percentage_24h'].toStringAsFixed(2)}%',
                                      style: TextStyle(
                                        color: crypto['price_change_percentage_24h'] > 0
                                            ? AppColors.green
                                            : AppColors.red,
                                        fontSize: 10,
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCrypto = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // QR Code
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (_walletAddress != null && _walletAddress!.isNotEmpty)
                    QrImageView(
                      data: _walletAddress!,
                      version: QrVersions.auto,
                      size: 240,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppColors.background,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: AppColors.background,
                      ),
                    )
                  else
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'No Address',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.qr_code,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Scan to receive ${_selectedCryptoData['symbol'] ?? ''}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Wallet Address
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Wallet Address',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _selectedCryptoData['symbol'] ?? '',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_walletAddress != null && _walletAddress!.isNotEmpty)
                    Text(
                      _walletAddress!,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    )
                  else
                    const Text(
                      'No wallet address',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copy Address'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Warning Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.red.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Important Notice',
                          style: TextStyle(
                            color: AppColors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Only send ${_selectedCryptoData['name'] ?? ''} ($_networkInfo) to this address. Sending other assets may result in permanent loss.',
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.8),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Info Cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.security,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Secure',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Protected by encryption',
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.6),
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: AppColors.green,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Fast',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Instant notifications',
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.6),
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}