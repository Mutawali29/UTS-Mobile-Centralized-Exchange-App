import 'package:flutter/material.dart';
import '../models/crypto_asset.dart';
import '../utils/app_colors.dart';

class CryptoListItem extends StatelessWidget {
  final CryptoAsset asset;

  const CryptoListItem({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    final isPositive = asset.changePercent >= 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon - use network image if available
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getIconColor(),
              shape: BoxShape.circle,
            ),
            child: asset.imageUrl != null
                ? ClipOval(
              child: Image.network(
                asset.imageUrl!,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      asset.icon,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary.withOpacity(0.5),
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            )
                : Center(
              child: Text(
                asset.icon,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name and value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      asset.symbol,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (asset.amount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Portfolio',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  asset.amount > 0
                      ? '\$${asset.valueUSD.toStringAsFixed(2)} ${isPositive ? '+' : ''}${asset.changePercent.toStringAsFixed(2)}%'
                      : '\$${asset.priceUSD >= 1 ? asset.priceUSD.toStringAsFixed(2) : asset.priceUSD.toStringAsFixed(6)} ${isPositive ? '+' : ''}${asset.changePercent.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: isPositive ? AppColors.green : AppColors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Amount and price or just price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (asset.amount > 0) ...[
                Text(
                  asset.amount < 1
                      ? asset.amount.toStringAsFixed(4)
                      : asset.amount.toStringAsFixed(2),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${asset.priceUSD >= 1 ? asset.priceUSD.toStringAsFixed(2) : asset.priceUSD.toStringAsFixed(4)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ] else ...[
                Text(
                  '\$${asset.priceUSD >= 1 ? asset.priceUSD.toStringAsFixed(2) : asset.priceUSD.toStringAsFixed(6)}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  asset.name,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getIconColor() {
    switch (asset.symbol) {
      case 'BTC':
        return AppColors.gold.withOpacity(0.2);
      case 'XRP':
        return Colors.grey.withOpacity(0.2);
      case 'ETH':
        return Colors.blueGrey.withOpacity(0.2);
      case 'BNB':
        return Colors.amber.withOpacity(0.2);
      case 'ADA':
        return Colors.blue.withOpacity(0.2);
      case 'SOL':
        return Colors.purple.withOpacity(0.2);
      case 'DOGE':
        return Colors.orange.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }
}