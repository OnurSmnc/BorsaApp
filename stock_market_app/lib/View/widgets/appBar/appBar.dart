import 'package:flutter/material.dart';
import 'package:stock_market_app/View/borsaIstanbul.dart';
import 'package:stock_market_app/View/gold.dart';
import 'package:stock_market_app/View/home.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String page;
  final List<dynamic> data;

  const MyAppBar(
      {Key? key,
      required this.scaffoldKey,
      required this.page,
      required this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String appBarTitle = '';
    if (page == 'Borsa') {
      appBarTitle = 'BORSA';
    } else if (page == 'Borsaİstanbul') {
      appBarTitle = 'BORSA İSTANBUL';
    } else if (page == 'Altın') {
      appBarTitle = 'ALTIN';
    }
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        color: Colors.white,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        appBarTitle,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      backgroundColor: Colors.black,
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            if (page == 'Borsa') {
              showSearch(
                context: context,
                delegate: mySearch(data: data),
              );
            } else if (page == 'Borsaİstanbul') {
              showSearch(
                context: context,
                delegate: mySearchIst(data: data),
              );
            } else if (page == 'Altın') {
              showSearch(
                context: context,
                delegate: mySearchGold(data: data),
              );
            }
          },
          icon: const Icon(Icons.search),
          color: Colors.white,
        ),
        IconButton(
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
          icon: Icon(Icons.menu),
          color: Colors.white,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
