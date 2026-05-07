// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../providers/game_provider.dart';
import '../services/supabase_service.dart';
import '../widgets/common_widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _signingOut = false;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final stats   = ref.watch(completionStatsProvider);

    return Scaffold(
      backgroundColor: ZennColors.background,
      body: profile.when(
        data: (p) {
          if (p == null) return _SignInPrompt();
          final totalCompleted = stats.valueOrNull != null
              ? (stats.valueOrNull!['easy'] ?? 0) +
                (stats.valueOrNull!['medium'] ?? 0) +
                (stats.valueOrNull!['hard'] ?? 0) +
                (stats.valueOrNull!['daily'] ?? 0)
              : 0;

          return SingleChildScrollView(
            child: Column(
              children: [
                // ── Gradient header + avatar ─────────────────────────────
                _ProfileHeader(
                  avatarUrl: p.avatarUrl,
                  username: p.username,
                  email: p.email,
                  totalCompleted: totalCompleted,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // ── Elmas kartı ──────────────────────────────────────
                      _DiamondCard(diamonds: p.totalDiamonds),

                      const SizedBox(height: 20),

                      // ── Tamamlanan bulmacalar ────────────────────────────
                      stats.when(
                        data: (s) => _StatsGrid(stats: s),
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 20),

                      // ── Ayarlar ──────────────────────────────────────────
                      _SettingsSection(),

                      const SizedBox(height: 20),

                      // ── Çıkış ────────────────────────────────────────────
                      ZennButton(
                        label: 'Çıkış Yap',
                        loading: _signingOut,
                        color: const Color(0xFFBA1A1A),
                        onTap: () async {
                          setState(() => _signingOut = true);
                          await SupabaseService.instance.signOut();
                          if (!mounted) return;
                          ref.invalidate(profileProvider);
                          ref.invalidate(completionStatsProvider);
                          ref.invalidate(dailyPuzzleProvider);
                          context.go(AppConstants.routeHome);
                        },
                      ),

                      const SizedBox(height: 12),
                      Text(
                        AppConstants.studio,
                        style: ZennTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 52),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _SignInPrompt(),
      ),
    );
  }
}

// ─── Profil Header (gradient arka plan + avatar) ──────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final String? avatarUrl;
  final String username;
  final String? email;
  final int totalCompleted;

  const _ProfileHeader({
    required this.avatarUrl,
    required this.username,
    required this.email,
    required this.totalCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Gradient arka plan
        Container(
          width: double.infinity,
          height: 180,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF003D28), Color(0xFF1A6B4A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Geri butonu
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  // Tamamlanan bulmaca özet etiketi
                  if (totalCompleted > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        '$totalCompleted bulmaca tamamlandı',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Avatar + isim (gradient'in altına taşar)
        Positioned(
          top: 110,
          left: 0,
          right: 0,
          child: Column(
            children: [
              // Avatar dairesi
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: avatarUrl != null
                      ? Image.network(avatarUrl!, fit: BoxFit.cover)
                      : Container(
                          color: ZennColors.cardLight,
                          child: const Icon(Icons.person_rounded,
                              size: 44, color: ZennColors.primary),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Text(username, style: ZennTextStyles.headline2),
              if (email != null) ...[
                const SizedBox(height: 2),
                Text(email!, style: ZennTextStyles.caption),
              ],
            ],
          ),
        ),

        // Header'ın yüksekliğini tutan boş alan
        const SizedBox(height: 280),
      ],
    );
  }
}

// ─── Elmas Kartı ──────────────────────────────────────────────────────────────

class _DiamondCard extends StatelessWidget {
  final int diamonds;
  const _DiamondCard({required this.diamonds});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF005235), Color(0xFF1A6B4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Toplam Kazandığın',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${diamonds.toString()} Elmas',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Text('💎', style: TextStyle(fontSize: 36)),
        ],
      ),
    );
  }
}

// ─── İstatistik Grid ──────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final Map<String, int> stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(
          label: 'Kolay',
          value: stats['easy'] ?? 0,
          icon: Icons.circle,
          color: ZennColors.easy),
      _StatItem(
          label: 'Orta',
          value: stats['medium'] ?? 0,
          icon: Icons.circle,
          color: ZennColors.medium),
      _StatItem(
          label: 'Zor',
          value: stats['hard'] ?? 0,
          icon: Icons.circle,
          color: ZennColors.hard),
      _StatItem(
          label: 'Günlük',
          value: stats['daily'] ?? 0,
          icon: Icons.calendar_today_rounded,
          color: ZennColors.daily),
    ];
    final total = items.fold(0, (s, i) => s + i.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Tamamlanan Bulmacalar',
                style: ZennTextStyles.headline3),
            const Spacer(),
            Text('Toplam: $total', style: ZennTextStyles.caption),
          ],
        ),
        const SizedBox(height: 14),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero, 
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: items
              .map((item) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: ZennColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: ZennColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(item.icon,
                              size: 18, color: item.color),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.value.toString(),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: ZennColors.textDark,
                              ),
                            ),
                            Text(item.label,
                                style: ZennTextStyles.caption),
                          ],
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _StatItem {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _StatItem(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});
}

