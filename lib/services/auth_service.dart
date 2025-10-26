import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Generate wallet address
  String _generateWalletAddress() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final userId = _auth.currentUser?.uid ?? 'unknown';
    final hash = userId.hashCode.abs().toString().padLeft(8, '0');
    final random = (timestamp % 1000000).toString().padLeft(6, '0');
    return '0x${hash.substring(0, 4)}${random}${hash.substring(4, 8)}';
  }

  // Initialize wallet for new user
  Future<void> _initializeWallet(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final data = userDoc.data();

      // Add wallet address if doesn't exist
      if (data?['walletAddress'] == null) {
        final walletAddress = _generateWalletAddress();
        await _firestore.collection('users').doc(userId).update({
          'walletAddress': walletAddress,
        });
        print('✓ Wallet address created: $walletAddress');

        // Initialize with empty portfolio (optional sample data)
        await _addSamplePortfolio(userId);
      }
    } catch (e) {
      print('Error initializing wallet: $e');
    }
  }

  // Add sample portfolio (optional - comment out if you don't want sample data)
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
        // Add sample holdings
        final samplePortfolio = {
          'bitcoin': {'amount': 0.04511, 'averagePrice': 45000.00},
          'ethereum': {'amount': 3.56, 'averagePrice': 2500.00},
          'ripple': {'amount': 4.0, 'averagePrice': 0.50},
        };

        for (var entry in samplePortfolio.entries) {
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('portfolio')
              .doc(entry.key)
              .set({
            'amount': entry.value['amount'],
            'averagePrice': entry.value['averagePrice'],
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
        print('✓ Sample portfolio initialized');
      }
    } catch (e) {
      print('Error adding sample portfolio: $e');
    }
  }

  // Sign up dengan email dan password
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(name);

        // Save user data to Firestore
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'email': email,
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
          'isVerified': false,
        });

        // Initialize wallet
        await _initializeWallet(credential.user!.uid);

        // Send email verification
        await credential.user!.sendEmailVerification();
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      print('Sign up error: ${e.code}');
      rethrow;
    }
  }

  // Sign in dengan email dan password
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Initialize wallet if not exists (for existing users)
      if (credential.user != null) {
        await _initializeWallet(credential.user!.uid);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.code}');
      rethrow;
    }
  }

  // Sign in dengan Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Save user data if new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'name': userCredential.user!.displayName,
          'createdAt': FieldValue.serverTimestamp(),
          'isVerified': true,
        });
      }

      // Initialize wallet
      if (userCredential.user != null) {
        await _initializeWallet(userCredential.user!.uid);
      }

      return userCredential;
    } catch (e) {
      print('Google sign in error: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Reset password error: ${e.code}');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  // Update profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      if (displayName != null) {
        await user.updateDisplayName(displayName);
        await _firestore.collection('users').doc(user.uid).update({
          'name': displayName,
        });
      }

      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }
    } catch (e) {
      print('Update profile error: $e');
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete user account
      await user.delete();
    } catch (e) {
      print('Delete account error: $e');
      rethrow;
    }
  }
}