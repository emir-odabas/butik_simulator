/// Default product categories offered out of the box.
///
/// This is a plain list (not an enum) on purpose: the spec calls for
/// letting the user add their own categories later, which is trivial
/// with a `List<String>` backed by storage but would require a data
/// migration if this were an enum.
class ProductCategories {
  ProductCategories._();

  static const List<String> defaults = [
    'Elbise',
    'Tişört',
    'Gömlek',
    'Kazak',
    'Sweatshirt',
    'Pantolon',
    'Etek',
    'Ceket',
    'Mont',
    'Ayakkabı',
    'Çanta',
    'Takı',
    'Aksesuar',
    'Diğer',
  ];
}
