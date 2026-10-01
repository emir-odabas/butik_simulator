import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/models/store_profile.dart';
import '../../campaigns/presentation/campaigns_screen.dart';
import '../../coupons/presentation/coupons_screen.dart';
import '../../statistics/presentation/statistics_screen.dart';
import '../../storefront/presentation/storefront_screen.dart';
import '../application/store_providers.dart';
import 'widgets/store_upgrades_section.dart';

/// Store identity settings, the virtual-economy upgrade shop, and a
/// management hub (campaigns, coupons, statistics) plus the entry point
/// into the customer-facing storefront preview.
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
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text('Mağaza bilgileri yüklenemedi: $error'),
          ),
        ),
        data: (profile) => _StoreForm(key: ValueKey(profile.id), profile: profile),
      ),
    );
  }
}

class _StoreForm extends ConsumerStatefulWidget {
  const _StoreForm({super.key, required this.profile});

  final StoreProfile profile;

  @override
  ConsumerState<_StoreForm> createState() => _StoreFormState();
}

class _StoreFormState extends ConsumerState<_StoreForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _logoController;
  bool _isSaving = false;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name)
      ..addListener(_markDirty);
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
        const SnackBar(content: Text('Mağaza bilgileri güncellendi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Center(
          child: CircleAvatar(
            radius: 44,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            backgroundImage: _logoController.text.trim().isNotEmpty
                ? NetworkImage(_logoController.text.trim())
                : null,
            child: _logoController.text.trim().isEmpty
                ? Icon(Icons.storefront_outlined, size: 36, color: theme.colorScheme.primary)
                : null,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Butik adı'),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(labelText: 'Mağaza açıklaması'),
          maxLines: 3,
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _logoController,
          decoration: const InputDecoration(
            labelText: 'Logo görsel URL (opsiyonel)',
          ),
          keyboardType: TextInputType.url,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: (_isDirty && !_isSaving) ? _save : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Kaydet'),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const StoreUpgradesSection(),
        const SizedBox(height: AppSpacing.lg),
        Text('Yönetim', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _ManagementTile(
                icon: Icons.local_offer_outlined,
                title: 'Kampanyalar',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CampaignsScreen()),
                ),
              ),
              const Divider(height: 1),
              _ManagementTile(
                icon: Icons.confirmation_number_outlined,
                title: 'Kuponlar',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CouponsScreen()),
                ),
              ),
              const Divider(height: 1),
              _ManagementTile(
                icon: Icons.bar_chart_outlined,
                title: 'İstatistikler',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const StatisticsScreen()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ManagementTile extends StatelessWidget {
  const _ManagementTile({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
