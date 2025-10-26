import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../widgets/transaction_item.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/app_colors.dart';
import 'transaction_detail_screen.dart';
import 'exchange_screen.dart';
import 'discover_screen.dart';
import 'profile_screen.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 1;
  late TabController _tabController;

  // Sample transaction data
  final List<Transaction> _allTransactions = [
    Transaction(
      id: '1',
      type: TransactionType.receive,
      status: TransactionStatus.completed,
      cryptoSymbol: 'BTC',
      cryptoName: 'Bitcoin',
      amount: 0.0245,
      valueUSD: 2021.45,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      fromAddress: '0x742d35Cc6634C0532925a3b8',
      transactionHash: '0xabc123...',
      fee: 0.0001,
    ),
    Transaction(
      id: '2',
      type: TransactionType.send,
      status: TransactionStatus.completed,
      cryptoSymbol: 'ETH',
      cryptoName: 'Ethereum',
      amount: 1.5,
      valueUSD: 3322.50,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      toAddress: '0x8f3Cf7ad51D57D8E6434C3A1',
      transactionHash: '0xdef456...',
      fee: 0.002,
    ),
    Transaction(
      id: '3',
      type: TransactionType.buy,
      status: TransactionStatus.completed,
      cryptoSymbol: 'BTC',
      cryptoName: 'Bitcoin',
      amount: 0.02,
      valueUSD: 1650.26,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      fee: 2.50,
    ),
    Transaction(
      id: '4',
      type: TransactionType.swap,
      status: TransactionStatus.pending,
      cryptoSymbol: 'ETH',
      cryptoName: 'Ethereum',
      amount: 0.5,
      valueUSD: 1107.50,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      fee: 0.001,
    ),
    Transaction(
      id: '5',
      type: TransactionType.receive,
      status: TransactionStatus.completed,
      cryptoSymbol: 'XRP',
      cryptoName: 'Ripple',
      amount: 100,
      valueUSD: 200.00,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      fromAddress: '0xrNative...1234',
      transactionHash: '0xghi789...',
      fee: 0.00001,
    ),
    Transaction(
      id: '6',
      type: TransactionType.sell,
      status: TransactionStatus.completed,
      cryptoSymbol: 'BTC',
      cryptoName: 'Bitcoin',
      amount: 0.01,
      valueUSD: 825.13,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      fee: 1.25,
    ),
    Transaction(
      id: '7',
      type: TransactionType.send,
      status: TransactionStatus.failed,
      cryptoSymbol: 'ETH',
      cryptoName: 'Ethereum',
      amount: 0.25,
      valueUSD: 553.75,
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      toAddress: '0x742d35Cc6634C0532925a3b8',
      transactionHash: '0xjkl012...',
      fee: 0.001,
    ),
    Transaction(
      id: '8',
      type: TransactionType.buy,
      status: TransactionStatus.completed,
      cryptoSymbol: 'XRP',
      cryptoName: 'Ripple',
      amount: 500,
      valueUSD: 1000.00,
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      fee: 5.00,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Transaction> get _filteredTransactions {
    final selectedTab = _tabController.index;

    if (selectedTab == 0) return _allTransactions; // All

    TransactionType? filterType;
    switch (selectedTab) {
      case 1:
        filterType = TransactionType.send;
        break;
      case 2:
        filterType = TransactionType.receive;
        break;
      case 3:
        return _allTransactions
            .where((t) =>
        t.type == TransactionType.buy ||
            t.type == TransactionType.sell ||
            t.type == TransactionType.swap)
            .toList();
    }

    if (filterType != null) {
      return _allTransactions
          .where((t) => t.type == filterType)
          .toList();
    }

    return _allTransactions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Activity',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          // TODO: Implement search
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.filter_list,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          // TODO: Implement filter
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Stats Cards
            _buildStatsCards(),

            const SizedBox(height: 20),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Sent'),
                  Tab(text: 'Received'),
                  Tab(text: 'Trade'),
                ],
                onTap: (index) {
                  setState(() {});
                },
              ),
            ),

            const SizedBox(height: 20),

            // Transaction List
            Expanded(
              child: _filteredTransactions.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                itemCount: _filteredTransactions.length,
                itemBuilder: (context, index) {
                  return TransactionItem(
                    transaction: _filteredTransactions[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionDetailScreen(
                            transaction: _filteredTransactions[index],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Update bagian bottomNavigationBar (ganti yang lama dengan ini)
      // Update bottomNavigationBar - ganti dengan kode lengkap ini
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            // Navigate back to Home
            Navigator.pop(context);
          } else if (index == 1) {
            // Already on Activity, do nothing
          } else if (index == 2) {
            // Navigate to Exchange
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ExchangeScreen(),
              ),
            );
          } else if (index == 3) {
            // Navigate to Discover
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DiscoverScreen(),
              ),
            );
          } else if (index == 4) {
            // Navigate to Profile
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildStatsCards() {
    final totalSent = _allTransactions
        .where((t) =>
    t.type == TransactionType.send && t.status == TransactionStatus.completed)
        .fold(0.0, (sum, t) => sum + t.valueUSD);

    final totalReceived = _allTransactions
        .where((t) =>
    t.type == TransactionType.receive &&
        t.status == TransactionStatus.completed)
        .fold(0.0, (sum, t) => sum + t.valueUSD);

    final totalTrade = _allTransactions
        .where((t) =>
    (t.type == TransactionType.buy ||
        t.type == TransactionType.sell ||
        t.type == TransactionType.swap) &&
        t.status == TransactionStatus.completed)
        .fold(0.0, (sum, t) => sum + t.valueUSD);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatCard(
            'Total Sent',
            '\$${totalSent.toStringAsFixed(2)}',
            Icons.arrow_upward,
            AppColors.gold,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Total Received',
            '\$${totalReceived.toStringAsFixed(2)}',
            Icons.arrow_downward,
            AppColors.green,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Total Trade',
            '\$${totalTrade.toStringAsFixed(2)}',
            Icons.swap_horiz,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No transactions yet',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your transaction history will appear here',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}