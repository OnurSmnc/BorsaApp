import 'package:hive/hive.dart';
import 'package:stock_market_app/model/wallet.dart';

class WalletService {
  static const String walletBoxName = 'walletBox';

  static Future<Wallet?> getWallet() async {
    var walletBox = await Hive.openBox<Wallet>(walletBoxName);
    return walletBox.get(0);
  }

  static Future<void> saveWallet(Wallet wallet) async {
    var walletBox = await Hive.openBox<Wallet>(walletBoxName);
    await walletBox.put(0, wallet);
  }

  Future<bool> addToWallet(double amount) async {
    var walletBox = await Hive.openBox<Wallet>(walletBoxName);
    Wallet wallet = walletBox.get(0) ?? Wallet(amount: 0.0);
    wallet.amount += amount;
    await WalletService.saveWallet(wallet);
    return true;
  }
}
