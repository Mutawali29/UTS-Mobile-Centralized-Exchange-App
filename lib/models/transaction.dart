enum TransactionType { send, receive, buy, sell, swap }

enum TransactionStatus { completed, pending, failed }

class Transaction {
  final String id;
  final TransactionType type;
  final TransactionStatus status;
  final String cryptoSymbol;
  final String cryptoName;
  final double amount;
  final double valueUSD;
  final DateTime timestamp;
  final String? toAddress;
  final String? fromAddress;
  final String? transactionHash;
  final double? fee;
  final String? imageUrl;

  Transaction({
    required this.id,
    required this.type,
    required this.status,
    required this.cryptoSymbol,
    required this.cryptoName,
    required this.amount,
    required this.valueUSD,
    required this.timestamp,
    this.toAddress,
    this.fromAddress,
    this.transactionHash,
    this.fee,
    this.imageUrl,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'cryptoSymbol': cryptoSymbol,
      'cryptoName': cryptoName,
      'amount': amount,
      'valueUSD': valueUSD,
      'timestamp': timestamp.toIso8601String(),
      'toAddress': toAddress,
      'fromAddress': fromAddress,
      'transactionHash': transactionHash,
      'fee': fee,
      'imageUrl': imageUrl,
    };
  }

  // Create from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: TransactionType.values.firstWhere(
            (e) => e.toString().split('.').last == json['type'],
      ),
      status: TransactionStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status'],
      ),
      cryptoSymbol: json['cryptoSymbol'],
      cryptoName: json['cryptoName'],
      amount: (json['amount'] as num).toDouble(),
      valueUSD: (json['valueUSD'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      toAddress: json['toAddress'],
      fromAddress: json['fromAddress'],
      transactionHash: json['transactionHash'],
      fee: json['fee'] != null ? (json['fee'] as num).toDouble() : null,
      imageUrl: json['imageUrl'],
    );
  }

  // Get icon for transaction type
  String getTypeIcon() {
    switch (type) {
      case TransactionType.send:
        return '↑';
      case TransactionType.receive:
        return '↓';
      case TransactionType.buy:
        return '+';
      case TransactionType.sell:
        return '−';
      case TransactionType.swap:
        return '⇄';
    }
  }

  // Get color for transaction type
  bool isPositive() {
    return type == TransactionType.receive || type == TransactionType.buy;
  }
}