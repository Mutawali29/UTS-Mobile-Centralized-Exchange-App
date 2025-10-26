import 'package:flutter/material.dart';
import '../models/news_article.dart';
import '../utils/app_colors.dart';

class TrendingCryptoCard extends StatelessWidget {
  final TrendingCrypto crypto;
  final VoidCallback? onTap;

  const TrendingCryptoCard({
    super.key,
    required this.crypto,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: crypto.isPositive
                ? AppColors.green.withOpacity(0.3)
                : AppColors.red.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rank and Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#${crypto.rank}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _getIconColor(),
                    shape: BoxShape.circle,
                  ),
                  child: crypto.imageUrl != null
                      ? ClipOval(
                    child: Image.network(
                      crypto.imageUrl!,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            crypto.icon,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                      : Center(
                    child: Text(
                      crypto.icon,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Symbol
            Text(
              crypto.symbol,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            // Name
            Text(
              crypto.name,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Price
            Text(
              '\$${crypto.priceUSD >= 1 ? crypto.priceUSD.toStringAsFixed(2) : crypto.priceUSD.toStringAsFixed(6)}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            // Change
            Row(
              children: [
                Icon(
                  crypto.isPositive
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  color: crypto.isPositive ? AppColors.green : AppColors.red,
                  size: 12,
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    '${crypto.isPositive ? '+' : ''}${crypto.changePercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: crypto.isPositive ? AppColors.green : AppColors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getIconColor() {
    switch (crypto.symbol) {
      case 'BTC':
        return AppColors.gold.withOpacity(0.2);
      case 'ETH':
        return Colors.blueGrey.withOpacity(0.2);
      case 'XRP':
        return Colors.grey.withOpacity(0.2);
      case 'BNB':
        return Colors.amber.withOpacity(0.2);
      case 'ADA':
        return Colors.blue.withOpacity(0.2);
      case 'SOL':
        return Colors.purple.withOpacity(0.2);
      case 'DOGE':
        return Colors.yellow.withOpacity(0.2);
      case 'DOT':
        return Colors.pink.withOpacity(0.2);
      case 'MATIC':
        return Colors.deepPurple.withOpacity(0.2);
      case 'LTC':
        return Colors.grey.shade400.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }
}