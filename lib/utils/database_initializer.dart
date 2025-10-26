import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';

class DatabaseInitializer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initialize SEMUA data yang diperlukan
  Future<Map<String, dynamic>> initializeUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'User not logged in!',
        };
      }

      final userId = user.uid;
      print('🚀 Starting initialization for user: $userId');

      // 1. Check & Add Wallet Address
      await _initializeWalletAddress(userId);

      // 2. Add Portfolio
      await _initializePortfolio(userId);

      print('✅ Initialization completed successfully!');
      return {
        'success': true,
        'message': 'Database initialized successfully!',
      };
    } catch (e) {
      print('❌ Error during initialization: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  Future<void> _initializeWalletAddress(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final data = userDoc.data();

      if (data?['walletAddress'] == null || data!['walletAddress'].isEmpty) {
        final walletAddress = _generateWalletAddress();
        await _firestore.collection('users').doc(userId).update({
          'walletAddress': walletAddress,
        });
        print('✅ Wallet address created: $walletAddress');
      } else {
        print('ℹ️ Wallet address already exists: ${data['walletAddress']}');
      }
    } catch (e) {
      print('❌ Error initializing wallet address: $e');
      rethrow;
    }
  }

  Future<void> _initializePortfolio(String userId) async {
    try {
      // Check if portfolio already exists
      final portfolioSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('portfolio')
          .limit(1)
          .get();

      if (portfolioSnapshot.docs.isNotEmpty) {
        print('ℹ️ Portfolio already exists, skipping...');
        return;
      }

      print('📦 Creating portfolio...');

      // Add Bitcoin
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('portfolio')
          .doc('bitcoin')
          .set({
        'amount': 0.04511,
        'averagePrice': 45000.0,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print('  ✅ Bitcoin added: 0.04511 BTC');

      // Add Ethereum
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('portfolio')
          .doc('ethereum')
          .set({
        'amount': 3.56,
        'averagePrice': 2500.0,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print('  ✅ Ethereum added: 3.56 ETH');

      // Add Ripple
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('portfolio')
          .doc('ripple')
          .set({
        'amount': 4.0,
        'averagePrice': 0.50,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print('  ✅ Ripple added: 4.0 XRP');

      print('✅ Portfolio created successfully!');
    } catch (e) {
      print('❌ Error initializing portfolio: $e');
      rethrow;
    }
  }

  String _generateWalletAddress() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 1000000).toString().padLeft(6, '0');
    return '0x19a15446affabcd1234$random';
  }

  // Check status database
  Future<Map<String, dynamic>> checkDatabaseStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'hasWallet': false,
          'hasPortfolio': false,
          'portfolioCount': 0,
        };
      }

      final userId = user.uid;

      // Check wallet
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final hasWallet = userDoc.data()?['walletAddress'] != null;

      // Check portfolio
      final portfolioSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('portfolio')
          .get();
      final hasPortfolio = portfolioSnapshot.docs.isNotEmpty;
      final portfolioCount = portfolioSnapshot.docs.length;

      return {
        'hasWallet': hasWallet,
        'hasPortfolio': hasPortfolio,
        'portfolioCount': portfolioCount,
        'walletAddress': userDoc.data()?['walletAddress'],
      };
    } catch (e) {
      print('Error checking database status: $e');
      return {
        'hasWallet': false,
        'hasPortfolio': false,
        'portfolioCount': 0,
      };
    }
  }
}

// Widget untuk UI - Tombol Initialize
class DatabaseInitializerWidget extends StatefulWidget {
  const DatabaseInitializerWidget({super.key});

  @override
  State<DatabaseInitializerWidget> createState() => _DatabaseInitializerWidgetState();
}

class _DatabaseInitializerWidgetState extends State<DatabaseInitializerWidget> {
  final DatabaseInitializer _initializer = DatabaseInitializer();
  bool _isLoading = false;
  bool _isChecking = true;
  Map<String, dynamic>? _status;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() {
      _isChecking = true;
    });

    final status = await _initializer.checkDatabaseStatus();

    setState(() {
      _status = status;
      _isChecking = false;
    });
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _initializer.initializeUserData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? AppColors.green : AppColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      if (result['success']) {
        // Refresh status
        await _checkStatus();
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final hasWallet = _status?['hasWallet'] ?? false;
    final hasPortfolio = _status?['hasPortfolio'] ?? false;
    final portfolioCount = _status?['portfolioCount'] ?? 0;

    return Container(
      margin: const EdgeInsets.all(20),
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
            children: [
              Icon(
                hasWallet && hasPortfolio ? Icons.check_circle : Icons.warning,
                color: hasWallet && hasPortfolio ? AppColors.green : AppColors.orange,
              ),
              const SizedBox(width: 12),
              const Text(
                'Database Status',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildStatusItem(
            'Wallet Address',
            hasWallet,
            _status?['walletAddress']?.toString() ?? 'Not set',
          ),
          const SizedBox(height: 8),
          _buildStatusItem(
            'Portfolio',
            hasPortfolio,
            hasPortfolio ? '$portfolioCount crypto assets' : 'Not initialized',
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading || (hasWallet && hasPortfolio) ? null : _initialize,
              icon: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Icon(
                hasWallet && hasPortfolio ? Icons.check : Icons.rocket_launch,
              ),
              label: Text(
                _isLoading
                    ? 'Initializing...'
                    : hasWallet && hasPortfolio
                    ? 'Already Initialized ✓'
                    : 'Initialize Database',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasWallet && hasPortfolio
                    ? AppColors.green.withOpacity(0.3)
                    : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          if (hasWallet && hasPortfolio) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _checkStatus,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh Status'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, bool isOk, String value) {
    return Row(
      children: [
        Icon(
          isOk ? Icons.check_circle : Icons.cancel,
          color: isOk ? AppColors.green : AppColors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}