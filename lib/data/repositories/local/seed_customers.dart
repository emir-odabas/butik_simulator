import '../../models/customer.dart';

List<Customer> buildSeedCustomers() {
  final now = DateTime.now();
  DateTime daysAgo(int d) => now.subtract(Duration(days: d));

  return [
    Customer(
      id: 'cust-elif',
      name: 'Elif',
      avatarUrl: 'https://i.pravatar.cc/150?img=47',
      totalSpent: 1240,
      preferredCategories: const ['Elbise', 'Takı'],
      joinedAt: daysAgo(90),
    ),
    Customer(
      id: 'cust-zeynep',
      name: 'Zeynep',
      avatarUrl: 'https://i.pravatar.cc/150?img=32',
      totalSpent: 860,
      preferredCategories: const ['Ceket', 'Pantolon'],
      joinedAt: daysAgo(60),
    ),
    Customer(
      id: 'cust-ece',
      name: 'Ece',
      avatarUrl: 'https://i.pravatar.cc/150?img=25',
      totalSpent: 2110,
      preferredCategories: const ['Çanta', 'Ayakkabı'],
      joinedAt: daysAgo(120),
    ),
    Customer(
      id: 'cust-duru',
      name: 'Duru',
      avatarUrl: 'https://i.pravatar.cc/150?img=19',
      totalSpent: 430,
      preferredCategories: const ['Kazak'],
      joinedAt: daysAgo(15),
    ),
    Customer(
      id: 'cust-irem',
      name: 'İrem',
      avatarUrl: 'https://i.pravatar.cc/150?img=41',
      totalSpent: 1580,
      preferredCategories: const ['Elbise', 'Etek'],
      joinedAt: daysAgo(45),
    ),
    Customer(
      id: 'cust-buse',
      name: 'Buse',
      avatarUrl: 'https://i.pravatar.cc/150?img=36',
      totalSpent: 690,
      preferredCategories: const ['Aksesuar', 'Takı'],
      joinedAt: daysAgo(30),
    ),
  ];
}
