import 'package:flutter/material.dart';
import 'dart:async';
import '../models/crypto_asset.dart';
import '../models/stock_asset.dart';
import '../models/nft_asset.dart';
import '../services/crypto_service.dart';
import '../services/stock_service.dart';
import '../services/nft_service.dart';
import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../widgets/wallet_card.dart';
import '../widgets/crypto_list_item.dart';
import '../widgets/stock_list_item.dart';
import '../widgets/nft_list_item.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/app_colors.dart';
import 'activity_screen.dart';
import 'exchange_screen.dart';
import 'discover_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import '../utils/database_initializer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _selectedTab = 1; // 0=Cash, 1=Crypto, 2=Stocks, 3=NFT

  // Data untuk setiap tab
  List<CryptoAsset> _cryptoAssets = [];
  List<StockAsset> _stockAssets = [];
  List<NFTAsset> _nftAssets = [];

  bool _isLoading = true;
  String? _errorMessage;
  Timer? _refreshTimer;
  String? _walletAddress;
  Map<String, double> _portfolio = {};

  final CryptoService _cryptoService = CryptoService();
  final StockService _stockService = StockService();
  final NFTService _nftService = NFTService();
  final AuthService _authService = AuthService();
  final WalletService _walletService = WalletService();

  StreamSubscription<Map<String, double>>? _portfolioSubscription;

  @override
  void initState() {
    super.initState();
    _initializeData();
    // Auto refresh setiap 30 detik
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadCurrentTabData(showLoading: false);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _portfolioSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadWalletAddress();
    _subscribeToPortfolio();
    await _loadCurrentTabData();
  }

  Future<void> _loadWalletAddress() async {
    try {
      final address = await _walletService.getWalletAddress();
      setState(() {
        _walletAddress = address;
      });
    } catch (e) {
      print('Error loading wallet address: $e');
    }
  }

  void _subscribeToPortfolio() {
    _portfolioSubscription = _walletService.portfolioStream().listen(
          (portfolio) {
        setState(() {
          _portfolio = portfolio;
        });
        _loadCurrentTabData(showLoading: false);
      },
      onError: (error) {
        print('Error in portfolio stream: $error');
      },
    );
  }

  Future<void> _loadCurrentTabData({bool showLoading = true}) async {
    switch (_selectedTab) {
      case 0: // Cash
      // TODO: Implement cash/fiat data
        break;
      case 1: // Crypto
        await _loadCryptoData(showLoading: showLoading);
        break;
      case 2: // Stocks
        await _loadStockData(showLoading: showLoading);
        break;
      case 3: // NFT
        await _loadNFTData(showLoading: showLoading);
        break;
    }
  }

  Future<void> _loadCryptoData({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final assets = await _cryptoService.fetchCryptoAssets(limit: 50);

      final updatedAssets = assets.map((asset) {
        if (_portfolio.containsKey(asset.id)) {
          return asset.copyWithAmount(_portfolio[asset.id]!);
        }
        return asset;
      }).toList();

      setState(() {
        _cryptoAssets = updatedAssets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load crypto data: $e';
      });
    }
  }

  Future<void> _loadStockData({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final assets = await _stockService.fetchStockAssets(limit: 20);

      final updatedAssets = assets.map((asset) {
        if (_portfolio.containsKey(asset.symbol.toLowerCase())) {
          return asset.copyWithAmount(_portfolio[asset.symbol.toLowerCase()]!);
        }
        return asset;
      }).toList();

      setState(() {
        _stockAssets = updatedAssets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load stock data: $e';
      });
    }
  }

  Future<void> _loadNFTData({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final assets = await _nftService.fetchNFTAssets(limit: 15);

      final updatedAssets = assets.map((asset) {
        if (_portfolio.containsKey(asset.id)) {
          return asset.copyWithAmount(_portfolio[asset.id]!);
        }
        return asset;
      }).toList();

      setState(() {
        _nftAssets = updatedAssets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load NFT data: $e';
      });
    }
  }

  double get _totalBalance {
    switch (_selectedTab) {
      case 1: // Crypto
        return _cryptoAssets
            .where((asset) => asset.amount > 0)
            .fold(0, (sum, asset) => sum + asset.valueUSD);
      case 2: // Stocks
        return _stockAssets
            .where((asset) => asset.amount > 0)
            .fold(0, (sum, asset) => sum + asset.valueUSD);
      case 3: // NFT
        return _nftAssets
            .where((asset) => asset.amount > 0)
            .fold(0, (sum, asset) => sum + asset.valueUSD);
      default:
        return 0;
    }
  }

  double get _totalChangePercent {
    List<dynamic> portfolioAssets;

    switch (_selectedTab) {
      case 1: // Crypto
        portfolioAssets = _cryptoAssets.where((asset) => asset.amount > 0).toList();
        break;
      case 2: // Stocks
        portfolioAssets = _stockAssets.where((asset) => asset.amount > 0).toList();
        break;
      case 3: // NFT
        portfolioAssets = _nftAssets.where((asset) => asset.amount > 0).toList();
        break;
      default:
        return 0;
    }

    if (portfolioAssets.isEmpty) return 0;

    double totalValue = 0;
    double weightedChange = 0;

    for (var asset in portfolioAssets) {
      final valueUSD = asset.valueUSD;
      final changePercent = asset.changePercent;
      totalValue += valueUSD;
      weightedChange += valueUSD * changePercent;
    }

    return totalValue > 0 ? weightedChange / totalValue : 0;
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Logout Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${_authService.currentUser?.displayName ?? 'User'}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.logout,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: _handleLogout,
                    tooltip: 'Logout',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Database Initializer
            if (_portfolio.isEmpty && !_isLoading) ...[
              const DatabaseInitializerWidget(),
              const SizedBox(height: 12),
            ],

            // Wallet Card
            WalletCard(
              balance: _totalBalance,
              changePercent: _totalChangePercent,
              walletAddress: _walletAddress,
            ),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildTab('Cash', 0),
                  _buildTab('Crypto', 1),
                  _buildTab('Stocks', 2),
                  _buildTab('NFT', 3),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Total Section with Refresh Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      if (!_isLoading) ...[
                        Text(
                          '\$${_totalBalance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_totalChangePercent >= 0 ? '+' : ''}${_totalChangePercent.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: _totalChangePercent >= 0
                                ? AppColors.green
                                : AppColors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: _isLoading
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: _isLoading ? null : () => _loadCurrentTabData(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Asset List
            Expanded(
              child: _buildAssetList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ActivityScreen(),
              ),
            ).then((_) {
              setState(() {
                _currentIndex = 0;
              });
            });
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExchangeScreen(),
              ),
            ).then((_) {
              setState(() {
                _currentIndex = 0;
              });
            });
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DiscoverScreen(),
              ),
            ).then((_) {
              setState(() {
                _currentIndex = 0;
              });
            });
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            ).then((_) {
              setState(() {
                _currentIndex = 0;
              });
            });
          }
        },
      ),
    );
  }

  Widget _buildAssetList() {
    if (_selectedTab == 0) {
      // Cash tab - placeholder
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cash/Fiat Coming Soon',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoading && _getCurrentList().isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (_errorMessage != null && _getCurrentList().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCurrentTabData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.cardBackground,
      onRefresh: () => _loadCurrentTabData(showLoading: false),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _getCurrentList().length,
        itemBuilder: (context, index) {
          switch (_selectedTab) {
            case 1: // Crypto
              return CryptoListItem(asset: _cryptoAssets[index]);
            case 2: // Stocks
              return StockListItem(asset: _stockAssets[index]);
            case 3: // NFT
              return NFTListItem(asset: _nftAssets[index]);
            default:
              return const SizedBox();
          }
        },
      ),
    );
  }

  List<dynamic> _getCurrentList() {
    switch (_selectedTab) {
      case 1:
        return _cryptoAssets;
      case 2:
        return _stockAssets;
      case 3:
        return _nftAssets;
      default:
        return [];
    }
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
          _loadCurrentTabData();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}