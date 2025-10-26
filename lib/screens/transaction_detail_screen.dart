import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../utils/app_colors.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Transaction Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.textSecondary),
            onPressed: () {
              // TODO: Share transaction
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Status Icon
            _buildStatusSection(),
            const SizedBox(height: 32),
            // Amount
            _buildAmountSection(),
            const SizedBox(height: 32),
            // Details
            _buildDetailsSection(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildStatusSection() {
    IconData icon;
    Color color;
    String statusText;

    switch (transaction.status) {
      case TransactionStatus.completed:
        icon = Icons.check_circle;
        color = AppColors.green;
        statusText = 'Completed';
        break;
      case TransactionStatus.pending:
        icon = Icons.pending;
        color = Colors.orange;
        statusText = 'Pending';
        break;
      case TransactionStatus.failed:
        icon = Icons.cancel;
        color = AppColors.red;
        statusText = 'Failed';
        break;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 48),
        ),
        const SizedBox(height: 16),
        Text(
          statusText,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getTypeText(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Column(
      children: [
        Text(
          '${transaction.isPositive() ? '+' : '-'}${transaction.amount.toStringAsFixed(6)} ${transaction.cryptoSymbol}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '\$${transaction.valueUSD.toStringAsFixed(2)} USD',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildDetailRow('Asset', transaction.cryptoName),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Date & Time',
            DateFormat('MMM dd, yyyy • hh:mm a').format(transaction.timestamp),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Status', _getStatusText()),
          if (transaction.fee != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              'Network Fee',
              '${transaction.fee!.toStringAsFixed(6)} ${transaction.cryptoSymbol}',
            ),
          ],
          if (transaction.fromAddress != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              'From',
              transaction.fromAddress!,
              isCopyable: true,
              context: context,
            ),
          ],
          if (transaction.toAddress != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              'To',
              transaction.toAddress!,
              isCopyable: true,
              context: context,
            ),
          ],
          if (transaction.transactionHash != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              'Transaction Hash',
              transaction.transactionHash!,
              isCopyable: true,
              context: context,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      String label,
      String value, {
        bool isCopyable = false,
        BuildContext? context,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  isCopyable ? _truncateAddress(value) : value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              if (isCopyable && context != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Copied to clipboard'),
                        backgroundColor: AppColors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.copy,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    if (transaction.status == TransactionStatus.completed) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: View on blockchain explorer
            },
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('View on Blockchain'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _getTypeText() {
    switch (transaction.type) {
      case TransactionType.send:
        return 'Sent ${transaction.cryptoName}';
      case TransactionType.receive:
        return 'Received ${transaction.cryptoName}';
      case TransactionType.buy:
        return 'Bought ${transaction.cryptoName}';
      case TransactionType.sell:
        return 'Sold ${transaction.cryptoName}';
      case TransactionType.swap:
        return 'Swapped ${transaction.cryptoName}';
    }
  }

  String _getStatusText() {
    switch (transaction.status) {
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.pending:
        return 'Pending Confirmation';
      case TransactionStatus.failed:
        return 'Failed';
    }
  }

  String _truncateAddress(String address) {
    if (address.length <= 16) return address;
    return '${address.substring(0, 8)}...${address.substring(address.length - 8)}';
  }
}