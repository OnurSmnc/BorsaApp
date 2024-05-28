import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rounded_background_text/rounded_background_text.dart';
import 'package:stock_market_app/View/widgets/mostChanged.dart';

class GoldPage extends StatefulWidget {
  const GoldPage({super.key});

  @override
  State<GoldPage> createState() => _GoldPageState();
}

class _GoldPageState extends State<GoldPage> {
  late List<dynamic> _data = [];

  Future<void> _getData() async {
    final response =
        await http.get(Uri.parse('https://doviz-api.onrender.com/api/altin'));
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success'] == true && responseData['data'] is Map) {
        setState(() {
          _data = (responseData['data'] as Map<String, dynamic>)
              .entries
              .map((entry) {
            return {
              'name': entry.key,
              ...entry.value,
            };
          }).toList();
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

  double _parseDegisim(String degisim) {
    return double.parse(
        degisim.replaceAll('%', '').replaceAll(',', '.').trim());
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
              'degisim': _parseDegisim(item['Degisim']),
              'Degisim': item['Degisim'],
              'Alis': item['Alis'],
              'Satis': item['Satis']
            })
        .toList();

    mostChanged.sort((a, b) => b['degisim'].compareTo(a['degisim']));

    mostChanged = mostChanged.take(4).toList();

    return Scaffold(
      appBar: AppBar(
          title: Text(
            'ALTIN',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
          ]),
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
            MostChanged(
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
                        padding: EdgeInsets.symmetric(vertical: 10),
                        itemCount: _data.length,
                        itemBuilder: (context, index) {
                          var item = _data[index];
                          var degisim = _parseDegisim(item['Degisim']);
                          return Card(
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
                                  Column(
                                    children: [
                                      Text(
                                        item['name'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      SizedBox(width: 8),
                                      RoundedBackgroundText(
                                        'Değişim: ${item['Degisim']}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            backgroundColor: degisim < 0
                                                ? Colors.red
                                                : Colors.green,
                                            color: Colors.white),
                                        innerRadius: 15.0,
                                        outerRadius: 10.0,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
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
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            )
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
        var degisim = double.parse(
            item['Degisim'].replaceAll('%', '').replaceAll(',', '.').trim());
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
                Column(
                  children: [
                    Text(
                      item['name'],
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(width: 8),
                    RoundedBackgroundText(
                      'Değişim: ${item['Degisim']}',
                      style: TextStyle(
                          fontSize: 15,
                          backgroundColor:
                              degisim < 0 ? Colors.red : Colors.green,
                          color: Colors.white),
                      innerRadius: 15.0,
                      outerRadius: 10.0,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Alış: ${item['Alis']}',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                    Text(
                      'Satış: ${item['Satis']}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
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
        var degisim = double.parse(
            item['Degisim'].replaceAll('%', '').replaceAll(',', '.').trim());
        return ListTile(
          title: Text(
            item['name'],
            style: TextStyle(color: Colors.black),
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Değişim: ${item['Degisim']} ',
                style:
                    TextStyle(color: degisim < 0 ? Colors.red : Colors.green),
              ),
              Text(
                'Alış: ${item['Alis']}',
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
              Text(
                'Satış: ${item['Satis']}',
                style: TextStyle(color: Colors.black),
              ),
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