// ─── Ayarlar Bölümü ───────────────────────────────────────────────────────────

class _SettingsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hapticEnabled = ref.watch(hapticEnabledProvider);

    void showComingSoon() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bu özellik yakında kullanılabilecek 🚀'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ZennColors.primary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ayarlar', style: ZennTextStyles.headline3),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: ZennColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ZennColors.border),
          ),
          child: Column(
            children: [
              // Bildirimler — yakında
              _SettingsTile(
                icon: Icons.notifications_outlined,
                label: 'Bildirimler',
                subtitle: 'Yakında',
                trailing: Switch(
                    value: false,
                    onChanged: (_) => showComingSoon(),
                    thumbColor: WidgetStateProperty.all(Colors.white),
                    trackColor: WidgetStateProperty.all(ZennColors.gridLine),
                    trackOutlineColor: WidgetStateProperty.all(ZennColors.gridLine),
                ),
              ),
              const Divider(height: 1, indent: 56),
              // Karanlık Mod — yakında
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                label: 'Karanlık Mod',
                subtitle: 'Yakında',
                trailing: Switch(
                    value: false,
                    onChanged: (_) => showComingSoon(),
                    thumbColor: WidgetStateProperty.all(Colors.white),
                    trackColor: WidgetStateProperty.all(ZennColors.gridLine),
                    trackOutlineColor: WidgetStateProperty.all(ZennColors.gridLine),
                ),
              ),
              const Divider(height: 1, indent: 56),
              // Titreşim — çalışır
              _SettingsTile(
                icon: Icons.vibration_rounded,
                label: 'Titreşim',
                trailing: Switch(
                  value: hapticEnabled,
                  onChanged: (v) =>
                      ref.read(hapticEnabledProvider.notifier).setEnabled(v),
                  activeColor: ZennColors.primary,
                ),
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.info_outlined,
                label: 'Uygulama Hakkında',
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: ZennColors.textHint),
                onTap: () => context.push(AppConstants.routeAbout),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.trailing,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: ZennColors.cardLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: ZennColors.primary),
      ),
      title: Text(label,
          style:
              ZennTextStyles.bodyMedium.copyWith(color: ZennColors.textDark)),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: ZennTextStyles.caption.copyWith(
                color: ZennColors.textHint,
                fontSize: 11,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

// ─── Giriş Yapma Ekranı ───────────────────────────────────────────────────────

class _SignInPrompt extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle_outlined,
              size: 80, color: ZennColors.textHint),
          const SizedBox(height: 16),
          Text('Giriş Yapın', style: ZennTextStyles.headline2),
          const SizedBox(height: 8),
          Text(
            'Elmas kazanmak ve istatistiklerinizi\ntakip etmek için giriş yapın.',
            style: ZennTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ZennButton(
              label: 'Google ile Giriş Yap',
              leading: const Icon(Icons.g_mobiledata,
                  color: Colors.white, size: 26),
              onTap: () => context.push(AppConstants.routeAuth),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Büyük Elmas Painter ──────────────────────────────────────────────────────

class _LargeDiamondPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width * .5, 0)
      ..lineTo(size.width, size.height * .4)
      ..lineTo(size.width * .5, size.height)
      ..lineTo(0, size.height * .4)
      ..close();
    canvas.drawPath(path, p);
    final shine = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    final sp = Path()
      ..moveTo(size.width * .5, 0)
      ..lineTo(size.width * .75, size.height * .38)
      ..lineTo(size.width * .5, size.height * .22)
      ..lineTo(size.width * .25, size.height * .38)
      ..close();
    canvas.drawPath(sp, shine);
  }

  @override
  bool shouldRepaint(_) => false;
}