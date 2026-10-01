import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/id_generator.dart';
import '../../../data/models/campaign.dart';
import '../application/campaign_providers.dart';

Future<void> showCampaignFormSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const _CampaignFormSheet(),
  );
}

class _CampaignFormSheet extends ConsumerStatefulWidget {
  const _CampaignFormSheet();

  @override
  ConsumerState<_CampaignFormSheet> createState() => _CampaignFormSheetState();
}

class _CampaignFormSheetState extends ConsumerState<_CampaignFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountController = TextEditingController(text: '10');

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitiş tarihi başlangıçtan önce olamaz')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final campaign = Campaign(
      id: IdGenerator.generate(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      discountPercent: double.parse(_discountController.text.trim()),
      startDate: _startDate,
      endDate: _endDate,
    );

    await ref.read(campaignsProvider.notifier).addCampaign(campaign);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormatShort();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              children: [
                Text('Yeni Kampanya', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Kampanya adı'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ad gerekli' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Açıklama'),
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _discountController,
                  decoration: const InputDecoration(labelText: 'İndirim oranı (%)'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'İndirim oranı gerekli';
                    final value = double.tryParse(v.trim());
                    if (value == null || value <= 0 || value > 90) return 'Geçersiz oran (1-90)';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(isStart: true),
                        child: Text('Başlangıç: ${dateFormat.format(_startDate)}'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(isStart: false),
                        child: Text('Bitiş: ${dateFormat.format(_endDate)}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Kampanyayı Oluştur'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Tiny locale-independent "d/M/yyyy" formatter so this form doesn't need
/// the tr_TR date-symbol data just to show two picked dates.
class DateFormatShort {
  String format(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
