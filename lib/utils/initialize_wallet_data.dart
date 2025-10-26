// Script untuk menginisialisasi data wallet di Firebase
// Jalankan ini sekali untuk menambahkan data awal

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletInitializer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Generate wallet address (simplified version)
  String _generateWalletAddress() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 1000000).toString().padLeft(6, '0');
    return '0x19a15446affabcd1234$random';
  }

  // Initialize wallet data untuk user yang sudah login
  Future<void> initializeCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No user logged in');
        return;
      }

      // Check if wallet address already exists
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final data = userDoc.data();

      if (data?['walletAddress'] == null) {
        // Generate and save wallet address
        final walletAddress = _generateWalletAddress();
        await _firestore.collection('users').doc(user.uid).update({
          'walletAddress': walletAddress,
        });
        print('Wallet address created: $walletAddress');
      } else {
        print('Wallet address already exists: ${data!['walletAddress']}');
      }

      // Add sample portfolio (optional - untuk testing)
      await _addSamplePortfolio(user.uid);

      print('Wallet initialization completed successfully!');
    } catch (e) {
      print('Error initializing wallet: $e');
      rethrow;
    }
  }

  Future<void> _addSamplePortfolio(String userId) async {
    try {
      // Check if portfolio already exists
      final portfolioSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('portfolio')
          .limit(1)
          .get();

      if (portfolioSnapshot.docs.isEmpty) {
        print('Adding sample portfolio...');

        // Add Bitcoin
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('portfolio')
            .doc('bitcoin')
            .set({
          'amount': 0.04511,
          'averagePrice': 45000.00,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        print('✓ Added Bitcoin: 0.04511 BTC');

        // Add Ethereum
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('portfolio')
            .doc('ethereum')
            .set({
          'amount': 3.56,
          'averagePrice': 2500.00,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        print('✓ Added Ethereum: 3.56 ETH');

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
        print('✓ Added Ripple: 4.0 XRP');

        print('Sample portfolio added successfully!');
      } else {
        print('Portfolio already exists, skipping sample data');
      }
    } catch (e) {
      print('Error adding sample portfolio: $e');
    }
  }

  // Menambahkan crypto ke portfolio
  Future<void> addCryptoToPortfolio({
    required String userId,
    required String cryptoId,
    required double amount,
    double? averagePrice,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('portfolio')
          .doc(cryptoId)
          .set({
        'amount': amount,
        'averagePrice': averagePrice ?? 0,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print('✓ Added $cryptoId: $amount');
    } catch (e) {
      print('Error adding crypto to portfolio: $e');
      rethrow;
    }
  }

  // Update wallet address secara manual
  Future<void> updateWalletAddress(String userId, String walletAddress) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'walletAddress': walletAddress,
      });
      print('✓ Wallet address updated: $walletAddress');
    } catch (e) {
      print('Error updating wallet address: $e');
      rethrow;
    }
  }

  // Hapus semua portfolio (untuk reset)
  Future<void> clearPortfolio(String userId) async {
    try {
      final portfolioSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('portfolio')
          .get();

      for (var doc in portfolioSnapshot.docs) {
        await doc.reference.delete();
      }
      print('✓ Portfolio cleared');
    } catch (e) {
      print('Error clearing portfolio: $e');
      rethrow;
    }
  }
}

// Helper function untuk memanggil dari UI
Future<void> initializeWalletForCurrentUser() async {
  final initializer = WalletInitializer();
  await initializer.initializeCurrentUser();
}