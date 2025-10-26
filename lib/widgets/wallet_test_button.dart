import 'package:flutter/material.dart';
import '../services/wallet_service.dart';
import '../utils/app_colors.dart';

/// Widget untuk testing wallet functionality
/// Tambahkan di ProfileScreen atau buat screen khusus untuk developer testing
class WalletTestControls extends StatelessWidget {
  const WalletTestControls({super.key});

  @override
  Widget build(BuildContext context) {
    final walletService = WalletService();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Developer Tools',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Test Button: Add Bitcoin
          _TestButton(
            label: 'Add 0.5 BTC',
            onPressed: () async {
              try {
                await walletService.updatePortfolio(
                  'bitcoin',
                  0.5,
                  averagePrice: 50000,
                );
                _showSuccess(context, 'Added 0.5 BTC to portfolio');
              } catch (e) {
                _showError(context, 'Error: $e');
              }
            },
          ),

          const SizedBox(height: 8),

          // Test Button: Add Ethereum
          _TestButton(
            label: 'Add 5 ETH',
            onPressed: () async {
              try {
                await walletService.updatePortfolio(
                  'ethereum',
                  5.0,
                  averagePrice: 3000,
                );
                _showSuccess(context, 'Added 5 ETH to portfolio');
              } catch (e) {
                _showError(context, 'Error: $e');
              }
            },
          ),

          const SizedBox(height: 8),

          // Test Button: Add Solana
          _TestButton(
            label: 'Add 50 SOL',
            onPressed: () async {
              try {
                await walletService.updatePortfolio(
                  'solana',
                  50.0,
                  averagePrice: 100,
                );
                _showSuccess(context, 'Added 50 SOL to portfolio');
              } catch (e) {
                _showError(context, 'Error: $e');
              }
            },
          ),

          const SizedBox(height: 8),

          // Test Button: Clear Portfolio
          _TestButton(
            label: 'Clear All Portfolio',
            color: AppColors.red,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.cardBackground,
                  title: const Text(
                    'Clear Portfolio?',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  content: const Text(
                    'This will remove all crypto from your portfolio.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                      ),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  final portfolio = await walletService.getPortfolio();
                  for (var cryptoId in portfolio.keys) {
                    await walletService.removeFromPortfolio(cryptoId);
                  }
                  _showSuccess(context, 'Portfolio cleared');
                } catch (e) {
                  _showError(context, 'Error: $e');
                }
              }
            },
          ),

          const SizedBox(height: 8),

          // Test Button: Initialize Default
          _TestButton(
            label: 'Initialize Default Portfolio',
            color: AppColors.green,
            onPressed: () async {
              try {
                await walletService.initializeDefaultPortfolio();
                _showSuccess(context, 'Default portfolio initialized');
              } catch (e) {
                _showError(context, 'Error: $e');
              }
            },
          ),

          const SizedBox(height: 16),

          // Portfolio Info
          FutureBuilder<Map<String, double>>(
            future: walletService.getPortfolio(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                );
              }

              final portfolio = snapshot.data!;
              if (portfolio.isEmpty) {
                return const Text(
                  'Portfolio is empty',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Portfolio:',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...portfolio.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _TestButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const _TestButton({
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}