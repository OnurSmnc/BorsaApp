import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rounded_background_text/rounded_background_text.dart';
import 'package:stock_market_app/View/addMonetWallet.dart';
import 'package:stock_market_app/View/widgets/mostChangedBorsa.dart';
import 'package:hive/hive.dart';
import 'package:stock_market_app/model/wallet.dart';
import 'package:stock_market_app/services/wallet_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List<dynamic> _data = [];
  late double _walletAmount = 0.0;
  Future<void> _getData() async {
    final response =
        await http.get(Uri.parse('https://doviz-api.onrender.com/api/borsa50'));
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success'] == true && responseData['data'] is List) {
        setState(() {
          _data = responseData['data'];
        });
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  void showInvestDialog(
      BuildContext context, String currencyCode, double value) {
    String enteredAmount =
        ''; // Kullanıcının girdiği miktarı saklamak için bir değişken

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ne kadar $currencyCode yatırmak istersiniz?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Miktar',
                  border: OutlineInputBorder(),
                ),
                onChanged: (String input) {
                  enteredAmount = input; // Kullanıcının girdiği miktarı sakla
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Para yatırma işlemini gerçekleştir
                  double amount = double.tryParse(enteredAmount) ?? 0.0;
                  // investToBorsa(currencyCode, amount);
                  Navigator.of(context).pop(); // Bottom sheet'i kapat
                },
                child: Text('Onayla'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getData(); // _getData fonksiyonunu initState içinde çağırıyoruz
  }

  double _parseDegisim(String degisim) {
    return double.parse(degisim.replaceAll(',', '.').trim());
  }

  Future<void> _loadWalletAmount() async {
    var box = await Hive.openBox<Wallet>(WalletService.walletBoxName);
    Wallet? wallet = box.get('wallet');
    if (wallet != null) {
      setState(() {
        _walletAmount = wallet.amount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    double myWidht = MediaQuery.of(context).size.width;

    _data.sort((a, b) => a['name'].compareTo(b['name']));

    // En çok değişen ilk dört altını seçme
    List<dynamic> mostChanged = _data
        .map((item) => {
              'name': item['name'],
              'degisim': _parseDegisim(item['change']),
              'Degisim': item['change'],
              'Fiyat': item['price']
            })
        .toList();

    mostChanged.sort((a, b) => b['degisim'].compareTo(a['degisim']));

    mostChanged = mostChanged.take(10).toList();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white, // Change this to your desired color
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'BORSA',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                showSearch(
                  context: context,
                  delegate: mySearch(data: _data),
                );
              });
            },
            icon: const Icon(Icons.search),
            color: Colors.white,
          ),
        ],
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
            MostChangedBorsa(
                mostChanged: mostChanged, myWidth: myWidht, myHeight: myHeight),
            Expanded(
              child: Container(
                width: myWidht,
                height: myHeight * 0.7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: _data.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        itemCount: _data.length,
                        itemBuilder: (context, index) {
                          var item = _data[index];
                          var degisim = _parseDegisim(item['change']);
                          return GestureDetector(
                            onTap: () {
                              showInvestDialog(context, item, item['price']);
                            },
                            child: Card(
                              margin: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 2),
                              color: Color.fromARGB(255, 23, 23, 23),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),

                                    RoundedBackgroundText(
                                      'Değişim: ${item['change']}',
                                      style: TextStyle(
                                          fontSize: 15,
                                          backgroundColor: degisim < 0
                                              ? Colors.red
                                              : Colors.green,
                                          color: Colors.white),
                                      innerRadius: 15.0,
                                      outerRadius: 10.0,
                                    ),
                                    // Add spacing between title and subtitle
                                    Text(
                                      'Fiyat: ${item['price']}',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.white),
                                    ),
                                  ],
                                ),
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
    );
  }
}

class mySearch extends SearchDelegate {
  final List<dynamic> data;

  mySearch({required this.data});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<dynamic> results = data
        .where(
            (item) => item['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        var item = results[index];
        var degisim = double.parse(item['change'].replaceAll(',', '.').trim());
        return Card(
          margin: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          color: Color.fromARGB(255, 23, 23, 23),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['name'],
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                RoundedBackgroundText(
                  'Değişim: ${item['change']}',
                  style: TextStyle(
                      fontSize: 15,
                      backgroundColor: degisim < 0 ? Colors.red : Colors.green,
                      color: Colors.white),
                  innerRadius: 15.0,
                  outerRadius: 10.0,
                ),
                Text(
                  'Fiyat: ${item['price']}',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<dynamic> suggestions = data
        .where(
            (item) => item['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        var item = suggestions[index];
        var degisim = double.parse(item['change'].replaceAll(',', '.').trim());
        return ListTile(
          title: Text(
            item['name'],
            style: TextStyle(color: Colors.black),
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Değişim: ${item['change']} ',
                style:
                    TextStyle(color: degisim < 0 ? Colors.red : Colors.green),
              ),
              Text(
                "Fiyat: ${item['price']}",
                style: TextStyle(color: Colors.black),
              )
            ],
          ),
          onTap: () {
            query = item['name'];
            showResults(context);
          },
        );
      },
    );
  }
}
