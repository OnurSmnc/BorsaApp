import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:stock_market_app/model/investment.dart';
import 'package:stock_market_app/services/investment_service.dart';
import 'package:stock_market_app/View/home.dart';

class MyInvestmentsPage extends StatefulWidget {
  @override
  _MyInvestmentsPageState createState() => _MyInvestmentsPageState();
}

class _MyInvestmentsPageState extends State<MyInvestmentsPage> {
  late List<Investment> _investments = [];
  bool isClickedAll = false;

  @override
  void initState() {
    super.initState();
    _loadInvestments();
  }

  Future<void> _loadInvestments() async {
    List<Investment> investments = await InvestmentService().getInvestments();
    setState(() {
      _investments = investments;
    });
  }

  Future<void> yatirimCek(BuildContext context, Investment investment) async {
    bool success =
        await InvestmentService().withdrawInvestment(investment.currencyCode);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Para çekme işlemi ve cüzdana ekleme başarılı! ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Para çekme işlemi başarısız!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
    _loadInvestments();
  }

  Future<void> filterInvestmentsByCategory(int category) async {
    List<Investment> investments = await InvestmentService().getInvestments();
    List<Investment> filteredInvestments = investments
        .where((investment) => investment.investmentStock == category)
        .toList();
    setState(() {
      _investments.clear(); // Mevcut yatırımları temizle
      _investments.addAll(filteredInvestments); // Filtrelenmiş yatırımları ekle
    });
  }

  @override
  Widget build(BuildContext context) {
    double myHight = MediaQuery.of(context).size.height;
    double myWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'YATIRIMLAR',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Container(
        height: myHight,
        width: myWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey, Colors.white],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: myWidth,
              height: myHight *
                  0.1, // En çok değişen ilk dört altın için ayrılan alan
              margin: EdgeInsets.symmetric(vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isClickedAll == true)
                    InkWell(
                      onTap: () {
                        _loadInvestments();
                        setState(() {
                          isClickedAll = false;
                        });
                      },
                      child: Container(
                        height: myHight * 0.05,
                        width: myWidth * 0.5,
                        padding: EdgeInsets.all(1),
                        child: Card(
                          color: Color.fromARGB(255, 23, 23, 23),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.money,
                                color: Colors.white,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Tüm Yatırımlar',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => {
                          filterInvestmentsByCategory(1),
                          setState(
                            () {
                              isClickedAll = true;
                            },
                          ),
                        },
                        child: Container(
                          height: myHight * 0.05,
                          width: myWidth * 0.5,
                          padding: EdgeInsets.all(1),
                          child: Card(
                            color: Color.fromARGB(255, 23, 23, 23),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.attach_money,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Borsa',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => {
                          filterInvestmentsByCategory(2),
                          setState(
                            () {
                              isClickedAll = true;
                            },
                          ),
                        },
                        child: Container(
                          height: myHight * 0.05,
                          width: myWidth * 0.5,
                          padding: EdgeInsets.all(1),
                          child: Card(
                            color: Color.fromARGB(255, 23, 23, 23),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/icons/gold.png',
                                  color: Colors.white,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Altın',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: myWidth,
                height: myHight * 0.7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: _investments.isNotEmpty
                    ? ListView.builder(
                        itemCount: _investments.length,
                        itemBuilder: (context, index) {
                          final investment = _investments[index];
                          return Slidable(
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) =>
                                      yatirimCek(context, investment),
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  icon: Icons.attach_money,
                                  label: 'Para Çek',
                                ),
                              ],
                            ),
                            child: Card(
                              color: Colors.black,
                              margin: EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 2,
                              ),
                              child: ListTile(
                                title: Text(
                                  investment.currencyCode,
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  'Para: ${investment.amount} ₺',
                                  style: TextStyle(color: Colors.white),
                                ),
                                trailing: Text(
                                  'Date: ${investment.timestamp}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          'Yatırım Yok',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 40,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final int investmentStock;
  final VoidCallback onTap;

  CategoryCard(
      {required this.title,
      required this.investmentStock,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      ),
    );
  }
}
