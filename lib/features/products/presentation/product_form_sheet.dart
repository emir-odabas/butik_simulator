import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/product_categories.dart';
import '../../../core/design/atelier_colors.dart';
import '../../../core/design/components/clipboard_sheet.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/id_generator.dart';
import '../../../data/models/product.dart';
import '../application/product_providers.dart';

/// Opens the add/edit product form as a scrollable modal bottom sheet.
/// Pass an existing [product] to edit it; omit it to create a new one.
Future<void> showProductFormSheet(BuildContext context, {Product? product}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _ProductFormSheet(product: product),
  );
}

class _ProductFormSheet extends ConsumerStatefulWidget {
  const _ProductFormSheet({this.product});

  final Product? product;

  @override
  ConsumerState<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends ConsumerState<_ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _discountController;
  late final TextEditingController _stockController;
  late final TextEditingController _imageUrlController;

  late String _category;
  late bool _isNew;
  late bool _isFeatured;

  bool _isSaving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(text: p != null ? p.price.toStringAsFixed(0) : '');
    _discountController = TextEditingController(
      text: p?.discountPrice != null ? p!.discountPrice!.toStringAsFixed(0) : '',
    );
    _stockController = TextEditingController(text: p != null ? p.stock.toString() : '');
    _imageUrlController = TextEditingController(text: p?.primaryImage ?? '');
    _category = p?.category ?? ProductCategories.defaults.first;
    _isNew = p?.isNew ?? false;
    _isFeatured = p?.isFeatured ?? false;
    _imageUrlController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageUrlController.text = image.path;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final imageUrl = _imageUrlController.text.trim();
    final discountText = _discountController.text.trim();

    final notifier = ref.read(productsProvider.notifier);

    if (_isEditing) {
      final updated = widget.product!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        price: double.parse(_priceController.text.trim()),
        discountPrice: discountText.isEmpty ? null : double.tryParse(discountText),
        clearDiscount: discountText.isEmpty,
        stock: int.parse(_stockController.text.trim()),
        images: imageUrl.isEmpty ? const [] : [imageUrl],
        isNew: _isNew,
        isFeatured: _isFeatured,
      );
      await notifier.updateProduct(updated);
    } else {
      final newProduct = Product(
        id: IdGenerator.generate(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        price: double.parse(_priceController.text.trim()),
        discountPrice: discountText.isEmpty ? null : double.tryParse(discountText),
        stock: int.parse(_stockController.text.trim()),
        images: imageUrl.isEmpty ? const [] : [imageUrl],
        isNew: _isNew,
        isFeatured: _isFeatured,
        createdAt: DateTime.now(),
      );
      await notifier.addProduct(newProduct);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final atelier = Theme.of(context).extension<AtelierColors>() ?? AtelierColors.light;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.96,
        expand: false,
        builder: (context, scrollController) {
          return ClipboardSheet(
            expand: true,
            child: Form(
              key: _formKey,
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                children: [
                  Text(
                    _isEditing ? 'Ürünü Düzenle' : 'Yeni Ürün',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Ürün adı'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Ürün adı gerekli' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Açıklama'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: [
                      for (final c in ProductCategories.defaults)
                        DropdownMenuItem(value: c, child: Text(c)),
                    ],
                    onChanged: (value) => setState(() => _category = value!),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(labelText: 'Fiyat (₺)'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Fiyat gerekli';
                            if (double.tryParse(v.trim()) == null) return 'Geçersiz fiyat';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: TextFormField(
                          controller: _discountController,
                          decoration: const InputDecoration(labelText: 'İndirimli (opsiyonel)'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            return double.tryParse(v.trim()) == null ? 'Geçersiz fiyat' : null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(labelText: 'Stok adedi'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Stok gerekli';
                      return int.tryParse(v.trim()) == null ? 'Geçersiz stok' : null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'FOTOĞRAFI İĞNELE',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: atelier.inkMuted,
                          letterSpacing: 1.8,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GestureDetector(
                    onTap: _pickImage,
                    child: _PhotoPinSlot(url: _imageUrlController.text.trim(), atelier: atelier),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Görsel URL veya Dosya Yolu',
                      helperText: 'Galeriden seçmek için yukarıdaki pin alanına tıklayın.',
                    ),
                    keyboardType: TextInputType.url,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final isWeb = v.trim().startsWith('http');
                      if (isWeb) return null;
                      if (File(v.trim()).existsSync()) return null;
                      return 'Geçersiz URL veya dosya yolu';
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Yeni ürün olarak işaretle'),
                    value: _isNew,
                    onChanged: (v) => setState(() => _isNew = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Öne çıkan ürün olarak işaretle'),
                    value: _isFeatured,
                    onChanged: (v) => setState(() => _isFeatured = v),
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
                          : Text(_isEditing ? 'Kaydet' : 'Ürünü Ekle'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A small square "pinned photo" preview: shows the image at the
/// current URL once it's a valid absolute URL, otherwise a placeholder
/// with a pin icon in the corner.
class _PhotoPinSlot extends StatelessWidget {
  const _PhotoPinSlot({required this.url, required this.atelier});

  final String url;
  final AtelierColors atelier;

  @override
  Widget build(BuildContext context) {
    final isNetwork = url.startsWith('http://') || url.startsWith('https://');
    final hasValidUrl = url.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: atelier.paper,
            border: Border.all(color: atelier.hairline),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasValidUrl
              ? (isNetwork
                  ? Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.broken_image_outlined, color: atelier.inkMuted),
                    )
                  : Image.file(
                      File(url),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.broken_image_outlined, color: atelier.inkMuted),
                    ))
              : Icon(Icons.add_photo_alternate_outlined, color: atelier.inkMuted),
        ),
        Positioned(
          top: -6,
          left: 34,
          child: Icon(Icons.push_pin, size: 18, color: atelier.seal),
        ),
      ],
    );
  }
}
