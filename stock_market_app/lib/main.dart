import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:stock_market_app/View/splash.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:stock_market_app/model/wallet.dart';
import 'package:stock_market_app/services/investment_service.dart';
import 'package:stock_market_app/services/wallet_service.dart';
import 'package:stock_market_app/model/investment.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(WalletAdapter());
  Hive.registerAdapter(InvestmentAdapter());

  Wallet? existingWallet = await WalletService.getWallet();
  if (existingWallet == null) {
    Wallet newWallet = Wallet(amount: 0.0);
    await WalletService.saveWallet(newWallet);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(),
    );
  }
}
