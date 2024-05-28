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
}
