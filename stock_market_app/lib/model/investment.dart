import 'package:hive/hive.dart';

part 'investment.g.dart';

@HiveType(typeId: 2)
class Investment extends HiveObject {
  @HiveField(0)
  String currencyCode;

  @HiveField(1)
  double amount;

  @HiveField(2)
  DateTime timestamp;
  @HiveField(3)
  var investmentStock;

  Investment(
      {required this.currencyCode,
      required this.amount,
      required this.timestamp,
      required this.investmentStock});
}
