import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/components/clipboard_sheet.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/id_generator.dart';
import '../../../data/models/coupon.dart';
import '../application/coupon_providers.dart';

Future<void> showCouponFormSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const _CouponFormSheet(),
  );
}

class _CouponFormSheet extends ConsumerStatefulWidget {
  const _CouponFormSheet();

  @override
  ConsumerState<_CouponFormSheet> createState() => _CouponFormSheetState();
}

class _CouponFormSheetState extends ConsumerState<_CouponFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _discountController = TextEditingController(text: '10');
  final _limitController = TextEditingController(text: '100');
  bool _isSaving = false;

  @override
  void dispose() {
    _codeController.dispose();
    _discountController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final coupon = Coupon(
      id: IdGenerator.generate(),
      code: _codeController.text.trim().toUpperCase(),
      discountPercent: double.parse(_discountController.text.trim()),
      usageLimit: int.parse(_limitController.text.trim()),
      createdAt: DateTime.now(),
    );

    await ref.read(couponsProvider.notifier).addCoupon(coupon);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ClipboardSheet(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Yeni Kupon', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Kupon kodu',
                    helperText: 'Örn. WELCOME10',
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Kod gerekli' : null,
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
                TextFormField(
                  controller: _limitController,
                  decoration: const InputDecoration(labelText: 'Kullanım limiti'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Limit gerekli';
                    return int.tryParse(v.trim()) == null ? 'Geçersiz sayı' : null;
                  },
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
                        : const Text('Kuponu Oluştur'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
