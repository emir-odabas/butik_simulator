import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/atelier_colors.dart';
import '../../../core/design/atelier_typography.dart';
import '../../../core/design/components/ledger_page.dart';
import '../../../core/design/components/ledger_row.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/money.dart';
import '../../../data/models/store_profile.dart';
import '../../campaigns/presentation/campaigns_screen.dart';
import '../../coupons/presentation/coupons_screen.dart';
import '../../statistics/presentation/statistics_screen.dart';
import '../../storefront/presentation/storefront_screen.dart';
import '../application/store_providers.dart';
import 'widgets/store_upgrades_section.dart';

/// The owner's workbench: store identity as letterhead, the renovation
/// checklist, and the way into the other notebooks (campaigns, coupons,
/// statistics) — not a settings screen. No `Card` anywhere on this page;
/// see `store_upgrades_section.dart` for the checklist and the
/// campaigns/coupons/statistics screens for the rest of the cluster.
class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(storeProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mağazam'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const StorefrontScreen()),
            ),
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Görüntüle'),
          ),
        ],
      ),
      body: LedgerPage(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text('Mağaza bilgileri yüklenemedi: $error'),
            ),
          ),
          data: (profile) => _WorkbenchPage(key: ValueKey(profile.id), profile: profile),
        ),
      ),
    );
  }
}

class _WorkbenchPage extends ConsumerStatefulWidget {
  const _WorkbenchPage({super.key, required this.profile});

  final StoreProfile profile;

  @override
  ConsumerState<_WorkbenchPage> createState() => _WorkbenchPageState();
}

class _WorkbenchPageState extends ConsumerState<_WorkbenchPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _logoController;
  bool _isSaving = false;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name)..addListener(_markDirty);
    _descriptionController = TextEditingController(text: widget.profile.description)
      ..addListener(_markDirty);
    _logoController = TextEditingController(text: widget.profile.logoUrl ?? '')
      ..addListener(_markDirty);
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final logo = _logoController.text.trim();
    final updated = widget.profile.copyWith(
      name: _nameController.text.trim().isEmpty ? widget.profile.name : _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      logoUrl: logo,
      clearLogo: logo.isEmpty,
    );
    await ref.read(storeProfileProvider.notifier).updateProfile(updated);
    if (mounted) {
      setState(() {
        _isSaving = false;
        _isDirty = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Antetli kağıt güncellendi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atelier = theme.extension<AtelierColors>() ?? AtelierColors.light;

    final underline = theme.inputDecorationTheme.copyWith(
      filled: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      border: UnderlineInputBorder(borderSide: BorderSide(color: atelier.hairline)),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: atelier.hairline)),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: atelier.seal, width: 1.6)),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        // --- Letterhead ---------------------------------------------
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LogoCircle(url: _logoController.text.trim(), name: _nameController.text),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.profile.level}. BÖLÜM — ATÖLYENİN GELİŞİMİ',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: atelier.inkMuted,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Theme(
                    data: theme.copyWith(inputDecorationTheme: underline),
                    child: TextField(
                      controller: _nameController,
                      style: theme.textTheme.headlineSmall,
                      decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Theme(
          data: theme.copyWith(inputDecorationTheme: underline),
          child: TextField(
            controller: _descriptionController,
            maxLines: 2,
            style: theme.textTheme.bodyMedium,
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'Mağazanı bir cümleyle tanıt…',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Theme(
          data: theme.copyWith(inputDecorationTheme: underline),
          child: TextField(
            controller: _logoController,
            keyboardType: TextInputType.url,
            style: theme.textTheme.bodySmall,
            decoration: const InputDecoration(isDense: true, labelText: 'Logo görsel URL (opsiyonel)'),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 15, color: atelier.inkMuted),
            const SizedBox(width: 6),
            Text(
              '${Money.format(widget.profile.virtualBalance)} sanal bakiye',
              style: AtelierTypography.ledger(color: atelier.ink, fontSize: 13),
            ),
            const Spacer(),
            if (_isDirty)
              TextButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Kaydet'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // --- Renovation checklist ------------------------------------
        const StoreUpgradesSection(),
        const SizedBox(height: AppSpacing.xl),

        // --- Other notebooks ------------------------------------------
        Text(
          'DİĞER DEFTERLER',
          style: theme.textTheme.labelMedium?.copyWith(
            color: atelier.inkMuted,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        LedgerRow(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CampaignsScreen()),
          ),
          child: _NotebookLink(icon: Icons.push_pin_outlined, label: 'Kampanyalar'),
        ),
        LedgerRow(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CouponsScreen()),
          ),
          child: _NotebookLink(icon: Icons.confirmation_number_outlined, label: 'Kuponlar'),
        ),
        LedgerRow(
          showDivider: false,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const StatisticsScreen()),
          ),
          child: _NotebookLink(icon: Icons.auto_stories_outlined, label: 'Satış Notları'),
        ),
      ],
    );
  }
}

class _LogoCircle extends StatelessWidget {
  const _LogoCircle({required this.url, required this.name});

  final String url;
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atelier = theme.extension<AtelierColors>() ?? AtelierColors.light;
    final uri = Uri.tryParse(url);
    final hasValidUrl = url.isNotEmpty && uri != null && uri.isAbsolute;

    Widget monogram() => Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '•',
            style: theme.textTheme.titleLarge?.copyWith(color: atelier.ink),
          ),
        );

    return Container(
      width: 52,
      height: 52,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: atelier.paperSurface,
        shape: BoxShape.circle,
        border: Border.all(color: atelier.hairline),
      ),
      child: hasValidUrl
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => monogram(),
            )
          : monogram(),
    );
  }
}

class _NotebookLink extends StatelessWidget {
  const _NotebookLink({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atelier = theme.extension<AtelierColors>() ?? AtelierColors.light;

    return Row(
      children: [
        Icon(icon, size: 19, color: atelier.ink),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
        Icon(Icons.chevron_right, size: 18, color: atelier.inkMuted),
      ],
    );
  }
}
