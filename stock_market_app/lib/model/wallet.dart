import 'package:hive/hive.dart';

part 'wallet.g.dart';

@HiveType(typeId: 1)
class Wallet {
  Wallet({required this.amount});
  @HiveField(0)
  double amount;
}
