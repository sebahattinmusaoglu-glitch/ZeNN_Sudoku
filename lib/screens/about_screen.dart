// lib/screens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../core/l10n.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = strings(context);
    return Scaffold(
      backgroundColor: ZennColors.background,
      appBar: AppBar(
        title: Text(s.aboutTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── Logo + isim + versiyon ───────────────────────────────────
            const _AppHeader(),
            const SizedBox(height: 32),

            // ── Destek ──────────────────────────────────────────────────
            _SectionCard(
              title: s.aboutSupport,
              children: [
                _AboutTile(
                  icon: Icons.mail_outline_rounded,
                  label: s.aboutSupportEmail,
                  subtitle: AppConstants.supportEmail,
                  onTap: () => _copyToClipboard(
                    context,
                    AppConstants.supportEmail,
                    s.aboutSupportEmailCopied,
                  ),
                  trailing: const Icon(Icons.copy_rounded,
                      size: 16, color: ZennColors.textHint),
                ),
                const Divider(height: 1, indent: 52),
                _AboutTile(
                  icon: Icons.star_outline_rounded,
                  label: s.aboutRateApp,
                  subtitle: s.aboutRateOnPlay,
                  onTap: () => _copyToClipboard(
                    context,
                    AppConstants.packageName,
                    s.aboutPackageCopied,
                  ),
                  trailing: const Icon(Icons.open_in_new_rounded,
                      size: 16, color: ZennColors.textHint),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Yasal ────────────────────────────────────────────────────
            _SectionCard(
              title: s.aboutLegal,
              children: [
                _AboutTile(
                  icon: Icons.shield_outlined,
                  label: s.aboutPrivacyPolicy,
                  onTap: () => _showLegalModal(
                    context,
                    title: s.aboutPrivacyPolicy,
                    content: s.privacyPolicyContent,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: ZennColors.textHint),
                ),
                const Divider(height: 1, indent: 52),
                _AboutTile(
                  icon: Icons.description_outlined,
                  label: s.aboutTerms,
                  onTap: () => _showLegalModal(
                    context,
                    title: s.aboutTerms,
                    content: s.termsContent,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: ZennColors.textHint),
                ),
                const Divider(height: 1, indent: 52),
                _AboutTile(
                  icon: Icons.code_rounded,
                  label: s.aboutOpenSource,
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: AppConstants.appName,
                    applicationVersion: AppConstants.appVersion,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: ZennColors.textHint),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Alt bilgi ────────────────────────────────────────────────
            Text(
              s.aboutVersion.replaceFirst('{v}', AppConstants.appVersion),
              style: ZennTextStyles.caption,
            ),
            const SizedBox(height: 4),
            Text(
              '© 2025 ${AppConstants.studio}',
              style: ZennTextStyles.caption,
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(
      BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: ZennColors.primary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLegalModal(BuildContext context,
      {required String title, required String content}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LegalModal(title: title, content: content),
    );
  }
}

// ─── Uygulama Header ─────────────────────────────────────────────────────────

class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(
          'assets/icons/logo.svg',
          width: 120,
          height: 120,
        ),
        const SizedBox(height: 12),
        const Text(AppConstants.appName, style: ZennTextStyles.headline2),
        const SizedBox(height: 4),
        Text(AppConstants.studio, style: ZennTextStyles.caption),
      ],
    );
  }
}

// ─── Bölüm Kartı ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ZennTextStyles.headline3),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: ZennColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ZennColors.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

// ─── Hakkında Tile ───────────────────────────────────────────────────────────

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback onTap;

  const _AboutTile({
    required this.icon,
    required this.label,
    required this.trailing,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: ZennColors.cardLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: ZennColors.primary),
      ),
      title: Text(
        label,
        style: ZennTextStyles.bodyMedium.copyWith(color: ZennColors.textDark),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: ZennTextStyles.caption)
          : null,
      trailing: trailing,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

// ─── Yasal Modal ─────────────────────────────────────────────────────────────

class _LegalModal extends StatelessWidget {
  final String title;
  final String content;

  const _LegalModal({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Tutma çubuğu
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ZennColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Başlık
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Text(title, style: ZennTextStyles.headline3),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: ZennColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: ZennColors.textMid),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // İçerik
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Text(
                content,
                style: ZennTextStyles.body.copyWith(height: 1.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}