import 'package:flutter/material.dart';
import 'package:rounded_background_text/rounded_background_text.dart';
import 'package:stock_market_app/model/investment.dart';
import 'package:stock_market_app/model/wallet.dart';
import 'package:stock_market_app/services/investment_service.dart';
import 'package:stock_market_app/services/wallet_service.dart';

class MostChangedBorsa extends StatelessWidget {
  final List<dynamic> mostChanged;
  final double myWidth;
  final double myHeight;

  MostChangedBorsa(
      {required this.mostChanged,
      required this.myWidth,
      required this.myHeight});

  void showInvestDialog(BuildContext context, String currencyCode) {
    String enteredAmount = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16,
              left: 16,
              right: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ne kadar $currencyCode yatırmak istersiniz?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  '$currencyCode',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Miktar',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String input) {
                    enteredAmount = input; // Store the entered amount
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    double eamount = double.tryParse(enteredAmount) ?? 0.0;
                    Wallet? wallet = await WalletService.getWallet();
                    if (wallet != null) {
                      if (wallet.amount > eamount) {
                        if (eamount > 0) {
                          final investment = Investment(
                              currencyCode: currencyCode,
                              amount: eamount,
                              timestamp: DateTime.now(),
                              investmentStock: 3);
                          await InvestmentService()
                              .addInvestment(currencyCode, eamount, 3);
                          wallet.amount -= eamount;
                          await WalletService.saveWallet(wallet);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Text(
                                '${currencyCode}a yatırılan Para: ${eamount.toStringAsFixed(2)} ₺',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                'Geçerli bir miktar giriniz.',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      } else {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              'Cüzdanınızda yeterli bakiye yok.',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  child: Text('Onayla'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: myWidth,
      height: myHeight * 0.2, // En çok değişen ilk dört altın için ayrılan alan
      margin: EdgeInsets.symmetric(vertical: 1), // Kenar boşluğu ekleme
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          mostChanged.isEmpty
              ? Text(
                  '',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              : Text(
                  'En Fazla Değişen Borsa',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
          Expanded(
            child: mostChanged.isEmpty
                ? Center(
                    child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: mostChanged.length,
                    itemBuilder: (context, index) {
                      var item = mostChanged[index];
                      return InkWell(
                        onTap: () => {
                          showInvestDialog(
                            context,
                            item['name'],
                          )
                        },
                        child: Container(
                          width: myWidth * 0.5,
                          padding: EdgeInsets.all(1),
                          child: Card(
                            color: Color.fromARGB(255, 23, 23, 23),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  item['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8),
                                RoundedBackgroundText(
                                  'Değişim: ${item['Degisim']}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    backgroundColor: item['degisim'] < 0
                                        ? Colors.red
                                        : Colors.green,
                                    color: Colors.white,
                                  ),
                                  innerRadius: 15.0,
                                  outerRadius: 10.0,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Fiyat: ${item['Fiyat']} ₺',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
