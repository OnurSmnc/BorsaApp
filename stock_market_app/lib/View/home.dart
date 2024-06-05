import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rounded_background_text/rounded_background_text.dart';
import 'package:stock_market_app/View/Wallet.dart';
import 'package:stock_market_app/View/addMonetWallet.dart';
import 'package:stock_market_app/View/myInvestments.dart';
import 'package:stock_market_app/View/widgets/appBar/appBar.dart';
import 'package:stock_market_app/View/widgets/mostChangedCard/mostChangedBorsa.dart';
import 'package:hive/hive.dart';
import 'package:stock_market_app/model/investment.dart';
import 'package:stock_market_app/model/wallet.dart';
import 'package:stock_market_app/services/investment_service.dart';
import 'package:stock_market_app/services/wallet_service.dart';
import 'package:stock_market_app/View/widgets/investmentsAdd/addInvestment.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

  double getDegisimYuzde(String name) {
    var item = _data.firstWhere((element) => element['name'] == name);
    if (item != null) {
      return _parseDegisim(item['change']);
    } else {
      throw Exception('Investment Not Found');
    }
  }

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    double myWidht = MediaQuery.of(context).size.width;
    bool isDrawerOpen = false;

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
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: MyAppBar(scaffoldKey: _scaffoldKey, page: 'Borsa', data: _data),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 23, 23, 23),
              ),
              child: Center(
                child: Text(
                  'Borsa Cebinde',
                  style: TextStyle(
                      fontSize: 35,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.wallet),
                  SizedBox(
                    width: 5,
                  ),
                  const Text('Cüzdanım')
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WalletPage(),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.money),
                  SizedBox(
                    width: 5,
                  ),
                  const Text('Yatırımlarım')
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyInvestmentsPage(),
                  ),
                );
              },
            ),
            Divider(),
            Container(
              margin: EdgeInsets.all(20),
            ),
            Image.asset('assets/icons/pngwing.com.png'),
          ],
        ),
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
                          return InkWell(
                            onTap: () async {
                              List<Investment> invs =
                                  await InvestmentService().getInvestments();
                              bool investmentExists = invs.any(
                                  (inv) => inv.currencyCode == item['name']);

                              if (!investmentExists) {
                                showInvestDialog(
                                    context,
                                    item['name'],
                                    double.parse(item['price']
                                        .replaceAll(',', '.')
                                        .trim()));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Center(
                                      child: Text(
                                        'Bu firmaya yatırımınız mevcut!',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
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
                        }),
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
  String? get searchFieldLabel => 'Ara...';
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(
          Icons.clear,
          color: Colors.black,
        ),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
        color: Colors.black,
      ),
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
        return InkWell(
          onTap: () async {
            List<Investment> invs = await InvestmentService().getInvestments();
            bool investmentExists =
                invs.any((inv) => inv.currencyCode == item['name']);

            if (!investmentExists) {
              showInvestDialog(context, item['name'],
                  double.parse(item['price'].replaceAll(',', '.').trim()));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Center(
                    child: Text(
                      'Bu firmaya yatırımınız mevcut!',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            color: Color.fromARGB(255, 23, 23, 23),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(
                item['name'],
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Değişim: ${item['change']} ',
                    style: TextStyle(
                        backgroundColor:
                            degisim < 0 ? Colors.red : Colors.green,
                        color: Colors.white),
                  ),
                  Text(
                    "Fiyat: ${item['price']}",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
