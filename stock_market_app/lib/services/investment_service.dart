import 'package:hive/hive.dart';
import 'package:stock_market_app/model/investment.dart';
import 'package:stock_market_app/services/wallet_service.dart';

class InvestmentService {
  static const String investmentBoxName = 'investments';

  Future<void> addInvestment(
      String currencyCode, double amount, int investmentStock) async {
    var box = await Hive.openBox<Investment>(investmentBoxName);
    final investment = Investment(
        currencyCode: currencyCode,
        amount: amount,
        timestamp: DateTime.now(),
        investmentStock: investmentStock);
    await box.add(investment);
  }

  Future<List<Investment>> getInvestments() async {
    var box = await Hive.openBox<Investment>(investmentBoxName);
    if (box != null && box.isNotEmpty) {
      return box.values.toList();
    } else {
      return [];
    }
  }

  Future<bool> withdrawInvestment(String currencyCode) async {
    var box = await Hive.openBox<Investment>(investmentBoxName);
    print('All investments: ${box.values}');
    var investmentList = await box.values.toList();
    var investment = investmentList
        .firstWhere((element) => element.currencyCode == currencyCode);
    if (investment != null) {
      await box.delete(investment.key);

      var wallet = await WalletService.getWallet();
      if (wallet != null) {
        
        wallet.amount += investment.amount;
        await WalletService.saveWallet(wallet);
      } else {}

      return true;
    }
    print('Investment with currency code $currencyCode not found.');
    return false;
  }
}
