// lib/screens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../core/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZennColors.background,
      appBar: AppBar(
        title: const Text('Uygulama Hakkında'),
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
              title: 'Destek',
              children: [
                _AboutTile(
                  icon: Icons.mail_outline_rounded,
                  label: 'Destek E-postası',
                  subtitle: 'hello@zennappstudio.com',
                  onTap: () => _copyToClipboard(
                    context,
                    'hello@zennappstudio.com',
                    'E-posta adresi kopyalandı',
                  ),
                  trailing: const Icon(Icons.copy_rounded,
                      size: 16, color: ZennColors.textHint),
                ),
                const Divider(height: 1, indent: 52),
                _AboutTile(
                  icon: Icons.star_outline_rounded,
                  label: 'Uygulamayı Puanla',
                  subtitle: 'Google Play\'de değerlendir',
                  onTap: () => _copyToClipboard(
                    context,
                    'com.zennappstudio.zenn_sudoku',
                    'Paket adı kopyalandı',
                  ),
                  trailing: const Icon(Icons.open_in_new_rounded,
                      size: 16, color: ZennColors.textHint),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Yasal ────────────────────────────────────────────────────
            _SectionCard(
              title: 'Yasal',
              children: [
                _AboutTile(
                  icon: Icons.shield_outlined,
                  label: 'Gizlilik Politikası',
                  onTap: () => _showLegalModal(
                    context,
                    title: 'Gizlilik Politikası',
                    content: _privacyPolicy,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: ZennColors.textHint),
                ),
                const Divider(height: 1, indent: 52),
                _AboutTile(
                  icon: Icons.description_outlined,
                  label: 'Kullanım Koşulları',
                  onTap: () => _showLegalModal(
                    context,
                    title: 'Kullanım Koşulları',
                    content: _termsOfUse,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: ZennColors.textHint),
                ),
                const Divider(height: 1, indent: 52),
                _AboutTile(
                  icon: Icons.code_rounded,
                  label: 'Açık Kaynak Lisansları',
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: AppConstants.appName,
                    applicationVersion: '1.0.0',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: ZennColors.textHint),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Alt bilgi ────────────────────────────────────────────────
            Text(
              'Sürüm 1.0.0',
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

  void _copyToClipboard(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: ZennColors.primary,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        const Text(
          AppConstants.appName,
          style: ZennTextStyles.headline2,
        ),
        const SizedBox(height: 4),
        Text(
          AppConstants.studio,
          style: ZennTextStyles.caption,
        ),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

// ─── Gizlilik Politikası metni ────────────────────────────────────────────────

const _privacyPolicy = '''
Son güncelleme: Mayıs 2026

Zenn App Studio olarak gizliliğinizi ciddiye alıyoruz. Bu politika, ZeNN Sudoku uygulamasının hangi verileri topladığını ve nasıl kullandığını açıklamaktadır.

1. Toplanan Veriler

Uygulamamız aşağıdaki verileri toplar:

• Hesap bilgileri: Google ile giriş yaptığınızda adınız, e-posta adresiniz ve profil fotoğrafınız Supabase altyapımızda saklanır.
• Oyun verileri: Tamamladığınız bulmacalar, kazandığınız elmaslar ve oyun istatistikleriniz hesabınıza bağlı olarak kaydedilir.
• Cihaz verileri: Uygulama performansı için anonim kullanım istatistikleri toplanabilir.

2. Verilerin Kullanımı

Toplanan veriler yalnızca şu amaçlarla kullanılır:

• Oyun ilerlemenizi ve istatistiklerinizi kaydetmek
• Liderboard gibi sosyal özellikleri sunmak
• Uygulama deneyimini iyileştirmek

Verileriniz üçüncü taraflarla paylaşılmaz, reklam amaçlı kullanılmaz veya satılmaz.

3. Veri Güvenliği

Verileriniz Supabase altyapısında güvenli biçimde saklanmakta ve SSL/TLS şifreleme ile korunmaktadır.

4. Veri Silme

Hesabınızı ve tüm verilerinizi silmek için hello@zennappstudio.com adresine e-posta gönderebilirsiniz. Talebiniz 30 gün içinde işleme alınır.

5. İletişim

Gizlilik politikamız hakkında sorularınız için:
hello@zennappstudio.com


''';

// ─── Kullanım Koşulları metni ─────────────────────────────────────────────────

const _termsOfUse = '''
Son güncelleme: Mayıs 2026

ZeNN Sudoku uygulamasını kullanarak aşağıdaki koşulları kabul etmiş sayılırsınız.

1. Uygulamanın Kullanımı

ZeNN Sudoku kişisel ve eğlence amaçlı kullanım için sunulmaktadır. Uygulamayı yasa dışı amaçlarla veya başkalarına zarar verecek şekilde kullanamazsınız.

2. Hesap

Google hesabınızla giriş yaparak oluşturduğunuz profil size aittir. Hesabınızın güvenliğinden siz sorumlusunuz. Hesabınızı başkalarıyla paylaşmamanızı öneririz.

3. Elmas Sistemi

Uygulama içindeki elmaslar yalnızca uygulama içi değere sahiptir; gerçek para karşılığı nakde çevrilemez veya transfer edilemez. Zenn App Studio, elmas sisteminde değişiklik yapma hakkını saklı tutar.

4. Güncellemeler

Uygulamayı ve bu koşulları önceden bildirmeksizin güncelleme hakkımızı saklı tutarız. Güncellemeden sonra uygulamayı kullanmaya devam etmeniz yeni koşulları kabul ettiğiniz anlamına gelir.

5. Sorumluluk Sınırı

Zenn App Studio, uygulama kesintileri, veri kayıpları veya beklenmedik hatalardan doğan zararlardan sorumlu tutulamaz. Uygulama "olduğu gibi" sunulmaktadır.

6. İletişim

Kullanım koşullarına ilişkin sorularınız için:
hello@zennappstudio.com


''';
