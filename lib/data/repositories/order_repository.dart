import '../models/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getAll();
  Future<void> add(Order order);
  Future<void> update(Order order);
}
