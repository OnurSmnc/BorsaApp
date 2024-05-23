import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:stock_market_app/utils/currencyKey.dart';

class CurrencyExchange extends StatefulWidget {
  const CurrencyExchange({super.key});

  @override
  State<CurrencyExchange> createState() => _CurrencyExchangeState();
}

class _CurrencyExchangeState extends State<CurrencyExchange> {
  late Map<String, num> _exchangeRates = {};
  bool _isLoading = true;

  Future<void> _getData() async {
    final response = await http
        .get(Uri.parse('https://v6.exchangerate-api.com/v6/${key}/latest/TRY'));
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['result'] == 'success' &&
          responseData['conversion_rates'] is Map) {
        setState(() {
          _exchangeRates =
              Map<String, num>.from(responseData['conversion_rates']);
          _isLoading = false;
        });
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    double myWidht = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DÖVİZ',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Container(
        height: myHeight,
        width: myWidht,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey, Colors.white]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: myWidht,
              height: myHeight * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: _exchangeRates.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      itemCount: _exchangeRates.length,
                      itemBuilder: (context, index) {
                        var currencyCode = _exchangeRates.keys.toList()[index];
                        var value = _exchangeRates.values.toList()[index];
                        return Card(
                          margin:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                          color: Color.fromARGB(255, 23, 23, 23),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$currencyCode',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  '$value',
                                  style: TextStyle(color: Colors.white),
                                )
                                // Add spacing between title and subtitle
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
