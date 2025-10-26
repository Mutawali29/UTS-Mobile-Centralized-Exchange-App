import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user's wallet address
  Future<String?> getWalletAddress() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.data()?['walletAddress'] as String?;
    } catch (e) {
      print('Error getting wallet address: $e');
      return null;
    }
  }

  // Get user's portfolio (all crypto holdings)
  Future<Map<String, double>> getPortfolio() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return {};

      final portfolioSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('portfolio')
          .get();

      final portfolio = <String, double>{};
      for (var doc in portfolioSnapshot.docs) {
        final amount = doc.data()['amount'] as num?;
        if (amount != null && amount > 0) {
          portfolio[doc.id] = amount.toDouble();
        }
      }

      return portfolio;
    } catch (e) {
      print('Error getting portfolio: $e');
      return {};
    }
  }

  // Add or update crypto in portfolio
  Future<void> updatePortfolio(
      String cryptoId,
      double amount, {
        double? averagePrice,
      }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('portfolio')
          .doc(cryptoId)
          .set({
        'amount': amount,
        'averagePrice': averagePrice ?? 0,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating portfolio: $e');
      rethrow;
    }
  }

  // Remove crypto from portfolio
  Future<void> removeFromPortfolio(String cryptoId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('portfolio')
          .doc(cryptoId)
          .delete();
    } catch (e) {
      print('Error removing from portfolio: $e');
      rethrow;
    }
  }

  // Get portfolio as stream for real-time updates
  Stream<Map<String, double>> portfolioStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value({});

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('portfolio')
        .snapshots()
        .map((snapshot) {
      final portfolio = <String, double>{};
      for (var doc in snapshot.docs) {
        final amount = doc.data()['amount'] as num?;
        if (amount != null && amount > 0) {
          portfolio[doc.id] = amount.toDouble();
        }
      }
      return portfolio;
    });
  }

  // Initialize default portfolio for new users (optional)
  Future<void> initializeDefaultPortfolio() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      // Check if portfolio already exists
      final portfolioSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('portfolio')
          .limit(1)
          .get();

      if (portfolioSnapshot.docs.isEmpty) {
        // Add some default holdings (optional)
        await updatePortfolio('bitcoin', 0.04511, averagePrice: 45000);
        await updatePortfolio('ethereum', 3.56, averagePrice: 2500);
        await updatePortfolio('ripple', 4.0, averagePrice: 0.5);
      }
    } catch (e) {
      print('Error initializing portfolio: $e');
      rethrow;
    }
  }

  // Update wallet address
  Future<void> updateWalletAddress(String walletAddress) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      await _firestore.collection('users').doc(userId).update({
        'walletAddress': walletAddress,
      });
    } catch (e) {
      print('Error updating wallet address: $e');
      rethrow;
    }
  }
}