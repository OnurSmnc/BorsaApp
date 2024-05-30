import 'package:flutter/material.dart';
import 'package:rounded_background_text/rounded_background_text.dart';
import 'package:stock_market_app/View/widgets/investmentsAdd/addGoldInvestment.dart';
import 'package:stock_market_app/model/investment.dart';
import 'package:stock_market_app/model/wallet.dart';
import 'package:stock_market_app/services/investment_service.dart';
import 'package:stock_market_app/services/wallet_service.dart';

class MostChanged extends StatelessWidget {
  final List<dynamic> mostChanged;
  final double myWidth;
  final double myHeight;

  MostChanged({
    required this.mostChanged,
    required this.myWidth,
    required this.myHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: myWidth,
      height: myHeight * 0.2, // En çok değişen ilk dört altın için ayrılan alan
      margin: EdgeInsets.symmetric(vertical: 1),
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
                  'En Çok Değişen Altın',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
          Expanded(
            child: mostChanged.isEmpty
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: mostChanged.length,
                    itemBuilder: (context, index) {
                      var item = mostChanged[index];
                      double? amountNullable = double.tryParse(
                          item['Alis'].replaceAll(RegExp(r'[^0-9.]'), ''));
                      double amount = amountNullable ?? 0.0;
                      return InkWell(
                        onTap: () =>
                            showInvestDialog(context, item['name'], amount),
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
                                  'Alış: ${item['Alis']}',
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.white),
                                ),
                                Text(
                                  'Satış: ${item['Satis']}',
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
