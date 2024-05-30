import 'package:flutter/material.dart';
import 'package:stock_market_app/View/Wallet.dart';
import 'package:stock_market_app/View/borsaIstanbul.dart';
import 'package:stock_market_app/View/currencyExchange.dart';
import 'package:stock_market_app/View/gold.dart';
import 'package:stock_market_app/View/home.dart';
import 'package:stock_market_app/View/myInvestments.dart';
import 'package:stock_market_app/model/wallet.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _currentIndex = 0;

  List<Widget> pages = [
    Home(),
    BorsaIstanbul(),
    GoldPage(),
    CurrencyExchange(),
  ];

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    double myWidht = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: pages.elementAt(_currentIndex),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
          currentIndex: _currentIndex,
          showSelectedLabels: false,
          showUnselectedLabels: true,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: ((value) {
            setState(() {
              _currentIndex = value;
            });
          }),
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/pngwing.com.png',
                height: myHeight * 0.03,
                color: Colors.white,
              ),
              label: 'Borsa',
            ),
            BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/icons/borsa_istanbul_logo_dikey.png',
                  height: myHeight * 0.03,
                  color: Colors.white,
                ),
                label: 'Borsa Istanbul'),
            BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/icons/gold.png',
                  height: myHeight * 0.03,
                  color: Colors.white,
                ),
                label: 'Altın'),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.currency_exchange_outlined,
                  color: Colors.white,
                ),
                label: 'Döviz'),
          ],
        ),
      ),
    );
  }
}
