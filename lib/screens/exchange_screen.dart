import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/exchange_rate.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/crypto_selector_bottom_sheet.dart';
import '../utils/app_colors.dart';
import 'discover_screen.dart';
import 'activity_screen.dart';
import 'profile_screen.dart';

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  int _currentIndex = 2;

  final TextEditingController _fromAmountController = TextEditingController();
  final TextEditingController _toAmountController = TextEditingController();

  // Sample crypto list
  final List<ExchangePair> _cryptoList = [
    ExchangePair(
      symbol: 'BTC',
      name: 'Bitcoin',
      icon: '₿',
      balance: 0.04511,
      priceUSD: 82513,
    ),
    ExchangePair(
      symbol: 'ETH',
      name: 'Ethereum',
      icon: '⟠',
      balance: 3.56,
      priceUSD: 2215,
    ),
    ExchangePair(
      symbol: 'XRP',
      name: 'Ripple',
      icon: '✕',
      balance: 4.0,
      priceUSD: 2.0,
    ),
    ExchangePair(
      symbol: 'BNB',
      name: 'Binance Coin',
      icon: 'B',
      balance: 2.5,
      priceUSD: 315,
    ),
    ExchangePair(
      symbol: 'ADA',
      name: 'Cardano',
      icon: '₳',
      balance: 100,
      priceUSD: 0.45,
    ),
    ExchangePair(
      symbol: 'SOL',
      name: 'Solana',
      icon: '◎',
      balance: 5.0,
      priceUSD: 98,
    ),
  ];

  late ExchangePair _fromCrypto;
  late ExchangePair _toCrypto;

  double _exchangeRate = 0.0;
  double _networkFee = 0.001;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _fromCrypto = _cryptoList[0]; // BTC
    _toCrypto = _cryptoList[1]; // ETH
    _calculateExchangeRate();
    _fromAmountController.addListener(_onFromAmountChanged);
  }

  @override
  void dispose() {
    _fromAmountController.dispose();
    _toAmountController.dispose();
    super.dispose();
  }

  void _calculateExchangeRate() {
    setState(() {
      _exchangeRate = _fromCrypto.priceUSD / _toCrypto.priceUSD;
    });
  }

  void _onFromAmountChanged() {
    if (_fromAmountController.text.isEmpty) {
      _toAmountController.text = '';
      return;
    }

    final fromAmount = double.tryParse(_fromAmountController.text) ?? 0;
    final toAmount = fromAmount * _exchangeRate;
    _toAmountController.text = toAmount.toStringAsFixed(6);
  }

  void _swapCryptos() {
    setState(() {
      final temp = _fromCrypto;
      _fromCrypto = _toCrypto;
      _toCrypto = temp;

      final tempAmount = _fromAmountController.text;
      _fromAmountController.text = _toAmountController.text;
      _toAmountController.text = tempAmount;

      _calculateExchangeRate();
    });
  }

  Future<void> _selectFromCrypto() async {
    final result = await showModalBottomSheet<ExchangePair>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CryptoSelectorBottomSheet(
        cryptoList: _cryptoList,
        selectedCrypto: _fromCrypto,
      ),
    );

    if (result != null && result.symbol != _toCrypto.symbol) {
      setState(() {
        _fromCrypto = result;
        _calculateExchangeRate();
        _onFromAmountChanged();
      });
    }
  }

  Future<void> _selectToCrypto() async {
    final result = await showModalBottomSheet<ExchangePair>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CryptoSelectorBottomSheet(
        cryptoList: _cryptoList,
        selectedCrypto: _toCrypto,
      ),
    );

    if (result != null && result.symbol != _fromCrypto.symbol) {
      setState(() {
        _toCrypto = result;
        _calculateExchangeRate();
        _onFromAmountChanged();
      });
    }
  }

  void _executeExchange() {
    final fromAmount = double.tryParse(_fromAmountController.text) ?? 0;

    if (fromAmount <= 0) {
      _showSnackBar('Please enter a valid amount', isError: true);
      return;
    }

    if (fromAmount > _fromCrypto.balance) {
      _showSnackBar('Insufficient balance', isError: true);
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => _buildConfirmationDialog(fromAmount),
    );
  }

  Widget _buildConfirmationDialog(double fromAmount) {
    final toAmount = double.tryParse(_toAmountController.text) ?? 0;
    final fee = _networkFee * _fromCrypto.priceUSD;

    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        'Confirm Exchange',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDialogRow('From:', '$fromAmount ${_fromCrypto.symbol}'),
          const SizedBox(height: 8),
          _buildDialogRow('To:', '$toAmount ${_toCrypto.symbol}'),
          const SizedBox(height: 8),
          _buildDialogRow('Rate:', '1 ${_fromCrypto.symbol} = ${_exchangeRate.toStringAsFixed(6)} ${_toCrypto.symbol}'),
          const SizedBox(height: 8),
          _buildDialogRow('Network Fee:', '\$${fee.toStringAsFixed(2)}'),
          const Divider(color: AppColors.textSecondary, height: 24),
          const Text(
            'This exchange cannot be reversed.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _performExchange();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _performExchange() {
    setState(() {
      _isCalculating = true;
    });

    // Simulate exchange process
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isCalculating = false;
        _fromAmountController.clear();
        _toAmountController.clear();
      });
      _showSnackBar('Exchange completed successfully!');
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.red : AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
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
                    'Exchange',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.history,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      // TODO: Show exchange history
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // From Card
                    _buildCryptoCard(
                      label: 'From',
                      crypto: _fromCrypto,
                      controller: _fromAmountController,
                      onTap: _selectFromCrypto,
                      isFrom: true,
                    ),

                    const SizedBox(height: 16),

                    // Swap Button
                    Center(
                      child: GestureDetector(
                        onTap: _swapCryptos,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.swap_vert,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // To Card
                    _buildCryptoCard(
                      label: 'To',
                      crypto: _toCrypto,
                      controller: _toAmountController,
                      onTap: _selectToCrypto,
                      isFrom: false,
                    ),

                    const SizedBox(height: 24),

                    // Exchange Rate Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Exchange Rate',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '1 ${_fromCrypto.symbol} = ${_exchangeRate.toStringAsFixed(6)} ${_toCrypto.symbol}',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Network Fee',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '$_networkFee ${_fromCrypto.symbol} (\$${(_networkFee * _fromCrypto.priceUSD).toStringAsFixed(2)})',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Exchange Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isCalculating ? null : _executeExchange,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                        ),
                        child: _isCalculating
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          'Exchange Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
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
            // Navigate to Activity
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ActivityScreen(),
              ),
            );
          } else if (index == 2) {
            // Already on Exchange
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

  Widget _buildCryptoCard({
    required String label,
    required ExchangePair crypto,
    required TextEditingController controller,
    required VoidCallback onTap,
    required bool isFrom,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              Text(
                'Balance: ${crypto.balance.toStringAsFixed(4)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Crypto Selector
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _getIconColor(crypto.symbol),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            crypto.icon,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        crypto.symbol,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Amount Input
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: !isFrom,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 24,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          if (controller.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '≈ \$${((double.tryParse(controller.text) ?? 0) * crypto.priceUSD).toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getIconColor(String symbol) {
    switch (symbol) {
      case 'BTC':
        return AppColors.gold.withOpacity(0.2);
      case 'ETH':
        return Colors.blueGrey.withOpacity(0.2);
      case 'XRP':
        return Colors.grey.withOpacity(0.2);
      case 'BNB':
        return Colors.amber.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }
}