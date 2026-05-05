// lib/models/profile.dart
class UserProfile {
  final String id;
  final String username;
  final String? email;
  final String? avatarUrl;
  final int totalDiamonds;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.username,
    this.email,
    this.avatarUrl,
    required this.totalDiamonds,
    required this.createdAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
    id: m['id'] as String,
    username: (m['username'] as String?) ?? 'Oyuncu',
    email: m['email'] as String?,
    avatarUrl: m['avatar_url'] as String?,
    totalDiamonds: (m['total_diamonds'] as int?) ?? 0,
    createdAt: DateTime.parse(m['created_at'] as String),
  );

  UserProfile copyWith({int? totalDiamonds, String? username}) => UserProfile(
    id: id,
    username: username ?? this.username,
    email: email,
    avatarUrl: avatarUrl,
    totalDiamonds: totalDiamonds ?? this.totalDiamonds,
    createdAt: createdAt,
  );
}
