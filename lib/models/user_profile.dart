import 'package:flutter/material.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String walletAddress;
  final DateTime joinedDate;
  final bool isVerified;
  final String currency;
  final String language;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    required this.walletAddress,
    required this.joinedDate,
    this.isVerified = false,
    this.currency = 'USD',
    this.language = 'English',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      avatarUrl: json['avatarUrl'],
      walletAddress: json['walletAddress'] ?? '',
      joinedDate: json['joinedDate'] != null
          ? DateTime.parse(json['joinedDate'])
          : DateTime.now(),
      isVerified: json['isVerified'] ?? false,
      currency: json['currency'] ?? 'USD',
      language: json['language'] ?? 'English',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'walletAddress': walletAddress,
      'joinedDate': joinedDate.toIso8601String(),
      'isVerified': isVerified,
      'currency': currency,
      'language': language,
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? walletAddress,
    DateTime? joinedDate,
    bool? isVerified,
    String? currency,
    String? language,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      walletAddress: walletAddress ?? this.walletAddress,
      joinedDate: joinedDate ?? this.joinedDate,
      isVerified: isVerified ?? this.isVerified,
      currency: currency ?? this.currency,
      language: language ?? this.language,
    );
  }
}

class ProfileMenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool showArrow;
  final bool isDanger;

  ProfileMenuItem({
    required this.title,
    required this.icon,
    this.subtitle = '',
    this.onTap,
    this.showArrow = true,
    this.isDanger = false,
  });
}