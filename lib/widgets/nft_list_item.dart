import 'package:flutter/material.dart';
import '../models/nft_asset.dart';
import '../utils/app_colors.dart';

class NFTListItem extends StatelessWidget {
  final NFTAsset asset;

  const NFTListItem({
    super.key,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = asset.changePercent >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // NFT Image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              image: asset.imageUrl.isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(asset.imageUrl),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  // Handle image load error
                },
              )
                  : null,
            ),
            child: asset.imageUrl.isEmpty
                ? const Icon(
              Icons.image,
              color: AppColors.primary,
              size: 24,
            )
                : null,
          ),
          const SizedBox(width: 12),

          // NFT Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name.length > 18
                      ? '${asset.name.substring(0, 18)}...'
                      : asset.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  asset.collection.length > 22
                      ? '${asset.collection.substring(0, 22)}...'
                      : asset.collection,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (asset.amount > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${asset.amount.toStringAsFixed(0)} owned',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Price Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${asset.floorPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isPositive
                      ? AppColors.green.withOpacity(0.1)
                      : AppColors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${isPositive ? '+' : ''}${asset.changePercent.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: isPositive ? AppColors.green : AppColors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (asset.amount > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '\$${asset.valueUSD.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}