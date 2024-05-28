import 'package:flutter/material.dart';
import 'package:stock_market_app/model/wallet.dart';
import 'package:hive/hive.dart';
import 'package:stock_market_app/services/wallet_service.dart';

class AddMoneyPage extends StatefulWidget {
  const AddMoneyPage({Key? key}) : super(key: key);

  @override
  _AddMoneyPageState createState() => _AddMoneyPageState();
}

class _AddMoneyPageState extends State<AddMoneyPage> {
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white, // Change this to your desired color
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'PARA YÜKLE',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.black,
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey, Colors.white],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Miktar',
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    double amount =
                        double.tryParse(_amountController.text) ?? 0.0;
                    _addMoneyToWallet(amount);
                  },
                  child: Text('Para Yükle'),
                ),
              ],
            ),
          ),
        ));
  }

  Future<double?> load() async {
    var box = await Hive.openBox<Wallet>(WalletService.walletBoxName);
    Wallet? wallet = box.get('wallet');
    if (wallet != null) {
      return wallet.amount;
    }
    return null;
  }

  Future<void> _addMoneyToWallet(double amount) async {
    Wallet? wallet = await WalletService.getWallet();
    if (wallet != null) {
      wallet.amount += amount;
      await WalletService.saveWallet(wallet);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Yatırılan Para: \$${amount.toStringAsFixed(2)} Mevuct Para : ${wallet.amount}  ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
