import 'dart:collection';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stock_market_app/View/widgets/mostValueCurrencies.dart';
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
  TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  List<String> mostUsedCurrencies = ["USD", "EUR", "GBP"];
  List<MapEntry<String, num>> mostUsed = [];

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
          mostUsed = _exchangeRates.entries
              .where((element) => mostUsedCurrencies.contains(element.key))
              .toList();
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
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _parseDegisim(String fiyat) {
    return double.parse(fiyat.replaceAll(',', '.').trim());
  }

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    double myWidth = MediaQuery.of(context).size.width;

    List<MapEntry<String, num>> sorted = _exchangeRates.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    List<MapEntry<String, num>> highestTop5 = sorted.reversed.take(5).toList();

    List<MapEntry<String, num>> filteredRates = _exchangeRates.entries
        .where((entry) =>
            entry.key.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
          width: myWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.fromARGB(255, 255, 255, 255), Colors.white],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MostValualeCurrencies(
                  mostUsed: mostUsed,
                  mostChanged: highestTop5,
                  myWidth: myWidth,
                  myHeight: myHeight),
              Expanded(
                child: Container(
                  width: myWidth,
                  height: myHeight * 0.7,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          itemCount: filteredRates.length,
                          itemBuilder: (context, index) {
                            var currencyCode = filteredRates[index].key;
                            var value = ((1 / filteredRates[index].value) * 1)
                                .toStringAsFixed(4);
                            ;
                            return Card(
                              margin: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 2),
                              color: Color.fromARGB(255, 23, 23, 23),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$currencyCode',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      '$value',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
